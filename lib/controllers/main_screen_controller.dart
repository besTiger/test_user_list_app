import 'dart:convert';
import 'package:get/get.dart';
import '../screens/user_details_screen.dart';
import '../services/user_provider.dart';
import '../model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreenController extends GetxController {
  final ApiProvider apiProvider = ApiProvider();
  final RxList<User> users = <User>[].obs;
  bool isOffline = false;
  int currentPage = 1;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isOffline = false;
      currentPage = 1;
      final usersResponse = await apiProvider.getUsers(currentPage, perPage: 12);
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

  Future<void> loadMoreUsers() async {
    try {
      isLoadingMore = true;
      currentPage++;
      final usersResponse = await apiProvider.getUsers(currentPage, perPage: 12);
      if (usersResponse.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        Get.snackbar('End of List', 'No more users available.');
      } else {
        users.addAll(usersResponse);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading more users: $e');
      }
    } finally {
      isLoadingMore = false;
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
