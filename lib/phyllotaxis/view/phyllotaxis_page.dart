import 'package:flutter/material.dart';

class PhyllotaxisPage extends StatefulWidget {
  const PhyllotaxisPage({super.key});

  @override
  State<PhyllotaxisPage> createState() => _PhyllotaxisPageState();
}

class _PhyllotaxisPageState extends State<PhyllotaxisPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(children: [
        Text("data")
      ],),
    );
  }
}
