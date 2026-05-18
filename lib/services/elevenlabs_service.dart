import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ElevenLabsService {
  final String apiKey;

  // You can choose a child-like voice ID from ElevenLabs Dashboard
  // Example: "pNInz6obpgDQGcFmaJgB" (Adam) or search for "Child" voices
  final String voiceId =
      "EXAVITQu4vr4xnSDxMaL"; // Default Bella, update to a child voice ID

  ElevenLabsService({required this.apiKey});

  // 1. Transcription (Scribe v2)
  Future<String> transcribe(String filePath) async {
    try {
      print('ElevenLabs: Starting transcription for $filePath');
      final url = Uri.parse('https://api.elevenlabs.io/v1/speech-to-text');

      var request = http.MultipartRequest('POST', url);
      request.headers['xi-api-key'] = apiKey;

      final File audioFile = File(filePath);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
      ));

      request.fields['model_id'] = 'scribe_v2';
      request.fields['tag_audio_events'] = 'true';
      request.fields['language_code'] =
          'ara'; // Set to 'ara' for Arabic, or null for auto
      request.fields['diarize'] = 'true';

      print('ElevenLabs: Sending transcription request (Scribe v2)...');
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ElevenLabs Scribe returns a complex object, we extract the text
        return data['text'] ?? '';
      } else {
        print(
            'ElevenLabs STT Error: ${response.statusCode} - ${response.body}');
        return '';
      }
    } catch (e) {
      print('ElevenLabs STT Exception: $e');
      return '';
    }
  }

  // 2. Text-to-Speech (High Quality)
  Future<File?> speech(String text) async {
    try {
      final url =
          Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId');

      final response = await http.post(
        url,
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
          }
        }),
      );

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/elevenlabs_voice.mp3');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('ElevenLabs TTS Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('ElevenLabs TTS Exception: $e');
      return null;
    }
  }
}
