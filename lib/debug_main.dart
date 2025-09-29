import 'package:flutter/material.dart';

void main() {
  print('DEBUG: Starting app');
  runApp(DebugApp());
}

class DebugApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building app');
    return MaterialApp(
      title: 'Debug Test',
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.radio,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'DEBUG TEST APP',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('DEBUG: Button pressed');
                },
                child: Text('Test Button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
