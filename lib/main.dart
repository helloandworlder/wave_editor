import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/pages/about_page.dart';
import 'package:wave_editor/pages/file_rename_page.dart';
import 'package:wave_editor/pages/file_scale_page.dart';
import 'package:wave_editor/pages/home_page.dart';
import 'package:wave_editor/pages/preview_wave_page.dart';
import 'package:wave_editor/pages/settings_page.dart';
import 'package:wave_editor/pages/http_server_page.dart';
import 'package:wave_editor/logic/logic.dart';

void main() {
  Get.put(AppController()); // 在这里注入 AppController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // 移除调试标记
      showSemanticsDebugger: false, // 关闭语义调试
      showPerformanceOverlay: false,
      title: '地震波处理工具',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: Platform.isWindows ? '微软雅黑' : null,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/renameFile', page: () => const FileRenamePage()),
        GetPage(name: '/scaleFile', page: () => const FileScalePage()),
        GetPage(name: '/previewWave', page: () => const WaveformPreviewPage()),
        GetPage(name: '/httpServer', page: () => const HttpServerPage()),
        GetPage(name: '/settings', page: () => const SettingsPage()),
        GetPage(name: '/about', page: () => const AboutPage()),
      ],
    );
  }
}
