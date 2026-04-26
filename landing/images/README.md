# Images Directory

## Required Images for Landing Page

Place the following images in this directory:

### 1. Phone Mockup
- **File:** `phone-mockup.png`
- **Description:** Main hero section phone mockup showing the app
- **Recommended Size:** 600x1200px
- **Format:** PNG with transparency
- **Note:** Should show the daily question screen

### 2. App Screenshots
- **File:** `screen-1.png` - Daily Question Screen
- **File:** `screen-2.png` - Leaderboard Screen
- **File:** `screen-3.png` - Profile Screen
- **File:** `screen-4.png` - Free Questions Screen
- **Recommended Size:** 400x800px each
- **Format:** PNG
- **Note:** Use actual app screenshots

### 3. Download Illustration
- **File:** `download-illustration.png`
- **Description:** Illustration for download section
- **Recommended Size:** 500x500px
- **Format:** PNG with transparency
- **Note:** Can be a phone with download icon or similar

## Image Optimization Tips

1. **Compress Images:**
   - Use tools like TinyPNG or ImageOptim
   - Target: < 200KB per image

2. **Use WebP Format:**
   - Better compression than PNG/JPG
   - Fallback to PNG for older browsers

3. **Responsive Images:**
   - Provide multiple sizes for different screens
   - Use `srcset` attribute

4. **Lazy Loading:**
   - Images load as user scrolls
   - Improves initial page load time

## Creating Mockups

### Tools:
- **Figma** - Free design tool
- **Canva** - Easy mockup creator
- **Mockuphone** - Online mockup generator
- **Smartmockups** - Professional mockups

### Steps:
1. Take screenshots from your Flutter app
2. Upload to mockup generator
3. Choose phone frame (iPhone/Android)
4. Download high-quality PNG
5. Optimize and place in this directory

## Placeholder Images

If you don't have images yet, you can use:
- **Placeholder.com** - `https://via.placeholder.com/600x1200`
- **Unsplash** - Free stock photos
- **Pexels** - Free stock photos

## Example HTML Usage

```html
<!-- Regular Image -->
<img src="images/phone-mockup.png" alt="App Preview" class="img-fluid">

<!-- Lazy Loading -->
<img data-src="images/screen-1.png" alt="Daily Question" class="img-fluid lazy">

<!-- Responsive Image -->
<img 
    src="images/phone-mockup.png" 
    srcset="images/phone-mockup-small.png 400w,
            images/phone-mockup.png 800w"
    sizes="(max-width: 600px) 400px, 800px"
    alt="App Preview">
```

## Current Status

- [ ] phone-mockup.png
- [ ] screen-1.png (Daily Question)
- [ ] screen-2.png (Leaderboard)
- [ ] screen-3.png (Profile)
- [ ] screen-4.png (Free Questions)
- [ ] download-illustration.png

## Notes

- Logo is already available at `../assets/icons/logo.png`
- Update image paths in `index.html` after adding images
- Test all images on mobile and desktop
- Ensure images look good on retina displays

---

**Need Help?**
Contact the design team or use online mockup generators to create professional-looking images quickly.
