# 🚀 Quick Setup Guide

Get your landing page live in 5 minutes!

## ✅ Step 1: Add Images

1. Navigate to `images/` directory
2. Add these required images:
   - `phone-mockup.png` (600x1200px)
   - `screen-1.png` (400x800px)
   - `screen-2.png` (400x800px)
   - `screen-3.png` (400x800px)
   - `screen-4.png` (400x800px)
   - `download-illustration.png` (500x500px)

### Quick Image Creation:
- Use **Figma** or **Canva** for mockups
- Take screenshots from your Flutter app
- Use **Mockuphone.com** for phone frames
- Compress with **TinyPNG.com**

## ✅ Step 2: Update Download Links

Open `index.html` and find these lines (around line 80 and 350):

```html
<!-- Replace # with your actual store links -->

<!-- Google Play -->
<a href="https://play.google.com/store/apps/details?id=com.yourapp.id" class="btn-download google-play">

<!-- App Store -->
<a href="https://apps.apple.com/app/id1234567890" class="btn-download app-store">
```

## ✅ Step 3: Customize Content

### Update Statistics (line ~95):
```html
<div class="stat-item">
    <h3>+1000</h3>  <!-- Change this -->
    <p>مستخدم نشط</p>
</div>
```

### Update Contact Info (line ~550):
```html
<p><i class="bi bi-envelope"></i> info@factormyth.com</p>
<!-- Change email -->
```

### Update Social Links (line ~540):
```html
<a href="https://facebook.com/yourpage" class="social-link">
<a href="https://twitter.com/yourhandle" class="social-link">
<a href="https://instagram.com/yourhandle" class="social-link">
```

## ✅ Step 4: Test Locally

### Option 1: Direct Open
- Double-click `index.html`
- Opens in default browser

### Option 2: Live Server (Recommended)
```bash
# Using Python
python -m http.server 8000

# Using Node.js
npx http-server

# Using PHP
php -S localhost:8000
```

Then open: `http://localhost:8000`

## ✅ Step 5: Deploy

### Option A: Netlify (Easiest)
1. Go to [netlify.com](https://netlify.com)
2. Drag & drop `landing/` folder
3. Done! Get free HTTPS URL

### Option B: GitHub Pages
```bash
# Create repo
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin YOUR_REPO_URL
git push -u origin main

# Enable GitHub Pages in repo settings
```

### Option C: Your Web Server
```bash
# Via FTP/SFTP
# Upload entire landing/ folder to:
# public_html/landing/

# Access at:
# https://yourdomain.com/landing/
```

## ✅ Step 6: Add Analytics (Optional)

### Google Analytics
1. Create GA4 property at [analytics.google.com](https://analytics.google.com)
2. Get Measurement ID (G-XXXXXXXXXX)
3. Add to `index.html` before `</head>`:

```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

## ✅ Step 7: Optimize (Optional)

### Compress Images
```bash
# Using ImageOptim (Mac)
# Or TinyPNG.com (Web)
# Target: < 200KB per image
```

### Minify CSS/JS
```bash
# Install tools
npm install -g cssnano terser

# Minify
cssnano css/style.css css/style.min.css
terser js/script.js -o js/script.min.js

# Update HTML to use .min files
```

### Enable Caching
- Upload `.htaccess` file (already included)
- Works on Apache servers
- Improves load time

## 🎯 Checklist

Before going live:

- [ ] All images added and optimized
- [ ] Download links updated
- [ ] Contact info updated
- [ ] Social links updated
- [ ] Statistics updated
- [ ] Tested on mobile
- [ ] Tested on desktop
- [ ] Analytics added
- [ ] SEO meta tags checked
- [ ] Performance tested (PageSpeed)

## 🐛 Common Issues

### Images Not Showing
**Problem:** Broken image icons
**Solution:** 
- Check file names match exactly
- Verify files are in `images/` folder
- Check file extensions (.png not .PNG)

### Download Buttons Not Working
**Problem:** Nothing happens on click
**Solution:**
- Update href="#" to actual store links
- Remove `e.preventDefault()` in script.js (line 120)

### Mobile Menu Not Closing
**Problem:** Menu stays open after click
**Solution:**
- Ensure Bootstrap JS is loaded
- Check browser console for errors
- Clear browser cache

### Slow Loading
**Problem:** Page takes too long to load
**Solution:**
- Compress images (< 200KB each)
- Use WebP format
- Enable caching (.htaccess)
- Use CDN for Bootstrap

## 📞 Need Help?

1. Check `README.md` for detailed docs
2. Review code comments in files
3. Test in different browsers
4. Check browser console for errors

## 🎉 You're Done!

Your landing page is ready to convert visitors into users!

### Next Steps:
1. Share the link on social media
2. Add to app store listings
3. Use in marketing campaigns
4. Monitor analytics
5. A/B test different versions

---

**Questions?** Check the main README.md or contact the dev team.

**Good luck! 🚀**
