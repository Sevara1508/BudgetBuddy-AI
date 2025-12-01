import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // load the key from .env
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  final String _url = "https://api.openai.com/v1/chat/completions";

  Future<String> sendPrompt(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception("Missing API key. Add OPENAI_API_KEY to .env");
    }

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "max_tokens": 200,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["choices"][0]["message"]["content"];
    } else {
      throw Exception("api call failed with status ${response.statusCode}\n${response.body}");
    }
  }

  Future<String> weeklySummary(List<Map<String, dynamic>> transactions) async {
    final prompt = """
summarize this week’s spending in 3 sentences. be concise.

transactions:
${jsonEncode(transactions)}
""";
    return await sendPrompt(prompt);
  }

  Future<String> dailyTip() async {
    const prompt = "give a short budgeting tip of the day. keep it to one sentence.";
    return await sendPrompt(prompt);
  }
}
