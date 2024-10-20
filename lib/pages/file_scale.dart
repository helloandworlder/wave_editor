import 'package:flutter/material.dart';
import 'package:wave_editor/utils/file_scaler.dart';
import 'package:file_picker/file_picker.dart';

class FileScalePage extends StatefulWidget {
  @override
  _FileScalePageState createState() => _FileScalePageState();
}

class _FileScalePageState extends State<FileScalePage> {
  String _srcFolderPath = '';
  String _dstFolderPath = '';
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final List<String> _suffixes = ['.AT2', '.VT2', '.DT2'];
  List<String> _selectedSuffixes = [];

  Future<void> _selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _srcFolderPath = selectedDirectory;
      });
    }
  }

  Future<void> _selectDstFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _dstFolderPath = selectedDirectory;
      });
    }
  }

  void _processFileScale() {
    double targetValue = double.parse(_targetValueController.text);
    List<String> prefixList = _prefixController.text.split('/');

    FileScaler fileScaler = FileScaler();
    fileScaler.processFileScale(_srcFolderPath, _dstFolderPath, targetValue,
        _selectedSuffixes, prefixList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('数据调幅处理'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _selectSrcFolder,
              child: InputDecorator(
                decoration: InputDecoration(labelText: '输入待调幅目录'),
                child: Text(
                    _srcFolderPath.isNotEmpty ? _srcFolderPath : '点击选择文件夹'),
              ),
            ),
            InkWell(
              onTap: _selectDstFolder,
              child: InputDecorator(
                decoration: InputDecoration(labelText: '->目标目录'),
                child: Text(
                    _dstFolderPath.isNotEmpty ? _dstFolderPath : '点击选择文件夹'),
              ),
            ),
            TextField(
              controller: _targetValueController,
              decoration: InputDecoration(labelText: '输入调幅目标幅值(浮点)'),
            ),
            TextField(
              controller: _prefixController,
              decoration: InputDecoration(labelText: '输入目标波形前缀(多个以正斜杠/分隔)'),
            ),
            ...List.generate(_suffixes.length, (index) {
              String suffix = _suffixes[index];
              return CheckboxListTile(
                title: Text(suffix),
                value: _selectedSuffixes.contains(suffix),
                onChanged: (bool? value) {
                  setState(() {
                    if (value != null && value) {
                      _selectedSuffixes.add(suffix);
                    } else {
                      _selectedSuffixes.remove(suffix);
                    }
                  });
                },
              );
            }),
            ElevatedButton(
              onPressed: _processFileScale,
              child: Text('开始调幅'),
            ),
          ],
        ),
      ),
    );
  }
}
