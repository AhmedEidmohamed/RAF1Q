# مواصفات تطبيق رفيق - الواجهة الأمامية (Flutter)
## RAFIQ Autism Training Platform - Flutter Specifications

---

## 📋 نظرة عامة على المشروع

**اسم المشروع:** رفيق (RAFIQ)  
**الوصف:** منصة تدريب للأطفال المصابين بالتوحد  
**الإطار التقني:** Flutter مع لغة Dart  
**اللغة:** العربية (RTL - من اليمين لليسار)  
**الهدف:** توفير منصة تفاعلية لتدريب الأطفال على المهارات الاجتماعية والتعرف والتواصل عبر تطبيق للهواتف الذكية (Android / iOS).

---

## 🛠️ التقنيات المستخدمة

### المكتبات الأساسية
- **Flutter:** إطار عمل واجهة المستخدم من جوجل (SDK >= 3.0.0)
- **Dart:** لغة البرمجة الأساسية

### إدارة الحالة وحقن التبعيات (State Management & DI)
- **Provider:** 6.x (لإدارة الحالة العامة للتطبيق)
- **GetIt:** 7.x (محدد مواقع الخدمات Dependency Injection)
- **Shared Preferences:** للتخزين المحلي (Local Storage)

### المكتبات الإضافية والذكاء الاصطناعي
- **Firebase:** (Auth, Firestore, Storage, App Check) للمصادقة وقواعد البيانات
- **Google Generative AI:** للذكاء الاصطناعي التوليدي (Gemini)
- **TensorFlow Lite (tflite_flutter):** للتعرف على الوجوه والإيماءات محلياً
- **Speech & Audio:** `speech_to_text`, `flutter_tts`, `audioplayers`, `just_audio` لتحويل الصوت والنطق
- **Animations & UI:** `lottie`, `fl_chart`, `confetti`, `google_fonts`, `google_nav_bar`

### أدوات التطوير
- **flutter_lints:** لفحص جودة الكود
- **build_runner & json_serializable:** لتوليد أكواد النماذج (Models)

---

## 📁 هيكل المشروع

```
frontend/
├── lib/
│   ├── main.dart               # نقطة الدخول للتطبيق (Entry Point)
│   │
│   ├── l10n/                   # ملفات الترجمة واللغات
│   │   └── app_localizations.dart
│   │
│   ├── models/                 # نماذج البيانات (Data Models)
│   │   ├── user.dart
│   │   ├── child.dart
│   │   └── progress.dart
│   │
│   ├── providers/              # مزودي الحالة (State Management)
│   │   ├── app_state.dart      # حالة التطبيق العامة (لغة، تسجيل دخول)
│   │   └── ...
│   │
│   ├── screens/                # شاشات التطبيق (Screens)
│   │   ├── onboarding/         # شاشات البداية
│   │   │   ├── onboarding_screen.dart
│   │   │   └── role_selection_screen.dart
│   │   ├── auth/               # المصادقة
│   │   │   ├── child_login_screen.dart
│   │   │   ├── doctor_login_screen.dart
│   │   │   └── doctor_registration_screen.dart
│   │   ├── dashboard/          # اللوحات الرئيسية
│   │   │   ├── home_dashboard_screen.dart
│   │   │   └── doctor_dashboard_screen.dart
│   │   ├── learning/           # شاشات التعلم والتفاعل
│   │   │   ├── stage1_recognizing_objects_screen.dart
│   │   │   ├── stage1_recognizing_people_screen.dart
│   │   │   ├── stage1_recognizing_places_screen.dart
│   │   │   ├── stage2_social_gestures_screen.dart
│   │   │   ├── stage3_initiating_interaction_screen.dart
│   │   │   └── gesture_practice_screen.dart
│   │   ├── tests/              # شاشات الاختبارات
│   │   │   ├── test_objects_recognition_screen.dart
│   │   │   ├── test_people_recognition_screen.dart
│   │   │   └── test_places_recognition_screen.dart
│   │   └── profiles/           # الملفات الشخصية
│   │       ├── child_profile_screen.dart
│   │       └── doctor_profile_view_screen.dart
│   │
│   ├── services/               # الخدمات والتواصل مع الـ API و Firebase
│   │   ├── auth_service.dart
│   │   ├── elevanlabs_service.dart
│   │   ├── gemini_service.dart
│   │   └── firestore_service.dart
│   │
│   ├── theme/                  # التنسيقات والألوان
│   │   └── app_theme.dart
│   │
│   └── widgets/                # المكونات المشتركة (UI Components)
│       ├── custom_widgets.dart
│       ├── emotion_tracker_wrapper.dart
│       └── ...
│
├── assets/                     # الملفات الثابتة
│   ├── images/                 # الصور
│   └── fonts/                  # الخطوط
│
├── android/                    # إعدادات تطبيق الأندرويد
├── ios/                        # إعدادات تطبيق الآيفون
├── pubspec.yaml                # ملف إدارة الحزم والتبعيات
└── README.md
```

---

## 🎨 التصميم والواجهة

### نظام الألوان (AppTheme)
- **اللون الأساسي:** `#007AFF` (أزرق iOS) للموثوقية والهدوء.
- **ألوان متدرجة (Gradients):** تدرجات مبهجة من الأزرق (`#0088ff` إلى `#007aff`) للبطاقات والأزرار.
- **لون الخلفية:** `Colors.white` (أبيض نقي).
- **لون النص الأساسي:** `#1F2937` (رمادي داكن دافئ).

### الخطوط
- **الخط الأساسي:** `Cairo` (عبر `google_fonts`) لدعم ممتاز للغة العربية.
- الأحجام والسماكة مخصصة بناءً على `Material 3` (Display, Headline, Body).

