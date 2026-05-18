import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  final List<Map<String, String>> _history = [];

  GeminiService({required this.apiKey}) {
    // Add system instruction as the first message
    _history.add({
      'role': 'user',
      'parts': 'أنت مساعد علاجي متخصص في مساعدة الأطفال المصابين بالتوحد على تطوير مهارات التواصل الاجتماعي. اسمك "رفيق". مهمتك هي إجراء محادثة بسيطة وودودة وممتعة مع الطفل. استخدم لغة عربية بسيطة. في كل رد، قم بتقييم "مستوى التفاعل الاجتماعي" للطفل بشكل مخفي (بين قوسين في نهاية الرد) باستخدام صيغة JSON كالتالي: {"score": 1-10, "feedback": "ملاحظة فنية للدكتور", "sentiment": "إيجابي"}'
    });
    _history.add({
      'role': 'model',
      'parts': 'حاضر، أنا جاهز لمساعدة الأطفال كصديقهم رفيق. كيف يمكنني مساعدتك اليوم؟'
    });
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      _history.add({'role': 'user', 'parts': message});

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': _history.map((e) => {
            'role': e['role'],
            'parts': [{'text': e['parts']}]
          }).toList(),
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        _history.add({'role': 'model', 'parts': text});

        // Extract hidden analysis
        final RegExp regExp = RegExp(r'(\{.*\})');
        final match = regExp.firstMatch(text);
        String cleanResponse = text.replaceAll(regExp, '').trim();

        return {
          'response': cleanResponse,
          'analysis': match?.group(0) ?? '',
        };
      } else {
        print('Gemini HTTP Error: ${response.body}');
        return {
          'response': 'عذراً، حدث خطأ في الاتصال بصديقك رفيق. (Status: ${response.statusCode})',
          'analysis': '',
        };
      }
    } catch (e) {
      print('Gemini Error: $e');
      return {
        'response': 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.',
        'analysis': '',
      };
    }
  }
}
