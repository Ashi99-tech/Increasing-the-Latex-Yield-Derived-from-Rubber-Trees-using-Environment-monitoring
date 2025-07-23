import 'package:flutter/material.dart';
import 'package:rubber_lk/welcomebody.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(child: WelcomeBody()),
    );
  }
}
