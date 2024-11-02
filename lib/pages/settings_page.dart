import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/logic.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSuffixesSetting(
            title: '全局文件后缀',
            suffixes: appController.defaultFileExtension,
          ),
          _buildSuffixesSetting(
            title: '全局波形方向',
            suffixes: appController.defaultWaveDirection,
          ),
          _buildSuffixesSetting(
            title: '全局分隔符',
            suffixes: appController.defaultSeparator,
          ),
          _buildWaveDirectionColorSetting(appController),
          ListTile(
            title: Obx(() => Text(
                '文件命名方式: ${appController.useIncrementalNaming.value ? '自增数字' : '原文件前缀'}')),
            subtitle: const Text('选择使用自增数字(1,2,3...)或使用原文件前缀命名文件'),
            trailing: Obx(() => Switch(
                  value: appController.useIncrementalNaming.value,
                  onChanged: (value) {
                    appController.useIncrementalNaming.value = value;
                  },
                )),
          ),
          ListTile(
            title: const Text('默认波形方向分隔符'),
            subtitle: const Text('设置波形方向识别符'),
            trailing: SizedBox(
              width: 80,
              child: Obx(() => TextField(
                    textAlign: TextAlign.center,
                    controller: TextEditingController(
                      text: appController.defaultWaveDirectionSeparator.value,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        appController.defaultWaveDirectionSeparator.value =
                            value;
                      }
                    },
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuffixesSetting({
    required String title,
    required RxList<String> suffixes,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Obx(() => Wrap(
            spacing: 8,
            children: [
              ...suffixes.map((suffix) => _buildSuffixChip(suffix, suffixes)),
              ActionChip(
                label: const Icon(Icons.add),
                onPressed: () async {
                  final newSuffix =
                      await Get.dialog<String>(_NewSuffixDialog());
                  if (newSuffix != null && newSuffix.isNotEmpty) {
                    suffixes.add(newSuffix);
                  }
                },
              ),
            ],
          )),
    );
  }

  Widget _buildSuffixChip(String suffix, RxList<String> suffixes) {
    return Chip(
      label: Text(suffix),
      deleteIcon: const Icon(Icons.close),
      onDeleted: () => suffixes.remove(suffix),
    );
  }
}

Widget _buildWaveDirectionColorSetting(AppController appController) {
  return ListTile(
    title: const Text('波形方向颜色'),
    subtitle: Obx(() => Wrap(
          spacing: 10,
          children: appController.waveDirectionColors.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(entry.key),
                        const SizedBox(width: 4),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: entry.value),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.color_lens),
                          onPressed: () async {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('选择颜色'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: appController
                                        .waveDirectionColors[entry.key]!,
                                    onColorChanged: (color) {
                                      appController
                                              .waveDirectionColors[entry.key] =
                                          color;
                                    },
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('确定'),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ))
              .toList(),
        )),
  );
}

class _NewSuffixDialog extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新字段'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: '请输入新的字段'),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Get.back(result: _controller.text.trim()),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