### الاتجاه
- **RTL:** التطبيق يدعم من اليمين لليسار بشكل أصلي عبر `flutter_localizations`.

### المكونات المشتركة
1. **GradientButton:** أزرار رئيسية بتدرج لوني أو لون صلب.
2. **RecognitionCard:** بطاقات عرض (للأشخاص والأماكن) تدعم الصور وحالات التحميل.
3. **CustomAppBar:** شريط علوي مخصص.
4. **LabeledProgressBar:** شريط تقدم مع نسب مئوية.

---

## 🔐 المصادقة والحماية

### نظام المصادقة
- **مزود الخدمة:** Firebase Auth & Google Sign-In.
- **التخزين:** حفظ حالة الجلسة (Session) محلياً عبر `SharedPreferences`.
- **الأدوار (Roles):**
  - ولي الأمر / الطفل.
  - الأخصائي / الطبيب.

### التوجيه الآمن
- فحص حالة الدخول عند بدء التطبيق في `OnboardingScreen` وإعادة التوجيه إلى `/home` إذا كان المستخدم مسجلاً.

---

## 📊 إدارة الحالة (Provider)

### AppState (مزود الحالة الرئيسي)
- `isLoggedIn`: تتبع حالة تسجيل الدخول.
- `currentLanguage`: إدارة لغة واجهة التطبيق.
- التحكم في بيانات المستخدم الحالي (Child أو Doctor).

---

## 🎯 الميزات الرئيسية

### 1. شاشات الترحيب والمصادقة
- **Onboarding:** شاشات تعريفية بمميزات التطبيق.
- **Role Selection:** اختيار نوع المستخدم (ولي أمر أو أخصائي).
- تسجيل دخول / إنشاء حساب مبسط.

### 2. التعرف الاجتماعي (Recognition - Stage 1)
- **الأشخاص:** التعرف على العائلة عبر تقنية TensorFlow و Firebase.
- **الأماكن:** صور أماكن مألوفة.
- **الأشياء:** أشياء من البيئة المحيطة.

### 3. التفاعل الاجتماعي (Interaction - Stage 2)
- **الإشارات والإيماءات:** ممارسة الحركات أمام الكاميرا وتقييمها.
- **تتبع المشاعر (Emotion Tracking):** تتبع تفاعل الطفل وحالته المزاجية أثناء استخدام الألعاب.
- **الألعاب التعاونية:** بناءร่วม (Building Game) والألغاز (Jigsaw).

### 4. التواصل (Communication - Stage 3)
- بدء المحادثة وتكوين الجمل والتفاعل اللفظي باستخدام خدمات مثل `ElevenLabs` و `Gemini`.

### 5. الاختبارات والتقييمات
- اختبارات قياس التطور (CARS/GARS).
- اختبارات تفاعلية لتقييم تقدم الطفل في مراحل التعرف (Test Places, Test Objects).

### 6. لوحة تحكم الأخصائي والتقارير
- تتبع تقدم الحالات.
- إدارة الملفات وعرض الإحصائيات (عبر `fl_chart`).

---

## 🔗 التوجيه (Routing)

يعتمد التطبيق على **Named Routes** في `MaterialApp`:
```dart
'/': (context) => const SplashScreen(),
'/onboarding': (context) => const OnboardingScreen(),
'/role-selection': (context) => const RoleSelectionScreen(),
'/child-login': (context) => const ChildLoginScreen(),
'/doctor-registration': (context) => const DoctorRegistrationScreen(),
'/home': (context) => const HomeDashboardScreen(),
// ... ومسارات مراحل التعلم والاختبارات
```

---

## 🎬 الحركات والانتقالات (Animations)

- **Lottie:** للرسوم المتحركة التوضيحية (مثل الاحتفالات عند النجاح).
- **Confetti:** تأثيرات الاحتفال عند إتمام المهام.
- **BouncingScrollPhysics:** تأثيرات السحب المرنة (iOS style) في القوائم.
- **Hero Animations:** للانتقال السلس للصور بين الشاشات.

---

## 📱 التجاوب (Responsiveness)

- الاعتماد على `MediaQuery` و `Expanded` و `Flexible` لضمان توافق الواجهة مع مختلف أحجام شاشات الهواتف والأجهزة اللوحية (Tablets).
- استخدام `SafeArea` لتجنب التداخل مع نوتش الشاشة والحواف.

---

## 🚀 أوامر التشغيل الأساسية

```bash
# جلب الحزم (Dependencies)
flutter pub get

# تشغيل التطبيق (وضع التطوير)
flutter run

# إنشاء نسخة APK للأندرويد
flutter build apk --release

# فحص وتحليل الكود (Linting)
flutter analyze

# تنظيف ذاكرة التخزين المؤقت
flutter clean
```

---

## 📝 ملاحظات مهمة لفريق فلاتر

1. **إدارة الأصول (Assets):** التأكد من إضافة مسارات الصور والملفات الصوتية في `pubspec.yaml` قبل استخدامها.
2. **الكاميرا والمايكروفون:** يجب طلب الصلاحيات (Permissions) باستخدام `permission_handler` قبل تشغيل أنشطة الإيماءات والصوت.
3. **تكامل Firebase:** ضرورة توافر ملفات `google-services.json` (للأندرويد) و `GoogleService-Info.plist` (للآيفون).
4. **الأداء:** استخدام `const` في ويدجت فلاتر لتقليل إعادة الرسم (Rebuilds) وتحسين الأداء.

---

**آخر تحديث:** مايو 2026  
**الإصدار:** 1.0.0
