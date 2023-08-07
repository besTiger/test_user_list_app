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
        title: const Text(
          'User Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[50],
      ),
      body: Obx(
        () => _user.value != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_user.value!.avatar),
                        radius: 60.0,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${_user.value!.id}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Name: ${_user.value!.firstName} ${_user.value!.lastName}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Email: ${_user.value!.email}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          // Add other user details here
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
