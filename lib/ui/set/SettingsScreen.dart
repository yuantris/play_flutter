
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('个人信息'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知设置'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('隐私与安全'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于我们'),
            onTap: () {},
          )
        ],
      ),
    );
  }
}