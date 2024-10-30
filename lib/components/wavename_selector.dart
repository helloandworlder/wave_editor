import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:wave_editor/logic/logic.dart';

class WaveformPrefixSelector extends StatelessWidget {
  final RxString srcFolderPath;
  final RxList<String> selectedWaveName;
  final bool multiSelect;
  final bool defaultSelectAll;

  // 将 prefixMap 定义为类的属性
  final RxMap<String, List<String>> prefixMap = <String, List<String>>{}.obs;

  WaveformPrefixSelector({
    required this.srcFolderPath,
    required this.selectedWaveName,
    this.multiSelect = false,
    this.defaultSelectAll = false,
  });

  void _refreshPrefixList() {
    if (srcFolderPath.value.isNotEmpty) {
      final directory = Directory(srcFolderPath.value);

      // 检查目录是否存在
      if (!directory.existsSync()) {
        print('目录不存在: ${srcFolderPath.value}');
        return;
      }

      final files = directory.listSync().whereType<File>();
      final appController = Get.find<AppController>();
      final separators = appController.defaultSeparator;

      // 提取所有文件名的前缀部分
      final newPrefixMap = <String, List<String>>{};
      for (final file in files) {
        final fileName = path.basename(file.path);
        String? prefix;

        for (final separator in separators) {
          final parts = fileName.split(separator);
          if (parts.isNotEmpty) {
            prefix = parts.first;
            break;
          }
        }

        if (prefix != null) {
          newPrefixMap.putIfAbsent(prefix, () => []).add(fileName);
        }
      }

      // 找出具有相同前缀的文件组成的前缀
      final prefixes = newPrefixMap.keys.toList();
      prefixMap.assignAll(newPrefixMap); // 更新 prefixMap
      selectedWaveName.assignAll(defaultSelectAll ? prefixes : []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Text('选择波形名称: ${selectedWaveName.join(" |")}'),
              ),
            ),
            ElevatedButton(
              onPressed: _refreshPrefixList,
              child: Text('扫描'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            children: [
              for (final prefix in prefixMap.keys) // 使用 prefixMap 的键
                ChoiceChip(
                  label: Text(prefix),
                  selected: selectedWaveName.contains(prefix),
                  onSelected: (selected) {
                    if (selected) {
                      if (!multiSelect)
                        selectedWaveName.assignAll([prefix]);
                      else
                        selectedWaveName.add(prefix);
                    } else {
                      selectedWaveName.remove(prefix);
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
