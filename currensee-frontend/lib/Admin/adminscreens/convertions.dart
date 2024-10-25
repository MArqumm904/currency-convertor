import 'package:flutter/material.dart';

class Convertions extends StatefulWidget {
  const Convertions({super.key});

  @override
  State<Convertions> createState() => _ConvertionsState();
}

class _ConvertionsState extends State<Convertions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversion Calculator'),
      ),
    );
  }
}