import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as math;
import 'package:wave_editor/logic/logic.dart';
import 'package:intl/intl.dart';

class FileProcessor {
  final String srcFolder;
  final String dstFolder;
  late final List<String> waveDirection; // ['H', 'HH', 'V']
  late final String waveDirectionSeparator; // '-'
  late final bool useIncrementalNaming; // false
  late final List<String> fileExtension; // ['AT2', 'DT2', 'VT2']
  late final List<String> separator; // ['-', '_']
  final void Function(double)? onProgress;

  // 添加计数器映射
  final Map<String, int> _prefixCounter = {};

  FileProcessor(this.srcFolder, this.dstFolder,
      {List<String>? fileExtension, this.onProgress}) {
    final appController = Get.find<AppController>();
    waveDirection = appController.defaultWaveDirection.toList();
    waveDirectionSeparator = appController.defaultWaveDirectionSeparator.value;
    useIncrementalNaming = appController.useIncrementalNaming.value;
    this.fileExtension =
        fileExtension ?? appController.defaultFileExtension.toList();
    separator = appController.defaultSeparator.toList();
  }

  Future<void> process() async {
    final files = await _getFiles();
    final groups = _groupFiles(files);

    int totalFiles = files.length;
    int processedFiles = 0;

    for (var groupEntry in groups.entries) {
      final extensionGroups = groupEntry.value;

      for (var ext in fileExtension) {
        if (!extensionGroups.containsKey(ext)) continue;

        final filesInExtGroup = extensionGroups[ext]!;
        final dataFrames = await Future.wait(filesInExtGroup.map(_readFile));

        final fileData = List<Map<String, dynamic>>.generate(
          filesInExtGroup.length,
          (index) => {
            'file': filesInExtGroup[index],
            'data': dataFrames[index],
          },
        );

        final int filesPerGroup = waveDirection.length;
        for (var i = 0; i < fileData.length; i += filesPerGroup) {
          final currentGroup =
              fileData.sublist(i, math.min(i + filesPerGroup, fileData.length));

          // 对当前组进行排序
          currentGroup.sort((a, b) =>
              _getMaxAbsValue(b['data']['data'] as List<double>).compareTo(
                  _getMaxAbsValue(a['data']['data'] as List<double>)));

          for (var j = 0; j < currentGroup.length; j++) {
            final file = currentGroup[j]['file'] as File;
            final data = currentGroup[j]['data'] as Map<String, List<double>>;
            final suffix = waveDirection[j];
            final originalPrefix = _getPrefix(file);
            final prefix = _getIncrementalPrefix(originalPrefix);
            final newName = '$prefix$waveDirectionSeparator$suffix.$ext';
            final newPath = path.join(dstFolder, newName);
            await _saveFile(data, newPath);

            // 更新进度
            processedFiles++;
            onProgress?.call(processedFiles / totalFiles);
          }
        }
      }
    }
  }

  Future<List<File>> _getFiles() async {
    final directory = Directory(srcFolder);
    final files = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => fileExtension.contains(
            path.extension(file.path).toUpperCase().replaceAll('.', '')))
        .toList();
    return files;
  }

  Map<String, Map<String, List<File>>> _groupFiles(List<File> files) {
    // 第一层key是文件前缀，第二层key是文件扩展名
    final groups = <String, Map<String, List<File>>>{};

    for (var file in files) {
      final prefix = _getPrefix(file);
      final ext = path.extension(file.path).toUpperCase().replaceAll('.', '');

      // 初始化前缀组
      if (!groups.containsKey(prefix)) {
        groups[prefix] = {};
      }

      // 初始化扩展名组
      if (!groups[prefix]!.containsKey(ext)) {
        groups[prefix]![ext] = [];
      }

      groups[prefix]![ext]!.add(file);
    }
    return groups;
  }

  String _getPrefix(File file) {
    final fileName = path.basename(file.path);
    // 遍历所有可能的分隔符
    for (var sep in separator) {
      final parts = fileName.split(sep);
      if (parts.length > 1) {
        // 如果能够成功分割，返回第一部分作为前缀
        return parts[0];
      }
    }

    throw FormatException(
        '无法从文件名 "$fileName" 中提取前缀。请检查全局分隔符是否正确: ${separator.join("|")}');
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
    final timeFormat = NumberFormat('0.####'); // 4位小数
    final dataFormat = NumberFormat('0.######'); // 6位小数

    final lines = <String>[];
    lines.add('time,data');
    for (var i = 0; i < data['time']!.length; i++) {
      final timeStr = timeFormat.format(data['time']![i]);
      final dataStr = dataFormat.format(data['data']![i]);
      lines.add('$timeStr,$dataStr');
    }
    await File(path).writeAsString(lines.join('\n'));
  }

  double _getMaxAbsValue(List<double> data) {
    return data
        .reduce(
            (value, element) => value.abs() > element.abs() ? value : element)
        .abs();
  }

  // 添加获取自增编号的方法
  String _getIncrementalPrefix(String originalPrefix) {
    if (!useIncrementalNaming) return originalPrefix;

    if (!_prefixCounter.containsKey(originalPrefix)) {
      _prefixCounter[originalPrefix] = _prefixCounter.length + 1;
    }
    return _prefixCounter[originalPrefix].toString();
  }
}
