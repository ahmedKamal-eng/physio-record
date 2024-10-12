import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';

import '../FetchAllRecord/fetch_record_cubit.dart';
import 'package:path/path.dart' as path;

class RecordCard extends StatelessWidget {
  PatientRecord patient;
  int patientIndex;
  RecordCard({Key? key, required this.patient, required this.patientIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return GestureDetector(
      onTap: () {
        print(patient.followUpList.length.toString()+")))))))))))))))))");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => RecordDetailsScreen(patientRecord: patient)));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16),
        decoration: BoxDecoration(
            color: isDark ? Colors.black54 : Colors.teal,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListTile(
              title: Text(patient.patientName,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white)),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(patient.diagnosis,
                    maxLines: 1,
                    overflow:TextOverflow.ellipsis ,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
              ),
              trailing: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content:
                              Text("Are you sure you want to delete this item"),
                          actions: [
                            ElevatedButton(
                                onPressed: () async{
                                  var box = Hive.box<PatientRecord>(
                                      'patient_records');
                                  box.deleteAt(patientIndex);
                                  if (patient.followUpList.isNotEmpty) {
                                    for(var followUp in patient.followUpList)
                                      {
                                        if(followUp.image!.isNotEmpty){
                                          for(var img in followUp.image!)
                                            {
                                              File file =File(img);
                                              final fileName = path.basename(file.path);
                                              deleteFile('images/${patient.id}/${followUp.id}/$fileName');
                                            }
                                         }
                                      }
                                  }

                                  final docRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('records').doc(patient.id);
                                  final batch = FirebaseFirestore.instance.batch();

                                  // Delete the document
                                  batch.delete(docRef);

                                  // Recursively delete subcollection
                                  final subcollectionRef = docRef.collection('followUp');
                                  final docs = await subcollectionRef.get();
                                  for (final doc in docs.docs) {
                                    batch.delete(doc.reference);
                                  }
                                  batch.commit();


                                 // await FirebaseFirestore.instance
                                 //      .collection('users')
                                 //      .doc(FirebaseAuth
                                 //          .instance.currentUser!.uid)
                                 //      .collection('records')
                                 //      .doc(patient.id)
                                 //      .delete();

                                  BlocProvider.of<FetchRecordCubit>(context)
                                      .fetchAllRecord();
                                  Navigator.pop(context);
                                },
                                child: Text('Yes')),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('cancel')),
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Text(patient.followUpList.length.toString() +
                "   follow up items      ",style: TextStyle(color: Colors.white),),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 20),
              child: Text(
                patient.date,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
