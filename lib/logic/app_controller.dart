import 'package:get/get.dart';
import 'package:wave_editor/io/file_picker_service.dart';
import 'dart:io'; // 添加此行以导入 File 类
import 'package:path/path.dart' as path;

class AppController extends GetxController {
  final FilePickerService _filePickerService = FilePickerService();

  // 设置
  final setting1 = false.obs;
  // 其他设置...

  // 选择文件夹
  Future<void> pickFolder() async {
    String? directory = await _filePickerService.pickDirectory();
    if (directory != null) {
      // 处理选择的文件夹
      print('选择的文件夹: $directory');
    }
  }

  // 选择文件
  Future<void> pickFiles() async {
    List<File>? files = await _filePickerService.pickFiles();
    if (files != null) {
      // 处理选择的文件
      print('选择的文件: ${files.map((f) => f.path).toList()}');
    }
  }

  Future<void> processFileName(
    String srcFolder,
    String dstFolder,
  ) async {
    final fileProcessor = FileProcessor(srcFolder, dstFolder);
    await fileProcessor.process();
  }
}

class FileProcessor {
  final String srcFolder;
  final String dstFolder;

  FileProcessor(this.srcFolder, this.dstFolder);

  Future<void> process() async {
    final files = await _getFiles();
    final groups = _groupFiles(files);

    for (var group in groups.values) {
      final dataFrames = await Future.wait(group.map(_readFile));

      final fileData = List<Map<String, dynamic>>.generate(
          group.length,
          (index) => {
                'file': group[index],
                'data': dataFrames[index],
              });

      fileData.sort((a, b) => _getMaxAbsValue(b['data']['data'] as List<double>)
          .compareTo(_getMaxAbsValue(a['data']['data'] as List<double>)));

      final suffixes = ['H', 'HH', 'V'];
      for (var i = 0; i < suffixes.length; i++) {
        if (i < fileData.length) {
          final file = fileData[i]['file'] as File;
          final data = fileData[i]['data'] as Map<String, List<double>>;
          final suffix = suffixes[i];
          final fileExtension = path.extension(file.path);
          final newName = '${_getPrefix(file)}_$suffix$fileExtension';
          final newPath = path.join(dstFolder, newName);
          await _saveFile(data, newPath);
        }
      }
    }
  }

  Future<List<File>> _getFiles() async {
    final directory = Directory(srcFolder);
    final files =
        directory.listSync(recursive: true).whereType<File>().toList();
    return files;
  }

  Map<String, List<File>> _groupFiles(List<File> files) {
    final groups = <String, List<File>>{};
    for (var file in files) {
      final prefix = _getPrefix(file);
      final extension = path.extension(file.path);
      final key = '$prefix$extension';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(file);
    }
    return groups;
  }

  String _getPrefix(File file) {
    final fileName = path.basename(file.path);
    final parts = fileName.split(RegExp(r'[-_]'));
    return parts.sublist(0, parts.length - 1).join('-');
  }

  Future<Map<String, List<double>>> _readFile(File file) async {
    final lines = await file.readAsLines();
    final dataLine = lines.firstWhere((line) => line.startsWith('NPTS='));
    final dtValue =
        dataLine.split(',')[1].trim().split('=')[1].trim().split(' SEC')[0];
    final dt = double.parse(dtValue);

    final data = <double>[];
    for (var line in lines.skip(4)) {
      for (var value in line.split(' ')) {
        if (value.startsWith('.') || value.startsWith('-')) {
          data.add(double.parse(value));
        }
      }
    }

    final time = List.generate(data.length, (index) => index * dt);
    return {'time': time, 'data': data};
  }

  Future<void> _saveFile(Map<String, List<double>> data, String path) async {
    final lines = <String>[];
    lines.add('time,data');
    for (var i = 0; i < data['time']!.length; i++) {
      lines.add('${data['time']![i]},${data['data']![i]}');
    }
    await File(path).writeAsString(lines.join('\n'));
  }

  double _getMaxAbsValue(List<double> data) {
    return data
        .reduce(
            (value, element) => value.abs() > element.abs() ? value : element)
        .abs();
  }
}
