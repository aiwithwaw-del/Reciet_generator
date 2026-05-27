import 'package:flutter/material.dart';

void main() => runApp(const ReceiptApp());

class ReceiptApp extends StatelessWidget {
  const ReceiptApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Receipt Generator')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text('🧾 Your Receipt App', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}