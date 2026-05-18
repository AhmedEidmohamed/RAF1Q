import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

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
}
