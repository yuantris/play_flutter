import 'dart:io';

import 'package:flutter/material.dart';
import 'package:play_flutter/ui/home/HomeScreen.dart';
import 'package:play_flutter/ui/set/SettingsScreen.dart';
import 'ui/screens/splash_screen.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());

  // if (Platform.isAndroid) {
  //   // Android 小白条沉浸  测试无用  直接在style.xml配置有效
  //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent,
  //       systemNavigationBarColor: Colors.transparent);
  //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // }
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Play Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
