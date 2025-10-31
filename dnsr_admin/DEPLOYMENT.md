# Deployment Guide - Netlify Drop

## Quick Deployment to Netlify

### Option 1: Secure Build (Recommended)

1. **Create production environment file**
   ```bash
   cp .env.production.example .env.production
   ```

2. **Edit `.env.production` with your keys**
   ```bash
   nano .env.production
   # or
   code .env.production
   ```
   
   Add your production credentials:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here
   GOOGLE_MAPS_API_KEY=your_google_maps_key_here
   ```

3. **Run secure build script**
   ```bash
   ./secure_build.sh
   ```

4. **Deploy to Netlify**
   - Go to https://app.netlify.com/drop
   - Drag and drop the `build/web` folder
   - Wait for deployment
   - Done! 🎉

### Option 2: Quick Build (Already Done)

Your app is already built! Just deploy it:

1. **Go to Netlify Drop**
   - Open https://app.netlify.com/drop

2. **Drag and Drop**
   - Drag the `build/web` folder to the drop zone
   - Wait for upload and deployment

3. **Configure Domain** (Optional)
   - Click "Domain settings"
   - Add custom domain or use provided subdomain

### Post-Deployment Configuration

#### 1. Restrict Google Maps API Key

In [Google Cloud Console](https://console.cloud.google.com/):
- Go to "APIs & Services" → "Credentials"
- Click your API key
- Under "Application restrictions":
  - Select "HTTP referrers (web sites)"
  - Add: `https://your-site.netlify.app/*`
  - Add: `https://your-custom-domain.com/*` (if applicable)

#### 2. Update Supabase Redirect URLs

In [Supabase Dashboard](https://app.supabase.com/):
- Go to Authentication → URL Configuration
- Add your Netlify URL to "Redirect URLs":
  - `https://your-site.netlify.app/**`

#### 3. Configure Firebase (if using FCM)

In [Firebase Console](https://console.firebase.google.com/):
- Go to Project Settings → Cloud Messaging
- Add your domain to authorized domains

### Netlify Configuration

The deployment includes:

✅ **Automatic routing** - `_redirects` file handles Flutter web routing  
✅ **Security headers** - `_headers` file adds security headers  
✅ **Caching** - Optimized cache control for assets  
✅ **HTTPS** - Free SSL certificate from Netlify  

### Verify Deployment

After deployment, test these features:

- [ ] Login page loads correctly
- [ ] Admin authentication works
- [ ] Map displays incidents
- [ ] Incident filtering works
- [ ] User management accessible
- [ ] No console errors
- [ ] API keys are working
- [ ] Real-time updates functioning

### Troubleshooting

#### Map not loading
- Check Google Maps API key restrictions
- Verify domain is whitelisted
- Check browser console for errors

#### Authentication failing
- Verify Supabase URL is correct
- Check Supabase redirect URLs include your domain
- Ensure user has ADMIN role

#### Real-time not working
- Check Supabase connection in browser network tab
- Verify WebSocket connection is established
- Check RLS policies allow real-time subscriptions

### Update Deployment

To update your deployment:

1. Make code changes
2. Run build script: `./secure_build.sh`
3. Go to Netlify site dashboard
4. Click "Deploys" → "Deploy site"
5. Drag new `build/web` folder

Or use Netlify CLI:
```bash
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

### Monitoring

#### Netlify Analytics
- View deployment logs in Netlify dashboard
- Monitor bandwidth and requests
- Set up notifications for failed deploys

#### Application Monitoring
- Check Supabase dashboard for API usage
- Monitor Google Maps API quota
- Review browser console logs in production

### Rollback

If deployment has issues:

1. Go to Netlify dashboard → Deploys
2. Find previous working deployment
3. Click "Publish deploy"
4. Previous version is restored immediately

### Cost Optimization

**Netlify Free Tier Includes:**
- 100 GB bandwidth/month
- Automatic HTTPS
- Continuous deployment
- Custom domain

**Upgrade if you need:**
- More bandwidth
- Password protection
- Analytics
- Form handling

---

## Alternative: GitHub Integration

For automatic deployments:

1. Push code to GitHub
2. Connect repository to Netlify
3. Set build command: `./secure_build.sh`
4. Set publish directory: `build/web`
5. Add environment variables in Netlify dashboard
6. Enable automatic deploys on push

---

## Security Reminder

⚠️ **Before deploying:**
- [ ] `.env.production` is NOT in git
- [ ] API keys are restricted to your domain
- [ ] RLS is enabled in Supabase
- [ ] Security headers are configured
- [ ] HTTPS is enabled

For detailed security guidelines, see [SECURITY.md](SECURITY.md).

---

**Need Help?**
- [Netlify Documentation](https://docs.netlify.com/)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Supabase Hosting Guide](https://supabase.com/docs/guides/hosting)
