import 'package:flutter/material.dart';

void main() {
  print('DEBUG: Starting main app');
  runApp(SimpleApp());
}

class SimpleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building SimpleApp');
    return MaterialApp(
      title: 'Turkradyo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building HomeScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Türk Radyoları'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radio,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Türk Radyoları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('DEBUG: Button pressed - would load stations');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Radyo istasyonları yüklenecek...')),
                );
              },
              child: Text('Radyo İstasyonlarını Yükle'),
            ),
          ],
        ),
      ),
    );
  }
}
