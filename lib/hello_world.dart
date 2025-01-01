import 'package:flutter/material.dart';
 
void main() {
  runApp(const GeeksForGeeks());
}
 
class GeeksForGeeks extends StatelessWidget {
  const GeeksForGeeks({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Nagarishakti'),
      ),
      body: const Center(child: Text('Hello World')),
    ));
  }
}