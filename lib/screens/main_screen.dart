import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_user_list_app/model/user_model.dart';
import 'package:test_user_list_app/screens/user_details_screen.dart';
import '../services/api_provider.dart';

class MainScreenController extends GetxController {
  final ApiProvider apiProvider = ApiProvider();
  final RxList<User> users = <User>[].obs;
  bool isOffline = false;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({int page = 1}) async {
    try {
      isOffline = false;
      final usersResponse = await apiProvider.getUsers(page, perPage: 12); // Update perPage value here
      users.assignAll(usersResponse);
    } catch (e) {
      isOffline = true;
      final localUsers = await getLocalUsers();
      users.assignAll(localUsers);
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    }
  }


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

  void onUserTap(int userId) {
    Get.to(() => UserDetailsScreen(userId: userId));
  }
}

class MainScreenWidget extends StatelessWidget {
  final MainScreenController controller = Get.put(MainScreenController());
  final ScrollController scrollController = ScrollController();

  MainScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
            () {
          final users = controller.users;
          if (users.isEmpty) {
            return _buildEmptyListWidget();
          } else {
            return RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () => controller.loadUsers(),
              child: ListView.separated(
                controller: scrollController,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                itemCount: users.length + 1,
                itemBuilder: (context, index) {
                  if (index < users.length) {
                    final user = users[index];
                    return ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar),
                          radius: 35,
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(fontSize: 22),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        controller.onUserTap(user.id);
                      },
                    );
                  } else {
                    return _buildEndOfListWidget();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyListWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEndOfListWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const Text(
        'End of List',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
