# Theme Usage Guide

This guide explains how to properly use the app theme throughout the application to ensure consistency.

## Overview

The app uses a centralized theme system defined in `lib/theme/app_theme.dart`. All screens should use this theme instead of hardcoding colors.

## How to Use the Theme

### 1. **Using Predefined Color Constants**

Instead of hardcoding colors like `Color(0xFF5B7FFF)`, use the predefined constants from `AppTheme`:

```dart
import '../theme/app_theme.dart';

// ❌ Don't do this:
Container(
  color: Color(0xFF5B7FFF),
)

// ✅ Do this instead:
Container(
  color: AppTheme.primaryBlue,
)
```

### 2. **Available Color Constants**

#### Primary Colors
- `AppTheme.primaryBlue` - Main blue color
- `AppTheme.primaryPurple` - Main purple color
- `AppTheme.primaryPink` - Main pink color

#### Background & Surface Colors
- `AppTheme.backgroundLight` - App background (Light: #FAFBFF)
- `AppTheme.cardBackground` - Card background (White)
- `AppTheme.surfaceLight` - Light surface areas
- `AppTheme.surfaceLightest` - Lightest surface (purple tint)
- `AppTheme.overlayLight` - Light overlay (green tint)

#### Text Colors
- `AppTheme.textPrimary` - Primary text color (Dark gray)
- `AppTheme.textSecondary` - Secondary text color (Medium gray)
- `AppTheme.textLight` - Light text color (Light gray)
- `AppTheme.textWhiteOverlay` - White text on overlays

#### Semantic Colors
- `AppTheme.successGreen` - Success state (#48BB78)
- `AppTheme.successGreenDark` - Dark green (#38A169)
- `AppTheme.successGreenLight` - Light green (#166534)
- `AppTheme.errorRed` - Error state (#F56565)
- `AppTheme.warningYellow` - Warning state (#ECC94B)

#### Borders & Dividers
- `AppTheme.borderColor` - Border color for UI elements
- `AppTheme.dividerColor` - Divider color

#### Gradient Colors
- `AppTheme.purpleDark` - Dark purple (#6B21A8)
- `AppTheme.purpleLightBg` - Light purple background (#DDD6FE)

### 3. **Using Theme from Context**

For dynamic theming (light/dark mode support), use `Theme.of(context)`:

```dart
// ❌ Don't hardcode:
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16,
    color: Color(0xFF2D3748),
  ),
)

// ✅ Use Theme.of(context):
Text(
  'Hello',
  style: Theme.of(context).textTheme.bodyLarge,
)

// ✅ Or for colors:
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.onSurface,
  ),
)
```

### 4. **Available TextThemes**

Flutter provides standard text styles through `Theme.of(context).textTheme`:

- `displayLarge` - 32px, w600
- `displayMedium` - 28px, w600
- `displaySmall` - 24px, w600
- `headlineLarge` - 22px, w600
- `headlineMedium` - 20px, w600
- `headlineSmall` - 18px, w600
- `bodyLarge` - 16px, w400
- `bodyMedium` - 14px, w400 (secondary color)
- `bodySmall` - 12px, w400 (light color)
- `labelLarge` - 16px, w500

### 5. **Using ColorScheme for Theme-Aware Colors**

```dart
// Access colors from ColorScheme that work in both light and dark mode
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)
```

### 6. **Using Predefined Gradients**

```dart
import '../theme/app_theme.dart';

Container(
  decoration: BoxDecoration(
    gradient: AppTheme.blueGradient,
    borderRadius: BorderRadius.circular(16),
  ),
)
```

Available gradients:
- `AppTheme.blueGradient`
- `AppTheme.purpleGradient`
- `AppTheme.pinkGradient`
- `AppTheme.bluePurpleGradient`

### 7. **Scaffold Background**

Always let the theme handle scaffold background:

```dart
// The theme automatically sets the background to AppTheme.backgroundLight
Scaffold(
  appBar: AppBar(...),
  body: SingleChildScrollView(...),
  // No need to set backgroundColor - it uses the theme
)
```

## Common Patterns

### Pattern 1: Card with Shadow

```dart
Card(
  child: Container(
    padding: EdgeInsets.all(16),
    child: Column(...),
  ),
)

// The Card theme is configured with:
// - elevation: 2
// - borderRadius: 24
// - color: cardBackground
// - shadow: subtle
```

### Pattern 2: Button

```dart
// Elevated Button
ElevatedButton(
  onPressed: () {},
  child: Text('Click Me'),
)

// The theme handles:
// - backgroundColor: primaryBlue
// - textColor: white
// - padding & border radius
```

### Pattern 3: Input Field

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    labelText: 'Label',
  ),
)

// The theme handles:
// - fillColor: surfaceLight
// - border radius: 16
// - focused border color: primaryBlue
```

## Migration Checklist

When updating screens to use the theme:

- [ ] Remove hardcoded `Color(0xFF...)` and use `AppTheme.*` constants
- [ ] Replace `Colors.white` with `AppTheme.textWhiteOverlay` or remove if on a themed widget
- [ ] Replace `Colors.grey` with appropriate `AppTheme.*` colors
- [ ] Use `Theme.of(context).textTheme.*` instead of hardcoded TextStyles
- [ ] Use `Theme.of(context).colorScheme.*` for theme-aware colors
- [ ] Remove `backgroundColor` from Scaffold (uses theme)
- [ ] Verify the screen looks good in light mode

## Benefits

✅ Consistent design across the app
✅ Easy dark mode support
✅ Faster updates to app branding
✅ Better accessibility
✅ Easier theme customization

