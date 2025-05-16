
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String specialization;
  final VoidCallback? onTap;

  const DoctorCard({
    required this.name,
    required this.imageUrl,
    required this.specialization,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(imageUrl),
                backgroundColor: Colors.grey[200],
                child: imageUrl.isEmpty ? Icon(Icons.person, size: 30) : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      specialization,
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}