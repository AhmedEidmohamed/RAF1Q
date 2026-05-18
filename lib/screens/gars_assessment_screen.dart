import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_dashboard_screen.dart';
import 'gars_questions.dart';

class GarsAssessmentScreen extends StatefulWidget {
  const GarsAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<GarsAssessmentScreen> createState() => _GarsAssessmentScreenState();
}

class _GarsAssessmentScreenState extends State<GarsAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentSectionIndex = 0;
  
  // Store answers as: Map<sectionIndex, Map<questionIndex, String value>>
  final Map<int, Map<int, String>> _answers = {};

  final List<Map<String, dynamic>> _sections = GarsQuestions.sections;

  void _submitAssessment() async {
    // Collect all results
    Map<String, dynamic> results = {};
    int completedQuestions = 0;
    
    for (int s = 0; s < _sections.length; s++) {
      Map<String, String> sectionAnswers = {};
      if (_answers[s] != null) {
        _answers[s]!.forEach((qIndex, val) {
          sectionAnswers[qIndex.toString()] = val;
          completedQuestions++;
        });
      }
      results['section_$s'] = sectionAnswers;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('children').doc(user.uid).set({
        'gars_results': results,
        'gars_completed': true,
        'gars_date': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (mounted) {
      // Show result summary dialog before navigating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('اكتمل التقييم بنجاح', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF007aff))),
          content: const Text(
            'تم حفظ جميع بيانات التقييم الشامل (CARS، Vineland، GARS و DSM-IV) بنجاح. سيتم الآن توجيهك إلى الشاشة الرئيسية.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007aff),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
                  );
                },
                child: const Text('متابعة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }
  }

  bool _isCurrentSectionComplete() {
    int requiredCount = _sections[_currentSectionIndex]['questions'].length;
    int answeredCount = _answers[_currentSectionIndex]?.length ?? 0;
    return answeredCount == requiredCount;
  }

  bool _isAllComplete() {
    for (int i = 0; i < _sections.length; i++) {
      if ((_answers[i]?.length ?? 0) < _sections[i]['questions'].length) {
        return false;
      }
    }
    return true;
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'المقاييس الشاملة (GARS / DSM-IV)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007aff),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'القسم ${_currentSectionIndex + 1} من ${_sections.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentSectionIndex + 1) / _sections.length,
                    backgroundColor: Colors.blue[50],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007aff)),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            // Section Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentSectionIndex = page),
                itemCount: _sections.length,
                itemBuilder: (context, secIndex) {
                  final section = _sections[secIndex];
                  final List<String> questions = List<String>.from(section['questions']);
                  final List<String> options = List<String>.from(section['options']);
                  
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          section['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: questions.length,
                          itemBuilder: (context, qIndex) {
                            String qText = questions[qIndex];
                            String? currentAnswer = _answers[secIndex]?[qIndex];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      qText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: options.map((opt) {
                                        bool isSelected = currentAnswer == opt;
                                        return ChoiceChip(
                                          label: Text(
                                            opt,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.grey[800],
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 13,
                                            ),
                                          ),
                                          selected: isSelected,
                                          selectedColor: const Color(0xFF007aff),
                                          backgroundColor: Colors.grey[100],
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() {
                                                _answers[secIndex] ??= {};
                                                _answers[secIndex]![qIndex] = opt;
                                              });
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentSectionIndex > 0)
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
                  
                  if (_currentSectionIndex < _sections.length - 1)
                    ElevatedButton(
                      onPressed: _isCurrentSectionComplete() ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007aff),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('التالي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton(
                      onPressed: _isAllComplete() ? _submitAssessment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Success green
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('عرض النتيجة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
