
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/JoiningRequestScreen/widgets/joining_request_card.dart';
import 'package:physio_record/models/joining_reuest_model.dart';

class JoiningRequestScreen extends StatefulWidget {
  const JoiningRequestScreen({super.key});

  @override
  State<JoiningRequestScreen> createState() => _JoiningRequestScreenState();
}

class _JoiningRequestScreenState extends State<JoiningRequestScreen> {
  final Stream<QuerySnapshot> _shareRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('joining_requests')
      .orderBy('date',descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: Text("Joining Requests",style: TextStyle(color: Colors.white),),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _shareRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return JoiningRequestCard(
                  requestModel: JoiningRequestModel.fromJson(
                      snapshot.data!.docs[index]));
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }
}




