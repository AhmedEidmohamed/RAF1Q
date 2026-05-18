import 'package:intl/intl.dart';

/// Complete App Localization - الترجمة الشاملة للتطبيق
/// Contains all translations for every screen and component
class AppLocalizations {
  static const Map<String, Map<String, String>> translations = {
    'ar': {
      // ==================== APP GENERAL ====================
      'app_title': 'خطوات اجتماعية',
      'app_subtitle': 'تطبيق تعليمي علاجي للأطفال',

      // Navigation
      'welcome_to_rafiq': 'مرحبا بك في رفيق',
      'activities': 'الأنشطة',
      'home': 'الرئيسية',
      'dashboard': 'لوحة التحكم',
      'progress': 'التقدم',
      'about': 'حول التطبيق',
      'logout': 'تسجيل الخروج',
      'profile': 'الملف الشخصي',
      'back': 'رجوع',
      'next': 'التالي',
      'previous': 'السابق',
      'skip': 'تخطي',
      'done': 'تم',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'confirm': 'تأكيد',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
      'try_again': 'حاول مجددا',
      'loading': 'جاري التحميل...',
      'success': 'نجح',
      'error': 'حدث خطأ',
      'warning': 'تحذير',
      'info': 'معلومات',

      // ==================== ONBOARDING ====================
      'welcome_to_socialsteps': 'مرحبا بك في خطوات اجتماعية',
      'welcome_desc':
          'تطبيق تعليمي علاقي مصمم لمساعدة الأطفال على تطوير المهارات الاجتماعية والتواصلية',
      'learn_grow_together': 'تعلم ونتعلم معا',
      'cooperative_play_description':
          'اللعب التعاوني يساعد الأطفال على تعلم العمل الجماعي والمشاركة ومهارات التفاعل الاجتماعي.',
      'min': 'دقيقة',

      // Success Messages
      'great_try_practice_gesture': 'رائع! الآن حاول ممارسة هذه الإيماءة.',
      'track_progress': 'تتبع التقدم',
      'track_progress_desc':
          'راقب تطور طفلكك مع تقارير التقدم المفصلة والإنجازات',
      'get_started': 'ابدأ الآن',

      // ==================== ROLE SELECTION ====================
      'who_are_you': 'من أنت؟',
      'select_role_continue': 'اختر دورك للمتابعة',
      'parent_guardian': 'ولي أمر / مربي',
      'specialist_therapist': 'متخصص / معالج',
      'parent_desc': 'أنا ولي أمر أو مربي',
      'specialist_desc': 'أنا متخصص أو معالج',

      // ==================== CHILD PROFILE ====================
      'child_profile': 'ملف الطفل',
      'create_new_profile': 'إنشاء ملف جديد',
      'view_edit_profile': 'عرض وتعديل الملف',
      'child_info': 'معلومات الطفل',
      'basic_info': 'المعلومات الأساسية',
      'medical_info': 'المعلومات الطبية',
      'parent_info': 'معلومات ولي الأمر/الوصي',
      'emergency_contact': 'جهة اتصال الطوارئ',
      'education_info': 'المعلومات التعليمية',
      'account_info': 'معلومات الحساب',

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
      'health_status_required_or_symptoms': 'الحالة الصحية او الشكوى',
      'enter_health_status_or_symptoms': 'أدخل الحالة الصحية او الشكوى',
      'allergies': 'الحساسية',
      'enter_allergies': 'أدخل الحساسية (افصل بينها بفواصل)',
      'medications': 'الأدوية',
      'enter_medications': 'أدخل الأدوية الحالية (افصل بينها بفواصل)',
      'parent_name': 'اسم ولي الأمر',
      'enter_parent_name': 'أدخل اسم ولي الأمر',
      'parent_phone': 'رقم هاتف ولي الأمر',
      'enter_parent_phone': 'أدخل رقم هاتف ولي الأمر',
      'address': 'العنوان',
      'enter_address': 'أدخل العنوان الكامل',
      'emergency_contact_name': 'اسم جهة الاتصال',
      'enter_emergency_contact': 'أدخل اسم جهة اتصال الطوارئ',
      'emergency_phone': 'رقم هاتف الطوارئ',
      'enter_emergency_phone': 'أدخل رقم هاتف الطوارئ',
      'username': 'اسم المستخدم',
      'username_required': 'اسم المستخدم *',
      'enter_username': 'اختر اسم المستخدم',
      'password': 'كلمة المرور',
      'password_required': 'كلمة المرور *',
      'enter_password': 'كلمة المرور',
      'doctor_name': 'اسم الطبيب',
      'enter_doctor_name': 'أدخل اسم الطبيب للربط',

      // Profile Photo
      'profile_photo': 'الصورة الشخصية',
      'tap_to_change_photo': 'اضغط لتغيير الصورة',
      'error_picking_image': 'خطأ في اختيار الصورة',

      // Validation Messages
      'required': 'مطلوب',
      'min_4_chars': 'الحد الأدنى 4 أحرف',
      'min_6_chars': 'الحد الأدنى 6 أحرف',
      'enter_valid_age': 'أدخل عمر صحيح',
      'enter_valid_phone': 'أدخل رقم هاتف صحيح',
      'enter_valid_email': 'أدخل بريدا إلكترونيا صحيحا',

      // Success/Error Messages
      'profile_saved_successfully': 'تم حفظ الملف بنجاح!',
      'profile_updated_successfully': 'تم تحديث الملف بنجاح!',
      'profile_created_successfully': 'تم إنشاء الملف بنجاح!',
      'error_saving_profile': 'خطأ في حفظ الملف',
      'profile_deleted_successfully': 'تم حذف الملف بنجاح',

      // ==================== DOCTOR PROFILE ====================
      'doctor_registration': 'تسجيل الطبيب',
      'create_professional_profile': 'إنشاء ملف احترافي',
      'passwords_do_not_match': 'كلمات المرور غير متطابقة',
      'doctor_registration_successful': 'تم تسجيل الطبيب بنجاح!',
      'doctor_dashboard': 'لوحة تحكم الطبيب',
      'linked_children': 'الأطفال المرتبطين',
      'no_children_linked_yet': 'لا يوجد أطفال مرتبطين بعد',
      'children_can_link_profile':
          'يمكن للأطفال الربط بملفك باستخدام اسم المستخدم',
      'active': 'نشط',
      'children': 'الأطفال',
      'messages': 'الرسائل',
      'settings': 'الإعدادات',
      'progress_rate': 'معدل التقدم',
      'sessions_this_week': 'الجلسات هذا الأسبوع',
      'average_rating': 'متوسط التقييم',
      'search_children': 'البحث عن الأطفال',
      'edit_profile': 'تعديل الملف الشخصي',
      'notifications': 'الإشعارات',
      'add_child': 'إضافة طفل',
      'manage_permissions': 'إدارة الصلاحيات',
      'schedule_sessions': 'جدولة الجلسات',
      'view_profile': 'عرض الملف الشخصي',
      'child_control': 'تحكم الطفل',
      'doctor_info': 'معلومات الطبيب',
      'specialization': 'التخصص',
      'enter_specialization': 'أدخل التخصص',
      'experience': 'سنوات الخبرة',
      'enter_experience': 'أدخل سنوات الخبرة',
      'license': 'الرخصة المهنية',
      'enter_license': 'أدخل رقم الرخصة المهنية',
      'clinic_address': 'عنوان العيادة',
      'enter_clinic_address': 'أدخل عنوان العيادة',
      'working_hours': 'ساعات العمل',
      'enter_working_hours': 'أدخل ساعات العمل',

      // ==================== STAGES ====================
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

      // ==================== PROGRESS ====================
      'your_progress': 'تقدمك',
      'overall_progress': 'التقدم الإجمالي',
      'achievements': 'الإنجازات',
      'completed': 'مكتمل',
      'in_progress': 'قيد التقدم',
      'not_started': 'لم يبدأ',
      'progress_reports': 'تقارير التقدم',
      'view_details': 'عرض التفاصيل',
      'no_progress_data': 'لا توجد بيانات تقدم',
      'start_learning': 'ابدأ التعلم',

      // ==================== SETTINGS ====================
      'language_audio': 'اللغة والصوت',
      'accessibility': 'إمكانية الوصول',
      'parental_controls': 'الرقابة الأبوية',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'voice_speed': 'سرعة الصوت',
      'volume': 'مستوى الصوت',
      'high_contrast': 'تباين عالي',
      'large_text': 'نص كبير',
      'audio_instructions': 'تعليمات صوتية',
      'background_music': 'موسيقى خلفية',
      'sound_effects': 'المؤثرات الصوتية',
      'daily_reminders': 'تذكيرات يومية',
      'progress_alerts': 'تنبيهات التقدم',
      'achievement_notifications': 'إشعارات الإنجاز',
      'privacy': 'الخصوصية',
      'terms_conditions': 'الشروط والأحكام',
      'help_support': 'المساعدة والدعم',
      'contact_us': 'اتصل بنا',
      'faq': 'الأسئلة الشائعة',
      'version': 'الإصدار',
      'build_number': 'رقم البناء',

      // ==================== ACTIVITY SCREENS ====================
      'tap_on_correct_answer': 'اضغط على الإجابة الصحيحة',
      'great_job': 'عمل رائع!',
      'correct': 'صحيح!',
      'incorrect': 'غير صحيح',
      'lesson_complete': 'اكتمل الدرس!',
      'next_lesson': 'الدرس التالي',
      'repeat_lesson': 'كرر الدرس',
      'score': 'النقاط',
      'time': 'الوقت',
      'attempts': 'المحاولات',
      'accuracy': 'الدقة',
      'hint': 'تلميح',
      'skip_question': 'تخطي السؤال',
      'listen_carefully': 'استمع بعناية',
      'watch_carefully': 'شاهد بعناية',
      'choose_correct_option': 'اختر الخيار الصحيح',
      'drag_and_drop': 'اسحب وأفلت',
      'match_items': 'طابق العناصر',
      'sort_items': 'رتب العناصر',
      'complete_pattern': 'أكمل النمط',
      'remember_sequence': 'تذكر التسلسل',

      // ==================== COMMON PHRASES ====================
      'welcome': 'مرحبا بك',
      'welcome_back': 'مرحلا بعودتك',
      'good_morning': 'صباح الخير',
      'learning_stages': 'مراحل التعلم',
      'ask_rafik': 'اسأل رفيق',
      'view_progress_reports': 'عرض تقارير التقدم',
      'stage': 'المرحلة',
      'child_name': 'علي',
      'good_afternoon': 'طاب مساؤك',
      'good_evening': 'مساء الخير',
      'have_fun': 'استمتع!',
      'keep_going': 'استمر!',
      'you_can_do_it': 'يمكنك فعلها!',
      'excellent_work': 'عمل ممتاز!',
      'well_done': 'أحسنت!',
      'fantastic': 'رائع!',
      'amazing': 'مذهل!',
      'wonderful': 'رائع!',
      'brilliant': 'عبقري!',
      'outstanding': 'متميز!',
      'perfect': 'مثالي!',
      'superb': 'رائع!',
      'magnificent': 'باهر!',
      'splendid': 'رائع!',
      'terrific': 'رائع!',
      'awesome': 'مذهل!',
      'cool': 'رائع!',
      'nice': 'جميل!',
      'good': 'جيد!',
      'very_good': 'جيد جدا!',
      'great': 'عظيم!',
      'very_great': 'عظيم جدا!',

      // Activity Details
      'my_home': 'منزلي',
      'my_school': 'مدرستي',
      'my_bathroom': 'حمامي',
      'my_kitchen': 'مطبخي',
      'my_bedroom': 'غرفتي',
      'my_playroom': 'غرفة لعب',
      'teddy_bear': 'دب محشو',
      'building_blocks': 'مكعبات بناء',
      'passing_ball': 'تمرير الكرة',
      'building_together': 'البناء معًا',
      'group_activity': 'نشاط جماعي',
      'asking_to_join_play': 'طلب الانضمام للعب',
      'sharing_toys': 'مشاركة الألعاب',
      'starting_game': 'بدء اللعبة',
      'how_are_you': 'كيف حالك؟',
      'what_is_name': 'ما اسمك؟',
      'how_old': 'كم عمرك؟',

      // Button Text
      'start_activity': 'ابدأ النشاط',
      'start_practice': 'ابدأ التدريب',
      'listen': 'استمع',
      'record': 'تسجيل',
      'recording': 'جاري التسجيل...',
      'recorded': 'تم التسجيل',
      'create_profile': 'إنشاء ملف شخصي',
      'confirm_password': 'تأكيد كلمة المرور',

      // Progress Screen
      'social_recognition': 'التعرف الاجتماعي',
      'social_interaction': 'التفاعل الاجتماعي',
      'social_communication': 'التواصل الاجتماعي',
      'first_conversation': 'المحادثة الأولى',
      'total_progress': 'إجمالي التقدم',
      'days_active': 'أيام النشاط',
      'weekly_activity': 'النشاط الأسبوعي',
      'stage_progress': 'تقدم المرحلة',
      'recent_achievements': 'الإنجازات الأخيرة',
      'child_journey': 'رحلة الطفل',

      // Settings
      'better_visibility': 'رؤية أفضل',
      'app_version': 'إصدار التطبيق',
      'last_updated': 'آخر تحديث',
      'privacy_policy': 'سياسة الخصوصية',

      // Age Calculation
      'age_calculated_automatically': 'يحسب تلقائياً',
      'select_birth_date': 'اختر تاريخ الميلاد',

      // Interaction Steps
      "learn_grow_desc": "تعلم وكُلّم معًا مع رفيق",
      'learn_ask_children_play': 'تعلم كيف تطلب من الأطفال الآخرين اللعب معك',
      'walk_up_children_playing': 'اقترب من الأطفال الذين يلعبون',
      'make_eye_contact_smile': 'تواصل بصريا وابتسم',
      'say_can_play': 'قل: "هل يمكنني اللعب معكم؟"',
      'wait_response': 'انتظر ردهم',
      'learn_offer_share_toys': 'تعلم كيف تقدم وتشارك ألعابك مع الأصدقاء',
      'hold_toy_share': 'امسك اللعبة التي تريد مشاركتها',
      'approach_friend': 'اقترب من صديقك',
      'say_want_play': 'قل: "هل تريد اللعب بهذا؟"',
      'hand_toy_smile': 'أعطه اللعبة بابتسامة',
      'learn_invite_start_activity': 'تعلم كيف تدعو الآخرين لبدء نشاط جديد',
      'think_fun_game': 'فكر في لعبة ممتعة',
      'find_friends_play': 'ابحث عن أصدقاء قد يرغبون في اللعب',
      'say_play_together': 'قل: "لنلعب معاً!"',
      'explain_game_rules': 'اشرح قواعد اللعبة',
      'steps_follow': 'الخطوات المتبعة:',
      'be_first_reach_out': 'كن الأول في التواصل',
      'practice_interactions':
          'تدرب على بدء التفاعلات مع الآخرين. لا تنتظر دعوة - اتخذ الخطوة الأولى!',
      'watch_learn': 'Watch & Learn',

      // Conversation Expected Responses
      'i_am_fine_good': 'I am fine / good',
      'my_name_is': 'My name is...',
      'i_am_years_old': 'I am ... years old',
      // Success Messages
      'great_job_answered': 'Great job! You answered the question! 🎉',

      // Instructions
      'tap_speaker_hear_question':
          'Tap the speaker to hear the question, then tap the microphone to record your answer.',

      // Cooperative Play Descriptions
      'learn_take_turns_pass_ball':
          'Learn to take turns and pass a ball with friends',
      'work_team_build_amazing': 'Work as a team to build something amazing',
      'join_fun_activities_children':
          'Join in fun activities with other children',
      'play_learn_together': 'العب وتعلم معًا',
      'cooperative_play_description_en':
          'Cooperative play helps children learn teamwork, sharing, and social interaction skills.',

      // Activity Info

      // Success Messages
      'bye': 'مع السلامة',
      'wave_hand_hello': 'حرك يديك لتحية',
      'nod_head_up_down': 'أومئ برأسك لأعلى ولأسفل',
      'shake_head_side': 'Shake your head side to side',
      'wave_hand_goodbye': 'Wave your hand to say goodbye',

      // ==================== ERRORS & MESSAGES ====================
      'network_error': 'خطأ في الشبكة',
      'no_internet': 'لا يوجد اتصال بالإنترنت',
      'server_error': 'خطأ في الخادم',
      'something_went_wrong': 'حدث خطأ ما',
      'please_try_later': 'الرجاء المحاولة لاحقا',
      'invalid_credentials': 'بيانات اعتماد غير صالحة',
      'access_denied': 'تم رفض الوصول',
      'file_not_found': 'ملف غير موجود',
      'invalid_file': 'ملف غير صالح',
      'upload_failed': 'فشل الرفع',
      'download_failed': 'فشل التنزيل',
      'operation_failed': 'فشلت العملية',
      'session_expired': 'انتهت الجلسة',
      'login_required': 'مطلوب تسجيل الدخول',
      'permission_denied': 'تم رفض الإذن',
      'feature_not_available': 'الميزة غير متاحة',
      'coming_soon': 'قريبا',
      'under_construction': 'قيد الإنشاء',
      'maintenance_mode': 'وضع الصيانة',
    },
    'en': {
      // ==================== APP GENERAL ====================
      'app_title': 'SocialSteps',
      'app_subtitle': 'Therapeutic Learning for Children',

      // Navigation

      'welcome_to_rafiq': 'Welcome to Rafiq',
      'activities': 'Activities',
      'home': 'Home',
      'progress': 'Progress',
      'profile': 'Profile',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'skip': 'Skip',
      'done': 'Done',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'try_again': 'Try Again',
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'info': 'Info',

      // ==================== ONBOARDING ====================
      'welcome_to_socialsteps': 'Welcome to SocialSteps',
      'welcome_desc':
          'A therapeutic and educational app designed to help children develop social and communication skills',
      'learn_grow_together': 'Learn & Grow Together',
      'learn_grow_desc':
          'Interactive activities help children recognize people, places, and understand social interactions',
      'track_progress': 'Track Progress',
      'track_progress_desc':
          'Monitor your child\'s development with detailed progress reports and achievements',
      'get_started': 'Get Started',

      // ==================== ROLE SELECTION ====================
      'who_are_you': 'Who are you?',
      'select_role_continue': 'Select your role to continue',
      'parent_guardian': 'Parent / Guardian',
      'specialist_therapist': 'Specialist / Therapist',
      'parent_desc': 'I am a parent or guardian',
      'specialist_desc': 'I am a specialist or therapist',

      // ==================== CHILD PROFILE ====================
      'child_profile': 'Child Profile',
      'create_new_profile': 'Create New Profile',
      'view_edit_profile': 'View and Edit Profile',
      'child_info': 'Child Information',
      'basic_info': 'Basic Information',
      'medical_info': 'Medical Information',
      'parent_info': 'Parent/Guardian Information',
      'emergency_contact': 'Emergency Contact',
      'education_info': 'Education Information',
      'account_info': 'Account Information',

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
      'allergies': 'Allergies',
      'enter_allergies': 'Enter allergies (separate with commas)',
      'medications': 'Medications',
      'enter_medications': 'Enter current medications (separate with commas)',
      'parent_name': 'Parent Name',
      'enter_parent_name': 'Enter parent name',
      'parent_phone': 'Parent Phone',
      'enter_parent_phone': 'Enter parent phone number',
      'address': 'Address',
      'enter_address': 'Enter full address',
      'emergency_contact_name': 'Emergency Contact Person',
      'enter_emergency_contact': 'Enter emergency contact person',
      'emergency_phone': 'Emergency Phone',
      'enter_emergency_phone': 'Enter emergency phone number',
      'username': 'Username',
      'username_required': 'Username *',
      'enter_username': 'Choose username',
      'password': 'Password',
      'password_required': 'Password *',
      'enter_password': 'Password',
      'doctor_username': 'Doctor Username',
      'enter_doctor_username': 'Enter doctor username to link profile',

      // Profile Photo
      'profile_photo': 'Profile Photo',
      'tap_to_change_photo': 'Tap to change photo',
      'error_picking_image': 'Error picking image',

      // Validation Messages
      'required': 'Required',
      'min_4_chars': 'Min 4 characters',
      'min_6_chars': 'Min 6 characters',
      'enter_valid_age': 'Enter valid age',
      'enter_valid_phone': 'Enter valid phone number',
      'enter_valid_email': 'Enter valid email',

      // Success/Error Messages
      'profile_saved_successfully': 'Profile saved successfully!',
      'profile_updated_successfully': 'Profile updated successfully!',
      'profile_created_successfully': 'Profile created successfully!',
      'error_saving_profile': 'Error saving profile',
      'profile_deleted_successfully': 'Profile deleted successfully',

      // ==================== DOCTOR PROFILE ====================
      'doctor_info': 'Doctor Information',
      'specialization': 'Specialization',
      'enter_specialization': 'Enter specialization',
      'experience': 'Years of Experience',
      'enter_experience': 'Enter years of experience',
      'license': 'Professional License',
      'enter_license': 'Enter professional license number',
      'clinic_address': 'Clinic Address',
      'enter_clinic_address': 'Enter clinic address',
      'working_hours': 'Working Hours',
      'enter_working_hours': 'Enter working hours',

      // ==================== STAGES ====================
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

      // ==================== PROGRESS ====================
      'your_progress': 'Your Progress',
      'overall_progress': 'Overall Progress',
      'achievements': 'Achievements',
      'completed': 'Completed',
      'in_progress': 'In Progress',
      'not_started': 'Not Started',
      'progress_reports': 'Progress Reports',
      'view_details': 'View Details',
      'no_progress_data': 'No progress data',
      'start_learning': 'Start Learning',

      // ==================== SETTINGS ====================
      'settings': 'Settings',
      'language_audio': 'Language & Audio',
      'accessibility': 'Accessibility',
      'parental_controls': 'Parental Controls',
      'language': 'Language',
      'arabic': 'العربية',
      'english': 'English',
      'voice_speed': 'Voice Speed',
      'volume': 'Volume',
      'high_contrast': 'High Contrast',
      'large_text': 'Large Text',
      'audio_instructions': 'Audio Instructions',
      'background_music': 'Background Music',
      'sound_effects': 'Sound Effects',
      'notifications': 'Notifications',
      'daily_reminders': 'Daily Reminders',
      'progress_alerts': 'Progress Alerts',
      'achievement_notifications': 'Achievement Notifications',
      'privacy': 'Privacy',
      'terms_conditions': 'Terms & Conditions',
      'help_support': 'Help & Support',
      'contact_us': 'Contact Us',
      'faq': 'FAQ',
      'version': 'Version',
      'build_number': 'Build Number',

      // ==================== ACTIVITY SCREENS ====================
      'tap_on_correct_answer': 'Tap on the correct answer',
      'great_job': 'Great job!',
      'correct': 'Correct!',
      'incorrect': 'Incorrect',
      'lesson_complete': 'Lesson complete!',
      'next_lesson': 'Next Lesson',
      'repeat_lesson': 'Repeat Lesson',
      'score': 'Score',
      'time': 'Time',
      'attempts': 'Attempts',
      'accuracy': 'Accuracy',
      'hint': 'Hint',
      'skip_question': 'Skip Question',
      'listen_carefully': 'Listen carefully',
      'watch_carefully': 'Watch carefully',
      'choose_correct_option': 'Choose the correct option',
      'drag_and_drop': 'Drag and Drop',
      'match_items': 'Match Items',
      'sort_items': 'Sort Items',
      'complete_pattern': 'Complete Pattern',
      'remember_sequence': 'Remember Sequence',

      // ==================== COMMON PHRASES ====================
      'welcome': 'Welcome',
      'welcome_back': 'Welcome back',
      'good_morning': 'Good morning',
      'learning_stages': 'Learning Stages',
      'ask_rafik': 'Ask Rafik',
      'view_progress_reports': 'View Progress Reports',
      'stage': 'Stage',
      'child_name': 'Ali',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'have_fun': 'Have fun!',
      'keep_going': 'Keep going!',
      'you_can_do_it': 'You can do it!',
      'excellent_work': 'Excellent work!',
      'well_done': 'Well done!',
      'fantastic': 'Fantastic!',
      'amazing': 'Amazing!',
      'wonderful': 'Wonderful!',
      'brilliant': 'Brilliant!',
      'outstanding': 'Outstanding!',
      'perfect': 'Perfect!',
      'superb': 'Superb!',
      'magnificent': 'Magnificent!',
      'splendid': 'Splendid!',
      'terrific': 'Terrific!',
      'awesome': 'Awesome!',
      'cool': 'Cool!',
      'nice': 'Nice!',
      'good': 'Good!',
      'very_good': 'Very good!',
      'great': 'Great!',
      'very_great': 'Very great!',

      // Activity Details
      'my_home': 'My Home',
      'my_school': 'My School',
      'my_bathroom': 'My Bathroom',
      'my_kitchen': 'My Kitchen',
      'my_bedroom': 'My Bedroom',
      'my_playroom': 'My Playroom',
      'teddy_bear': 'Teddy Bear',
      'building_blocks': 'Building Blocks',
      'passing_ball': 'Passing the Ball',
      'building_together': 'Building Together',
      'group_activity': 'Group Activity',
      'asking_to_join_play': 'Asking to Join Play',
      'sharing_toys': 'Sharing Toys',
      'starting_game': 'Starting a Game',
      'how_are_you': 'How are you?',
      'what_is_name': 'What is your name?',
      'how_old': 'How old are you?',

      // Button Text
      'start_activity': 'Start Activity',
      'start_practice': 'Start Practice',
      'listen': 'Listen',
      'record': 'Record',
      'recording': 'Recording...',
      'recorded': 'Recorded',
      'create_profile': 'Create Profile',
      'doctor_registration': 'Doctor Registration',
      'confirm_password': 'Confirm password',

      // Progress Screen
      'social_recognition': 'Social Recognition',
      'social_interaction': 'Social Interaction',
      'social_communication': 'Social Communication',
      'first_conversation': 'First Conversation',
      'total_progress': 'Total Progress',
      'days_active': 'Days Active',
      'weekly_activity': 'Weekly Activity',
      'stage_progress': 'Stage Progress',
      'recent_achievements': 'Recent Achievements',
      'child_journey': 'Child\'s journey',

      // Settings
      'better_visibility': 'Better visibility',
      'app_version': 'App Version',
      'last_updated': 'Last Updated',
      'privacy_policy': 'Privacy Policy',

      // Age Calculation
      'age_calculated_automatically': 'Calculated automatically',
      'select_birth_date': 'Select birth date',

      // Interaction Steps
      'learn_ask_children_play':
          'Learn to ask other children if you can play with them',
      'walk_up_children_playing': 'Walk up to the children playing',
      'make_eye_contact_smile': 'Make eye contact and smile',
      'say_can_play': 'Say: "Can I play with you?"',
      'wait_response': 'Wait for their response',
      'learn_offer_share_toys':
          'Learn to offer and share your toys with friends',
      'hold_toy_share': 'Hold the toy you want to share',
      'approach_friend': 'Approach your friend',
      'say_want_play': 'Say: "Do you want to play with this?"',
      'hand_toy_smile': 'Hand them the toy with a smile',
      'learn_invite_start_activity':
          'Learn to invite others to start a new activity',
      'think_fun_game': 'Think of a fun game',
      'find_friends_play': 'Find friends who might want to play',
      'say_play_together': 'Say: "Let\'s play together!"',
      'explain_game_rules': 'Explain the game rules',
      'steps_follow': 'Steps to follow:',
      'be_first_reach_out': 'Be the First to Reach Out!',
      'practice_interactions':
          'Practice starting interactions with others. Don\'t wait to be invited - take the first step!',

      // ==================== ERRORS & MESSAGES ====================
      'network_error': 'Network error',
      'no_internet': 'No internet connection',
      'server_error': 'Server error',
      'something_went_wrong': 'Something went wrong',
      'please_try_later': 'Please try again later',
      'invalid_credentials': 'Invalid credentials',
      'access_denied': 'Access denied',
      'file_not_found': 'File not found',
      'invalid_file': 'Invalid file',
      'upload_failed': 'Upload failed',
      'download_failed': 'Download failed',
      'operation_failed': 'Operation failed',
      'session_expired': 'Session expired',
      'login_required': 'Login required',
      'permission_denied': 'Permission denied',
      'feature_not_available': 'Feature not available',
      'coming_soon': 'Coming soon',
      'under_construction': 'Under construction',
      'maintenance_mode': 'Maintenance mode',
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

  /// Get all available locales
  static List<String> get availableLocales {
    return translations.keys.toList();
  }

  /// Get supported languages display names
  static Map<String, String> get supportedLanguages {
    return {
      'ar': t('arabic', locale: 'ar'),
      'en': t('english', locale: 'en'),
    };
  }
}
