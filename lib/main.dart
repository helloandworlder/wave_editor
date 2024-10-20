import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/pages/home_page.dart';
import 'package:wave_editor/pages/settings_page.dart';
import 'package:wave_editor/pages/http_server.dart';
import 'package:wave_editor/logic/app_controller.dart';

void main() {
  Get.put(AppController()); // 在这里注入 AppController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '文件选择器演示',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/settings', page: () => SettingsPage()),
        GetPage(name: '/httpServer', page: () => HttpServerPage()),
      ],
    );
  }
}
