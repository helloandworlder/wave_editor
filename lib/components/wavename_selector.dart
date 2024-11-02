import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:wave_editor/logic/logic.dart';

class WaveformPrefixSelector extends StatefulWidget {
  final RxString srcFolderPath;
  final RxList<String> selectedWaveName;
  final bool multiSelect;
  final bool defaultSelectAll;

  const WaveformPrefixSelector({
    super.key,
    required this.srcFolderPath,
    required this.selectedWaveName,
    this.multiSelect = false,
    this.defaultSelectAll = false,
  });

  @override
  State<WaveformPrefixSelector> createState() => _WaveformPrefixSelectorState();
}

class _WaveformPrefixSelectorState extends State<WaveformPrefixSelector> {
  final RxMap<String, List<String>> prefixMap = <String, List<String>>{}.obs;

  @override
  void initState() {
    super.initState();
    _refreshPrefixList();
    ever(widget.srcFolderPath, (_) => _refreshPrefixList());
  }

  void _refreshPrefixList() {
    if (widget.srcFolderPath.value.isNotEmpty) {
      final directory = Directory(widget.srcFolderPath.value);

      if (!directory.existsSync()) {
        debugPrint('目录不存在: ${widget.srcFolderPath.value}');
        return;
      }

      final files = directory.listSync().whereType<File>();
      final appController = Get.find<AppController>();
      final separators = appController.defaultSeparator;

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

      final prefixes = newPrefixMap.keys.toList();
      prefixMap.assignAll(newPrefixMap);
      widget.selectedWaveName
          .assignAll(widget.defaultSelectAll ? prefixes : []);
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
                () => Text('选择波形名称: ${widget.selectedWaveName.join(" | ")}'),
              ),
            ),
            ElevatedButton(
              onPressed: _refreshPrefixList,
              child: const Text('扫描'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            children: [
              for (final prefix in prefixMap.keys)
                ChoiceChip(
                  label: Text(prefix),
                  selected: widget.selectedWaveName.contains(prefix),
                  onSelected: (selected) {
                    if (selected) {
                      if (!widget.multiSelect) {
                        widget.selectedWaveName.assignAll([prefix]);
                      } else {
                        widget.selectedWaveName.add(prefix);
                      }
                    } else {
                      if (!widget.multiSelect) {
                        widget.selectedWaveName.assignAll([]);
                      } else {
                        widget.selectedWaveName.remove(prefix);
                      }
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
