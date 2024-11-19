import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/logic.dart';
import 'package:wave_editor/utils/file_scaler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wave_editor/components/wavename_selector.dart';

class FileScalePage extends StatefulWidget {
  const FileScalePage({super.key});

  @override
  FileScalePageState createState() => FileScalePageState();
}

class FileScalePageState extends State<FileScalePage> {
  final AppController appController = Get.find();

  final RxList<String> _selectedWaveName = <String>[].obs;
  final TextEditingController _targetValueController = TextEditingController();
  final RxSet<String> _targetFileSuffix = <String>{}.obs;
  final RxDouble _progress = 0.0.obs;   

  @override
  void initState() {
    super.initState();
    _targetFileSuffix.assignAll(appController.defaultFileExtension);
  }

  Future<void> _selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      appController.scaleInputFolder.value = selectedDirectory;
    }
  }

  Future<void> _selectDstFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      appController.scaleOutputFolder.value = selectedDirectory;
    }
  }

  void _processFileScale() async {
    if (appController.scaleInputFolder.isEmpty) {
      Get.snackbar('错误', '输入目录不能为空');
      return;
    } else if (appController.scaleOutputFolder.isEmpty) {
      Get.snackbar('错误', '输出目录不能为空');
      return;
    } else if (_targetFileSuffix.isEmpty) {
      Get.snackbar('错误', '文件后缀不能为空');
      return;
    } else if (_targetValueController.text.isEmpty) {
      Get.snackbar('错误', '目标幅值不能为空');
      return;
    } else if (_selectedWaveName.isEmpty) {
      Get.snackbar('错误', '波形名称不能为空');
      return;
    }

    try {
      double targetValue = double.parse(_targetValueController.text);
      List<String> prefix =
          _selectedWaveName.isNotEmpty ? _selectedWaveName.toList() : [];
      List<String> suffixes = _targetFileSuffix.toList();

      FileScaler fileScaler = FileScaler(
        onProgress: (progress) async {
          _progress.value = progress;
          debugPrint('progress: ${_progress.value}');
        },
      );
      final startTime = DateTime.now();

      await fileScaler.processFileScale(
        appController.scaleInputFolder.value,
        appController.scaleOutputFolder.value,
        targetValue,
        suffixes,
        prefix,
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('处理消耗时间: ${duration.inMilliseconds} 毫秒');
      Get.snackbar('调幅完成', '处理消耗时间: ${duration.inMilliseconds} 毫秒');
    } catch (e) {
      Get.snackbar('调幅错误', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据调幅处理'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _selectSrcFolder,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: '输入待调幅目录'),
                child: Obx(() => Text(appController.scaleInputFolder.isNotEmpty
                    ? appController.scaleInputFolder.value
                    : '点击选择文件夹')),
              ),
            ),
            WaveformPrefixSelector(
              srcFolderPath: appController.scaleInputFolder,
              selectedWaveName: _selectedWaveName,
              multiSelect: true,
              defaultSelectAll: true,
            ),
            InkWell(
              onTap: _selectDstFolder,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: '目标目录'),
                child: Obx(() => Text(appController.scaleOutputFolder.isNotEmpty
                    ? appController.scaleOutputFolder.value
                    : '点击选择文件夹')),
              ),
            ),
            TextField(
              controller: _targetValueController,
              decoration: const InputDecoration(labelText: '输入调幅目标幅值(浮点)'),
            ),
            const SizedBox(height: 16),
            const Text('选择文件后缀:'),
            Obx(() => Wrap(
                  spacing: 8.0,
                  children: appController.defaultFileExtension.map((suffix) {
                    return ChoiceChip(
                      label: Text(suffix),
                      selected: _targetFileSuffix.contains(suffix),
                      onSelected: (selected) {
                        if (selected) {
                          _targetFileSuffix.add(suffix);
                        } else {
                          _targetFileSuffix.remove(suffix);
                        }
                      },
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),
            Obx(() {
              debugPrint('Obx rebuild: progress = ${_progress.value}');
              return LinearProgressIndicator(value: _progress.value);
            }),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _processFileScale,
                child: const Text('开始调幅'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
