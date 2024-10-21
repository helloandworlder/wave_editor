import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

class PreviewWaveformPage extends StatefulWidget {
  @override
  _PreviewWaveformPageState createState() => _PreviewWaveformPageState();
}

class _PreviewWaveformPageState extends State<PreviewWaveformPage> {
  String _srcFolderPath = ''; // 存储选择的源文件夹路径
  final TextEditingController _prefixController =
      TextEditingController(); // 用于输入文件前缀的控制器
  String _selectedSuffix = 'AT2'; // 默认选中的文件后缀
  List<String> _selectedWaveTypes = []; // 存储选中的波形类型
  List<LineSeries<WaveformData, num>> _seriesList = []; // 存储绘制的波形数据系列

  // 选择源文件夹
  Future<void> _selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _srcFolderPath = selectedDirectory;
      });
    }
  }

  // 绘制波形图
  void _plotWaveforms() {
    String srcFolderPath = _srcFolderPath;
    String prefix = _prefixController.text;
    String suffix = _selectedSuffix;
    List<String> waveTypes = _selectedWaveTypes;

    _seriesList.clear(); // 清空之前的波形数据系列

    Directory srcFolder = Directory(srcFolderPath);
    List<FileSystemEntity> files = srcFolder.listSync();

    Map<String, Color> colors = {
      'H': Colors.blue,
      'HH': Colors.green,
      'V': Colors.red,
    };

    for (FileSystemEntity entity in files) {
      if (entity is File) {
        String fileName = path.basename(entity.path);
        if (fileName.startsWith(prefix) && fileName.endsWith(suffix)) {
          String waveType = fileName.split('-')[1].split('.')[0];
          if (waveTypes.contains(waveType)) {
            List<List<dynamic>> csvData =
                CsvToListConverter().convert(entity.readAsStringSync());
            List<WaveformData> data = [];
            for (int i = 1; i < csvData.length; i++) {
              data.add(WaveformData(csvData[i][0], csvData[i][1]));
            }
            _seriesList.add(
              LineSeries<WaveformData, num>(
                dataSource: data,
                xValueMapper: (WaveformData data, _) => data.x,
                yValueMapper: (WaveformData data, _) => data.y,
                color: colors[waveType],
              ),
            );
          }
        }
      }
    }

    setState(() {}); // 触发重新构建界面
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('预览波形'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _selectSrcFolder,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '输入待预览波形目录',
                ),
                child: Text(
                    _srcFolderPath.isNotEmpty ? _srcFolderPath : '点击选择文件夹'),
              ),
            ),
            TextField(
              controller: _prefixController,
              decoration: InputDecoration(
                labelText: '输入目标波形前缀(仅可输入一个)',
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedSuffix,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSuffix = newValue!;
                });
              },
              items: <String>['AT2', 'VT2', 'DT2']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: '选择后缀(单选)',
              ),
            ),
            Wrap(
              children: [
                CheckboxListTile(
                  title: Text('H'),
                  value: _selectedWaveTypes.contains('H'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        _selectedWaveTypes.add('H');
                      } else {
                        _selectedWaveTypes.remove('H');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('HH'),
                  value: _selectedWaveTypes.contains('HH'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        _selectedWaveTypes.add('HH');
                      } else {
                        _selectedWaveTypes.remove('HH');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('V'),
                  value: _selectedWaveTypes.contains('V'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        _selectedWaveTypes.add('V');
                      } else {
                        _selectedWaveTypes.remove('V');
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _plotWaveforms,
              child: Text('渲染波形'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SfCartesianChart(
                series: _seriesList,
                primaryXAxis: NumericAxis(
                  initialZoomFactor: 0.5, // 设置初始缩放比例
                  initialZoomPosition: 0.5, // 设置初始缩放位置
                ),
                primaryYAxis: NumericAxis(
                  initialZoomFactor: 0.5,
                  initialZoomPosition: 0.5,
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true, // 启用双指缩放
                  enablePanning: true, // 启用拖动
                  zoomMode: ZoomMode.xy, // 同时缩放 X 轴和 Y 轴
                  enableMouseWheelZooming: true, // 启用鼠标滚轮缩放
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
