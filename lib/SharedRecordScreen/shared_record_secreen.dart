import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/shared_record_model.dart';

import '../SharedRecordDetailsScreen/shared_record_details_screen.dart';

class SharedRecordScreen extends StatelessWidget {
  SharedRecordScreen({super.key});

  final Stream<QuerySnapshot> _shareRecordStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('sharedRecords')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Records"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _shareRecordStream,
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
              SharedRecordModel recordModel =
                  SharedRecordModel.fromFirestore(snapshot.data!.docs[index]);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SharedRecordDetailsScreen(
                                  sharedRecordModel: recordModel,
                                )));
                  },
                  tileColor: isDark ? Colors.black54 : Colors.teal,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  isThreeLine: true,
                  title: Text(
                    snapshot.data!.docs[index]['patientName'],
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Colors.white),
                  ),
                  subtitle: Text(snapshot.data!.docs[index]['diagnosis'] +
                      "\n" +
                      convertTimestampToString(
                          snapshot.data!.docs[index]['date'])),
                ),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }
}
