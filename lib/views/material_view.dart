import 'package:flutter/material.dart';

class MaterialView extends StatelessWidget {
  const MaterialView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is your Material View.', style: TextStyle(fontSize: 18)),
    );
  }
}
