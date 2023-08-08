import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class ApiProvider {
  final String baseUrl = 'https://reqres.in/api';
  final http.Client client = http.Client();

  Future<List<User>> getLocalUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('users');
    if (jsonString != null) {
      final jsonData = jsonDecode(jsonString);
      final users = (jsonData['data'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      return users;
    } else {
      return [];
    }
  }

  Future<void> saveUsersLocally(List<User> users) async {
    final jsonData = users.map((user) => user.toJson()).toList();
    final jsonString = jsonEncode({'data': jsonData});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('users', jsonString);
  }

  Future<List<User>> getUsers(int page, {int perPage = 12}) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUrl/users?page=$page&per_page=$perPage'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final users = (jsonData['data'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();

        // Save user data to shared_preferences
        await saveUsersLocally(users);

        return users;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      return getLocalUsers();
    }
  }

  Future<User> getUserDetails(int id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users/$id'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return User.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('users');
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);
        final users = (jsonData['data'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
        final user = users.firstWhere((user) => user.id == id,
            orElse: () => User.empty());
        return user;
      } else {
        throw Exception('Error fetching user details');
      }
    }
  }
}
