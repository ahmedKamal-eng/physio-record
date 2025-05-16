

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/models/user_model.dart';

class UserCard extends StatefulWidget {

  String userId;
   UserCard({required this.userId});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {

   UserModel? userModel;

  @override
  void initState() {
    getDoctorData();
    super.initState();
  }

   Future<UserModel> getDoctorData() async {
     final docSnapshot = await FirebaseFirestore.instance
         .collection('users')
         .doc(widget.userId)
         .get();
     return UserModel.fromJson(docSnapshot);
   }
   

  @override
  Widget build(BuildContext context) {
    
    
    return FutureBuilder<UserModel>(future: getDoctorData(), builder: (context,snapshot){


      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {

        return Center(child: Text('Something went wrong'));
      } else if (snapshot.hasData) {

        UserModel userModel = snapshot.data!;
        return  Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userModel.imageUrl),),
            title: Text(userModel.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(userModel.medicalSpecialization, style: const TextStyle(fontSize: 16)),
          ),);

      } else {

        return Center(child: Text('No data found'));
      }

    });
    

  }
}
