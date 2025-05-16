
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/AddMedicalCenterScreen/add_medical_center_screen.dart';
import 'package:physio_record/MedicalCenters/widgets/medical_center_card.dart';
import 'package:physio_record/models/medical_center_model.dart';

class MedicalCentersScreen extends StatefulWidget {
  const MedicalCentersScreen({super.key});

  @override
  State<MedicalCentersScreen> createState() => _MedicalCentersScreenState();
}

class _MedicalCentersScreenState extends State<MedicalCentersScreen> {


  Stream<QuerySnapshot> centersStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('medical_centers')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        leading: IconButton(onPressed: (){
        Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),

        title: Text('Medical Centers',style: TextStyle(color: Colors.black),),
      ),

      body:   StreamBuilder<QuerySnapshot>(
          stream: centersStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("something went wrong");
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              physics:const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                MedicalCenterModel centerModel=MedicalCenterModel.fromJson(snapshot.data!.docs[index]);
                return MedicalCenterCard(centerModel: centerModel,);
              },
              itemCount: snapshot.data!.docs.length,
            );
          },),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          elevation: 10,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddMedicalCenterScreen()));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Center",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.white),
            ),
            SizedBox(
              width: 15,
            ),
            Icon(
              Icons.health_and_safety,
              color: Colors.white,
            )
          ],
        ),
      ),);

  }
}
