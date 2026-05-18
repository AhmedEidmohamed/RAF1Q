# 🎨 System Integration Guide - Theme, Provider & Localization

## ✅ ماتم إنجازه

### 1. **Theme System** (الثيم) ✅
- 35+ color constants
- Light و Dark themes
- 11 typography styles
- Widget theming شامل

### 2. **Provider System** (إدارة الحالة) ✅
- `AppState` - حالة التطبيق الرئيسية
- `ProgressProvider` - تتبع تقدم الطفل
- Service Locator (GetIt) - Dependency Injection

### 3. **Localization System** (التعريب) ✅
- دعم العربية والإنجليزية
- +50 translation string
- RTL/LTR support

---

## 📚 كيفية الاستخدام

### 1️⃣ استخدام AppState في الشاشات

```dart
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Read state (لا يعيد بناء عند التغيير)
    final userRole = context.read<AppState>().userRole;
    
    // Watch state (يعيد بناء عند التغيير)
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Text('Language: ${appState.currentLanguage}');
      },
    );
  }
}
```

### 2️⃣ استخدام ProgressProvider

```dart
class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, _) {
        return Column(
          children: [
            Text('Overall: ${progress.overallProgress}'),
            // عرض التقدم
          ],
        );
      },
    );
  }
}
```

### 3️⃣ تغيير اللغة

```dart
// تغيير اللغة من الإعدادات
final appState = context.read<AppState>();
await appState.setLanguage('en'); // تبديل للإنجليزية
await appState.setLanguage('ar'); // تبديل للعربية
```

### 4️⃣ استخدام Localization (الترجمات)

```dart
import '../l10n/localization_strings.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final locale = appState.currentLanguage;
        
        // Method 1: Using LocalizationStrings
        String title = LocalizationStrings.t('stage_1', locale: locale);
        
        // Method 2: Using extension (easier)
        String desc = context.t('stage_1_desc', locale: locale);
        
        return Text(title);
      },
    );
  }
}
```

### 5️⃣ حفظ البيانات تلقائياً

```dart
// كل هذه القيم تُحفظ تلقائياً في SharedPreferences

// حفظ دور المستخدم
await appState.setUserRole('parent');

// حفظ اسم الطفل
await appState.setChildName('أحمد');

// حفظ اللغة
await appState.setLanguage('ar');

// تبديل الوضع الليلي
await appState.toggleDarkMode();
```

---

## 🏗️ البنية الكاملة

```
lib/
├── main.dart                          ← نقطة الدخول (محدّثة)
├── theme/
│   └── app_theme.dart                 ← Theme system
├── providers/
│   ├── app_state.dart                 ← إدارة الحالة الرئيسية
│   └── progress_provider.dart         ← تتبع التقدم
├── services/
│   └── service_locator.dart           ← Dependency Injection
├── l10n/
│   ├── localization_strings.dart      ← الترجمات
│   └── localization_delegate.dart     ← LocalizationDelegate
├── screens/
│   └── ... (الشاشات)
└── widgets/
    └── ... (الـ widgets)
```

---

## 🎯 أمثلة عملية كاملة

