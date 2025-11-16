import 'package:flutter/material.dart';
import 'package:screen_capture_event/screen_capture_event.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScreenCaptureEvent _screenListener = ScreenCaptureEvent();
  String _result = 'Нажми "ДЕТЕКТ"';

  @override
  void initState() {
    super.initState();
    _screenListener.addScreenRecordListener((filePath) {
      if (filePath != null) _analyze(filePath);
    });
  }

  Future<void> _analyze(String path) async {
    setState(() => _result = 'Анализируем...');
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path),
      });
      final response = await Dio().post(
        'https://api.hive.com/v1/task/sync',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer YOUR_KEY'}),
      );
      setState(() {
        _result = 'ИИ: ${response.data['result']['score'] ?? '??'}%';
      });
    } catch (e) {
      setState(() => _result = 'Ошибка. Попробуй ещё.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[800],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_result, style: TextStyle(color: Colors.white, fontSize: 20)),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _analyze(''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text('ДЕТЕКТ', style: TextStyle(fontSize: 32, color: Colors.red[800])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
