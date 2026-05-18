import 'package:flutter/material.dart';

class GlobalChatFAB extends StatelessWidget {
  const GlobalChatFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/chat');
      },
      backgroundColor: const Color(0xFF007aff),
      foregroundColor: Colors.white,
      elevation: 8,
      child: ClipOval(
        child: Image.asset(
          'assets/images/robot_avatar.png',
          width: 45,
          height: 45,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
