import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/logic.dart';
import 'dart:io';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path/path.dart' as path;
import 'package:wave_editor/components/wavename_selector.dart';

class PreviewWaveformPage extends StatefulWidget {
  const PreviewWaveformPage({super.key});
  @override
  PreviewWaveformPageState createState() => PreviewWaveformPageState();
}

class PreviewWaveformPageState extends State<PreviewWaveformPage> {
  final AppController appController = Get.find();

  final RxList<String> _selectedWaveName = <String>[].obs;
  final RxList<String> _selectedWaveDirection = <String>[].obs;
  final Rx<String> _selectedSuffix = ''.obs;

  final RxList<LineSeries<WaveformData, num>> _seriesList =
      <LineSeries<WaveformData, num>>[].obs;

  @override
  void initState() {
    super.initState();
    _selectedSuffix.value = appController.defaultWaveDirection.first;
    _selectedWaveDirection.assignAll(appController.defaultWaveDirection);
  }

  Future<void> _selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      appController.previewInputFolder.value = selectedDirectory;
    }
  }

  void _plotWaveforms() {
    // 检查输入目录是否为空
    if (appController.previewInputFolder.isEmpty) {
      Get.snackbar('错误', '输入目录不能为空');
      return;
    } else if (_selectedWaveName.isEmpty) {
      Get.snackbar('错误', '波形名称不能为空');
      return;
    } else if (_selectedSuffix.isEmpty) {
      Get.snackbar('错误', '文件后缀不能为空');
      return;
    } else if (_selectedWaveDirection.isEmpty) {
      Get.snackbar('错误', '波形方向不能为空');
      return;
    }

    _seriesList.clear(); // 清除之前的波形数据

    String waveName = _selectedWaveName.first;
    List<String> waveDirections = _selectedWaveDirection.toList();
    String selectedSuffix = _selectedSuffix.value;

    Directory srcFolder = Directory(appController.previewInputFolder.value);
    List<FileSystemEntity> files = srcFolder.listSync();

    try {
      for (FileSystemEntity entity in files) {
        if (entity is File) {
          String fileName = path.basename(entity.path);
          // 检查文件名是否以选定的波形名称开头，并且以选定的后缀结尾
          if (fileName.startsWith(waveName) &&
              fileName.endsWith('.$selectedSuffix')) {
            for (String waveDirection in waveDirections) {
              if (waveDirection == fileName.split('-')[1].split('.')[0]) {
                List<List<dynamic>> csvData =
                    CsvToListConverter().convert(entity.readAsStringSync());
                List<WaveformData> data = [];
                for (int i = 1; i < csvData.length; i++) {
                  data.add(WaveformData(csvData[i][0], csvData[i][1]));
                }

                // 使用 AppController 中的颜色映射
                Color waveColor =
                    appController.waveDirectionColors[waveDirection] ??
                        Colors.black;

                _seriesList.add(
                  LineSeries<WaveformData, num>(
                    dataSource: data,
                    xValueMapper: (WaveformData data, _) => data.x,
                    yValueMapper: (WaveformData data, _) => data.y,
                    color: waveColor, // 使用指定颜色
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('预览波形错误', e.toString());
    }
    setState(() {});
  }

  void _clearWaveforms() {
    _seriesList.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预览波形'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _selectSrcFolder,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '输入待预览波形目录',
                ),
                child: Obx(() => Text(
                    appController.previewInputFolder.isNotEmpty
                        ? appController.previewInputFolder.value
                        : '点击选择文件夹')),
              ),
            ),
            WaveformPrefixSelector(
              srcFolderPath: appController.previewInputFolder,
              selectedWaveName: _selectedWaveName,
            ),
            const SizedBox(height: 16),
            const Text('选择波形方向:'),
            Obx(() => Wrap(
                  spacing: 8.0,
                  children: appController.defaultWaveDirection.map((suffix) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            ChoiceChip(
                              label: Text(suffix),
                              selected: _selectedWaveDirection.contains(suffix),
                              onSelected: (selected) {
                                if (selected) {
                                  _selectedWaveDirection.add(suffix);
                                } else {
                                  _selectedWaveDirection.remove(suffix);
                                }
                              },
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: appController
                                        .waveDirectionColors[suffix],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // 添加颜色选择器
                                IconButton(
                                  icon: const Icon(Icons.color_lens),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('选择颜色'),
                                        content: SingleChildScrollView(
                                          child: ColorPicker(
                                            pickerColor: appController
                                                .waveDirectionColors[suffix]!,
                                            onColorChanged: (color) {
                                              setState(() {
                                                appController
                                                        .waveDirectionColors[
                                                    suffix] = color;
                                              });
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('确定'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),
            const Text('选择文件后缀:'),
            Obx(() => Wrap(
                  spacing: 8.0,
                  children: appController.defaultFileSuffixes.map((suffix) {
                    return ChoiceChip(
                      label: Text(suffix),
                      selected: _selectedSuffix.value == suffix,
                      onSelected: (selected) {
                        if (selected) {
                          _selectedSuffix.value = suffix;
                        }
                      },
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _plotWaveforms,
                  child: const Text('渲染波形'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _clearWaveforms,
                  child: const Text('清除波形'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SfCartesianChart(
                series: _seriesList,
                primaryXAxis: const NumericAxis(
                  initialZoomFactor: 0.5,
                  initialZoomPosition: 0.5,
                ),
                primaryYAxis: const NumericAxis(
                  initialZoomFactor: 0.5,
                  initialZoomPosition: 0.5,
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  zoomMode: ZoomMode.xy,
                  enableMouseWheelZooming: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 表示波形数据点的类
class WaveformData {
  final double x;
  final double y;

  WaveformData(this.x, this.y);
}
