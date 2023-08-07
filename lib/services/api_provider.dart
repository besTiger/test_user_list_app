import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class ApiProvider {
  final String baseUrl = 'https://reqres.in/api';
  final http.Client client = http.Client();

  Future<List<User>> getUsers(int page, int perPage) async {
    final response = await client.get(Uri.parse('$baseUrl/users?page=$page&per_page=$perPage'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final users = (jsonData['data'] as List).map((userJson) => User.fromJson(userJson)).toList();
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> getUserDetails(int id) async {
    final response = await client.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return User.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load user details');
    }
  }
}
