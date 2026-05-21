import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'screens/doctor_registration_screen.dart';
import 'screens/setting_cild_screen.dart';
import 'widgets/custom_widgets.dart';
import 'models/models.dart';

import 'screens/onboarding_screen.dart';

import 'screens/role_selection_screen.dart';

import 'screens/child_profile_screen.dart';

import 'screens/child_profile_view_screen.dart';

import 'screens/doctor_profile_view_screen.dart';

import 'screens/edit_doctor_profile_screen.dart';

import 'screens/child_login_screen.dart';

import 'screens/child_detail_screen.dart';

import 'screens/edit_child_profile_screen.dart';

import 'screens/doctor_login_screen.dart';

import 'screens/doctor_dashboard_screen.dart';

import 'screens/home_dashboard_screen.dart';

import 'screens/stage1_recognizing_people_screen.dart';

import 'screens/stage1_recognizing_places_screen.dart';

import 'screens/stage1_recognizing_objects_screen.dart';

import 'screens/stage2_social_gestures_screen.dart';

import 'screens/stage2_cooperative_play_screen.dart';

import 'screens/stage3_starting_conversation_screen.dart';

import 'screens/smart_gallery_screen.dart';

import 'screens/stage3_initiating_interaction_screen.dart';
import 'screens/turn_taking_game_screen.dart';

import 'screens/progress_reports_screen.dart';

import 'screens/settings_screen.dart';

import 'screens/chat_screen.dart';

import 'screens/test_people_recognition_screen.dart';

import 'screens/test_places_recognition_screen.dart';

import 'screens/test_objects_recognition_screen.dart';

import 'screens/behavior_assessment_screen.dart';

import 'screens/behavior_training_screen.dart';

import 'theme/app_theme.dart';

import 'providers/app_state.dart';

import 'providers/progress_provider.dart';

import 'services/service_locator.dart';

import 'l10n/localization_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // App Check can be initialized after the app starts or in background
    FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  }

  // Then setup service locator (after Firebase is ready)
  await ServiceLocator.setup();

  runApp(const SocialStepsApp());
}

