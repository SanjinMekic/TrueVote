import 'package:flutter/material.dart';

class PocetnaScreen extends StatelessWidget {
  const PocetnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Dobrodošli na početnu stranicu!",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}