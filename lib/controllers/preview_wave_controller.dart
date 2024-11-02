import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wave_editor/logic/logic.dart';
import 'package:wave_editor/pages/preview_wave_page.dart';

class PreviewWaveController extends GetxController {
  final AppController appController = Get.find();

  final RxList<String> selectedWaveName = <String>[].obs;
  final RxList<String> selectedWaveDirection = <String>[].obs;
  final RxString selectedSuffix = ''.obs;
  final RxList<LineSeries<WaveformData, num>> seriesList =
      <LineSeries<WaveformData, num>>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedSuffix.value = appController.defaultWaveDirection.first;
    selectedWaveDirection.assignAll(appController.defaultWaveDirection);
  }

  Future<void> selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      appController.previewInputFolder.value = selectedDirectory;
    }
  }

  void plotWaveforms() {
    // 检查输入条件
    if (appController.previewInputFolder.isEmpty) {
      Get.snackbar('错误', '输入目录不能为空');
      return;
    } else if (selectedWaveName.isEmpty) {
      Get.snackbar('错误', '波形名称不能为空');
      return;
    } else if (selectedSuffix.isEmpty) {
      Get.snackbar('错误', '文件后缀不能为空');
      return;
    } else if (selectedWaveDirection.isEmpty) {
      Get.snackbar('错误', '波形方向不能为空');
      return;
    }

    seriesList.clear();

    // ... 原有的波形绘制逻辑 ...
  }

  void clearWaveforms() {
    seriesList.clear();
  }

  void updateWaveDirectionColor(String direction, Color color) {
    appController.waveDirectionColors[direction] = color;
    update();
  }
}
