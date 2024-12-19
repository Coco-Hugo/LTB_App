import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  final String label;
  final String num;

  const Stat({
    super.key,
    required this.label,
    required this.num,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          num,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }
}
