import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';

import '../../FollowUpScreen/follow_up_screen.dart';
import '../../SearchForDoctorsScreen/search_for_doctors_screen.dart';
import '../../ShareWithFriendScreen/share_with_friend_screen.dart';
import '../FetchAllRecord/fetch_record_cubit.dart';
import 'package:path/path.dart' as path;

class RecordCard extends StatelessWidget {
  PatientRecord patient;
  bool internetConnection;
  int patientIndex;
  RecordCard({Key? key, required this.patient, required this.patientIndex,required this.internetConnection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return GestureDetector(
      onTap: () {
        print(patient.followUpList.length.toString() + ")))))))))))))))))");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowUPScreen(
                    patientRecord: patient,
                   internetConnection:internetConnection ,
                )));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                    Colors.teal.withOpacity(0.4), // Shadow color with opacity
                spreadRadius: 5, // How much the shadow spreads
                blurRadius: 5, // How soft or blurred the shadow is
                offset: Offset(0, 3), // Offset (horizontal, vertical)
              ),
            ],
            color: isDark ? Colors.black54 : Colors.white,
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListTile(
              title: Text(patient.patientName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.teal,fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(patient.diagnosis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.teal)),
              ),
              trailing: PopupMenuButton(
                  iconColor: Colors.teal,
                  iconSize: 50,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            child: TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final List<ConnectivityResult>
                                      connectivityResult = await (Connectivity()
                                          .checkConnectivity());

                                  if (!connectivityResult
                                      .contains(ConnectivityResult.none)) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                "Are you sure you want to delete this item"),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    var box =
                                                        Hive.box<PatientRecord>(
                                                            'patient_records');
                                                    box.deleteAt(patientIndex);
                                                    if (patient.followUpList
                                                        .isNotEmpty) {
                                                      for (var followUp
                                                          in patient
                                                              .followUpList) {
                                                        if (followUp.image!
                                                            .isNotEmpty) {
                                                          for (var img
                                                              in followUp
                                                                  .image!) {
                                                            File file =
                                                                File(img);
                                                            final fileName =
                                                                path.basename(
                                                                    file.path);
                                                            deleteFile(
                                                                'images/${patient.id}/${followUp.id}/$fileName');
                                                          }
                                                        }
                                                      }
                                                    }

                                                    final docRef =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection(
                                                                'records')
                                                            .doc(patient.id);
                                                    final batch =
                                                        FirebaseFirestore
                                                            .instance
                                                            .batch();

                                                    // Delete the document
                                                    batch.delete(docRef);

                                                    // Recursively delete subcollection
                                                    final subcollectionRef =
                                                        docRef.collection(
                                                            'followUp');
                                                    final docs =
                                                        await subcollectionRef
                                                            .get();
                                                    for (final doc
                                                        in docs.docs) {
                                                      batch.delete(
                                                          doc.reference);
                                                    }
                                                    batch.commit();

                                                    // await FirebaseFirestore.instance
                                                    //      .collection('users')
                                                    //      .doc(FirebaseAuth
                                                    //          .instance.currentUser!.uid)
                                                    //      .collection('records')
                                                    //      .doc(patient.id)
                                                    //      .delete();

