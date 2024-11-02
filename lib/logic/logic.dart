import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final RxList<String> defaultFileExtension = <String>['AT2', 'VT2', 'DT2'].obs;
  final RxList<String> defaultWaveDirection = <String>['H', 'HH', 'V'].obs;
  final RxList<String> defaultSeparator = <String>['-', '_'].obs;
  final RxString defaultWaveDirectionSeparator = '-'.obs;
  final RxBool useIncrementalNaming = false.obs;

  final RxString renameInputFolder = ''.obs;
  final RxString renameOutputFolder = ''.obs;
  final RxString scaleInputFolder = ''.obs;
  final RxString scaleOutputFolder = ''.obs;
  final RxString previewInputFolder = ''.obs;

  // 添加波形方向到颜色的映射
  final RxMap<String, Color> waveDirectionColors = <String, Color>{
    'H': Colors.blue,
    'HH': Colors.green,
    'V': Colors.red,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    ever(renameOutputFolder,
        (_) => scaleInputFolder.value = renameOutputFolder.value);
    ever(scaleOutputFolder,
        (_) => previewInputFolder.value = scaleOutputFolder.value);
    ever(
        defaultWaveDirection,
        (_) => waveDirectionColors.value = {
              for (var suffix in defaultWaveDirection)
                suffix: waveDirectionColors[suffix] ?? Colors.blue,
            });
  }
}
