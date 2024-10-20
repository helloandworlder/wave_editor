import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/app_controller.dart';

class SettingsPage extends StatelessWidget {
  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   title: Text('设置项1'),
          //   trailing: Switch(
          //     value: appController.setting1.value,
          //     onChanged: (value) => appController.setting1.value = value,
          //   ),
          // ),
          // 其他设置项...
        ],
      ),
    );
  }
}
