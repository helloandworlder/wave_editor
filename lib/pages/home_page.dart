import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/logic.dart';
import 'package:wave_editor/pages/preview_wave_page.dart';
import 'package:wave_editor/pages/settings_page.dart';
import 'package:wave_editor/pages/http_server_page.dart';
import 'package:wave_editor/pages/file_rename_page.dart';
import 'package:wave_editor/pages/file_scale_page.dart';
import 'package:wave_editor/pages/about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AppController appController = Get.find<AppController>();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FileRenamePage(),
    const FileScalePage(),
    const WaveformPreviewPage(),
    const HttpServerPage(),
    const SettingsPage(),
    const AboutPage(),
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
        title: const Text('地震波处理工具'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.drive_file_rename_outline),
                label: Text('重命名'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.scale),
                label: Text('文件缩放'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.preview),
                label: Text('预览波形'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.http),
                label: Text('HTTP Server'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('设置'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                label: Text('关于'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
