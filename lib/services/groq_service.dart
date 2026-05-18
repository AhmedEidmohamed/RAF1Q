import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class GroqService {
  final String apiKey;

  GroqService({required this.apiKey});

  // 1. Transcription (Whisper)
  Future<String> transcribe(String filePath) async {
    try {
      print('Groq: Starting transcription for $filePath');
      final url =
          Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $apiKey';

      final File audioFile = File(filePath);
      if (!await audioFile.exists()) {
        print('Groq: File does not exist');
        return '';
      }

      final List<int> bytes = await audioFile.readAsBytes();
      print('Groq: Read ${bytes.length} bytes');

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'audio.mp3',
        contentType: MediaType('audio', 'mpeg'),
      ));

      request.fields['model'] = 'whisper-large-v3-turbo';
      request.fields['language'] = 'ar';
      request.fields['prompt'] = 'هذه محادثة بسيطة مع طفل، لا يوجد موسيقى ولا أسماء مشاهير، فقط كلام طفولي بريء.';
      request.fields['response_format'] = 'json';

      print('Groq: Sending request...');
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      print('Groq: Request sent, status: ${streamedResponse.statusCode}');

      var response = await http.Response.fromStream(streamedResponse);
      print('Groq: Response body received: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? '';
      } else {
        print('Groq Transcription Error Status: ${response.statusCode}');
        print('Groq Transcription Error Body: ${response.body}');
        return '';
      }
    } catch (e) {
      print('Groq Error during transcription: $e');
      return '';
    }
  }

  // 2. Chat (Llama 3) - Optional but faster than Gemini
  Future<Map<String, dynamic>> chat(
      String message, List<Map<String, String>> history) async {
    try {
      print('Groq Chat: Sending request for message: $message');
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'أنت "رفيق"، صديق مصري مريح جداً للأطفال. '
                  'ممنوع تماماً استخدام اللغة العربية الفصحى. '
                  'مهمتك إجراء حوار بطيء، مريح، ومتسلسل مع الطفل للتعرف عليه وعلى عائلته واهتماماته. '
                  'قواعد هامة جداً: اسأل سؤالاً واحداً فقط في كل مرة، وانتظر إجابته قبل أن تنتقل للسؤال الذي يليه. لا تسأل عدة أسئلة معاً أبداً.\n'
                  'تحدث ببطء بنبرة محببة للأطفال، ويمكنك مد حرف أو حرفين فقط بشكل خفيف جداً (مثل: شااطر، برافوو، يا سلاام).\n'
                  'تجنب تكرار كلمة "ممتاز"، واستخدم بدلاً منها كلمات تشجيعية، مع استخدام إيموجي التصفيق والنجوم (مثل ⭐ و 👏 و 🎉) عندما يجيب بشكل صحيح.\n'
                  'تسلسل الأسئلة (امشِ خطوة بخطوة):\n'
                  '1. ابدأ بسؤاله: عامل إيه يا بطل؟ أو أخبارك إيه النهاردة؟ (وهذا ما ستبدأ به).\n'
                  '2. بعد أن يجيب، اسأله عن اسمه: اسمك إيه الجميل ده؟\n'
                  '3. بعد أن يجيب، اسأله عن عمره: عندك كام سنة يا بطل؟\n'
                  '4. بعد أن يجيب، اسأله عن والدته: ماما الجميلة اسمها إيه؟\n'
                  '5. بعد أن يجيب، اسأله عن والده: بابا حبيبي اسمه إيه؟\n'
                  '6. بعد أن يجيب، اسأله عن إخوته: عندك إخوات؟ (سؤال واحد فقط).\n'
                  '7. بعد أن يجيب، اسأله عن أسمائهم (إن وجدوا): اسمهم إيه بقى؟\n'
                  '8. بعد أن يجيب، اسأله عن مدرسته أو حضانته: بتروح مدرسة إيه؟\n'
                  '9. بعد أن يجيب، اسأله عن ألعابه: بتحب تلعب لعبة إيه أكتر حاجة؟\n'
                  '10. بعد أن يجيب، اسأله عن أكله المفضل: بتحب تاكل إيه؟\n'
                  '11. بعد أن يجيب، اسأله عن لونه المفضل: إيه أكتر لون بتحبه؟\n\n'
                  'ملاحظة هامة جداً: بعد كل إجابة من الطفل، شجعه وامدحه بكلمات فيها مد خفيف مثل "برافوو يا بطل! 👏⭐"، "شااطر جداً! 🎉"، ثم اطرح السؤال التالي فقط.\n'
                  'في نهاية كل رد من ردودك، يجب أن تقوم بتقييم سلوك الطفل وتفاعله بناءً على كلامه (هل هو متردد، خجول، متجاوب، إلخ). '
                  'أضف هذا التقييم كـ كود JSON مخفي في نهاية النص تماماً بهذا الشكل الدقيق: '
                  '{"behavior_analysis": "تحليلك لسلوك الطفل هنا", "score": 8} '
                  'لا تجعل الطفل يلاحظ هذا الكود أبداً.'
            },
            ...history.map((e) => {
                  'role': e['role'],
                  'content': e['parts'] ?? e['content']
                }),
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
        }),
      );

      print('Groq Chat: Status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = data['choices'][0]['message']['content'];
        print('Groq Chat: Response received');

        // Extract hidden JSON analysis if present
        final RegExp regExp = RegExp(r'(\{.*"behavior_analysis".*\})');
        final match = regExp.firstMatch(text);
        String cleanResponse = text.replaceAll(regExp, '').trim();
        String analysisJson = match?.group(0) ?? '';

        return {
          'response': cleanResponse,
          'analysis': analysisJson,
        };
      } else {
        print('Groq Chat Error Body: ${response.body}');
        return {'response': 'خطأ في الاتصال بـ Groq', 'analysis': ''};
      }
    } catch (e) {
      print('Groq Chat Exception: $e');
      return {'response': 'خطأ غير متوقع', 'analysis': ''};
    }
  }

  // 3. Text-to-Speech (OpenAI compatible TTS)
  Future<File?> speech(String text) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/audio/speech');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'tts-1', // Groq's TTS model
          'input': text,
          'voice': 'fable', // 'fable' is the most playful and youthful voice
        }),
      );

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/response_audio.mp3');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Groq TTS Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Groq TTS Error: $e');
      return null;
    }
  }
}
