// Import standard libraries from Deno
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// CORS headers for preflight requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface NotificationRequest {
  title: string;
  body: string;
  tokens: string[]; // Array of FCM tokens
  data?: Record<string, string>; // Optional data payload
}

interface UserProfile {
  id: string;
  email: string;
  role: 'ADMIN' | 'CITOYEN';
  status: 'ACTIVE' | 'DEACTIVATED';
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify JWT token and get user
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    );

    // Get user from JWT token
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    
    if (userError || !user) {
      console.error('Auth error:', userError);
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Get user profile to check role and status
    const { data: userProfile, error: profileError } = await supabaseClient
      .from('utilisateurs')
      .select('id, email, role, status')
      .eq('id', user.id)
      .single();

    if (profileError || !userProfile) {
      console.error('Profile error:', profileError);
      return new Response(
        JSON.stringify({ error: 'User profile not found' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Verify user is admin and active
    if (userProfile.role !== 'ADMIN') {
      return new Response(
        JSON.stringify({ error: 'Insufficient privileges. Admin role required.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (userProfile.status !== 'ACTIVE') {
      return new Response(
        JSON.stringify({ error: 'Account is deactivated' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Parse notification request
    const notificationData: NotificationRequest = await req.json();
    
    // Validate request data
    if (!notificationData.title || !notificationData.body) {
      return new Response(
        JSON.stringify({ error: 'Title and body are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (!notificationData.tokens || notificationData.tokens.length === 0) {
      return new Response(
        JSON.stringify({ error: 'At least one FCM token is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Get the Google service account JSON from environment
    const serviceAccountJson = Deno.env.get("GOOGLE_SERVICE_ACCOUNT");
    if (!serviceAccountJson) {
      return new Response(
        JSON.stringify({ error: 'Google service account not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const serviceAccount = JSON.parse(serviceAccountJson);

    // Generate OAuth2 access token using JWT
    const accessToken = await generateAccessToken(serviceAccount);

    // Send notifications to all tokens
    const results = await sendNotificationsToTokens(
      serviceAccount.project_id,
      accessToken,
      notificationData
    );

    // Count successful and failed sends
    const successful = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;

    console.log(`Notification sent by admin ${userProfile.email}: ${successful} successful, ${failed} failed`);

    return new Response(
      JSON.stringify({
        message: 'Notifications processed',
        total: notificationData.tokens.length,
        successful,
        failed,
        results: results
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ error: `Server error: ${error.message}` }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

/**
 * Generate OAuth2 access token using Google service account
 */
async function generateAccessToken(serviceAccount: any): Promise<string> {
  // Create JWT header
  const jwtHeader = { alg: "RS256", typ: "JWT" };
  
  // Create JWT claim set
  const now = Math.floor(Date.now() / 1000);
  const jwtClaimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600, // Token expires in 1 hour
    iat: now,
  };

  // Helper function to encode base64url
  const base64UrlEncode = (obj: unknown): string =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

  // Create unsigned JWT
  const unsignedJwt = `${base64UrlEncode(jwtHeader)}.${base64UrlEncode(jwtClaimSet)}`;

  // Import private key for signing
  const privateKeyPem = serviceAccount.private_key
    .replace(/-----[^-]+-----/g, "")
    .replace(/\n/g, "");
  
  const privateKeyBuffer = Uint8Array.from(atob(privateKeyPem), c => c.charCodeAt(0));
  
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    privateKeyBuffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  // Sign the JWT
  const encoder = new TextEncoder();
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    encoder.encode(unsignedJwt)
  );

  // Create signed JWT
  const signedJwt = `${unsignedJwt}.${btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "")}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signedJwt}`,
  });

  if (!tokenResponse.ok) {
    throw new Error(`Failed to get access token: ${tokenResponse.statusText}`);
  }

  const { access_token } = await tokenResponse.json();
  return access_token;
}

/**
 * Send FCM notifications to multiple tokens
 */
async function sendNotificationsToTokens(
  projectId: string,
  accessToken: string,
  notificationData: NotificationRequest
): Promise<Array<{ token: string; success: boolean; error?: string }>> {
  
  const results = [];
  
  // Send notifications with batch processing (max 10 concurrent)
  const batchSize = 10;
  for (let i = 0; i < notificationData.tokens.length; i += batchSize) {
    const batch = notificationData.tokens.slice(i, i + batchSize);
    
    const batchPromises = batch.map(async (token) => {
      try {
        const payload = {
          message: {
            token: token,
            notification: {
              title: notificationData.title,
              body: notificationData.body,
            },
            data: notificationData.data || {},
          },
        };

        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(payload),
          }
        );

        if (response.ok) {
          return { token, success: true };
        } else {
          const errorData = await response.json();
          return { 
            token, 
            success: false, 
            error: errorData.error?.message || `HTTP ${response.status}` 
          };
        }
      } catch (error) {
        return { 
          token, 
          success: false, 
          error: error.message 
        };
      }
    });

    const batchResults = await Promise.all(batchPromises);
    results.push(...batchResults);
    
    // Add small delay between batches to avoid rate limiting
    if (i + batchSize < notificationData.tokens.length) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
  }
  
  return results;
}
