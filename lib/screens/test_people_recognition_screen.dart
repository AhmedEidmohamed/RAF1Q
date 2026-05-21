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

/// Test Screen for People Recognition
/// Shows 3 images and asks "Who is your father/mother/etc?"
class TestPeopleRecognitionScreen extends StatefulWidget {
  const TestPeopleRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<TestPeopleRecognitionScreen> createState() =>
      _TestPeopleRecognitionScreenState();
}

class _TestPeopleRecognitionScreenState
    extends State<TestPeopleRecognitionScreen> {
  List<Map<String, dynamic>> voiceProfiles = [];
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

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadVoiceProfiles();
  }

  @override
  void dispose() {
    _player.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadVoiceProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('voice_profiles') ?? [];

      List<Map<String, dynamic>> loadedProfiles = profilesJson.map((json) {
        return Map<String, dynamic>.from(jsonDecode(json));
      }).toList();

      // Fetch learned people from Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('children')
            .doc(user.uid)
            .collection('learning_activities')
            .where('category', isEqualTo: 'person')
            .get();

        Set<String> learnedNames = {};
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['itemName'] != null) {
            learnedNames.add(data['itemName'] as String);
          }
        }

        loadedProfiles = loadedProfiles.where((obj) => learnedNames.contains(obj['name'])).toList();
      }

      setState(() {
        voiceProfiles = loadedProfiles;
      });

      if (voiceProfiles.length >= 3) {
        _generateTestQuestions();
      }
    } catch (e) {
      print('Error loading voice profiles: $e');
    }
  }

  void _generateTestQuestions() {
    if (voiceProfiles.length < 3) return;

    List<Map<String, dynamic>> questions = [];
    Random random = Random();

    for (int i = 0; i < 5; i++) {
      List<Map<String, dynamic>> availableProfiles = List.from(voiceProfiles);
      availableProfiles.shuffle(random);

      Map<String, dynamic> correctAnswer = availableProfiles[0];
      List<Map<String, dynamic>> wrongAnswers = availableProfiles.sublist(1, 3);

      List<Map<String, dynamic>> options = [correctAnswer, ...wrongAnswers];
      options.shuffle(random);

      int correctIndex = options.indexOf(correctAnswer);

      questions.add({
        'question': 'مين ${correctAnswer['relation']}؟',
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
            SizedBox(height: 20),
            Text(
              'لا يوجد ما يكفي من الأشخاص لإجراء الاختبار',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'يجب إضافة على الأقل 3 أشخاص',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('العودة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4F46E5),
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
        // Progress indicator
        LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / testQuestions.length,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
        ),
        SizedBox(height: 20),

        // Question number
        Text(
          'السؤال ${currentQuestionIndex + 1} من ${testQuestions.length}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),

        // Question text with audio button
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF4F46E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question['question'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(width: 15),
              IconButton(
                onPressed: () => _playQuestionAudio(question['question']),
                icon: Icon(Icons.volume_up, color: Color(0xFF4F46E5)),
                iconSize: 30,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),

        // Answer options
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: question['options'].length,
            itemBuilder: (context, index) {
              final option = question['options'][index];
              final isSelected = selectedAnswerIndex == index;
              final isCorrect = index == question['correctIndex'];
              final showCorrectAnswer = showResult && isCorrect;

              return GestureDetector(
                onTap: () => _selectAnswer(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : showCorrectAnswer
                              ? Colors.green
                              : Colors.grey.shade300,
                      width: 3,
                    ),
                    color: isSelected
                        ? (isCorrect
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2))
                        : showCorrectAnswer
                            ? Colors.green.withOpacity(0.2)
                            : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: option['image_path'] != null
                                ? kIsWeb
                                    ? Image.network(
                                        option['image_path'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.purple.shade700,
                                          );
                                        },
                                      )
                                    : Image.file(
                                        File(option['image_path']),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.purple.shade700,
                                          );
                                        },
                                      )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.purple.shade700,
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                option['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                option['relation'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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

    return Center(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختبار التعرف على الأشخاص',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF007aff),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: _buildQuestionCard(),
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
    );
  }
}
