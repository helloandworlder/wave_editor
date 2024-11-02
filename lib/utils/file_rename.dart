import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:wave_editor/logic/logic.dart';

class FileProcessor {
  final String srcFolder;
  final String dstFolder;
  late final List<String> waveDirection; // ['H', 'HH', 'V']
  late final String waveDirectionSeparator; // '-'
  late final bool useIncrementalNaming; // false
  late final List<String> fileExtension; // ['H', 'HH', 'V']

  FileProcessor(this.srcFolder, this.dstFolder) {
    final appController = Get.find<AppController>();
    waveDirection = appController.defaultWaveDirection.toList();
    waveDirectionSeparator = appController.defaultWaveDirectionSeparator.value;
    useIncrementalNaming = appController.useIncrementalNaming.value;
    fileExtension = appController.defaultFileExtension;
  }

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

      final suffixes = waveDirection;
      for (var i = 0; i < suffixes.length; i++) {
        if (i < fileData.length) {
          final file = fileData[i]['file'] as File;
          final data = fileData[i]['data'] as Map<String, List<double>>;
          final suffix = suffixes[i];
          final fileExtension = path.extension(file.path);
          final newName =
              '${_getPrefix(file)}$waveDirectionSeparator$suffix$fileExtension';
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

      if (!groups.containsKey(prefix)) {
        groups[prefix] = [];
      }
      groups[prefix]!.add(file);
    }
    return groups;
  }

  String _getPrefix(File file) {
    final fileName = path.basename(file.path);
    // 直接获取 RSN26_HOLLISTR_B 作为前缀
    return fileName.split('-')[0];
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
