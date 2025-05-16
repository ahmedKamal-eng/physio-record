
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/MedicalCenterDetails/medical_center_details_screen.dart';
import 'package:physio_record/models/medical_center_model.dart';



class MedicalCenterCard extends StatelessWidget {

  final VoidCallback? onTap;
  final MedicalCenterModel centerModel;

   MedicalCenterCard({

    this.onTap,
    required this.centerModel
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicalCenterDetailsScreen(centerModel: centerModel)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
        BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        blurRadius: 10,
        spreadRadius: 2,
        offset: Offset(0, 4),
        )],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Unit Background Image
            Container(
              height: 180,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: centerModel.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.teal[100]),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),

            // Dark overlay for better text visibility
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Unit name and doctor count
            Positioned(
              left: 16,
              bottom: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    centerModel.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${centerModel.doctorCount} ${centerModel.doctorCount == 1 ? 'Doctor' : 'Doctors'}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Admin info section
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    // Admin avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(centerModel.adminImage),
                      backgroundColor: Colors.grey[200],
                      child: centerModel.adminImage.isEmpty
                          ? Icon(Icons.person, color: Colors.teal)
                          : null,
                    ),
                    SizedBox(width: 12),

                    // Admin details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Dr."+centerModel.adminName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            centerModel.adminSpecialization,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Chevron icon
                    Icon(Icons.chevron_right, color: Colors.teal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}