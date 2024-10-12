import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/patient_record.dart';

class SubmittedRequestsScreen extends StatefulWidget {
  const SubmittedRequestsScreen({super.key});

  @override
  State<SubmittedRequestsScreen> createState() =>
      _SubmittedRequestsScreenState();
}

class _SubmittedRequestsScreenState extends State<SubmittedRequestsScreen> {
  final Stream<QuerySnapshot> _shareRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('submittedRequests')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submitted Requests"),
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
            reverse: true,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              // return ShareRequestCard(
              //     requestModel: ShareRequestModel.fromFirestore(
              //         snapshot.data!.docs[index]));
              if (data['status'] == 'waiting') {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "You send ${data['patientName']} record to Dr.${data['doctorName']}.",
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 20,
                    ),
                  ),
                );
              } else if (data['status'] == 'refuse') {
                return Card(
                  color: Colors.red,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Dr.${data['doctorName']} refuse your request to share ${data['patientName']} Record with him",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: Colors.white),
                      maxLines: 20,
                    ),
                  ),
                );
              } else if (data['status'] == 'accept') {

                // // delete record
                // var box = Hive.box<PatientRecord>('patient_records');
                // // Find the object using its ID
                // PatientRecord? recordToDelete = box.values.firstWhere(
                //   (record) => record.id == data['recordId'],
                //   // orElse: () => null,
                // );
                // if (recordToDelete != null) {
                //   // Delete the object
                //   recordToDelete.delete();
                //   FirebaseFirestore.instance
                //       .collection('users')
                //       .doc(data['senderId'])
                //       .collection('records')
                //       .doc(data['recordId'])
                //       .delete();
                // } else {
                //   print('Record not found');
                // }

                return Card(
                  color: Colors.teal,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Dr.${data['doctorName']} accept your request. You con found ${data['patientName']} record in Shared Record Section",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: Colors.white),
                      maxLines: 20,
                    ),
                  ),
                );
              }
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }
}
