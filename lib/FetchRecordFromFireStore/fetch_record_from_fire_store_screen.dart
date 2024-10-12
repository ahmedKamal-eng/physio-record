import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/global_vals.dart';

import '../HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import '../models/patient_record.dart';

class FetchRecordFromFireStoreScreen extends StatefulWidget {
  const FetchRecordFromFireStoreScreen({super.key});

  @override
  State<FetchRecordFromFireStoreScreen> createState() =>
      _FetchRecordFromFireStoreScreenState();
}

class _FetchRecordFromFireStoreScreenState
    extends State<FetchRecordFromFireStoreScreen> {
  _storeRecordLocally() async {
    Map<String, bool> recordsIds = {};
    var recordBox = Hive.box<PatientRecord>('patient_records');

    for (int i = 0; i < recordBox.values.length; i++) {
      String patientId = recordBox.values.toList()[i].id;
      recordsIds[patientId] = true;
    }

    //fetch record from firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('records')
        .get()
        .then((result) async {
      for (int i = 0; i < result.docs.length; i++) {
        // QuerySnapshot followUpSnapshot= await result.docs[i].reference.collection('followUp').get();

        if (recordsIds[result.docs[i].data()['id']] ?? false) {
        } else {
          PatientRecord patientRecord =
              PatientRecord.fromFirestore(result.docs[i]);
          recordBox.add(patientRecord);

          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('records')
              .doc(patientRecord.id)
              .collection('followUp')
              .get()
              .then((val) async {
            if (val.docs.isNotEmpty) {
              for (int i = 0; i < val.docs.length; i++) {
                FollowUp followUp = FollowUp.fromFirestore(val.docs[i]);
                followUp.image = await fetchAndDownloadFiles('images',
                    val.docs[i].data()['RecordId'], val.docs[i].data()['id']);
                followUp.docPath = await fetchAndDownloadFiles('docs',
                    val.docs[i].data()['RecordId'], val.docs[i].data()['id']);
                // print("#############################${followUp.image![0]}");

                patientRecord.followUpList.add(followUp);
              }
            }
          }).whenComplete(() {
            patientRecord.save();
            // print(patientRecord.followUpList.length);
          });
        }
      }
    }).whenComplete(() async{

      BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  void initState() {
    _storeRecordLocally();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              "There are a number of records on your account that are not stored locally. Please wait a moment...",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: LinearProgressIndicator(),
          )
        ],
      ),
    );
  }
}
