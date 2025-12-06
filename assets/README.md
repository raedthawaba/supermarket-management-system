# Assets Directory

This directory contains all the assets for the Supermarket System application.

## Structure

```
assets/
├── images/           # Application images (logos, backgrounds, etc.)
├── icons/            # Application icons
├── fonts/            # Custom fonts (Cairo, Inter)
└── logos/            # Store logos and branding
```

## Required Assets

### Images
- splash_logo.png (512x512)
- app_icon.png (512x512)
- background_image.jpg
- product_placeholder.png
- no_image.png

### Icons
- cart_icon.png
- product_icon.png
- user_icon.png
- settings_icon.png
- report_icon.png

### Fonts
- Cairo-Regular.ttf
- Cairo-Bold.ttf
- Cairo-SemiBold.ttf
- Inter-Regular.ttf
- Inter-Bold.ttf

### Logos
- store_logo.png
- company_logo.png

## Usage in App

```dart
// In pubspec.yaml
assets:
  - assets/images/
  - assets/icons/
  - assets/logos/
  - assets/fonts/

// In code
Image.asset('assets/images/logo.png')
Icon(Icons.shopping_cart) // Built-in icon
Text('Text', style: TextStyle(fontFamily: 'Cairo'))
```

## Notes

- All images should be optimized for mobile (use WebP format when possible)
- Icons should be in PNG format with transparent background
- Fonts should be in TTF format
- Use @2x and @3x versions for different screen densities
- Maximum file size should be under 500KB per file