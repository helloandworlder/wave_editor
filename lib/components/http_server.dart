import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

String fileDirectory = 'default';

Response _getFilesName(Request request) {
  final srcFolderPath = fileDirectory;
  final files = Directory(srcFolderPath).listSync().map((e) => e.path).toList();
  return Response.ok(files.join('\n'));
}

Response _getFileByName(Request request) {
  final filename = request.url.queryParameters['filename'];
  final filePath = '$fileDirectory/$filename';
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

  final filePath = '$fileDirectory/$filename';
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

void startServer(String filePath, int port) {
  fileDirectory = filePath;
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) {
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

  io.serve(handler, InternetAddress.anyIPv4, port).then((server) {
    print('Server running on localhost:${server.port}');
  });
}
