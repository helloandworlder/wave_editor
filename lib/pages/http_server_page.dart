import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' as path;

class HttpServerPage extends StatefulWidget {
  const HttpServerPage({super.key});
  @override
  HttpServerPageState createState() => HttpServerPageState();
}

class HttpServerPageState extends State<HttpServerPage> {
  HttpServer? _server;
  List<String> _logEntries = [];
  String _ip = '127.0.0.1';
  int _port = 5000;
  String _fileDirectory = '';

  void _startServer() async {
    if (_fileDirectory.isEmpty) {
      Get.snackbar('错误', '服务文件夹路径不能为空');
      return;
    } else if (_ip.isEmpty) {
      Get.snackbar('错误', '监听IP地址不能为空');
      return;
    } else if (_port <= 0 || _port > 65535) {
      Get.snackbar('错误', '监听端口仅支持1-65535');
      return;
    }

    if (_server != null) {
      _logEntries.add('Server is already running.');
      setState(() {});
      return;
    }

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler((Request request) {
      final httpRequest =
          request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
      final requesterIp = httpRequest?.remoteAddress.address ?? 'Unknown IP';

      final queryParams = request.url.queryParameters.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      _logEntries.add(
          'Received request: ${request.url.path} RequesterIP: $requesterIp QueryParams: $queryParams');
      setState(() {});

      if (request.url.path == 'getFilesName') {
        return _getFilesName(request);
      } else if (request.url.path == 'getFilesByFileName') {
        return _getFileByName(request);
      } else if (request.url.path == 'getFilesByFileNameSetRange') {
        return _getFileByNameSetRange(request);
      } else {
        return Response.notFound('Not Found');
      }
    });

    try {
      _server = await io.serve(handler, InternetAddress(_ip), _port);
      _logEntries.add('Server running on $_ip:$_port');
    } catch (e) {
      _logEntries.add('Failed to start server: $e');
    }
    setState(() {});
  }

  void _stopServer() {
    if (_server != null) {
      _server!.close();
      _server = null;
      _logEntries.add('Server stopped.');
    } else {
      _logEntries.add('No server is running.');
    }
    setState(() {});
  }

  Response _getFilesName(Request request) {
    final files = Directory(_fileDirectory)
        .listSync()
        .map((e) => path.basename(e.path))
        .toList();
    return Response.ok(files.join('\n'));
  }

  Response _getFileByName(Request request) {
    final filename = request.url.queryParameters['filename'];
    final filePath = '$_fileDirectory/$filename';
    final file = File(filePath);

    if (file.existsSync()) {
      return Response.ok(file.readAsStringSync());
    } else {
      return Response.notFound('File not found');
    }
  }

  Response _getFileByNameSetRange(Request request) {
    final filename = request.url.queryParameters['filename'];
    final startLine =
        int.tryParse(request.url.queryParameters['startLine'] ?? '0') ?? 0;
    final endLine =
        int.tryParse(request.url.queryParameters['endLine'] ?? '-1') ?? -1;

    final filePath = '$_fileDirectory/$filename';
    final file = File(filePath);

    if (!file.existsSync()) {
      return Response.notFound('File not found');
    }

    final lines = file.readAsLinesSync();
    final end = endLine == -1 ? lines.length : endLine;

    if (startLine < 0 || end > lines.length || startLine > end) {
      return Response(400, body: 'Invalid range specified');
    }

    final selectedLines = lines.sublist(startLine, end).join('\n');
    return Response.ok(selectedLines);
  }

  Future<void> _selectServerFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _fileDirectory = selectedDirectory;
      });
    }
  }

  void _clearLog() {
    setState(() {
      _logEntries.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _selectServerFolder, // 需要实现 _selectServiceFolder 方法
              child: InputDecorator(
                decoration: const InputDecoration(labelText: '服务文件夹路径'),
                child: Text(
                  _fileDirectory.isNotEmpty ? _fileDirectory : '点击选择服务文件夹',
                ),
              ),
            ),
            TextField(
              decoration: const InputDecoration(labelText: '监听IP地址'),
              onChanged: (value) => _ip = value,
              controller: TextEditingController(text: _ip),
            ),
            TextField(
              decoration: const InputDecoration(labelText: '监听端口'),
              onChanged: (value) => _port = int.tryParse(value) ?? 5000,
              controller: TextEditingController(text: _port.toString()),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startServer,
                  child: const Text('启动服务器'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _stopServer,
                  child: const Text('停止服务器'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _clearLog,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            Expanded(
              flex:1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4.0, // 控制阴影的深度
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // 圆角
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: _logEntries.length,
                        itemBuilder: (context, index) {
                          return Text(_logEntries[index]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('接口定义:'),
            const Text('/getFilesName - 获取文件名列表\n'
                '/getFilesByFileName?filename= - 获取文件内容\n'
                '/getFilesByFileNameSetRange?filename=&startLine=&endLine= - 获取文件部分内容\n'),
          ],
        ),
      ),
    );
  }
}