                                                    BlocProvider.of<
                                                                FetchRecordCubit>(
                                                            context)
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
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Please check Your enternet connection'),
                                            actions: [],
                                          );
                                        });
                                  }
                                },
                                child: Text(
                                  "delete",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ))),
                        PopupMenuItem(
                            child: TextButton(
                              onPressed: ()async{
                                Navigator.pop(context);
                                final List<ConnectivityResult> connectivityResult =
                                await (Connectivity().checkConnectivity());

                                if (connectivityResult.contains(ConnectivityResult.none)) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              "There is no internet connection please try again"),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Ok")),
                                          ],
                                        );
                                      });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Center(child: Text("Share this record")),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.teal),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ShareWithFriendScreen(
                                                                  doctorIds:patient.doctorsId,
                                                                  recordModel: patient,
                                                                  isSharedBefore:
                                                                  patient.isShared!,
                                                                )));

                                                  },
                                                  child: Text(
                                                    "Share with friend doctors",
                                                    style: TextStyle(color: Colors.white),
                                                  )),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.teal),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    showSearch(context: context, delegate: UserSearchDelegate(patientRecord: patient,isSharedBefore: patient.isShared,doctorsIds: patient.doctorsId));
                                                  },
                                                  child: Text(
                                                    "Search for doctors",
                                                    style: TextStyle(color: Colors.white),
                                                  )),
                                            ],
                                          ),
                                        );
                                      });
                                }
                              },
                              child: Text("share",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            )),
                        PopupMenuItem(
                            child: TextButton(
                              onPressed: (){
                                if(Navigator.canPop(context))
                                  {
                                    Navigator.pop(context);
                                  }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => RecordDetailsScreen(patientRecord: patient)));
                              },
                              child: Text("edit",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            )),
                      ]),
              // IconButton(
              //   onPressed: ()async {
              //     final List<ConnectivityResult>
              //     connectivityResult = await (Connectivity()
              //         .checkConnectivity());
              //
              //     if (!connectivityResult
              //         .contains(ConnectivityResult.none)) {
              //       showDialog(
              //           context: context,
              //           builder: (context) {
              //             return AlertDialog(
              //               title:
              //               Text("Are you sure you want to delete this item"),
              //               actions: [
              //                 ElevatedButton(
              //                     onPressed: () async {
              //
              //                       var box = Hive.box<PatientRecord>(
              //                           'patient_records');
              //                       box.deleteAt(patientIndex);
              //                       if (patient.followUpList.isNotEmpty) {
              //                         for (var followUp
              //                         in patient.followUpList) {
              //                           if (followUp.image!.isNotEmpty) {
              //                             for (var img in followUp.image!) {
              //                               File file = File(img);
              //                               final fileName =
              //                               path.basename(file.path);
              //                               deleteFile(
              //                                   'images/${patient.id}/${followUp.id}/$fileName');
              //                             }
              //                           }
              //                         }
              //                       }
              //
              //                       final docRef = FirebaseFirestore.instance
              //                           .collection('users')
              //                           .doc(FirebaseAuth
              //                           .instance.currentUser!.uid)
              //                           .collection('records')
              //                           .doc(patient.id);
              //                       final batch =
              //                       FirebaseFirestore.instance.batch();
              //
              //                       // Delete the document
              //                       batch.delete(docRef);
              //
              //                       // Recursively delete subcollection
              //                       final subcollectionRef =
              //                       docRef.collection('followUp');
              //                       final docs = await subcollectionRef.get();
              //                       for (final doc in docs.docs) {
              //                         batch.delete(doc.reference);
              //                       }
              //                       batch.commit();
              //
              //                       // await FirebaseFirestore.instance
              //                       //      .collection('users')
              //                       //      .doc(FirebaseAuth
              //                       //          .instance.currentUser!.uid)
              //                       //      .collection('records')
              //                       //      .doc(patient.id)
              //                       //      .delete();
              //
              //                       BlocProvider.of<FetchRecordCubit>(context)
              //                           .fetchAllRecord();
              //                       Navigator.pop(context);
              //
              //                     },
              //                     child: Text('Yes')),
              //                 ElevatedButton(
              //                     onPressed: () {
              //                       Navigator.pop(context);
              //                     },
              //                     child: Text('cancel')),
              //               ],
              //             );
              //           });
              //     } else {
              //       showDialog(
              //           context: context,
              //           builder: (context) {
              //             return AlertDialog(
              //               title: Text('Please check Your enternet connection'),
              //               actions: [],
              //             );
              //           });
              //     }
              //
              //
              //
              //   },
              //   icon: Icon(
              //     Icons.delete,
              //     color: Colors.teal,
              //     size: 30,
              //   ),
              // ),
            ),
            Text(
              patient.followUpList.length.toString() +
                  "   follow up items      ",
              style: TextStyle(color: Colors.teal),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 20),
              child: Text(
                patient.date,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.teal),
              ),
            )
          ],
        ),
      ),
    );
  }
}
