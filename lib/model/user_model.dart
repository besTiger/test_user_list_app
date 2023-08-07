import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
    );
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get('https://reqres.in/api/users?page=2' as Uri);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final List<User> users = [];
    for (var userJson in jsonData['data']) {
      users.add(User.fromJson(userJson));
    }
    return users;
  } else {
    throw Exception('Failed to load users');
  }
}
