import 'package:intl/intl.dart';

/// Localization Strings
class LocalizationStrings {
  static const Map<String, Map<String, String>> translations = {
    'ar': {
      // General
      'app_title': 'خطوات اجتماعية',
      'app_subtitle': 'تطبيق تعليمي علاجي للأطفال',

      // Navigation
      'home': 'الرئيسية',
      'settings': 'الإعدادات',
      'progress': 'التقدم',
      'about': 'حول التطبيق',
      'logout': 'تسجيل الخروج',
      'dashboard': 'لوحة التحكم',
      'profile': 'الملف الشخصي',

      // Onboarding
      'welcome': 'مرحبا بك',
      'welcome_desc': 'تطبيق مصمم لمساعدة الأطفال على تطوير مهارات اجتماعية',
      'get_started': 'ابدأ الآن',
      'next': 'التالي',
      'skip': 'تخطي',
      'previous': 'السابق',

      // Role Selection
      'who_are_you': 'من أنت؟',
      'select_role': 'اختر دورك للمتابعة',
      'parent_guardian': 'ولي أمر / مربي',
      'specialist_therapist': 'متخصص / معالج',
      'parent_desc': 'أنا ولي أمر أو مربي',
      'specialist_desc': 'أنا متخصص أو معالج',

      // Child Profile
      'child_profile': 'ملف الطفل',
      'child_name': 'اسم الطفل',
      'child_age': 'عمر الطفل',
      'child_info': 'معلومات الطفل',
      'enter_name': 'أدخل اسم الطفل',
      'continue_btn': 'متابعة',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'edit': 'تعديل',
      'delete': 'حذف',
      'create_new': 'إنشاء جديد',
      'view_edit': 'عرض وتعديل',

      // Profile Fields
      'full_name': 'الاسم الكامل',
      'full_name_required': 'الاسم الكامل *',
      'enter_full_name': 'أدخل الاسم الكامل للطفل',
      'name_required': 'الرجاء إدخال اسم الطفل',
      'age': 'العمر',
      'age_required': 'العمر *',
      'enter_age': 'أدخل عمر الطفل',
      'date_of_birth': 'تاريخ الميلاد',
      'select_date': 'اختر التاريخ',
      'gender': 'الجنس',
      'gender_required': 'الجنس *',
      'select_gender': 'اختر الجنس',
      'male': 'ذكر',
      'female': 'أنثى',
      'governorate': 'المحافظة',
      'governorate_required': 'المحافظة *',
      'enter_governorate': 'أدخل المحافظة',
      'school': 'المدرسة',
      'enter_school': 'أدخل اسم المدرسة',
      'iq_level': 'مستوى الذكاء',
      'enter_iq': 'أدخل مستوى الذكاء',
      'health_status': 'الحالة الصحية',
      'health_status_required': 'الحالة الصحية *',
      'enter_health_status': 'أدخل الحالة الصحية',

      // Account Information
      'account_info': 'معلومات الحساب',
      'username': 'اسم المستخدم',
      'username_required': 'اسم المستخدم *',
      'enter_username': 'اختر اسم المستخدم',
      'password': 'كلمة المرور',
      'password_required': 'كلمة المرور *',
      'enter_password': 'كلمة المرور',
      'doctor_username': 'اسم المستخدم للطبيب',
      'enter_doctor_username': 'أدخل اسم المستخدم للطبيب للربط',

      // Parent/Guardian Information
      'parent_info': 'معلومات ولي الأمر/الوصي',
      'parent_name': 'اسم ولي الأمر',
      'enter_parent_name': 'أدخل اسم ولي الأمر',
      'parent_phone': 'رقم هاتف ولي الأمر',
      'enter_parent_phone': 'أدخل رقم هاتف ولي الأمر',
      'address': 'العنوان',
      'enter_address': 'أدخل العنوان الكامل',

      // Medical Information
      'medical_info': 'المعلومات الطبية',
      'allergies': 'الحساسية',
      'enter_allergies': 'أدخل الحساسية (افصل بينها بفواصل)',
      'medications': 'الأدوية',
      'enter_medications': 'أدخل الأدوية الحالية (افصل بينها بفواصل)',

      // Emergency Contact
      'emergency_contact': 'جهة اتصال الطوارئ',
      'emergency_contact_name': 'اسم جهة الاتصال',
      'enter_emergency_contact': 'أدخل اسم جهة اتصال الطوارئ',
      'emergency_phone': 'رقم هاتف الطوارئ',
      'enter_emergency_phone': 'أدخل رقم هاتف الطوارئ',

      // Education Information
      'education_info': 'المعلومات التعليمية',

      // Profile Photo
      'profile_photo': 'الصورة الشخصية',
      'tap_to_change_photo': 'اضغط لتغيير الصورة',
      'error_picking_image': 'خطأ في اختيار الصورة',

      // Validation Messages
      'required': 'مطلوب',
      'min_4_chars': 'الحد الأدنى 4 أحرف',
      'min_6_chars': 'الحد الأدنى 6 أحرف',
      'enter_valid_age': 'أدخل عمر صحيح',

      // Success/Error Messages
      'profile_saved_successfully': 'تم حفظ الملف بنجاح!',
      'profile_updated_successfully': 'تم تحديث الملف بنجاح!',
      'error_saving_profile': 'خطأ في حفظ الملف',
      'profile_created_successfully': 'تم إنشاء الملف بنجاح!',

      // Stages
      'stage_1': 'التعرف الاجتماعي',
      'stage_1_desc': 'التعرف على الأشخاص والأماكن والأشياء',
      'stage_2': 'التفاعل الاجتماعي',
      'stage_2_desc': 'فهم الإيماءات والتفاعل التعاوني',
      'stage_3': 'التواصل',
      'stage_3_desc': 'بدء المحادثات والتفاعل الاجتماعي',

      // Activities
      'recognizing_people': 'التعرف على الأشخاص',
      'recognizing_places': 'التعرف على الأماكن',
      'recognizing_objects': 'التعرف على الأشياء',
      'social_gestures': 'الإيماءات الاجتماعية',
      'cooperative_play': 'اللعب التعاوني',
      'starting_conversation': 'بدء المحادثة',
      'initiating_interaction': 'بدء التفاعل',

      // Progress
      'your_progress': 'تقدمك',
      'overall_progress': 'التقدم الإجمالي',
      'achievements': 'الإنجازات',
      'completed': 'مكتمل',
      'in_progress': 'قيد التقدم',
      'not_started': 'لم يبدأ',
      'progress_reports': 'تقارير التقدم',
      'view_progress_reports': 'عرض تقارير التقدم',
      'learning_stages': 'مراحل التعلم',
      'ask_rafik': 'اسأل رفيق',
      'stage': 'المرحلة',

      // Stage Activities
      'sharing_toys': 'مشاركة الألعاب',
      'sharing_toys_desc': 'تعلم عرض ومشاركة ألعابك مع الأصدقاء',
      'building_together': 'البناء معًا',
      'building_together_desc': 'اعمل كفريق لبناء شيء رائع',
      'group_activity': 'نشاط جماعي',
      'group_activity_desc': 'انضم إلى أنشطة ممتعة مع الأطفال الآخرين',

      // Places
      'my_home': 'منزلي',
      'my_school': 'مدرستي',
      'my_bathroom': 'حمامي',
      'my_kitchen': 'مطبخي',
      'my_bedroom': 'غرفتي',
      'my_playroom': 'غرفة لعب',

      // Objects
      'teddy_bear': 'دب محشو',
      'building_blocks': 'مكعبات بناء',

      // Common Actions
      'listen': 'استمع',
      'start_practice': 'ابدأ التدريب',
      'start_activity': 'ابدأ النشاط',

      // Progress Screen
      'total_progress': 'إجمالي التقدم',
      'days_active': 'أيام النشاط',
      'weekly_activity': 'النشاط الأسبوعي',
      'first_conversation': 'المحادثة الأولى',

      // Settings
      'better_visibility': 'رؤية أفضل',
      'app_version': 'إصدار التطبيق',
      'last_updated': 'آخر تحديث',
      'privacy_policy': 'سياسة الخصوصية',

      // Subtitles
      'tap_to_hear_names': 'اضغط لسماع الأسماء',
      'tap_to_hear_place_names': 'اضغط لسماع أسماء الأماكن',
      'tap_to_hear_object_names': 'اضغط لسماع أسماء الأشياء',
      'learn_communicate_gestures': 'تعلم التواصل بالإيماءات',
      'learn_play_others': 'تعلم اللعب مع الآخرين',
      'learn_start_interactions': 'تعلم بدء التفاعلات',
      'child_journey': 'رحلة الطفل',

      // Settings
      'language': 'اللغة',
      'theme': 'المظهر',
      'dark_mode': 'الوضع الليلي',
      'notifications': 'التنبيهات',
      'about_app': 'حول التطبيق',
      'version': 'الإصدار',

      // Doctor Profile
      'doctor_profile': 'ملف الطبيب',
      'doctor_info': 'معلومات الطبيب',
      'specialization': 'التخصص',
      'enter_specialization': 'أدخل التخصص',
      'experience': 'سنوات الخبرة',
      'enter_experience': 'أدخل سنوات الخبرة',
      'license': 'الرخصة المهنية',
      'enter_license': 'أدخل رقم الرخصة المهنية',

      // Messages
      'loading': 'جاري التحميل...',
      'success': 'نجح',
      'error': 'حدث خطأ',
      'try_again': 'حاول مجددا',
      'confirm': 'تأكيد',
      'are_you_sure': 'هل أنت متأكد؟',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
    },
    'en': {
      // General
      'app_title': 'SocialSteps',
      'app_subtitle': 'Therapeutic Learning for Children',

      // Navigation
      'home': 'Home',
      'settings': 'Settings',
      'progress': 'Progress',
      'about': 'About',
      'logout': 'Logout',
      'dashboard': 'Dashboard',
      'profile': 'Profile',

      // Onboarding
      'welcome_desc': 'App designed to help children develop social skills',
      'get_started': 'Get Started',
      'next': 'Next',
      'skip': 'Skip',
      'previous': 'Previous',
      'child_name': 'Ali',

      // Role Selection
      'who_are_you': 'Who are you?',
      'select_role': 'Select your role to continue',
      'parent_guardian': 'Parent / Guardian',
      'specialist_therapist': 'Specialist / Therapist',
      'parent_desc': 'I am a parent or guardian',
      'specialist_desc': 'I am a specialist or therapist',

      // Child Profile
      'child_profile': 'Child Profile',

      'child_age': 'Child Age',
      'child_info': 'Child Information',
      'enter_name': 'Enter child name',
      'continue_btn': 'Continue',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'create_new': 'Create New',
      'view_edit': 'View and Edit',

      // Profile Fields
      'full_name': 'Full Name',
      'full_name_required': 'Full Name *',
      'enter_full_name': 'Enter child\'s full name',
      'name_required': 'Please enter child\'s name',
      'age': 'Age',
      'age_required': 'Age *',
      'enter_age': 'Enter child\'s age',
      'date_of_birth': 'Date of Birth',
      'select_date': 'Select Date',
      'gender': 'Gender',
      'gender_required': 'Gender *',
      'select_gender': 'Select gender',
      'male': 'Male',
      'female': 'Female',
      'governorate': 'Governorate',
      'governorate_required': 'Governorate *',
      'enter_governorate': 'Enter governorate',
      'school': 'School',
      'enter_school': 'Enter school name',
      'iq_level': 'IQ Level',
      'enter_iq': 'Enter IQ level',
      'health_status': 'Health Status',
      'health_status_required': 'Health Status *',
      'enter_health_status': 'Enter health status',

      // Account Information
      'account_info': 'Account Information',
      'username': 'Username',
      'username_required': 'Username *',
      'enter_username': 'Choose username',
      'password': 'Password',
      'password_required': 'Password *',
      'enter_password': 'Password',
      'doctor_username': 'Doctor Username',
      'enter_doctor_username': 'Enter doctor username to link profile',

      // Parent/Guardian Information
      'parent_info': 'Parent/Guardian Information',
      'parent_name': 'Parent Name',
      'enter_parent_name': 'Enter parent name',
      'parent_phone': 'Parent Phone',
      'enter_parent_phone': 'Enter parent phone number',
      'address': 'Address',
      'enter_address': 'Enter full address',

      // Medical Information
      'medical_info': 'Medical Information',
      'allergies': 'Allergies',
      'enter_allergies': 'Enter allergies (separate with commas)',
      'medications': 'Medications',
      'enter_medications': 'Enter current medications (separate with commas)',

      // Emergency Contact
      'emergency_contact': 'Emergency Contact',
      'emergency_contact_name': 'Emergency Contact Person',
      'enter_emergency_contact': 'Enter emergency contact person',
      'emergency_phone': 'Emergency Phone',
      'enter_emergency_phone': 'Enter emergency phone number',

      // Education Information
      'education_info': 'Education Information',

      // Profile Photo
      'profile_photo': 'Profile Photo',
      'tap_to_change_photo': 'Tap to change photo',
      'error_picking_image': 'Error picking image',

      // Validation Messages
      'required': 'Required',
      'min_4_chars': 'Min 4 characters',
      'min_6_chars': 'Min 6 characters',
      'enter_valid_age': 'Enter valid age',

      // Success/Error Messages
      'profile_saved_successfully': 'Profile saved successfully!',
      'profile_updated_successfully': 'Profile updated successfully!',
      'error_saving_profile': 'Error saving profile',
      'profile_created_successfully': 'Profile created successfully!',

      // Stages
      'stage_1': 'Social Recognition',
      'stage_1_desc': 'Recognizing people, places, and objects',
      'stage_2': 'Social Interaction',
      'stage_2_desc': 'Understanding gestures and cooperative play',
      'stage_3': 'Communication',
      'stage_3_desc': 'Starting conversations and social interaction',

      // Activities
      'recognizing_people': 'Recognizing People',
      'recognizing_places': 'Recognizing Places',
      'recognizing_objects': 'Recognizing Objects',
      'social_gestures': 'Social Gestures',
      'cooperative_play': 'Cooperative Play',
      'starting_conversation': 'Starting Conversation',
      'initiating_interaction': 'Initiating Interaction',

      // Progress
      'your_progress': 'Your Progress',
      'overall_progress': 'Overall Progress',
      'achievements': 'Achievements',
      'completed': 'Completed',
      'in_progress': 'In Progress',
      'not_started': 'Not Started',
      'progress_reports': 'Progress Reports',
      'view_progress_reports': 'View Progress Reports',
      'learning_stages': 'Learning Stages',
      'ask_rafik': 'Ask Rafik',
      'stage': 'Stage',

      // Stage Activities
      'sharing_toys': 'Sharing Toys',
      'sharing_toys_desc': 'Learn to offer and share your toys with friends',
      'building_together': 'Building Together',
      'building_together_desc': 'Work as a team to build something amazing',
      'group_activity': 'Group Activity',
      'group_activity_desc': 'Join in fun activities with other children',

      // Places
      'my_home': 'My Home',
      'my_school': 'My School',
      'my_bathroom': 'My Bathroom',
      'my_kitchen': 'My Kitchen',
      'my_bedroom': 'My Bedroom',
      'my_playroom': 'My Playroom',

      // Objects
      'teddy_bear': 'Teddy Bear',
      'building_blocks': 'Building Blocks',

      // Common Actions
      'listen': 'Listen',
      'start_practice': 'Start Practice',
      'start_activity': 'Start Activity',

      // Progress Screen
      'total_progress': 'Total Progress',
      'days_active': 'Days Active',
      'weekly_activity': 'Weekly Activity',
      'first_conversation': 'First Conversation',

      // Settings
      'better_visibility': 'Better visibility',
      'app_version': 'App Version',
      'last_updated': 'Last Updated',
      'privacy_policy': 'Privacy Policy',

      // Subtitles
      'tap_to_hear_names': 'Tap to hear names',
      'tap_to_hear_place_names': 'Tap to hear place names',
      'tap_to_hear_object_names': 'Tap to hear object names',
      'learn_communicate_gestures': 'Learn to communicate with gestures',
      'learn_play_others': 'Learn to play with others',
      'learn_start_interactions': 'Learn to start interactions',
      'child_journey': 'Child\'s journey',

      // Settings
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'about_app': 'About App',
      'version': 'Version',

      // Doctor Profile
      'doctor_profile': 'Doctor Profile',
      'doctor_info': 'Doctor Information',
      'specialization': 'Specialization',
      'enter_specialization': 'Enter specialization',
      'experience': 'Years of Experience',
      'enter_experience': 'Enter years of experience',
      'license': 'Professional License',
      'enter_license': 'Enter professional license number',

      // Messages
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'An error occurred',
      'try_again': 'Try Again',
      'confirm': 'Confirm',
      'are_you_sure': 'Are you sure?',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
    },
  };

  /// Get localized string
  static String t(String key, {String locale = 'ar'}) {
    return translations[locale]?[key] ?? key;
  }

  /// Get current locale
  static String getCurrentLocale() {
    return Intl.getCurrentLocale().split('_')[0];
  }

  /// Format date
  static String formatDate(DateTime date, {String locale = 'ar'}) {
    final format = DateFormat.yMd(locale);
    return format.format(date);
  }

  /// Format time
  static String formatTime(DateTime time, {String locale = 'ar'}) {
    final format = DateFormat.jm(locale);
    return format.format(time);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime, {String locale = 'ar'}) {
    final format = DateFormat.yMd(locale).add_jm();
    return format.format(dateTime);
  }

  /// Check if is RTL (Arabic)
  static bool isRTL(String locale) {
    return locale == 'ar';
  }
}
