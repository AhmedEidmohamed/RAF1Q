import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/global_chat_fab.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Behavior Training Screen
/// شاشة التدريب السلوكي بناءً على نتيجة التقييم
class BehaviorTrainingScreen extends StatefulWidget {
  const BehaviorTrainingScreen({Key? key}) : super(key: key);

  @override
  State<BehaviorTrainingScreen> createState() => _BehaviorTrainingScreenState();
}

class _BehaviorTrainingScreenState extends State<BehaviorTrainingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _speechController;

  ChildProfile? _childProfile;
  Map<String, dynamic>? _assessmentResult;
  Map<String, dynamic>? _trainingPlan;

  bool _isPlaying = false;
  bool _isTrainingCompleted = false;
  int _currentStep = 0;

  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _speechController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _animationController.forward();
    });
  }

  void _initializeTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("ar-EG");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _loadData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _childProfile = args['childProfile'] as ChildProfile?;
        _assessmentResult = args['assessmentResult'] as Map<String, dynamic>?;
        _trainingPlan = _generateTrainingPlan();
      });
    }
  }

  Map<String, dynamic>? _generateTrainingPlan() {
    if (_assessmentResult == null) return {};

    final behavior = _assessmentResult!['behavior'] as String?;
    final function = _assessmentResult!['predicted_function'] as String?;
    final severity = _assessmentResult!['severity'] as String?;

    // Simple training plan generation (you can enhance this)
    final plans = {
      'العض': {
        'هروب': {
          'replacement_skill': 'طلب استراحة',
          'training_activity': 'تدريب بطاقة الاستراحة',
          'communication_phrase': 'أنا محتاج استراحة',
          'teaching_strategies': ['النمذجة', 'التدريب', 'التلقين', 'التعزيز'],
          'environmental_interventions': [
            'توفير مكان للاستراحة',
            'تعديل صعوبة المهمة'
          ],
          'reinforcements': ['نجوم', 'مدح صوتي'],
        },
        'انتباه': {
          'replacement_skill': 'طلب الانضمام',
          'training_activity': 'نشاط دور المساعد',
          'communication_phrase': 'ممكن ألعب معاكم؟',
          'teaching_strategies': ['النمذجة', 'لعب الأدوار', 'التعزيز'],
          'environmental_interventions': ['روتين منظم'],
          'reinforcements': ['تصفيق', 'مدح بصري'],
        },
        'حسي': {
          'replacement_skill': 'طلب نشاط حركي',
          'training_activity': 'نشاط حسي',
          'communication_phrase': 'عايز نشاط حركي',
          'teaching_strategies': ['الدعم البصري', 'التدريب', 'التلقين'],
          'environmental_interventions': ['أدوات حسية', 'توفير مكان للاستراحة'],
          'reinforcements': ['نجوم', 'مكافأة اختيارية'],
        },
        'شيء مادي': {
          'replacement_skill': 'طلب الشيء بأدب',
          'training_activity': 'لعبة تبادل الدور',
          'communication_phrase': 'ممكن آخده؟',
          'teaching_strategies': ['النمذجة', 'لعب الأدوار', 'التعزيز'],
          'environmental_interventions': ['جدول بصري', 'روتين منظم'],
          'reinforcements': ['نقاط', 'تصفيق'],
        },
      },
      // Add more behaviors as needed
    };

    return plans[behavior]?[function] ?? plans['العض']?['هروب'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const GlobalChatFAB(),
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(
          'التدريب السلوكي',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _trainingPlan == null
          ? const Center(child: CircularProgressIndicator())
          : _buildTrainingContent(),
    );
  }

  Widget _buildTrainingContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.05),
            const Color(0xFF764BA2).withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Progress Steps
              _buildProgressSteps(),
              const SizedBox(height: 32),

              // Training Content based on current step
              _buildStepContent(),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
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
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خطة التدريب',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'الطفل: ${_childProfile?.fullName ?? "غير محدد"}',
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
                const SizedBox(height: 16),
                Text(
                  'السلوك: ${_assessmentResult?['behavior'] ?? "غير محدد"}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'الوظيفة: ${_assessmentResult?['predicted_function'] ?? "غير محدد"}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSteps() {
    final steps = ['الجملة المستهدفة', 'النشاط التدريبي', 'التطبيق'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خطوات التدريب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              steps.length,
              (index) => Expanded(
                child: _buildStepIndicator(
                    index + 1, steps[index], index < _currentStep),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isCompleted ? const Color(0xFF667EEA) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color:
                isCompleted ? const Color(0xFF667EEA) : const Color(0xFF64748B),
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPhraseStep();
      case 1:
        return _buildActivityStep();
      case 2:
        return _buildApplicationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhraseStep() {
    final phrase = _trainingPlan?['communication_phrase'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  color: Color(0xFF667EEA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'الجملة المستهدفة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  phrase,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _speechController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Container(
                          width: 4,
                          height:
                              _speechController.value > (index * 0.2) ? 20 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _playPhrase,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying ? 'إيقاف' : '🔊 تشغيل الجملة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    final activity = _trainingPlan?['training_activity'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF667EEA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'النشاط التدريبي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'هذا النشاط مصمم لمساعدة الطفل على تعلم المهارة البديلة بطريقة ممتعة وتفاعلية.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildTeachingStrategies(),
        ],
      ),
    );
  }

  Widget _buildTeachingStrategies() {
    final strategies =
        _trainingPlan?['teaching_strategies'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'استراتيجيات التعليم:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        ...strategies.map((strategy) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF667EEA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strategy.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildApplicationStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF667EEA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'التطبيق والممارسة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ممتاز! لقد أكملت خطوات التدريب',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الآن يمكنك تطبيق هذه المهارة مع الطفل في المواقف الحقيقية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildReinforcements(),
        ],
      ),
    );
  }

  Widget _buildReinforcements() {
    final reinforcements =
        _trainingPlan?['reinforcements'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طرق التعزيز المناسبة:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reinforcements
              .map((reinforcement) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF667EEA).withOpacity(0.2)),
                    ),
                    child: Text(
                      reinforcement.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isTrainingCompleted) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded),
              SizedBox(width: 8),
              Text('العودة للرئيسية'),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64748B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 8),
                    Text('السابق'),
                  ],
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentStep < 2 ? 'التالي' : 'إنهاء'),
                  const SizedBox(width: 8),
                  Icon(_currentStep < 2 ? Icons.arrow_forward : Icons.check),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _playPhrase() async {
    final phrase = _trainingPlan?['communication_phrase'] ?? '';
    if (phrase.isEmpty) return;

    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _speechController.repeat();

      // Speak the phrase
      await _flutterTts.speak(phrase);

      // Listen for completion
      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          _speechController.stop();
          _speechController.reset();
        }
      });
    } else {
      await _flutterTts.stop();
      _speechController.stop();
      _speechController.reset();
      setState(() => _isPlaying = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      setState(() => _isTrainingCompleted = true);
      _saveTrainingCompletion();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _saveTrainingCompletion() {
    // Save training completion to app state or local storage
    final appState = Provider.of<AppState>(context, listen: false);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('تم إكمال التدريب بنجاح'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
