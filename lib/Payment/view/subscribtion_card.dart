

import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final double price;
  final String duration;
  final VoidCallback onSubscribe;

  const SubscriptionCard({
    Key? key,
    required this.planName,
    required this.price,
    required this.duration,
    required this.onSubscribe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 7,
      shadowColor: Colors.teal,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "EGP $price",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                ElevatedButton(
                  onPressed: onSubscribe,
                  child: const Text("Subscribe"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
