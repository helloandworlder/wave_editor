import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

class FileScaler {
  void processFileScale(String srcFolder, String dstFolder, double targetValue,
      List<String> suffixes, List<String> prefixList) {
    // 遍历后缀列表
    for (String suffix in suffixes) {
      // 遍历前缀列表
      for (String prefix in prefixList) {
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
    }
  }

  void _scaleFiles(
      List<String> srcFilePaths, String dstFolder, double targetValue) {
    List<double> maxValues = [];
    double scaleFlex = 0.0;

    // 遍历源文件路径列表
    for (String filePath in srcFilePaths) {
      // 读取CSV文件并转换为List<List<dynamic>>
      List<List<dynamic>> csvData =
          CsvToListConverter().convert(File(filePath).readAsStringSync());

      // 解析CSV数据,提取数值列并转换为double类型
      List<double> data = csvData.map((row) {
        String valueString = row[1].toString().replaceAll(RegExp(r'[eE]'), 'e');
        double? value = double.tryParse(valueString);
        print('Parsed value: $value');
        return value ?? 0.0;
      }).toList();

      // 如果数据不为空,则计算最大绝对值并添加到maxValues列表中
      if (data.isNotEmpty) {
        double maxValue =
            data.reduce((a, b) => a.abs() > b.abs() ? a : b).abs();
        print('$filePath 极大绝对值 $maxValue');
        maxValues.add(maxValue);
      } else {
        maxValues.add(0);
      }
    }

    // 计算缩放系数
    scaleFlex = targetValue / maxValues.reduce((a, b) => a > b ? a : b);

    // 遍历源文件路径列表
    for (int i = 0; i < srcFilePaths.length; i++) {
      String srcFilePath = srcFilePaths[i];
      // 构建目标文件路径
      String dstFilePath = path.join(dstFolder, path.basename(srcFilePath));

      // 读取CSV文件并转换为List<List<dynamic>>
      List<List<dynamic>> csvData =
          CsvToListConverter().convert(File(srcFilePath).readAsStringSync());

      // 解析CSV数据,提取数值列并转换为double类型
      List<double> data = csvData.map((row) {
        String valueString = row[1].toString().replaceAll(RegExp(r'[eE]'), 'e');
        double? value = double.tryParse(valueString);
        return value ?? 0.0;
      }).toList();

      // 如果数据不为空且对应的最大值不为0,则对数据进行缩放处理
      if (data.isNotEmpty && maxValues[i] != 0) {
        data = data.map((value) => value * scaleFlex).toList();
      }

      // 将缩放后的数据转换为CSV格式字符串
      String csvString = ListToCsvConverter().convert([
        ['time', 'data'],
        ...data
            .asMap()
            .entries
            .map((entry) => [entry.key, entry.value])
            .toList(),
      ]);

      // 创建目标文件夹(如果不存在)
      Directory(path.dirname(dstFilePath)).createSync(recursive: true);
      // 将CSV字符串写入目标文件
      File(dstFilePath).writeAsStringSync(csvString);
    }
  }
}
