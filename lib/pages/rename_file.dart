import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wave_editor/logic/app_controller.dart';
import 'package:file_picker/file_picker.dart';

class RenameFilePage extends StatefulWidget {
  @override
  _RenameFilePageState createState() => _RenameFilePageState();
}

class _RenameFilePageState extends State<RenameFilePage> {
  final AppController appController = Get.find();

  String srcFolderPath = '';
  String separator = '';
  List<String> targetFileSuffix = [];
  String dstFolderPath = '';

  Future<void> _selectSrcFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        srcFolderPath = selectedDirectory;
      });
    }
  }

  Future<void> _selectDstFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        dstFolderPath = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('数据批量命名'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '# Python在地震波处理中的应用',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: _selectSrcFolder,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '<-待重命名|格式化文件夹目录',
                  ),
                  child: Text(
                      srcFolderPath.isNotEmpty ? srcFolderPath : '点击选择文件夹'),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    separator = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: '输入分隔符(-) 可设置多个如- _',
                ),
              ),
              SizedBox(height: 16),
              Text('选择后缀(可多选)'),
              CheckboxListTile(
                title: Text('.AT2'),
                value: targetFileSuffix.contains('.AT2'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      targetFileSuffix.add('.AT2');
                    } else {
                      targetFileSuffix.remove('.AT2');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('.VT2'),
                value: targetFileSuffix.contains('.VT2'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      targetFileSuffix.add('.VT2');
                    } else {
                      targetFileSuffix.remove('.VT2');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('.DT2'),
                value: targetFileSuffix.contains('.DT2'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      targetFileSuffix.add('.DT2');
                    } else {
                      targetFileSuffix.remove('.DT2');
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: _selectDstFolder,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '->目标文件夹目录',
                  ),
                  child: Text(
                      dstFolderPath.isNotEmpty ? dstFolderPath : '点击选择文件夹'),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    appController.processFileName(
                      // targetFileSuffix,
                      srcFolderPath,
                      dstFolderPath,
                      // separator,
                    );
                  },
                  child: Text('开始重命名|格式化[Start]'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
