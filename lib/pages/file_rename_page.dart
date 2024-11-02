import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/logic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wave_editor/utils/file_rename.dart';

class FileRenamePage extends StatefulWidget {
  const FileRenamePage({super.key});
  @override
  FileRenamePageState createState() => FileRenamePageState();
}

class FileRenamePageState extends State<FileRenamePage> {
  final AppController appController = Get.find();
  List<String> targetFileSuffix = <String>[];

  @override
  void initState() {
    super.initState();
    targetFileSuffix.assignAll(appController.defaultFileExtension);
  }

  Future<void> _selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        appController.renameInputFolder.value = selectedDirectory;
      });
    }
  }

  Future<void> _selectDstFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        appController.renameOutputFolder.value = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据批量命名/格式化'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _selectSrcFolder,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '待格式化文件夹目录',
                  ),
                  child: Text(appController.renameInputFolder.isNotEmpty
                      ? appController.renameInputFolder.value
                      : '点击选择文件夹'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('选择后缀(可多选)'),
              Obx(() => Wrap(
                    spacing: 8.0,
                    children: appController.defaultFileExtension.map((suffix) {
                      return ChoiceChip(
                        label: Text(suffix),
                        selected: targetFileSuffix.contains(suffix),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              targetFileSuffix.add(suffix);
                            } else {
                              targetFileSuffix.remove(suffix);
                            }
                          });
                        },
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDstFolder,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '目标文件夹目录',
                  ),
                  child: Text(appController.renameOutputFolder.isNotEmpty
                      ? appController.renameOutputFolder.value
                      : '点击选择文件夹'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // 检查输入输出目录是否为空
                    if (appController.renameInputFolder.isEmpty) {
                      Get.snackbar('错误', '输入目录不能为空');
                      return;
                    } else if (appController.renameOutputFolder.isEmpty) {
                      Get.snackbar('错误', '输出目录不能为空');
                      return;
                    } else if (targetFileSuffix.isEmpty) {
                      Get.snackbar('错误', '文件后缀不能为空');
                      return;
                    }
                    // 捕获异常
                    try {
                      FileProcessor(
                        appController.renameInputFolder.value,
                        appController.renameOutputFolder.value,
                        fileExtension: targetFileSuffix,
                      ).process();
                    } catch (e) {
                      Get.snackbar('重命名/格式化错误', e.toString());
                    }
                  },
                  child: const Text('开始格式化'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
