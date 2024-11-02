import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final RxList<String> defaultFileExtension = <String>['AT2', 'VT2', 'DT2'].obs;
  final RxList<String> defaultWaveDirection = <String>['H', 'HH', 'V'].obs;
  final RxList<String> defaultSeparator = <String>['-', '_'].obs;
  final RxString defaultWaveDirectionSeparator = '-'.obs;
  final RxBool useIncrementalNaming = true.obs;

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

    // 重命名输出文件夹与缩放输入文件夹双向绑定
    ever(renameOutputFolder,
        (_) => scaleInputFolder.value = renameOutputFolder.value);
    ever(scaleInputFolder,
        (_) => renameOutputFolder.value = scaleInputFolder.value);

    // 缩放输出文件夹与预览输入文件夹双向绑定
    ever(scaleOutputFolder,
        (_) => previewInputFolder.value = scaleOutputFolder.value);
    ever(previewInputFolder,
        (_) => scaleOutputFolder.value = previewInputFolder.value);

    // 波形方向颜色映射更新
    ever(
        defaultWaveDirection,
        (_) => waveDirectionColors.value = {
              for (var suffix in defaultWaveDirection)
                suffix: waveDirectionColors[suffix] ?? Colors.blue,
            });
  }
}
