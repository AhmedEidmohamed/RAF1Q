# Theme Quick Reference Card

## 🎨 Color Constants (Use These!)

```dart
// Instead of: Color(0xFF5B7FFF)
import '../theme/app_theme.dart';

// Primary Colors
AppTheme.primaryBlue       // #5B7FFF
AppTheme.primaryPurple     // #8B5CF6
AppTheme.primaryPink       // #EC4899

// Backgrounds
AppTheme.backgroundLight   // #FAFBFF - Main app background
AppTheme.cardBackground    // #FFFFFF - White cards
AppTheme.surfaceLight      // #F7FAFC
AppTheme.surfaceLightest   // #F3E8FF
AppTheme.overlayLight      // #F0FDF4

// Text Colors
AppTheme.textPrimary       // #2D3748 - Main text
AppTheme.textSecondary     // #718096 - Secondary text
AppTheme.textLight         // #A0AEC0 - Light text
AppTheme.textWhiteOverlay  // #FFFFFF - White text

// Status Colors
AppTheme.successGreen      // #48BB78 ✅
AppTheme.successGreenDark  // #38A169
AppTheme.successGreenLight // #166534
AppTheme.errorRed          // #F56565 ❌
AppTheme.warningYellow     // #ECC94B ⚠️

// Borders
AppTheme.borderColor       // #E2E8F0
AppTheme.dividerColor      // #E2E8F0

// Gradients
AppTheme.blueGradient      // Blue gradient
AppTheme.purpleGradient    // Purple gradient
AppTheme.pinkGradient      // Pink gradient
AppTheme.bluePurpleGradient // Blue to purple
```

## 📝 Text Styles

```dart
// Instead of custom TextStyle, use:
Theme.of(context).textTheme.displayLarge      // 32px, bold
Theme.of(context).textTheme.displayMedium     // 28px, bold
Theme.of(context).textTheme.displaySmall      // 24px, bold
Theme.of(context).textTheme.headlineLarge     // 22px, bold
Theme.of(context).textTheme.headlineMedium    // 20px, bold
Theme.of(context).textTheme.headlineSmall     // 18px, bold
Theme.of(context).textTheme.bodyLarge         // 16px, normal
Theme.of(context).textTheme.bodyMedium        // 14px, normal (secondary color)
Theme.of(context).textTheme.bodySmall         // 12px, normal (light color)
Theme.of(context).textTheme.labelLarge        // 16px, w500
```

## 🔄 Before & After Examples

### Example 1: Container with Color

**❌ BEFORE:**
```dart
Container(
  color: Color(0xFFFAFBFF),
  child: Text('Hello'),
)
```

**✅ AFTER:**
```dart
Container(
  color: AppTheme.backgroundLight,
  child: Text('Hello'),
)
```

### Example 2: Text with Custom Style

**❌ BEFORE:**
```dart
Text(
  'Title',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2D3748),
  ),
)
```

**✅ AFTER:**
```dart
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
)
```

### Example 3: Button

**❌ BEFORE:**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF5B7FFF),
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  ),
  onPressed: () {},
  child: Text('Button'),
)
```

**✅ AFTER:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Button'),
)
```
Theme is automatically applied!

### Example 4: Card

**❌ BEFORE:**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [...],
  ),
)
```

**✅ AFTER:**
```dart
Card(
  child: YourContent(),
)
```
Theme handles color, radius, and shadow!

### Example 5: Input Field

**❌ BEFORE:**
```dart
TextField(
  decoration: InputDecoration(
    fillColor: Color(0xFFF7FAFC),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

**✅ AFTER:**
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
  ),
)
```
Theme handles all styling!

## 🎯 When to Use Theme.of(context)

Use when you need dynamic colors that respond to light/dark mode:

```dart
// For colors that should respond to theme
Text(
  'Dynamic text',
  style: TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)

// For text styles (always use this!)
Text(
  'Styled text',
  style: Theme.of(context).textTheme.bodyLarge,
)
```

## 🎨 ColorScheme Reference

For advanced theme-aware styling:

```dart
Theme.of(context).colorScheme.primary        // Main blue
Theme.of(context).colorScheme.secondary      // Purple
Theme.of(context).colorScheme.tertiary       // Pink
Theme.of(context).colorScheme.surface        // Card white
Theme.of(context).colorScheme.background     // Light background
Theme.of(context).colorScheme.error          // Red
Theme.of(context).colorScheme.onPrimary      // White (on blue)
Theme.of(context).colorScheme.onSurface      // Dark text (on white)
```

## ✅ Migration Checklist

For each file you update:

- [ ] Import `AppTheme` from `../theme/app_theme.dart`
- [ ] Replace all `Color(0xFF...)` with `AppTheme.*`
- [ ] Replace all custom `TextStyle()` with `Theme.of(context).textTheme.*`
- [ ] Remove `backgroundColor` from `Scaffold` (uses theme)
- [ ] Remove custom `Card` decorations (uses theme)
- [ ] Remove custom button styles (uses theme)
- [ ] Test in light mode

## 💡 Pro Tips

1. **Always import**: `import '../theme/app_theme.dart';`
2. **For text**: Always use `Theme.of(context).textTheme.*`
3. **For colors**: Use `AppTheme.*` constants or `Theme.of(context).colorScheme.*`
4. **For Cards**: Let Card widget handle styling
5. **For Buttons**: Let button themes handle styling
6. **For Inputs**: Let input decoration theme handle styling

---

**Key Rule**: If you're hardcoding colors or text styles, you should probably be using the theme instead! 🎨
