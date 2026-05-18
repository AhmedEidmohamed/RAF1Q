import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record_mp3_plus/record_mp3_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/session_tracker.dart';
import '../widgets/custom_widgets.dart';
import '../services/groq_service.dart';
import '../services/elevenlabs_service.dart';
import '../services/gemini_service.dart';
import '../providers/app_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Stage 3A: Starting Conversation Screen
/// Voice interaction UI with continuous AI dialogue
class StartingConversationScreen extends StatefulWidget {
  const StartingConversationScreen({Key? key}) : super(key: key);

  @override
  State<StartingConversationScreen> createState() =>
      _StartingConversationScreenState();
}

class _StartingConversationScreenState
    extends State<StartingConversationScreen> {
  late SessionTracker _sessionTracker;
  late FlutterTts _flutterTts;
  late GroqService _groqService;
  late ElevenLabsService _elevenLabsService;
  late GeminiService _geminiService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String _lastWords = '';
  String _rafiqResponse = '';
  bool _isRafiqThinking = false;
  bool _isAiSpeaking = false;
  bool _shouldContinueLoop = true;
  final List<Map<String, String>> _conversationHistory = [];

  // Groq API Key (Using the one found in the project)
  String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  // ElevenLabs API Key (Place your key here)
  String get _elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';

  // Gemini API Key (Placeholder - hopefully available in AppState or provided)
  String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _sessionTracker =
        SessionTracker(stageNumber: 3, activityName: 'Starting Conversation');
    _sessionTracker.startSession();

    _groqService = GroqService(apiKey: _groqApiKey);
    _elevenLabsService = ElevenLabsService(apiKey: _elevenLabsApiKey);
    _geminiService = GeminiService(
        apiKey: "AIzaSy..."); // I will use a dummy or try to find it

    _initTts();
    _requestMicrophonePermission();

    // Start the conversation after a short delay to ensure everything is ready
    Future.delayed(const Duration(seconds: 1), () {
      _startConversation();
    });
  }

  Future<void> _requestMicrophonePermission() async {
    await Permission.microphone.request();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("ar-SA");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      setState(() => _isAiSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isAiSpeaking = false);
      // Automatically start listening after AI finishes speaking, unless loop is stopped
      if (_shouldContinueLoop) {
        _recordResponse();
      }
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      setState(() => _isAiSpeaking = false);
    });

    // Handle just_audio completion
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _isAiSpeaking = false);
        if (_shouldContinueLoop) {
          _recordResponse();
        }
      }
    });
  }

  @override
  void dispose() {
    _sessionTracker.endSession();
    _flutterTts.stop();
    _audioPlayer.dispose();
    RecordMp3.instance.stop();
    super.dispose();
  }

  // 1. AI Starts the conversation
  void _startConversation() {
    String greeting = "أزيك يا بطل! أنا رفيق صاحبك الجديد.. عامل إيه النهاردة؟";
    _handleAiResponse(greeting);
    
    // Log view_item activity (starting a conversation session)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseService().logLearningActivity(
        childId: user.uid,
        activityType: 'view_item',
        itemName: 'محادثة مع رفيق',
        category: 'conversation',
      );
    }
  }

  // 2. AI Speaks (Using ElevenLabs for best child voice)
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;

    try {
      setState(() => _isAiSpeaking = true);

      // Step 1: Generate high-quality child voice from ElevenLabs
      File? voiceFile = await _elevenLabsService.speech(text);

      if (voiceFile != null && await voiceFile.exists()) {
        await _audioPlayer.setFilePath(voiceFile.path);
        await _audioPlayer.play();
      } else {
        // Fallback to local TTS if ElevenLabs fails
        print("ElevenLabs TTS failed, fallback to local");
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print("Speak Error: $e");
      await _flutterTts.speak(text);
    }
  }

  // 3. Listen to Child (Record)
  Future<void> _recordResponse() async {
    if (_isRecording || _isAiSpeaking) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/child_voice.mp3';

      setState(() {
        _isRecording = true;
        _lastWords = 'أنا أسمعك الآن...';
      });

      print('Starting recording to path: $path');
      RecordMp3.instance.start(path, (type) {
        print('Record error: $type');
      });

      // Automatically stop after 5 seconds of recording
      Future.delayed(const Duration(seconds: 5), () {
        if (_isRecording) {
          _stopAndProcess(path);
        }
      });
    } catch (e) {
      print('Recording Error: $e');
      setState(() => _isRecording = false);
    }
  }

  // 4. Stop and Process (STT -> Gemini -> TTS)
  Future<void> _stopAndProcess(String path) async {
    print('Attempting to stop recording...');
    bool stopped = RecordMp3.instance.stop();
    print('Record stop result: $stopped');
    if (!stopped) return;

    // Small delay to ensure the file is fully written and closed by the OS
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isRecording = false;
      _isRafiqThinking = true;
    });

    try {
      // Step A: Transcribe voice to text (STT)
      File file = File(path);
      print("Recording file size: ${await file.length()} bytes");
      if (!await file.exists() || await file.length() < 100) {
        _handleAiResponse("لم أسمعك جيداً، هل يمكنك قول ذلك مرة أخرى؟");
        return;
      }

      // Step A: Transcribe voice to text (Using ElevenLabs Scribe v2 only)
      print("Starting ElevenLabs Scribe v2 transcription...");
      String transcribedText = await _elevenLabsService.transcribe(path);

      if (transcribedText.isEmpty) {
        _handleAiResponse("أنا مش سامعك كويس يا بطل، ممكن تقول تاني؟");
        return;
      }

      // Filter out Whisper hallucinations (like "Nancy Ajram" or common silent audio outputs)
      final hallucinations = [
        "شكراً",
        "تم التسجيل",
        "Subtitles by",
        "Subtitles",
        "Translated by",
        "you",
        "Thank you"
      ];
      bool isHallucination =
          hallucinations.any((h) => transcribedText.contains(h));

      if (transcribedText.isEmpty ||
          transcribedText.length < 3 ||
          isHallucination) {
        final suggestions = [
          "أنا سامع سكوت.. تفتكر القطة بتعمل صوت إزاي؟ قولي كدة!",
          "ساكت ليه يا بطل؟ تيجى نلعب لعبة؟ قولي بتحب العربيات ولا المكعبات؟",
          "إيه رأيك نلعب استغماية؟ قولي لو موافق!",
          "أنا مستني أسمع صوتك الجميل.. قولي بقى، إيه أكتر لون بتحبه؟"
        ];
        _handleAiResponse((suggestions..shuffle()).first);
        return;
      }

      setState(() {
        _lastWords = transcribedText;
        _conversationHistory.add({'role': 'user', 'content': transcribedText});
      });

      // Check if child wants to end the conversation
      final exitWords = [
        "شكرا",
        "شكراً",
        "سلام",
        "مع السلامه",
        "مع السلامة",
        "باي",
        "خلصت",
        "كفايه",
        "كفاية",
        "تعبت"
      ];
      bool wantsToExit =
          exitWords.any((word) => transcribedText.contains(word));

      if (wantsToExit) {
        _handleAiResponse(
            "أنا اتبسطت أوي إني لعبت معاك النهاردة.. مع السلامة يا بطل ونشوف بعض تاني قريب!");
        // We stop the loop by NOT calling _recordResponse again in TTS completion
        _shouldContinueLoop = false;
        return;
      }

      // Step B: Get AI response (Llama)
      final aiResult =
          await _groqService.chat(transcribedText, _conversationHistory);
      String responseText =
          aiResult['response'] ?? "أنا معك، ماذا تريد أن نقول؟";

      // Handle the behavioral analysis report
      String analysisJson = aiResult['analysis'] ?? "";
      if (analysisJson.isNotEmpty) {
        print("💡 Behavior Report Generated: $analysisJson");
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Parse the JSON to ensure it's valid before saving
            final Map<String, dynamic> reportData = jsonDecode(analysisJson);

            await FirebaseFirestore.instance
                .collection('children')
                .doc(user.uid)
                .collection('behavior_reports')
                .add({
              'report': reportData,
              'timestamp': FieldValue.serverTimestamp(),
              'stage': 'Stage 3 - Starting Conversation',
              'context': transcribedText,
            });
            print("✅ Behavior Report Saved to Firestore.");
          }
        } catch (e) {
          print("❌ Error saving behavior report: $e");
        }
      }

      _handleAiResponse(responseText);
    } catch (e) {
      print("Process Error: $e");
      _handleAiResponse("حدث خطأ بسيط، دعنا نحاول مرة أخرى.");
    }
  }

  void _handleAiResponse(String response) {
    if (mounted) {
      setState(() {
        _rafiqResponse = response;
        _isRafiqThinking = false;
        _conversationHistory.add({'role': 'assistant', 'content': response});
      });
      _speak(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'المحادثة مع رفيق',
        subtitle: _isRecording
            ? 'رفيق يسمعك...'
            : (_isAiSpeaking ? 'رفيق يتحدث...' : 'تحدث مع رفيق'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Reward System UI
                  _buildRewardSystem(theme),
                  const SizedBox(height: 20),

                  // Rafiq Avatar with animation effect when speaking
                  TweenAnimationBuilder(
                    tween: Tween<double>(
                        begin: 1.0, end: _isAiSpeaking ? 1.1 : 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _isAiSpeaking
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                                width: 3),
                            boxShadow: _isAiSpeaking
                                ? [
                                    BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 5)
                                  ]
                                : [],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/robot_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Speech Bubbles
                  if (_lastWords.isNotEmpty)
                    _buildChatBubble(
                        text: _lastWords, isUser: true, theme: theme),

                  if (_isRafiqThinking)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),

                  if (_rafiqResponse.isNotEmpty)
                    _buildChatBubble(
                        text: _rafiqResponse, isUser: false, theme: theme),
                ],
              ),
            ),
          ),

          // Action Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              children: [
                if (_isRecording)
                  const Column(
                    children: [
                      Icon(Icons.mic, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text('رفيق يستمع إليك الآن...',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                if (_isAiSpeaking)
                  const Column(
                    children: [
                      Icon(Icons.volume_up, color: Colors.blue, size: 40),
                      SizedBox(height: 8),
                      Text('رفيق يتحدث...',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                if (!_isRecording && !_isAiSpeaking && !_isRafiqThinking)
                  ElevatedButton.icon(
                    onPressed: _recordResponse,
                    icon: const Icon(Icons.mic),
                    label: const Text("تحدث مع رفيق"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
      {required String text, required bool isUser, required ThemeData theme}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardSystem(ThemeData theme) {
    int userResponses =
        _conversationHistory.where((msg) => msg['role'] == 'user').length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber.shade400, width: 2),
        boxShadow: userResponses > 0
            ? [
                BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Text(
            'نجوم البطل: $userResponses',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          if (userResponses > 0) ...[
            const SizedBox(width: 10),
            Text('🎉', style: const TextStyle(fontSize: 28)),
          ]
        ],
      ),
    );
  }
}
