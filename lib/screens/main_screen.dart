import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_user_list_app/model/user_model.dart';
import 'package:test_user_list_app/screens/user_details_screen.dart';
import '../services/api_provider.dart';

class MainScreen extends GetxController {
  final ApiProvider apiProvider = ApiProvider();
  final RxList<User> users = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  void _loadUsers() async {
    try {
      final List<User> userList = [];
      for (int page = 1; page <= 2; page++) {
        final usersResponse = await apiProvider.getUsers(page);
        userList.addAll(usersResponse);
      }
      users.assignAll(userList);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    }
  }

  void onUserTap(int userId) {
    Get.to(() => UserDetailsScreen(userId: userId));
  }
}

class MainScreenWidget extends StatelessWidget {
  final MainScreen controller = Get.put(MainScreen());

  MainScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Obx(
        () {
          final users = controller.users;
          if (users.isEmpty) {
            return _buildEmptyListWidget();
          } else {
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text(user.email),
                  onTap: () {
                    controller.onUserTap(user.id);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyListWidget() {
    return const Center(child: CircularProgressIndicator());
  }
}
