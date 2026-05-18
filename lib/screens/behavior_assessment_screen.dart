import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/global_chat_fab.dart';

/// Behavior Assessment Screen
/// تقييم سلوك الطفل لتحديد الخطة العلاجية المناسبة
class BehaviorAssessmentScreen extends StatefulWidget {
  final ChildProfile childProfile;

  const BehaviorAssessmentScreen({
    Key? key,
    required this.childProfile,
  }) : super(key: key);

  @override
  State<BehaviorAssessmentScreen> createState() =>
      _BehaviorAssessmentScreenState();
}

class _BehaviorAssessmentScreenState extends State<BehaviorAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBehavior;
  String? _selectedAntecedent;
  String? _selectedConsequence;
  String? _sensorySigns = 'لا';
  int _frequency = 1;
  String? _durationLevel;
  String? _intensityLevel;

  bool _isAssessing = false;
  Map<String, dynamic>? _assessmentResult;

  final List<String> _behaviors = [
    'العض',
    'العدوان الجسدي',
    'العدوان اللفظي',
    'رمي الأشياء',
    'الهروب',
    'البصق',
    'السرقة',
    'الكلام بدون إذن',
    'ترك المقعد',
    'عدم التركيز',
    'حركات مزعجة بسيطة',
    'لمس شخصي غير مناسب',
    'رفض التعليمات',
    'مقاومة الانتقال',
    'صعوبة التنظيم',
  ];

  final List<String> _antecedents = [
    'عند طلب مهمة',
    'عند منع شيء مفضل',
    'عند تجاهل الطفل',
    'عند وجود ضوضاء أو زحام',
    'بدون سبب واضح',
  ];

  final List<String> _consequences = [
    'توقف النشاط أو الطلب',
    'حصل الطفل على انتباه',
    'حصل الطفل على الشيء الذي يريده',
    'استمر السلوك دون تغيير واضح',
  ];

  final List<String> _durationLevels = [
    'أقل من دقيقة',
    '1-5 دقائق',
    'أكثر من 5 دقائق',
  ];

  final List<String> _intensityLevels = [
    'بسيط',
    'متوسط',
    'شديد',
  ];

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Provider.of<AppState>(context).currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      floatingActionButton: const GlobalChatFAB(),
      appBar: AppBar(
        title: Text(
          'تقييم السلوك',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
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
                        Text(
                          'تقييم سلوك الطفل',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'الطفل: ${widget.childProfile.fullName}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ساعدنا في فهم سلوك طفلك لتقديم الدعم المناسب',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Behavior Selection
                  _buildSectionTitle('اختر السلوك المراد تقييمه'),
                  _buildDropdown(
                    value: _selectedBehavior,
                    items: _behaviors,
                    hint: 'اختر السلوك',
                    validator: (value) =>
                        value == null ? 'يرجى اختيار السلوك' : null,
                    onChanged: (value) =>
                        setState(() => _selectedBehavior = value),
                  ),
                  const SizedBox(height: 24),

                  // Antecedent
                  _buildSectionTitle('متى يحدث السلوك غالبًا؟'),
                  _buildDropdown(
                    value: _selectedAntecedent,
                    items: _antecedents,
                    hint: 'اختر الوقت',
                    validator: (value) =>
                        value == null ? 'يرجى اختيار الوقت' : null,
                    onChanged: (value) =>
                        setState(() => _selectedAntecedent = value),
                  ),
                  const SizedBox(height: 24),

                  // Consequence
                  _buildSectionTitle('ماذا يحدث غالبًا بعد السلوك؟'),
                  _buildDropdown(
                    value: _selectedConsequence,
                    items: _consequences,
                    hint: 'اختر النتيجة',
                    validator: (value) =>
                        value == null ? 'يرجى اختيار النتيجة' : null,
                    onChanged: (value) =>
                        setState(() => _selectedConsequence = value),
                  ),
                  const SizedBox(height: 24),

                  // Sensory Signs
                  _buildSectionTitle(
                      'هل يبدو أن الطفل يبحث عن إحساس أو يتأثر بالحواس؟'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('نعم'),
                          value: 'نعم',
                          groupValue: _sensorySigns,
                          onChanged: (value) =>
                              setState(() => _sensorySigns = value),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('لا'),
                          value: 'لا',
                          groupValue: _sensorySigns,
                          onChanged: (value) =>
                              setState(() => _sensorySigns = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Frequency
                  _buildSectionTitle('عدد مرات حدوث السلوك اليوم'),
                  TextFormField(
                    initialValue: _frequency.toString(),
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('عدد المرات'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'يرجى إدخال عدد المرات';
                      final num = int.tryParse(value);
                      if (num == null || num < 1 || num > 20)
                        return 'يرجى إدخال رقم بين 1 و 20';
                      return null;
                    },
                    onChanged: (value) => _frequency = int.tryParse(value) ?? 1,
                  ),
                  const SizedBox(height: 24),

                  // Duration
                  _buildSectionTitle('مدة السلوك غالبًا'),
                  _buildDropdown(
                    value: _durationLevel,
                    items: _durationLevels,
                    hint: 'اختر المدة',
                    validator: (value) =>
                        value == null ? 'يرجى اختيار المدة' : null,
                    onChanged: (value) =>
                        setState(() => _durationLevel = value),
                  ),
                  const SizedBox(height: 24),

                  // Intensity
                  _buildSectionTitle('مدى خطورة السلوك'),
                  _buildDropdown(
                    value: _intensityLevel,
                    items: _intensityLevels,
                    hint: 'اختر الخطورة',
                    validator: (value) =>
                        value == null ? 'يرجى اختيار الخطورة' : null,
                    onChanged: (value) =>
                        setState(() => _intensityLevel = value),
                  ),
                  const SizedBox(height: 32),

                  // Assessment Button
                  if (_assessmentResult == null)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isAssessing ? null : _performAssessment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: _isAssessing
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('جاري التقييم...'),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.psychology_rounded),
                                  SizedBox(width: 8),
                                  Text('حساب التقييم'),
                                ],
                              ),
                      ),
                    ),

                  // Assessment Result
                  if (_assessmentResult != null) ...[
                    const SizedBox(height: 32),
                    _buildAssessmentResult(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _navigateToTraining,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_rounded),
                            SizedBox(width: 8),
                            Text('بدء التدريب'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    String? Function(String?)? validator,
    Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      hint: Text(hint),
      validator: validator,
      onChanged: onChanged,
      decoration: _buildInputDecoration(hint),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF667EEA)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53E3E)),
      ),
    );
  }

  Widget _buildAssessmentResult() {
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
                'نتيجة التقييم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultItem('السلوك', _selectedBehavior ?? ''),
          _buildResultItem('الوظيفة المتوقعة',
              _assessmentResult!['predicted_function'] ?? ''),
          _buildResultItem('مستوى الشدة', _assessmentResult!['severity'] ?? ''),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
            ),
            child: Text(
              _assessmentResult!['summary'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0C4A6E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performAssessment() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAssessing = true);

    // Simulate assessment process
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // Simple assessment logic (you can enhance this)
      final result = _calculateAssessment();

      setState(() {
        _isAssessing = false;
        _assessmentResult = result;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('تم التقييم بنجاح'),
            ],
          ),
          backgroundColor: const Color(0xFF667EEA),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  Map<String, dynamic> _calculateAssessment() {
    // Simple assessment logic (you can replace with real engine)
    String function = 'هروب';
    String severity = 'بسيط';
    int severityScore = 3;

    // Enhanced logic based on inputs
    if (_selectedAntecedent == 'عند طلب مهمة') {
      function = 'هروب';
    } else if (_selectedAntecedent == 'عند تجاهل الطفل') {
      function = 'انتباه';
    } else if (_selectedAntecedent == 'عند وجود ضوضاء أو زحام') {
      function = 'حسي';
    } else if (_selectedAntecedent == 'عند منع شيء مفضل') {
      function = 'شيء مادي';
    }

    // Calculate severity
    final durationMap = {
      'أقل من دقيقة': 1,
      '1-5 دقائق': 2,
      'أكثر من 5 دقائق': 3
    };
    final intensityMap = {'بسيط': 1, 'متوسط': 2, 'شديد': 3};

    final frequencyScore = _frequency <= 2
        ? 1
        : _frequency <= 5
            ? 2
            : 3;
    final durationScore = durationMap[_durationLevel] ?? 1;
    final intensityScore = intensityMap[_intensityLevel] ?? 1;

    severityScore = frequencyScore + durationScore + intensityScore;

    if (severityScore <= 4) {
      severity = 'بسيط';
    } else if (severityScore <= 7) {
      severity = 'متوسط';
    } else {
      severity = 'شديد';
    }

    return {
      'predicted_function': function,
      'severity': severity,
      'severity_score': severityScore,
      'summary':
          'تشير الإجابات إلى أن وظيفة السلوك الأقرب هي: $function. كما أن شدة السلوك الحالية مصنفة على أنها: $severity (درجة الشدة = $severityScore).',
      'behavior': _selectedBehavior,
      'antecedent': _selectedAntecedent,
      'consequence': _selectedConsequence,
      'sensory_signs': _sensorySigns,
      'frequency': _frequency,
      'duration_level': _durationLevel,
      'intensity_level': _intensityLevel,
    };
  }

  void _navigateToTraining() {
    if (_assessmentResult == null) return;

    // Save assessment result to app state or local storage
    final appState = Provider.of<AppState>(context, listen: false);

    // Navigate to appropriate training based on assessment
    Navigator.of(context).pushNamed('/behavior-training', arguments: {
      'childProfile': widget.childProfile,
      'assessmentResult': _assessmentResult,
    });
  }
}
