import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:camera/camera.dart';
import '../widgets/global_chat_fab.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import 'progress_reports_screen.dart';
import 'stage3_starting_conversation_screen.dart';
import '../services/emotion_tracker_service.dart';
import 'assessment_screen.dart';
import '../widgets/custom_widgets.dart';
import 'stage1_dashboard_screen.dart';
import 'stage2_dashboard_screen.dart';
import 'stage3_starting_conversation_screen.dart';
import 'vineland_assessment_screen.dart';
import 'gars_assessment_screen.dart';

/// Home Dashboard Screen
/// Shows three learning stages with progress
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ChildProfile? _childProfile;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  int _unlockedStagesCount = 3;

  // Keys for scrolling to sections
  final GlobalKey _stage1Key = GlobalKey();
  final GlobalKey _stage2Key = GlobalKey();
  final GlobalKey _stage3Key = GlobalKey();

  late ConfettiController _confettiController;
  late AnimationController _robotAnimationController;
  late Animation<double> _robotAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _robotAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _robotAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
          parent: _robotAnimationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkChildProfile();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    _robotAnimationController.dispose();
    EmotionTrackerService().dispose();
    super.dispose();
  }

  Future<void> _checkChildProfile() async {
    try {
      await Future.delayed(const Duration(
          milliseconds: 100)); // Small delay to ensure state is updated

      final prefs = await SharedPreferences.getInstance();
      // Try to get any child profile (check for current user first)
      final appState = Provider.of<AppState>(context, listen: false);
      final currentUsername = appState.childName ?? '';

      String? childProfileJson;

      // First try with current username
      if (currentUsername.isNotEmpty) {
        childProfileJson = prefs.getString('child_profile_$currentUsername');
      }

      // If not found, fetch from Firestore
      if (childProfileJson == null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('children')
              .doc(user.uid)
              .get();
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            final profile = ChildProfile(
              fullName: data['name'] ?? user.displayName ?? '',
              username: data['username'] ?? '',
              password: '',
              age: int.tryParse(data['age']?.toString() ?? '0') ?? 0,
              dateOfBirth: DateTime.now(),
              gender: data['gender'] ?? '',
              governorate: data['governorate'] ?? '',
              healthStatus: data['healthStatus'] ?? '',
              doctorId: data['doctorId'] ?? '',
            );
            _childProfile = profile;

            // Set in app state
            appState.setChildName(profile.fullName);
            appState.setChildAge(profile.age);
          }
        }
      }

      if (childProfileJson != null) {
        final childData = jsonDecode(childProfileJson);
        _childProfile = ChildProfile.fromMap(childData);
      }

      // Check Assessment Status from Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('children')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['assessment_completed'] != true) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssessmentScreen()),
              );
            }
            return;
          }
          if (mounted) {
            setState(() {
              _unlockedStagesCount = data['unlocked_stages'] ?? 3;
            });
          }
        }
      }
    } catch (e) {
      // Error loading profile, continue without redirecting
      debugPrint('Error loading child profile: $e');
    }
  }

  // _initEmotionTracking was removed

  void _scrollToSection(GlobalKey key, int index) {
    setState(() {
      _selectedIndex = index;
    });
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;
    final appState = Provider.of<AppState>(context);

    // Get child name from profile, Firebase Auth, or fallback to localization
    String childName = _childProfile?.fullName ??
        appState.childName ??
        FirebaseAuth.instance.currentUser?.displayName ??
        AppLocalizations.t('child_name', locale: currentLanguage);

    final currentUser = FirebaseAuth.instance.currentUser;

    // Fetch real progress from Firestore instead of static values
    return StreamBuilder<QuerySnapshot>(
      stream: currentUser != null
          ? FirebaseFirestore.instance
              .collection('children')
              .doc(currentUser.uid)
              .collection('stage_progress')
              .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        Map<int, double> stageProgressMap = {1: 0.0, 2: 0.0, 3: 0.0};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final stageNum = data['stageNumber'] as int?;
            if (stageNum != null) {
              // Calculate progress: 60 minutes = 100% for now
              double minutes = (data['totalMinutes'] ?? 0).toDouble();
              stageProgressMap[stageNum] = (minutes / 60).clamp(0.0, 1.0);
            }
          }
        }

        final stages = [
          StageData(
            number: 1,
            title: "التعارف",
            description: AppLocalizations.t('stage_1_desc', locale: currentLanguage),
            icon: Icons.visibility_rounded,
            progress: stageProgressMap[1]!,
            color: AppTheme.primaryBlue,
            routes: ['/recognizing-people', '/recognizing-places', '/recognizing-objects'],
            routeLabels: [
              AppLocalizations.t('recognizing_people', locale: currentLanguage),
              AppLocalizations.t('recognizing_places', locale: currentLanguage),
              AppLocalizations.t('recognizing_objects', locale: currentLanguage),
            ],
          ),
          StageData(
            number: 2,
            title: "التواصل",
            description: AppLocalizations.t('stage_2_desc', locale: currentLanguage),
            icon: Icons.people_rounded,
            progress: stageProgressMap[2]!,
            color: AppTheme.primaryBlue,
            routes: ['/social-gestures', '/cooperative-play'],
            routeLabels: [
              AppLocalizations.t('social_gestures', locale: currentLanguage),
              AppLocalizations.t('cooperative_play', locale: currentLanguage),
            ],
          ),
          StageData(
            number: 3,
            title: "التفاعل",
            description: AppLocalizations.t('stage_3_desc', locale: currentLanguage),
            icon: Icons.chat_bubble_rounded,
            progress: stageProgressMap[3]!,
            color: AppTheme.primaryPink,
            routes: ['/stage3-starting-conversation', '/initiating-interaction'],
            routeLabels: [
              AppLocalizations.t('starting_conversation', locale: currentLanguage),
              AppLocalizations.t('initiating_interaction', locale: currentLanguage),
            ],
          ),
        ];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          endDrawer:
              _buildDrawer(context, appState, currentLanguage, childName),
          floatingActionButton: const GlobalChatFAB(),
          body: ConstrainedPage(
            maxWidth: 800, // Slightly wider for dashboard
            child: Stack(
              children: [
                // Background Animated Blobs (Simplified Mesh Gradient)
                Positioned(
                  top: -100,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                SafeArea(
                  child: _selectedIndex == 1 
                      ? const Stage1DashboardScreen()
                      : _selectedIndex == 2
                          ? const Stage2DashboardScreen()
                          : _selectedIndex == 3
                              ? const StartingConversationScreen()
                              : SingleChildScrollView(
                                  controller: _scrollController,
                          child: Column(
                      children: [
                        // Header
                        Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.bluePurpleGradient,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40)),
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 27),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              AppLocalizations.t('welcome',
                                                  locale: currentLanguage),
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 16)),
                                          const SizedBox(height: 4),
                                          Text(childName,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Premium 3D Robot Avatar with Floating Animation
                                  AnimatedBuilder(
                                    animation: _robotAnimation,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, _robotAnimation.value),
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color:
                                                    Colors.white.withOpacity(0.5),
                                                width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.black.withOpacity(0.1),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/robot_avatar.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // ... menu icon removed from here if it overflows, or kept
                                  IconButton(
                                      icon: const Icon(Icons.menu_rounded,
                                          color: Colors.white, size: 32),
                                      onPressed: () => _scaffoldKey.currentState
                                          ?.openEndDrawer()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stage 1
                        _buildStageContent(stages[0], currentLanguage, 1,
                            key: _stage1Key),

                        // Stage 2
                        _buildStageContent(stages[1], currentLanguage, 2,
                            key: _stage2Key),

                        // Stage 3
                        _buildStageContent(stages[2], currentLanguage, 3,
                            key: _stage3Key),

                        const SizedBox(height: 16),
                        _buildAdditionalSections(),

                        const SizedBox(
                            height:
                                80), // Padding at bottom for BottomNavigationBar
                      ],
                    ),
                  ),
                ),

                // Confetti Overlay
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: ConstrainedPage(
            maxWidth: 800,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: AppTheme.primaryBlue,
                color: Colors.grey[600]!,
                tabs: const [
                  GButton(
                    icon: Icons.grid_view_rounded,
                    text: 'الرئيسية',
                  ),
                  GButton(
                    icon: Icons.fingerprint,
                    text: 'التعرف',
                  ),
                  GButton(
                    icon: Icons.track_changes_rounded,
                    text: 'التفاعل',
                  ),
                  GButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    text: 'التواصل',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  if (index != 0 && index > _unlockedStagesCount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('هذه المرحلة مقفلة حالياً. يرجى إكمال المراحل السابقة أولاً.'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Force rebuild to revert the visual selection in GNav
                    setState(() {});
                    return;
                  }

                  setState(() => _selectedIndex = index);
                  if (index == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      }
                    });
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, AppState appState,
      String currentLanguage, String childName) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: AppTheme.bluePurpleGradient,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/robot_avatar.png',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  childName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'تعديل الملف الشخصي',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/setting_cild');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'الصفحة الرئيسية',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'التقارير',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/progress-reports');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.smart_toy_outlined,
                  title: 'المساعد الذكي',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chat');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'حول التطبيق',
                  onTap: () {
                    Navigator.pop(context);
                    // Add About screen logic if exists
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  color: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    await appState.logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/child-login', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_left_rounded, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildAdditionalSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Parents Guide Banner
          _buildParentsGuideCard(),
          const SizedBox(height: 24),
          // Tests and Evaluation Header
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'الاختبارات والتقييم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Test Cards
          _buildTestCard(
            title: 'الاختبار الأول',
            description: 'يقيس شدة أعراض التوحد من خلال ملاحظة سلوك الطفل في مجالات: التفاعل الاجتماعي، التواصل (اللفظي وغير اللفظي)، والاستجابة للبيئة المحيطة.',
            icon: Icons.bar_chart_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssessmentScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'الاختبار الثاني',
            description: 'يستخدم كأداة تشخيصية أولية، يركز على 3 مجالات رئيسية: السلوكيات التكرارية (الحركات الروتينية)، التواصل، والتفاعل الاجتماعي.',
            icon: Icons.inbox_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VinelandAssessmentScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            title: 'الاختبار الثالث',
            description: 'يستخدم كاختبار مسح مبكر، يركز على: تطور اللغة، التواصل البصري، الانتباه، والاستجابة لنداء الآخرين.',
            icon: Icons.assignment_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GarsAssessmentScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParentsGuideCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إرشادات الوالدين لتحسين سلوك الطفل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'دليل شامل يساعد الوالدين في فهم سلوكيات الطفل وتقديم التدخل المناسب بأساليب علمية ومبسطة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3B67E9), // Similar blue to image
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B67E9).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent(
      StageData stage, String currentLanguage, int stageIndex,
      {Key? key}) {
    bool isLocked = stageIndex > _unlockedStagesCount;
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Opacity(
        opacity: isLocked ? 0.7 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.t('stage', locale: currentLanguage)} ${stage.number}: ${stage.title}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Stage Header
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        stage.number == 1
                            ? 'assets/images/recognition_hero.png'
                            : stage.number == 2
                                ? 'assets/images/interaction_hero.png'
                                : 'assets/images/communication_hero.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.t('overall_progress',
                              locale: currentLanguage),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stage.progress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(stage.color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(stage.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: stage.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activities List
                  Text(
                    AppLocalizations.t('activities', locale: currentLanguage),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stage.routes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildActivityChip(
                        stage.routeLabels[index],
                        stage.routes[index],
                        stage.color,
                        isLocked,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChip(
      String label, String route, Color color, bool isLocked) {
    return InkWell(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'هذه المرحلة مغلقة حالياً بناءً على تقييم الطفل. يرجى إكمال المراحل السابقة أولاً.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          : () {
              if (route == '/stage3-starting-conversation') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StartingConversationScreen()),
                );
              } else {
                Navigator.of(context).pushNamed(route);
              }
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (isLocked)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child:
                    Icon(Icons.lock_rounded, size: 16, color: Colors.grey[600]),
              ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: color.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stage Data Model
class StageData {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final Color color;
  final List<String> routes;
  final List<String> routeLabels;

  StageData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.color,
    required this.routes,
    required this.routeLabels,
  });
}
