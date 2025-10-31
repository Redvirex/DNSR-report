# Security Guide for DNSR Admin Dashboard

## 🔒 Security Best Practices

### Understanding Frontend Security Limitations

**Important**: Flutter web apps (and all JavaScript-based frontend applications) **cannot completely hide API keys** because:
- All code is compiled to JavaScript that runs in the browser
- Users can inspect network requests, view source code, and decompile JavaScript
- Any keys embedded in the frontend are effectively public

### The Right Approach

Instead of trying to hide keys (which is impossible), we follow these security principles:

## 1. Use Public Keys Only

### ✅ Safe Keys for Frontend

**Supabase Anon Key**
- Designed to be public
- Can be safely embedded in frontend code
- Protected by Row-Level Security (RLS)
- Cannot access data without proper RLS policies

**Google Maps API Key**
- Restrict to specific domains in Google Cloud Console
- Set HTTP referrer restrictions
- Enable only required APIs
- Monitor usage for anomalies

### ❌ NEVER Use in Frontend

**Supabase Service Role Key**
- Bypasses all RLS policies
- Has full database access
- Must ONLY be used in backend/edge functions

**Firebase Admin SDK Keys**
- Full project access
- Must stay server-side only

## 2. Implement Row-Level Security (RLS)

### Supabase RLS Policies

Ensure these policies are enabled in your Supabase dashboard:

#### Users Table (`utilisateurs`)
```sql
-- Admins can read all users
CREATE POLICY "Admins can view all users"
ON utilisateurs FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM utilisateurs
    WHERE id = auth.uid()
    AND role = 'ADMIN'
  )
);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON utilisateurs FOR UPDATE
TO authenticated
USING (auth.uid() = id);
```

#### Incidents Table (`incident`)
```sql
-- Everyone can read incidents
CREATE POLICY "Anyone can view incidents"
ON incident FOR SELECT
TO authenticated
USING (true);

-- Admins can update incidents
CREATE POLICY "Admins can update incidents"
ON incident FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM utilisateurs
    WHERE id = auth.uid()
    AND role = 'ADMIN'
  )
);

-- Admins can delete incidents
CREATE POLICY "Admins can delete incidents"
ON incident FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM utilisateurs
    WHERE id = auth.uid()
    AND role = 'ADMIN'
  )
);
```

#### Storage Bucket Policies
```sql
-- Admins can delete incident images
CREATE POLICY "Admins can delete incident images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'incident-images' AND
  EXISTS (
    SELECT 1 FROM utilisateurs
    WHERE id = auth.uid()
    AND role = 'ADMIN'
  )
);
```

## 3. API Key Restrictions

### Google Maps API Key
In Google Cloud Console:

1. **Application restrictions**
   - HTTP referrers (web sites)
   - Add your domains:
     - `https://your-domain.netlify.app/*`
     - `https://your-custom-domain.com/*`
     - `http://localhost:*` (for development)

2. **API restrictions**
   - Restrict key to only required APIs:
     - Maps JavaScript API
     - Geocoding API (if used)

### Firebase Cloud Messaging
In Firebase Console:

1. Set allowed domains
2. Use VAPID key (public key) only
3. Keep Server Key secret

## 4. Secure Build Process

### Production Build Steps

1. **Create `.env.production`** (never commit this!)
   ```bash
   cp .env.production.example .env.production
   # Edit with your production keys
   ```

2. **Run secure build script**
   ```bash
   ./secure_build.sh
   ```

3. **Deploy to Netlify**
   - Drag and drop `build/web` folder to Netlify Drop
   - Or use Netlify CLI
   - Or connect to GitHub with environment variables

### Alternative: Netlify Environment Variables

Instead of `.env.production`, you can use Netlify's environment variables:

1. Go to Site Settings → Build & deploy → Environment
2. Add variables:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GOOGLE_MAPS_API_KEY`
3. Update build command in `netlify.toml`

## 5. Network Security

### HTTPS Only
- Always use HTTPS in production
- Netlify provides free SSL certificates
- Never deploy to HTTP-only sites

### Content Security Policy (CSP)
Add to `web/index.html`:
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' 'unsafe-eval' https://maps.googleapis.com; 
               style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
               img-src 'self' data: https://*.supabase.co https://maps.gstatic.com;
               font-src 'self' https://fonts.gstatic.com;
               connect-src 'self' https://*.supabase.co wss://*.supabase.co https://maps.googleapis.com;">
```

## 6. Monitoring & Alerts

### Supabase Monitoring
- Monitor API usage in Supabase dashboard
- Set up alerts for unusual activity
- Review auth logs regularly

### Google Maps Monitoring
- Check quota usage in Google Cloud Console
- Set up billing alerts
- Review API usage patterns

## 7. Security Headers

The secure build script automatically adds these headers:

```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: no-referrer
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

## 8. Audit Checklist

### Before Production Deployment

- [ ] RLS enabled on all Supabase tables
- [ ] RLS policies tested and working
- [ ] Google Maps API key restricted to production domain
- [ ] Firebase project has domain restrictions
- [ ] No Service Role keys in frontend code
- [ ] `.env.production` not in git
- [ ] `.env.production` added to `.gitignore`
- [ ] HTTPS enabled on deployment platform
- [ ] Security headers configured
- [ ] Content Security Policy set
- [ ] Monitoring and alerts configured

### Regular Security Reviews

- [ ] Review Supabase auth logs monthly
- [ ] Check API usage patterns
- [ ] Rotate API keys if compromised
- [ ] Update dependencies regularly
- [ ] Review RLS policies for changes
- [ ] Test security policies with non-admin users

## 9. Incident Response

### If API Key is Compromised

1. **Immediately revoke the key**
2. **Generate new key**
3. **Update production environment**
4. **Redeploy application**
5. **Review logs for unauthorized usage**
6. **Update billing alerts if needed**

### If Unauthorized Access Detected

1. **Check Supabase auth logs**
2. **Review RLS policies**
3. **Verify admin user accounts**
4. **Force password resets if needed**
5. **Enable MFA for admin accounts**

## 10. Additional Recommendations

### Multi-Factor Authentication (MFA)
- Enable MFA for all admin accounts
- Use Supabase Auth MFA features

### Rate Limiting
- Implement rate limiting in Supabase edge functions
- Use Netlify's rate limiting features

### IP Whitelisting (Optional)
- For extra security, whitelist admin IP addresses
- Implement in Supabase RLS or edge functions

### Audit Logging
- Log all admin actions
- Store in separate audit table
- Monitor for suspicious activity

## Resources

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [Google Maps API Security](https://developers.google.com/maps/api-security-best-practices)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [OWASP Web Security](https://owasp.org/www-project-web-security-testing-guide/)

---

**Remember**: Security is a process, not a one-time setup. Regularly review and update your security measures!
