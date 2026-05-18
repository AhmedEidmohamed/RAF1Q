import 'package:flutter/material.dart';
import '../services/session_tracker.dart';
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

/// Stage 3B: Initiating Interaction Screen
/// Interactive scenarios for initiating play and conversation
class InitiatingInteractionScreen extends StatefulWidget {
  const InitiatingInteractionScreen({Key? key}) : super(key: key);

  @override
  State<InitiatingInteractionScreen> createState() =>
      _InitiatingInteractionScreenState();
}

class _InitiatingInteractionScreenState extends State<InitiatingInteractionScreen> {
  late SessionTracker _sessionTracker;

  @override
  void initState() {
    super.initState();
    _sessionTracker = SessionTracker(stageNumber: 3, activityName: 'Initiating Interaction');
    _sessionTracker.startSession();
  }

  @override
  void dispose() {
    _sessionTracker.endSession();
    super.dispose();
  }
  final Map<String, bool> _completed = {};

  void _startScenario(String scenarioId) {
    // Log view_item activity
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService().logLearningActivity(
        childId: user.uid,
        activityType: 'view_item',
        itemName: scenarioId, // Ideally get the actual title but ID is better than nothing
        category: 'social_interaction',
      );
    }

    // Simulate completion
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _completed[scenarioId] = true;
        });

        // Log quiz_success (scenario completion)
        if (user != null) {
          FirebaseService().logLearningActivity(
            childId: user.uid,
            activityType: 'quiz_success',
            itemName: scenarioId,
            category: 'social_interaction',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    final List<InteractionScenario> scenarios = [
      InteractionScenario(
        id: 'asking-to-join',
        title:
            AppLocalizations.t('asking_to_join_play', locale: currentLanguage),
        description: AppLocalizations.t('learn_ask_children_play',
            locale: currentLanguage),
        imageUrl:
            'https://images.unsplash.com/photo-1629839423284-9499d8aa4857?w=600',
        steps: [
          AppLocalizations.t('walk_up_children_playing',
              locale: currentLanguage),
          AppLocalizations.t('make_eye_contact_smile', locale: currentLanguage),
          AppLocalizations.t('say_can_play', locale: currentLanguage),
          AppLocalizations.t('wait_response', locale: currentLanguage),
        ],
      ),
      InteractionScenario(
        id: 'sharing-toys',
        title: AppLocalizations.t('sharing_toys', locale: currentLanguage),
        description: AppLocalizations.t('learn_offer_share_toys',
            locale: currentLanguage),
        imageUrl:
            'https://images.unsplash.com/photo-1758598738033-2368946ce823?w=600',
        steps: [
          AppLocalizations.t('hold_toy_share', locale: currentLanguage),
          AppLocalizations.t('approach_friend', locale: currentLanguage),
          AppLocalizations.t('say_want_play', locale: currentLanguage),
          AppLocalizations.t('hand_toy_smile', locale: currentLanguage),
        ],
      ),
      InteractionScenario(
        id: 'starting-game',
        title: AppLocalizations.t('starting_game', locale: currentLanguage),
        description: AppLocalizations.t('learn_invite_start_activity',
            locale: currentLanguage),
        imageUrl:
            'https://images.unsplash.com/photo-1767858898988-ba0fa7a6c22f?w=600',
        steps: [
          AppLocalizations.t('think_fun_game', locale: currentLanguage),
          AppLocalizations.t('find_friends_play', locale: currentLanguage),
          AppLocalizations.t('say_play_together', locale: currentLanguage),
          AppLocalizations.t('explain_game_rules', locale: currentLanguage),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: CustomAppBar(
        title: AppLocalizations.t('initiating_interaction',
            locale: currentLanguage),
        subtitle: AppLocalizations.t('learn_start_interactions',
            locale: currentLanguage),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Info Banner
          GradientCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF007aff), Color(0xFF0088ff)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t('be_first_reach_out',
                      locale: currentLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.t('practice_interactions',
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

          // Scenarios
          ...List.generate(
            scenarios.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ScenarioCard(
                scenario: scenarios[index],
                isCompleted: _completed[scenarios[index].id] ?? false,
                onStart: () => _startScenario(scenarios[index].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scenario Card Widget
class _ScenarioCard extends StatelessWidget {
  final InteractionScenario scenario;
  final bool isCompleted;
  final VoidCallback onStart;

  const _ScenarioCard({
    Key? key,
    required this.scenario,
    required this.isCompleted,
    required this.onStart,
  }) : super(key: key);

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
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  scenario.imageUrl,
                  height: 190,
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
              if (isCompleted)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECC94B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
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
                      scenario.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Steps
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.t('steps_follow',
                            locale: currentLanguage),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B21A8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        scenario.steps.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDDD6FE),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B21A8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  scenario.steps[index],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B21A8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Start Button
                GradientButton(
                  text: isCompleted
                      ? AppLocalizations.t('completed', locale: currentLanguage)
                      : AppLocalizations.t('start_practice',
                          locale: currentLanguage),
                  onPressed: isCompleted ? () {} : onStart,
                  icon: isCompleted ? Icons.star : Icons.play_arrow_rounded,
                  gradient: isCompleted
                      ? const LinearGradient(
                          colors: [Color(0xFF48BB78), Color(0xFF38A169)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF007aff), Color(0xFF0088ff)],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Interaction Scenario Model
class InteractionScenario {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> steps;

  InteractionScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.steps,
  });
}
