
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/global_vals.dart';

class TrialStatusCard extends StatelessWidget {
  final DateTime registrationDate;
  final DateTime endDate;

   TrialStatusCard({super.key, required this.registrationDate,required this.endDate});


  @override
  Widget build(BuildContext context) {
    final trialEndDate = registrationDate.add(Duration(days:freeTrialMonths*30));
    final daysRemaining = trialEndDate.difference(DateTime.now()).inDays;
    final isTrialActive = daysRemaining > 0;

    final days=endDate.difference(DateTime.now()).inDays;

    // if (!isTrialActive) return const SizedBox.shrink();

    if(isTrialActive) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'FREE TRIAL ACTIVE',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$daysRemaining days remaining (ends ${DateFormat('MMM d').format(
                  trialEndDate)})',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }else{
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '$days days remaining (ends ${DateFormat('MMM d y').format(
                  endDate)})',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
  }
}