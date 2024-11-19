import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileScaler {
  final void Function(double)? onProgress;

  FileScaler({this.onProgress});

  Future<void> processFileScale(String srcFolder, String dstFolder,
      double targetValue, List<String> suffixes, List<String> prefixList) async {
    // 遍历后缀列表
    for (String prefix in prefixList) {
      // 遍历后缀列表
      for (String suffix in suffixes) {
        // 获取符合条件的源文件路径列表
        List<String> srcFilePaths = Directory(srcFolder)
            .listSync()
            .where((entity) =>
                entity is File &&
                entity.path.endsWith(suffix) &&
                path.basename(entity.path).startsWith(prefix))
            .map((entity) => entity.path)
            .toList();

        // 如果存在符合条件的源文件,则进行缩放处理
        if (srcFilePaths.isNotEmpty) {
          _scaleFiles(srcFilePaths, dstFolder, targetValue);
        }
      }
      debugPrint('${prefixList.indexOf(prefix)} / ${prefixList.length}');
      onProgress?.call((prefixList.indexOf(prefix) + 1) / prefixList.length);
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  void _scaleFiles(
      List<String> srcFilePaths, String dstFolder, double targetValue) {
    List<double> maxValues = [];
    double scaleFlex = 0.0;

    for (int i = 0; i < srcFilePaths.length; i++) {
      String filePath = srcFilePaths[i];
      final lines = File(filePath).readAsLinesSync();
      final data = lines
          .skip(1)
          .map((line) => line.split(','))
          .map((fields) => double.parse(fields[1]))
          .toList();

      if (data.isNotEmpty) {
        double maxValue = data.reduce((a, b) => a.abs() > b.abs() ? a : b).abs();
        maxValues.add(maxValue);
      } else {
        maxValues.add(0);
      }
    }

    scaleFlex = targetValue / maxValues.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < srcFilePaths.length; i++) {
      String srcFilePath = srcFilePaths[i];
      String dstFilePath = path.join(dstFolder, path.basename(srcFilePath));

      final lines = File(srcFilePath).readAsLinesSync();
      final data = lines
          .skip(1)
          .map((line) => line.split(','))
          .map((fields) => double.parse(fields[1]))
          .toList();

      if (data.isNotEmpty && maxValues[i] != 0) {
        final scaledData = data.map((value) => value * scaleFlex).toList();
        String csvString =
            '${lines[0]}\n${scaledData.asMap().entries.map((entry) => '${entry.key * 0.01},${entry.value}').join('\n')}';

        Directory(path.dirname(dstFilePath)).createSync(recursive: true);
        File(dstFilePath).writeAsStringSync(csvString);
      }
    }
  }
}
