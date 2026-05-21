import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/config/app_config.dart';

class VoiceChatService {
  static const String apiKey = AppConfig.groqChatApiKey;

  static final SpeechToText _speechToText = SpeechToText();
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  // Initialize voice services
  static Future<bool> initializeVoiceServices() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Initialize speech to text
      bool speechAvailable = await _speechToText.initialize(
        onError: (error) => print('Speech error: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );

      // Initialize text to speech
      await _flutterTts.setLanguage("ar-SA"); // Arabic by default
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _isInitialized = speechAvailable;
      return _isInitialized;
    } catch (e) {
      print('Error initializing voice services: $e');
      return false;
    }
  }

  // Request necessary permissions
  static Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  // Check if voice services are available
  static bool get isVoiceAvailable => _isInitialized;

  // Start listening for voice input
  static Future<String?> startListening() async {
    if (!_isInitialized) {
      bool initialized = await initializeVoiceServices();
      if (!initialized) return null;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          print('Speech result: ${result.recognizedWords}');
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: 'ar_SA', // Arabic
      );

      // Wait for speech recognition to complete
      await Future.delayed(const Duration(seconds: 5));

      String lastWords = _speechToText.lastRecognizedWords;
      await _speechToText.stop();

      return lastWords.isNotEmpty ? lastWords : null;
    } catch (e) {
      print('Error in speech recognition: $e');
      await _speechToText.stop();
      return null;
    }
  }

  // Stop listening
  static Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Convert text to speech
  static Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await initializeVoiceServices();
    }

    try {
      if (language != null) {
        await _flutterTts.setLanguage(language);
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('Error in text to speech: $e');
    }
  }

  // Stop speaking
  static Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Original chat functionality
  static Future<String> sendMessage(String message,
      {String? context, String? question}) async {
    final systemPrompt = """
أنت مساعد متخصص فقط في اضطراب طيف التوحد للأطفال.

التعليمات:
1. لا تجاوب على أي سؤال خارج التوحد.
2. استخدم المعلومات المتاحة إذا كانت موجودة في قاعدة المعرفة.
3. إذا لم تكن المعلومات كافية، اجاوب بما أعرفه عن التوحد فقط.
4. لا تعطي نصائح عامة عن السفر أو الطعام أو الأماكن أو أي شيء غير متعلق بالتوحد.
5. حافظ على إجابات مبسطة وواضحة للأهل والمعلمين.
6.خلى الاجابه قصيره علشان المستخدم ميملش من كتر القراه.

${context != null ? "المعلومات:\n$context\n\n" : ""}${question != null ? "السؤال:\n$question\n\n" : ""}الإجابة:""";

    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "openai/gpt-oss-120b",
        "messages": [
          {
            "role": "system",
            "content": systemPrompt,
          },
          {"role": "user", "content": message},
        ],
      }),
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"] ?? "لا يوجد رد";
    } else {
      return "حدث خطأ في الاتصال بالـ API";
    }
  }

  // Voice-enabled chat: listen -> process -> speak
  static Future<String?> voiceChat({String? context, String? question}) async {
    try {
      // 1. Listen to user voice
      String? userMessage = await startListening();
      if (userMessage == null || userMessage.isEmpty) {
        return "لم أتمكن من سماعك، يرجى المحاولة مرة أخرى";
      }

      // 2. Process with AI
      String aiResponse = await sendMessage(
        userMessage,
        context: context,
        question: question,
      );

      // 3. Speak the response
      await speak(aiResponse);

      return aiResponse;
    } catch (e) {
      print('Error in voice chat: $e');
      return "حدث خطأ في المحادثة الصوتية";
    }
  }
}
