import 'package:flutter/material.dart';

class OutfitCard extends StatelessWidget {
  final String name;
  final String image;
  const OutfitCard({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset(image, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name),
          ),
        ],
      ),
    );
  }
}