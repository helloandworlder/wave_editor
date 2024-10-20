import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/app_controller.dart';
import 'package:wave_editor/pages/settings_page.dart';
import 'package:wave_editor/pages/http_server.dart';
import 'package:wave_editor/pages/rename_file.dart';
import 'package:wave_editor/pages/file_scale.dart'; // 添加这一行

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController appController = Get.find<AppController>();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RenameFilePage(),
    HttpServerPage(),
    FileScalePage(), // 添加这一行
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主页'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_file_rename_outline),
            label: '重命名',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.http),
            label: 'HTTP Server',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scale), // 添加这一行
            label: '文件缩放', // 添加这一行
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