### مثال 1: شاشة تتابع اللغة والحالة

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/localization_strings.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppState>(
          builder: (context, appState, _) {
            return Text(
              LocalizationStrings.t('settings', locale: appState.currentLanguage),
            );
          },
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          return ListView(
            children: [
              // اختيار اللغة
              ListTile(
                title: Text(LocalizationStrings.t('language', locale: appState.currentLanguage)),
                trailing: DropdownButton<String>(
                  value: appState.currentLanguage,
                  items: [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (lang) {
                    if (lang != null) {
                      appState.setLanguage(lang);
                    }
                  },
                ),
              ),
              
              // تبديل الوضع الليلي
              SwitchListTile(
                title: Text(LocalizationStrings.t('dark_mode', locale: appState.currentLanguage)),
                value: appState.isDarkMode,
                onChanged: (_) => appState.toggleDarkMode(),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### مثال 2: عرض التقدم مع التعريب

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/app_state.dart';
import '../l10n/localization_strings.dart';

class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppState>(
          builder: (context, appState, _) {
            return Text(
              LocalizationStrings.t('your_progress', locale: appState.currentLanguage),
            );
          },
        ),
      ),
      body: Consumer2<AppState, ProgressProvider>(
        builder: (context, appState, progress, _) {
          final locale = appState.currentLanguage;
          
          return Column(
            children: [
              // العنوان
              Text(
                LocalizationStrings.t('overall_progress', locale: locale),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              // شريط التقدم
              LinearProgressIndicator(value: progress.overallProgress),
              
              // قائمة المراحل
              ...progress.stagesProgress.entries.map((entry) {
                String stageName = LocalizationStrings.t(
                  'stage_${entry.key.replaceAll('stage', '')}',
                  locale: locale,
                );
                
                return ListTile(
                  title: Text(stageName),
                  trailing: Text('${(entry.value.progress * 100).toStringAsFixed(0)}%'),
                  subtitle: LinearProgressIndicator(value: entry.value.progress),
                );
              }).toList(),
              
              // الإنجازات
              if (progress.getAchievements().isNotEmpty) ...[
                Divider(),
                Text(
                  LocalizationStrings.t('achievements', locale: locale),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Wrap(
                  children: progress.getAchievements().map((achievement) {
                    return Chip(label: Text(achievement));
                  }).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
```

### مثال 3: تسجيل دخول مع الحفظ

```dart
class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          return Column(
            children: [
              // اختيار دور الوالد
              ElevatedButton(
                onPressed: () async {
                  await appState.setUserRole('parent');
                  Navigator.pushNamed(context, '/child-profile');
                },
                child: const Text('ولي أمر'),
              ),
              
              // اختيار دور المتخصص
              ElevatedButton(
                onPressed: () async {
                  await appState.setUserRole('specialist');
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('متخصص'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 🔧 الملفات المحدّثة

### ✅ pubspec.yaml
- ✅ أضيفت: `provider: ^6.1.0`
- ✅ أضيفت: `get_it: ^7.6.0`
- ✅ أضيفت: `intl: ^0.18.1`
- ✅ أضيفت: `shared_preferences: ^2.2.2`

### ✅ lib/main.dart
- ✅ أضيفت: MultiProvider
- ✅ أضيفت: AppState و ProgressProvider
- ✅ أضيفت: Localization
- ✅ أضيفت: Service Locator

### ✅ ملفات جديدة
- ✅ `lib/providers/app_state.dart` - حالة التطبيق
- ✅ `lib/providers/progress_provider.dart` - تتبع التقدم
- ✅ `lib/services/service_locator.dart` - Dependency Injection
- ✅ `lib/l10n/localization_strings.dart` - الترجمات
- ✅ `lib/l10n/localization_delegate.dart` - LocalizationDelegate

---

## 💡 نصائح مهمة

### 1. استخدم Consumer لتحديث الـ UI
```dart
Consumer<AppState>(
  builder: (context, appState, child) {
    return Text(appState.currentLanguage);
  },
)
```

### 2. استخدم read للقراءة فقط (بدون rebuild)
```dart
final userRole = context.read<AppState>().userRole;
```

### 3. استخدم Consumer2 للـ providers متعددة
```dart
Consumer2<AppState, ProgressProvider>(
  builder: (context, appState, progress, _) {
    // استخدام كلا الـ provider
  },
)
```

### 4. حفظ البيانات يتم تلقائياً
لا تحتاج لحفظ يدوي - كل التغييرات تُحفظ في SharedPreferences

---

## 🚀 الخطوات التالية

1. **تحديث الشاشات** - أضف localization و provider usage
2. **إضافة Assets** - صور وفيديوهات
3. **إضافة وظائف** - تسجيل الخروج، إدارة الملفات الشخصية، إلخ

---

**النظام المتكامل جاهز الآن!** 🎉

استخدم الأمثلة أعلاه كمرجع عند تحديث الشاشات.
