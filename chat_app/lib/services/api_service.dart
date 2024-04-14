import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:7777';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({'username': username, 'password': password});
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> signUp(String username, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final body = jsonEncode({'username': username, 'password': password});
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

}
