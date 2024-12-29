import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskSubmitService {
  static Future<Map<String, dynamic>> submitTask(String inputText) async {
    print('TaskSubmitService: Starting request');
    try {
    final response = await http.post(
      Uri.parse(
          'https://still-inlet-59136-d4ddfc326659.herokuapp.com/parse_task'),
      // Heroku cloud backend URL
      headers: {'Content-Type': 'application/json',
                'Accept': 'application/json'},
      body: json.encode({'input_text': inputText}),
    );


    print('TaskSubmitService: Response status code: ${response.statusCode}');
    print('TaskSubmitService: Response body: ${response.body}');


    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          "Failed to submit task. Status code: ${response.statusCode}");
    }
  } catch (e) {
  print('TaskSubmitService: Error occurred: $e');
  throw Exception("Network error: $e");
    }
  }
}
