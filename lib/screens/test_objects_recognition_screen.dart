import '../core/config/app_config.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:universal_html/html.dart' as html show Blob, Url, AudioElement;

import 'package:confetti/confetti.dart';

/// Test Screen for Objects Recognition
/// Shows 3 images and asks "What is this object?"
class TestObjectsRecognitionScreen extends StatefulWidget {
  const TestObjectsRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<TestObjectsRecognitionScreen> createState() =>
      _TestObjectsRecognitionScreenState();
}

class _TestObjectsRecognitionScreenState
    extends State<TestObjectsRecognitionScreen> {
  List<Map<String, dynamic>> objectProfiles = [];
  List<Map<String, dynamic>> testQuestions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswerIndex;
  bool showResult = false;
  bool testCompleted = false;
  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;

  final String apiKey = AppConfig.elevenLabsApiKey;
  final String voiceId = "EXAVITQu4vr4xnSDxMaL";

  // Default objects that come with the app (using same images as recognizing objects screen)
  final List<Map<String, dynamic>> defaultObjects = [
    {
      'name': 'تفاحة',
      'place_type': 'فواكه',
      'image_path':
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800&q=80',
    },
    {
      'name': 'موز',
      'place_type': 'فواكه',
      'image_path':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800&q=80',
    },
    {
      'name': 'برتقال',
      'place_type': 'فواكه',
      'image_path':
          'https://images.unsplash.com/photo-1547514701-42782101795e?w=800&q=80',
    },
    {
      'name': 'عنب',
      'place_type': 'فواكه',
      'image_path':
          'https://images.unsplash.com/photo-1537640538965-175f62f4f947?w=800&q=80',
    },
    {
      'name': 'قطة',
      'place_type': 'حيوانات',
      'image_path':
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800&q=80',
    },
    {
      'name': 'كلب',
      'place_type': 'حيوانات',
      'image_path':
          'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=800&q=80',
    },
    {
      'name': 'أرنب',
      'place_type': 'حيوانات',
      'image_path':
          'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=800&q=80',
    },
    {
      'name': 'طماطم',
      'place_type': 'خضروات',
      'image_path':
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=800&q=80',
    },
    {
      'name': 'جزر',
      'place_type': 'خضروات',
      'image_path':
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=800&q=80',
    },
    {
      'name': 'كرة',
      'place_type': 'ألعاب',
      'image_path':
          'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadObjectProfiles();
  }

  @override
  void dispose() {
    _player.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadObjectProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('object_profiles') ?? [];

      // Load user-added objects
      final userObjects = profilesJson.map((json) {
        return Map<String, dynamic>.from(jsonDecode(json));
      }).toList();

      List<Map<String, dynamic>> allObjects = [...defaultObjects, ...userObjects];

      // Fetch learned objects from Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('children')
            .doc(user.uid)
            .collection('learning_activities')
            .where('category', isEqualTo: 'object')
            .get();

        Set<String> learnedNames = {};
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['itemName'] != null) {
            learnedNames.add(data['itemName'] as String);
          }
        }

        allObjects = allObjects.where((obj) => learnedNames.contains(obj['name'])).toList();
      }

      // Combine default objects with user objects (or filtered ones)
      setState(() {
        objectProfiles = allObjects;
      });

      if (objectProfiles.length >= 4) {
        _generateTestQuestions();
      }
    } catch (e) {
      print('Error loading object profiles: $e');
    }
  }

  void _generateTestQuestions() {
    if (objectProfiles.length < 4) return;

    List<Map<String, dynamic>> questions = [];
    Random random = Random();

    for (int i = 0; i < 5; i++) {
      List<Map<String, dynamic>> availableProfiles = List.from(objectProfiles);
      availableProfiles.shuffle(random);

      Map<String, dynamic> correctAnswer = availableProfiles[0];
      List<Map<String, dynamic>> wrongAnswers = availableProfiles.sublist(1, 4);

      List<Map<String, dynamic>> options = [correctAnswer, ...wrongAnswers];
      options.shuffle(random);

      int correctIndex = options.indexOf(correctAnswer);

      questions.add({
        'question': 'فين "${correctAnswer['name']}"؟',
        'options': options,
        'correctIndex': correctIndex,
        'correctAnswer': correctAnswer,
      });
    }

    setState(() {
      testQuestions = questions;
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswerIndex = null;
      showResult = false;
      testCompleted = false;
    });
  }

  Future<void> _playQuestionAudio(String question) async {
    try {
      final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId",
      );

      final response = await http
          .post(
            url,
            headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
            body: jsonEncode({"text": question}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        Uint8List audioBytes = response.bodyBytes;

        if (kIsWeb) {
          final blob = html.Blob([audioBytes], 'audio/mpeg');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final audio = html.AudioElement();
          audio.src = url;
          audio.play();
          audio.onEnded.listen((_) => html.Url.revokeObjectUrl(url));
        } else {
          await _player.setSourceBytes(audioBytes);
          await _player.resume();
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _selectAnswer(int index) {
    if (showResult) return;

    setState(() {
      selectedAnswerIndex = index;
      showResult = true;

      if (index == testQuestions[currentQuestionIndex]['correctIndex']) {
        score++;
        _playSuccessAudio();
      } else {
        _playErrorAudio();
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  Future<void> _playSuccessAudio() async {
    try {
      final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId",
      );

      final response = await http
          .post(
            url,
            headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
            body: jsonEncode({"text": "برافو! إجابة صحيحة"}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        Uint8List audioBytes = response.bodyBytes;

        if (kIsWeb) {
          final blob = html.Blob([audioBytes], 'audio/mpeg');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final audio = html.AudioElement();
          audio.src = url;
          audio.play();
          audio.onEnded.listen((_) => html.Url.revokeObjectUrl(url));
        } else {
          await _player.setSourceBytes(audioBytes);
          await _player.resume();
        }
      }
    } catch (e) {
      print('Error playing success audio: $e');
    }
  }

  Future<void> _playErrorAudio() async {
    try {
      final url = Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$voiceId",
      );

      final response = await http
          .post(
            url,
            headers: {"xi-api-key": apiKey, "Content-Type": "application/json"},
            body: jsonEncode({"text": "إجابة خاطئة، حاول مرة أخرى"}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        Uint8List audioBytes = response.bodyBytes;

        if (kIsWeb) {
          final blob = html.Blob([audioBytes], 'audio/mpeg');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final audio = html.AudioElement();
          audio.src = url;
          audio.play();
          audio.onEnded.listen((_) => html.Url.revokeObjectUrl(url));
        } else {
          await _player.setSourceBytes(audioBytes);
          await _player.resume();
        }
      }
    } catch (e) {
      print('Error playing error audio: $e');
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < testQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        showResult = false;
      });
    } else {
      setState(() {
        testCompleted = true;
        if (score >= 3) {
          _confettiController.play();
        }
      });
    }
  }

  void _restartTest() {
    _generateTestQuestions();
  }

  Widget _buildQuestionCard() {
    if (testQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'لا يوجد ما يكفي من الأشياء لإجراء الاختبار',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'يجب إضافة على الأقل 4 أشياء',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007aff),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (testCompleted) {
      return _buildResultCard();
    }

    final question = testQuestions[currentQuestionIndex];

    return Column(
      children: [
        // Question text with audio button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A), // Dark blue
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _playQuestionAudio(question['question']),
              icon: const Icon(Icons.volume_up, color: Color(0xFF007aff)),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Answer options
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.95,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: question['options'].length,
            itemBuilder: (context, index) {
              final option = question['options'][index];
              final isSelected = selectedAnswerIndex == index;
              final isCorrect = index == question['correctIndex'];
              final showCorrectAnswer = showResult && isCorrect;

              Color borderColor = Colors.transparent;
              if (isSelected) {
                borderColor = isCorrect ? Colors.green : Colors.red;
              } else if (showCorrectAnswer) {
                borderColor = Colors.green;
              }

              return GestureDetector(
                onTap: () => _selectAnswer(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                      width: (isSelected || showCorrectAnswer) ? 4 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox.expand(child: _buildOptionImage(option)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    double percentage = (score / testQuestions.length) * 100;
    String message;
    Color messageColor;

    if (percentage >= 80) {
      message = 'ممتاز! أداء رائع';
      messageColor = Colors.green;
    } else if (percentage >= 60) {
      message = 'جيد جداً! استمر في التقدم';
      messageColor = Colors.blue;
    } else if (percentage >= 40) {
      message = 'جيد! تحتاج إلى المزيد من التدريب';
      messageColor = Colors.orange;
    } else {
      message = 'تحاول جيداً! كرر المحاولة';
      messageColor = Colors.red;
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: messageColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: messageColor, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: messageColor,
                    ),
                  ),
                  Text(
                    'من ${testQuestions.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: messageColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: messageColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'نسبة النجاح: ${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _restartTest,
                  child: Text('إعادة الاختبار'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('العودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build option image (handles both image_path and icon)
  Widget _buildOptionImage(Map<String, dynamic> option) {
    // If has icon field (default objects), show icon
    if (option['icon'] != null) {
      IconData iconData = Icons.category;
      switch (option['icon']) {
        case 'pets':
          iconData = Icons.pets;
          break;
        case 'emoji_nature':
          iconData = Icons.emoji_nature;
          break;
        case 'apple':
          iconData = Icons.apple;
          break;
        case 'eco':
          iconData = Icons.eco;
          break;
      }
      return Center(
        child: Icon(
          iconData,
          size: 60,
          color: Colors.green.shade700,
        ),
      );
    }

    // If has image_path (user added objects), show image
    if (option['image_path'] != null) {
      return _buildImage(option['image_path']);
    }

    // Fallback
    return Center(
      child: Icon(
        Icons.category,
        size: 60,
        color: Colors.green.shade700,
      ),
    );
  }

  // Helper method to build image based on path type
  Widget _buildImage(String imagePath) {
    final errorWidget = Icon(
      Icons.category,
      size: 60,
      color: Colors.green.shade700,
    );

    // Asset image (starts with 'assets/')
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }

    // Web URL (starts with http/https)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }

    // Local file path
    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Question tracker pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Text(
                          testQuestions.isEmpty 
                              ? 'سؤال 0 من 0' 
                              : 'سؤال ${currentQuestionIndex + 1} من ${testQuestions.length}',
                          style: const TextStyle(
                            color: Color(0xFF007aff),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      // Title
                      const Text(
                        'اختبار الأشياء',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A), // Dark blue
                        ),
                      ),
                      // Back button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF007aff)),
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF007aff),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: testQuestions.isEmpty ? 0 : (currentQuestionIndex + 1) / testQuestions.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007aff)),
                      minHeight: 6,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Question Card & Options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuestionCard(),
                  ),
                ),
              ],
            ),
            
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
    );
  }
}
