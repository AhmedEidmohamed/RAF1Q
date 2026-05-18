import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import 'home_dashboard_screen.dart';
import 'vineland_questions.dart';
import 'gars_assessment_screen.dart';

class VinelandAssessmentScreen extends StatefulWidget {
  const VinelandAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<VinelandAssessmentScreen> createState() => _VinelandAssessmentScreenState();
}

class _VinelandAssessmentScreenState extends State<VinelandAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentDimensionIndex = 0;
  
  // Store answers as: Map<dimensionIndex, Map<questionIndex, String value>>
  final Map<int, Map<int, String>> _answers = {};

  final List<Map<String, dynamic>> _dimensions = VinelandQuestions.dimensions;

  final List<String> _options = ['2', '1', '0', 'م', 'ع'];
  final Map<String, String> _optionLabels = {
    '2': 'نعم، عادة',
    '1': 'أحياناً',
    '0': 'لا، أبداً',
    'م': 'لم تسنح',
    'ع': 'لا أعرف'
  };

  void _submitAssessment() async {
    // Collect all scores
    int totalScore = 0;
    Map<String, dynamic> results = {};
    
    for (int d = 0; d < _dimensions.length; d++) {
      int dimScore = 0;
      Map<String, String> dimAnswers = {};
      if (_answers[d] != null) {
        _answers[d]!.forEach((qIndex, val) {
          dimAnswers[qIndex.toString()] = val;
          if (val == '2') dimScore += 2;
          if (val == '1') dimScore += 1;
          // '0', 'م', 'ع' add 0 to score (usually)
        });
      }
      results['dimension_$d'] = dimAnswers;
      results['dimension_${d}_score'] = dimScore;
      totalScore += dimScore;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('children').doc(user.uid).set({
        'vineland_score': totalScore,
        'vineland_results': results,
        'vineland_completed': true,
        'vineland_date': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GarsAssessmentScreen()),
      );
    }
  }

  bool _isCurrentDimensionComplete() {
    int requiredCount = _dimensions[_currentDimensionIndex]['questions'].length;
    int answeredCount = _answers[_currentDimensionIndex]?.length ?? 0;
    return answeredCount == requiredCount;
  }

  bool _isAllComplete() {
    for (int i = 0; i < _dimensions.length; i++) {
      if ((_answers[i]?.length ?? 0) < _dimensions[i]['questions'].length) {
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
                    'مقياس فاينلاند للسلوك التكيفي',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007aff),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'البعد ${_currentDimensionIndex + 1} من ${_dimensions.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentDimensionIndex + 1) / _dimensions.length,
                    backgroundColor: Colors.blue[50],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007aff)),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            // Dimension Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentDimensionIndex = page),
                itemCount: _dimensions.length,
                itemBuilder: (context, dimIndex) {
                  final dim = _dimensions[dimIndex];
                  final List<String> questions = List<String>.from(dim['questions']);
                  
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          dim['title'],
                          style: const TextStyle(
                            fontSize: 18,
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
                            String? currentAnswer = _answers[dimIndex]?[qIndex];
                            
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
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _options.map((opt) {
                                          bool isSelected = currentAnswer == opt;
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: ChoiceChip(
                                              label: Text(
                                                '${_optionLabels[opt]}',
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : Colors.grey[700],
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                              selected: isSelected,
                                              selectedColor: const Color(0xFF007aff),
                                              backgroundColor: Colors.grey[100],
                                              onSelected: (selected) {
                                                if (selected) {
                                                  setState(() {
                                                    _answers[dimIndex] ??= {};
                                                    _answers[dimIndex]![qIndex] = opt;
                                                  });
                                                }
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
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
                  if (_currentDimensionIndex > 0)
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
                  
                  if (_currentDimensionIndex < _dimensions.length - 1)
                    ElevatedButton(
                      onPressed: _isCurrentDimensionComplete() ? () {
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
                        backgroundColor: const Color(0xFF10B981), // Success green for final submit
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
