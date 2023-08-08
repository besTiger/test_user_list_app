import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_screen_controller.dart';
import '../widgets/empty_list_widget.dart';
import '../widgets/end_of_list_widget.dart';
import '../widgets/user_list_item.dart';

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
            return const EmptyListWidget();
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
                    return UserListItem(user: user);
                  } else {
                    if (controller.isLoadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      // Check if data is unavailable and show the end message with delay
                      if (controller.isOffline || controller.currentPage > 1) {
                        return const EndOfListWidget();
                      } else {
                        return FutureBuilder(
                          future: Future.delayed(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else {
                              return const EndOfListWidget();
                            }
                          },
                        );
                      }
                    }
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}