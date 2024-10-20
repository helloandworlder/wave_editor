import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HttpServerPage extends StatefulWidget {
  @override
  _HttpServerPageState createState() => _HttpServerPageState();
}

class _HttpServerPageState extends State<HttpServerPage> {
  HttpServer? _server;
  String _log = '';
  final TextEditingController _ipController =
      TextEditingController(text: '127.0.0.1');
  final TextEditingController _portController =
      TextEditingController(text: '8080');

  void _startServer() async {
    final ip = _ipController.text;
    final port = int.tryParse(_portController.text) ?? 8080;
    _server = await HttpServer.bind(ip, port);
    _log += 'Server started on $ip:$port\n';
    setState(() {});

    _server?.listen((HttpRequest request) async {
      if (request.uri.path == '/hello') {
        request.response.write('world');
      } else if (request.uri.path == '/queryTime') {
        final timeZone = request.uri.queryParameters['timeZone'] ?? 'UTC';
        final now = DateTime.now().toUtc();
        final localTime = now.add(Duration(hours: int.tryParse(timeZone) ?? 0));
        request.response
            .write(DateFormat('yyyy-MM-dd HH:mm:ss').format(localTime));
      }
      await request.response.close();
      _log += 'Request: ${request.uri}\n';
      setState(() {});
    });
  }

  void _stopServer() {
    _server?.close();
    _log += 'Server stopped\n';
    setState(() {});
  }

  void _clearLog() {
    _log = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTTP Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'IP Address'),
            ),
            TextField(
              controller: _portController,
              decoration: InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _startServer,
                  child: Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _stopServer,
                  child: Text('Stop'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log),
              ),
            ),
            ElevatedButton(
              onPressed: _clearLog,
              child: Text('Clear Log'),
            ),
          ],
        ),
      ),
    );
  }
}
