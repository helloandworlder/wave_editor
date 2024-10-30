import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/logic.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSuffixesSetting(
            title: '全局文件后缀',
            suffixes: appController.defaultFileSuffixes,
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
