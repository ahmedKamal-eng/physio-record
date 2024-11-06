import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/ShareRequestScreen/widgets/share_request_card.dart';
import 'package:physio_record/models/share_request_model.dart';

class ShareRequestScreen extends StatefulWidget {
  const ShareRequestScreen({super.key});

  @override
  State<ShareRequestScreen> createState() => _ShareRequestScreenState();
}

class _ShareRequestScreenState extends State<ShareRequestScreen> {
  final Stream<QuerySnapshot> _shareRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('shareRequests')
  .orderBy('date',descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Share Request"),
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
              return ShareRequestCard(
                  requestModel: ShareRequestModel.fromFirestore(
                      snapshot.data!.docs[index]));
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }
}
