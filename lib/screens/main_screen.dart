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
    loadUsers(); // Use the public method to load users on initialization
  }

  Future<void> loadUsers() async {
    try {
      final List<User> userList = [];
      const int perPage = 12;
      for (int page = 1; page <= 2; page++) {
        final usersResponse = await apiProvider.getUsers(page, perPage);
        userList.addAll(usersResponse);
      }
      users.assignAll(userList);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading users: $e');
      }
    }
  }

  Future<void> loadMoreUsers() async {
    try {
      final List<User> userList = [];
      const int perPage = 12;
      for (int page = 3; page <= 4; page++) {
        final usersResponse = await apiProvider.getUsers(page, perPage);
        userList.addAll(usersResponse);
      }
      users.addAll(userList);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading more users: $e');
      }
    }
  }

  void onUserTap(int userId) {
    Get.to(() => UserDetailsScreen(userId: userId));
  }
}

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({Key? key}) : super(key: key);

  @override
  MainScreenWidgetState createState() => MainScreenWidgetState();
}

class MainScreenWidgetState extends State<MainScreenWidget> {
  final MainScreen controller = Get.put(MainScreen());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_loadMoreDataIfScrolledToBottom);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _loadMoreDataIfScrolledToBottom() {
    if (scrollController.position.extentAfter < 200) {
      controller.loadMoreUsers();
    }
  }

  Future<void> _refreshData() async {
    await controller.loadUsers(); // Call the loadUsers method to refresh data
  }

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
              onRefresh: _refreshData,
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
