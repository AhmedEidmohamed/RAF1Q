import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import 'home_dashboard_screen.dart';
import 'vineland_assessment_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, int> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'title': '1. العلاقات مع الآخرين',
      'question': 'كيف تصف علاقة الطفل بالآخرين وقدرته على التفاعل الاجتماعي معهم؟',
      'options': [
        'سلوك طبيعي مناسب للعمر',
        'شذوذ بسيط',
        'شذوذ متوسط',
        'شذوذ شديد',
      ],
    },
    {
      'title': '2. التقليد',
      'question': 'كيف يقيم الطفل قدرته على تقليد الآخرين (أصوات، كلمات، حركات)؟',
      'options': [
        'تقليد مناسب للعمر',
        'تقليد بسيط غير طبيعي',
        'تقليد متوسط غير طبيعي',
        'تقليد شديد غير طبيعي',
      ],
    },
    {
      'title': '3. الاستجابة الانفعالية',
      'question': 'كيف تصف استجابات الطفل الانفعالية (مناسبة الموقف، مبالغ فيها، أو غير مبالية)؟',
      'options': [
        'استجابة انفعالية مناسبة للعمر والموقف',
        'استجابة انفعالية غير طبيعية بسيطة',
        'استجابة انفعالية غير طبيعية متوسطة',
        'استجابة انفعالية غير طبيعية شديدة',
      ],
    },
    {
      'title': '4. استخدام الجسم',
      'question': 'كيف يقيم تنسيق الطفل الحركي واستخدامه لجسمه (تناسق الحركة، الغرائب الحركية)؟',
      'options': [
        'استخدام طبيعي للجسم مناسب للعمر',
        'استخدام بسيط غير طبيعي للجسم',
        'استخدام متوسط غير طبيعي للجسم',
        'استخدام شديد غير طبيعي للجسم',
      ],
    },
    {
      'title': '5. استخدام الأشياء',
      'question': 'كيف يتعامل الطفل مع الأشياء والألعاب (اهتمام مناسب، تعلق غير طبيعي، أو تجاهل تام)؟',
      'options': [
        'استخدام طبيعي للأشياء مناسب للعمر',
        'استخدام بسيط غير طبيعي للأشياء',
        'استخدام متوسط غير طبيعي للأشياء',
        'استخدام شديد غير طبيعي للأشياء',
      ],
    },
    {
      'title': '6. التكيف مع التغيير',
      'question': 'كيف يستجيب الطفل للتغيرات في الروتين اليومي أو البيئة المحيطة؟',
      'options': [
        'استجابة تكيفية طبيعية للتغيير',
        'استجابة تكيفية غير طبيعية بسيطة للتغيير',
        'استجابة تكيفية غير طبيعية متوسطة للتغيير',
        'استجابة تكيفية غير طبيعية شديدة للتغيير',
      ],
    },
    {
      'title': '7. الاستجابة البصرية',
      'question': 'كيف يقيم سلوك الطفل البصري (طريقة نظره للأشياء، تجنب التواصل، التحديق)؟',
      'options': [
        'استجابة بصرية طبيعية مناسبة للعمر',
        'استجابة بصرية غير طبيعية بسيطة',
        'استجابة بصرية غير طبيعية متوسطة',
        'استجابة بصرية غير طبيعية شديدة',
      ],
    },
    {
      'title': '8. الاستجابة السمعية',
      'question': 'كيف يستجيب الطفل للأصوات من حوله (حساسية زائدة، تجاهل، استجابة طبيعية)؟',
      'options': [
        'استجابة سمعية طبيعية مناسبة للعمر',
        'استجابة سمعية غير طبيعية بسيطة',
        'استجابة سمعية غير طبيعية متوسطة',
        'استجابة سمعية غير طبيعية شديدة',
      ],
    },
    {
      'title': '9. استجابات اللمس والشم والتذوق',
      'question': 'كيف يستجيب الطفل للمؤثرات الحسية من خلال اللمس أو الشم أو التذوق؟',
      'options': [
        'استجابات حسية طبيعية مناسبة للعمر',
        'استجابات حسية غير طبيعية بسيطة',
        'استجابات حسية غير طبيعية متوسطة',
        'استجابات حسية غير طبيعية شديدة',
      ],
    },
    {
      'title': '10. الخوف والعصبية',
      'question': 'كيف يقيم مستوى الخوف والتوتر أو القلق لدى الطفل؟',
      'options': [
        'مستوى خوف وعصبية طبيعي مناسب للعمر',
        'مستوى خوف وعصبية غير طبيعي بسيط',
        'مستوى خوف وعصبية غير طبيعي متوسط',
        'مستوى خوف وعصبية غير طبيعي شديد',
      ],
    },
    {
      'title': '11. التواصل اللفظي',
      'question': 'كيف يصف مستوى تطور اللغة المنطوقة وقدرة الطفل على استخدام الكلمات؟',
      'options': [
        'تواصل لفظي طبيعي مناسب للعمر',
        'تواصل لفظي غير طبيعي بسيط',
        'تواصل لفظي غير طبيعي متوسط',
        'تواصل لفظي غير طبيعي شديد',
      ],
    },
    {
      'title': '12. التواصل غير اللفظي',
      'question': 'كيف يستخدم الطفل الإيماءات، تعبيرات الوجه، والإشارات للتواصل؟',
      'options': [
        'تواصل غير لفظي طبيعي مناسب للعمر',
        'تواصل غير لفظي غير طبيعي بسيط',
        'تواصل غير لفظي غير طبيعي متوسط',
        'تواصل غير لفظي غير طبيعي شديد',
      ],
    },
    {
      'title': '13. مستوى النشاط',
      'question': 'كيف يقيم مستوى نشاط الطفل الحركي (هادئ، مفرط النشاط، خامل)؟',
      'options': [
        'مستوى نشاط طبيعي مناسب للعمر',
        'مستوى نشاط غير طبيعي بسيط',
        'مستوى نشاط غير طبيعي متوسط',
        'مستوى نشاط غير طبيعي شديد',
      ],
    },
    {
      'title': '14. المستوى العقلي',
      'question': 'كيف يقيم تناسق القدرات العقلية لدى الطفل مقارنة بعمره؟',
      'options': [
        'استجابات عقلية طبيعية متناسقة مع العمر',
        'استجابات عقلية غير طبيعية بسيطة',
        'استجابات عقلية غير طبيعية متوسطة',
        'استجابات عقلية غير طبيعية شديدة',
      ],
    },
    {
      'title': '15. الانطباع العام',
      'question': 'بناءً على ملاحظتك الشاملة، ما هو تقييمك العام لمدى تأثر الطفل بطيف التوحد؟',
      'options': [
        'لا يوجد توحد',
        'توحد بسيط',
        'توحد متوسط',
        'توحد شديد',
      ],
    },
  ];

  void _submitAssessment() async {
    int totalScore = _answers.values.fold(0, (sum, score) => sum + score);
    int unlockedStages = 3;

    if (totalScore >= 38) {
      unlockedStages = 1; // شديد
    } else if (totalScore >= 30) {
      unlockedStages = 2; // متوسط
    } else {
      unlockedStages = 3; // بسيط/طبيعي
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('children').doc(user.uid).set({
        'assessment_score': totalScore,
        'unlocked_stages': unlockedStages,
        'assessment_completed': true,
        'assessment_date': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VinelandAssessmentScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'تقييم رفيق للقدرات',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007aff),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'السؤال ${_currentPage + 1} من ${_questions.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / _questions.length,
                    backgroundColor: Colors.blue[50],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007aff)),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  q['question'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ...List.generate(4, (optionIndex) {
                            int score = optionIndex + 1;
                            bool isSelected = _answers[index] == score;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _answers[index] = score;
                                  });
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (_currentPage < _questions.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF007aff) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF007aff) : Colors.grey[200]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$score',
                                            style: TextStyle(
                                              color: isSelected ? const Color(0xFF007aff) : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          q['options'][optionIndex],
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Color(0xFF1E293B),
                                            fontSize: 15,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20), // Extra space at bottom
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      label: const Text('السابق'),
                    )
                  else
                    const SizedBox(),
                  
                  if (_currentPage == _questions.length - 1)
                    ElevatedButton(
                      onPressed: _answers.length == _questions.length ? _submitAssessment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007aff),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('إنهاء التقييم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
