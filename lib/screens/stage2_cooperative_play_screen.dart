import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/session_tracker.dart';
import '../widgets/custom_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import 'turn_taking_game_screen.dart';
import 'building_game_screen.dart';
import 'collaborative_painting_screen.dart';

/// Stage 2B: Cooperative Play Screen
/// مشاهدات جماعية للعب التعاوني والأنشطة
class CooperativePlayScreen extends StatefulWidget {
  const CooperativePlayScreen({Key? key}) : super(key: key);

  @override
  State<CooperativePlayScreen> createState() => _CooperativePlayScreenState();
}

class _CooperativePlayScreenState extends State<CooperativePlayScreen> {
  late SessionTracker _sessionTracker;

  @override
  void initState() {
    super.initState();
    _sessionTracker =
        SessionTracker(stageNumber: 2, activityName: 'Cooperative Play');
    _sessionTracker.startSession();
  }

  @override
  void dispose() {
    _sessionTracker.endSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    final activities = [
      CooperativeActivity(
        id: 'passing-ball',
        title: AppLocalizations.t('passing_ball', locale: currentLanguage),
        description: AppLocalizations.t('learn_take_turns_pass_ball',
            locale: currentLanguage),
        imageUrl:
            'https://images.unsplash.com/photo-1629839423284-9499d8aa4857?w=600',
        participants: 3,
        duration: '5',
      ),
      CooperativeActivity(
        id: 'building-together',
        title: AppLocalizations.t('building_together', locale: currentLanguage),
        description: AppLocalizations.t('work_team_build_amazing',
            locale: currentLanguage),
        imageUrl:
            'https://images.unsplash.com/photo-1758598738033-2368946ce823?w=600',
        participants: 4,
        duration: '10',
      ),
      CooperativeActivity(
        id: 'group-activity',
        title: AppLocalizations.t('group_activity', locale: currentLanguage),
        description: AppLocalizations.t('join_fun_activities_children',
            locale: currentLanguage),
        imageUrl:
            'https://images.unsplash.com/photo-1767858898988-ba0fa7a6c22f?w=600',
        participants: 5,
        duration: '15',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: CustomAppBar(
        title: AppLocalizations.t('cooperative_play', locale: currentLanguage),
        subtitle:
            AppLocalizations.t('learn_play_others', locale: currentLanguage),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // لافتة معلومات
          GradientCard(
            gradient: AppTheme.bluePurpleGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.t('play_learn_together',
                          locale: currentLanguage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.t('cooperative_play_description',
                      locale: currentLanguage),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),


          // الأنشطة
          ...activities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ActivityCard(activity: activity),
              )),
        ],
      ),
    );
  }
}

/// بطاقة النشطة
class _ActivityCard extends StatelessWidget {
  final CooperativeActivity activity;

  const _ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الصورة مع تراكب متدرج
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  activity.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.people,
                          '${activity.participants} ${AppLocalizations.t('children', locale: currentLanguage)}',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.access_time,
                            '${activity.duration} ${AppLocalizations.t('min', locale: currentLanguage)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // زر البدء
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              text:
                  AppLocalizations.t('start_activity', locale: currentLanguage),
              onPressed: () {
                // Log start_activity
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  FirebaseService().logLearningActivity(
                    childId: user.uid,
                    activityType: 'start_game',
                    itemName: activity.title,
                    category: 'cooperative_play',
                  );
                }

                if (activity.id == 'building-together') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BuildingGameScreen()),
                  );
                } else if (activity.id == 'passing-ball') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TurnTakingGameScreen()),
                  );
                } else if (activity.id == 'group-activity') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CollaborativePaintingScreen()),
                  );
                } else {
                  // TODO: بدء الفيديو للأنواع الأخرى
                }
              },
              icon: Icons.play_arrow_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// نموذج النشاط التعاوني
class CooperativeActivity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final String duration;

  CooperativeActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.duration,
  });
}

/// 🎮 بطاقة لعبة دوري مين؟
class _TurnTakingGameCard extends StatefulWidget {
  @override
  State<_TurnTakingGameCard> createState() => _TurnTakingGameCardState();
}

class _TurnTakingGameCardState extends State<_TurnTakingGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TurnTakingGameScreen()),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1a237e), Color(0xFF1565C0), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Emojis
              const Column(
                children: [
                  Text('🎮', style: TextStyle(fontSize: 36)),
                  SizedBox(height: 4),
                  Text('⚽🏀🎁🎵', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(width: 16),
              // Text info
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دوري مين؟ 🌟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'تعلم الانتظار والمشاركة مع الأصدقاء',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _PillChip(label: '4 مستويات', icon: Icons.bar_chart),
                        SizedBox(width: 8),
                        _PillChip(
                            label: 'نجوم ومكافآت', icon: Icons.star_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PillChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