class SocialStepsApp extends StatelessWidget {
  const SocialStepsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(
          create: (_) => ServiceLocator.getAppState(),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ServiceLocator.getProgressProvider(),
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'SocialSteps - Therapeutic Learning',

            debugShowCheckedModeBanner: false,

            // Theming

            theme: AppTheme.lightTheme,

            darkTheme: AppTheme.darkTheme,

            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Localization

            localizationsDelegates: const [
              LocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],

            locale: Locale(appState.currentLanguage),

            // RTL/LTR support

            builder: (context, child) {
              return Directionality(
                textDirection: appState.currentLanguage == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: ConstrainedPage(
                  maxWidth: 900,
                  child: child!,
                ),
              );
            },

            // Navigation with animations

            initialRoute: appState.isLoggedIn ? '/home' : '/',
            home: appState.isLoggedIn
                ? const HomeDashboardScreen()
                : const OnboardingScreen(),

            onGenerateRoute: (settings) {
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  Widget screen;
                  switch (settings.name) {
                    case '/':
                      screen = const OnboardingScreen();
                      break;
                    case '/doctor-registration':
                      screen = const DoctorRegistrationScreen();
                      break;
                    case '/role-selection':
                      screen = const RoleSelectionScreen();
                      break;
                    case '/child-profile':
                      screen = const ChildProfileScreen();
                      break;
                    case '/child-login':
                      screen = const ChildLoginScreen();
                      break;
                    case '/child-detail':
                      final args = settings.arguments;
                      if (args is ChildProfile) {
                        screen = ChildDetailScreen(child: args);
                      } else {
                        screen = ChildDetailScreen(
                            child: ChildProfile(
                          fullName: '',
                          username: '',
                          password: '',
                          age: 0,
                          dateOfBirth: DateTime.now(),
                          gender: '',
                          governorate: '',
                          healthStatus: '',
                          iqLevel: '',
                          school: '',
                          doctorId: '',
                        ));
                      }
                      break;
                    case '/setting_cild':
                      screen = const SettingCildScreen();
                      break;
                    case '/edit-child-profile':
                      final args = settings.arguments;
                      if (args is ChildProfile) {
                        screen = EditChildProfileScreen(childProfile: args);
                      } else {
                        screen = EditChildProfileScreen(
                            childProfile: ChildProfile(
                          fullName: '',
                          username: '',
                          password: '',
                          age: 0,
                          dateOfBirth: DateTime.now(),
                          gender: '',
                          governorate: '',
                          healthStatus: '',
                          iqLevel: '',
                          school: '',
                          doctorId: '',
                        ));
                      }
                      break;
                    case '/child-profile-view':
                      screen =
                          const ChildProfileViewScreen(doctorProfile: null);
                      break;
                    case '/doctor-profile-view':
                      screen =
                          const DoctorProfileViewScreen(doctorProfile: null);
                      break;
                    case '/edit-doctor-profile':
                      final args = settings.arguments;
                      if (args is DoctorProfile) {
                        screen = EditDoctorProfileScreen(doctorProfile: args);
                      } else {
                        screen = EditDoctorProfileScreen(
                            doctorProfile: DoctorProfile(
                          id: '',
                          fullName: '',
                          username: '',
                          password: '',
                          email: '',
                          phone: '',
                          specialization: '',
                        ));
                      }
                      break;
                    case '/doctor-login':
                      screen = const DoctorLoginScreen();
                      break;
                    case '/doctor-dashboard':
                      screen = const DoctorDashboardScreen();
                      break;
                    case '/home':
                      screen = const HomeDashboardScreen();
                      break;
                    case '/home-dashboard':
                      screen = const HomeDashboardScreen();
                      break;
                    case '/recognizing-people':
                      screen = const RecognizingPeopleScreen();
                      break;
                    case '/recognizing-places':
                      screen = const RecognizingPlacesScreen();
                      break;
                    case '/recognizing-objects':
                      screen = const RecognizingObjectsScreen();
                      break;
                    case '/social-gestures':
                      screen = const SocialGesturesScreen();
                      break;
                    case '/cooperative-play':
                      screen = const CooperativePlayScreen();
                      break;
                    case '/stage3-starting-conversation':
                      screen = const StartingConversationScreen();
                      break;
                    case '/smart-gallery':
                      screen = const SmartGalleryScreen();
                      break;
                    case '/initiating-interaction':
                      screen = const InitiatingInteractionScreen();
                      break;
                    case '/test-people':
                      screen = const TestPeopleRecognitionScreen();
                      break;
                    case '/test-places':
                      screen = const TestPlacesRecognitionScreen();
                      break;
                    case '/test-objects':
                      screen = const TestObjectsRecognitionScreen();
                      break;
                    case '/behavior-assessment':
                      final args = settings.arguments;
                      if (args is ChildProfile) {
                        screen = BehaviorAssessmentScreen(childProfile: args);
                      } else {
                        screen = BehaviorAssessmentScreen(
                          childProfile: ChildProfile(
                            fullName: '',
                            username: '',
                            password: '',
                            age: 0,
                            dateOfBirth: DateTime.now(),
                            gender: '',
                            governorate: '',
                            healthStatus: '',
                            iqLevel: '',
                            school: '',
                            doctorId: '',
                          ),
                        );
                      }
                      break;
                    case '/behavior-training':
                      screen = const BehaviorTrainingScreen();
                      break;
                    case '/turn-taking-game':
                      screen = TurnTakingGameScreen();
                      break;
                    case '/chat':
                      screen = const ChatScreen();
                      break;
                    case '/settings':
                      screen = const SettingsScreen();
                      break;
                    case '/progress-reports':
                      screen = const ProgressReportsScreen();
                      break;
                    default:
                      screen = const OnboardingScreen();
                  }
                  return screen;
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  // Use Shared Axis transition for smooth RTL-friendly animations
                  final isRtl = Directionality.of(context) == TextDirection.rtl;
                  final beginOffset =
                      isRtl ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0);

                  var tween = Tween(begin: beginOffset, end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOutCubic));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              );
            },
          );
        },
      ),
    );
  }
}
