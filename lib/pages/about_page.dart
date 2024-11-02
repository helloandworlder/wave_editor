import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('项目名称：'),
                    SizedBox(height: 4),
                    Text('Python在地震波处理中的应用'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('项目功能：'),
                    SizedBox(height: 4),
                    Text('数据批量命名、数据调幅处理、Web波形预览、HTTP数据接口'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('项目指导老师：'),
                    SizedBox(height: 4),
                    Text('吕鑫颖'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('项目组成员：'),
                    SizedBox(height: 4),
                    Text('杨雪 卜宇曦 俞梦莎 宋佳琪 穆烨欣'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('项目立项于：'),
                    SizedBox(height: 4),
                    Text('2023年12月'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
