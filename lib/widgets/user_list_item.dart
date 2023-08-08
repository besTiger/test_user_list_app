import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_screen_controller.dart';
import '../model/user_model.dart';


class UserListItem extends StatelessWidget {
  final User user;

  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final MainScreenController controller = Get.find();
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
  }
}
