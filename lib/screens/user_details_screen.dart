import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/user_model.dart';
import '../services/api_provider.dart';

class UserDetailsScreen extends StatelessWidget {
  final int userId;
  final _user = Rx<User?>(null);

  UserDetailsScreen({super.key, required this.userId}) {
    _loadUser();
  }

  void _loadUser() {
    final apiProvider = ApiProvider();
    apiProvider.getUserDetails(userId).then((user) {
      _user.value = user;
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Obx(
        () => _user.value != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(_user.value!.avatar),
                      radius: 50.0,
                    ),
                    const SizedBox(height: 20),
                    Text('ID: ${_user.value!.id}'),
                    const SizedBox(height: 10),
                    Text(
                        'Name: ${_user.value!.firstName} ${_user.value!.lastName}'),
                    const SizedBox(height: 10),
                    Text('Email: ${_user.value!.email}'),
                    // Add other user details here
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
