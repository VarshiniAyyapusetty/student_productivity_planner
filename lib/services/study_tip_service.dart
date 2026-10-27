import 'dart:convert';

import 'package:http/http.dart' as http;

class StudyTipService {
  static final Uri _apiUri = Uri.parse('https://api.adviceslip.com/advice');

  Future<String> fetchStudyTip() async {
    final response = await http
        .get(_apiUri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Could not load a tip (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final slip = decoded['slip'] as Map<String, dynamic>?;
    final advice = slip?['advice'] as String?;

    if (advice == null || advice.trim().isEmpty) {
      throw const FormatException('The API returned an empty tip.');
    }

    return advice.trim();
  }
}
