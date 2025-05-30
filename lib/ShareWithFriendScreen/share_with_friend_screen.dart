import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_cubit.dart';
import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_state.dart';
import 'package:physio_record/global_vals.dart';

import '../models/shared_record_model.dart';

class ShareWithFriendScreen extends StatelessWidget {
  List<String> doctorIds;
  final recordModel;
  bool isSharedBefore;
  ShareWithFriendScreen(
      {required this.doctorIds,
      required this.recordModel,
      required this.isSharedBefore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('share with Colleagues'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('friends')
            .snapshots(),
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
              if (doctorIds.contains(snapshot.data!.docs[index]['id'])) {
                return Container();
              }
              return BlocConsumer<ShareRecordCubit, ShareRecordState>(
                  listener: (context, state) {
                if (state is ShareRecordSuccess) {
                  Fluttertoast.showToast(
                      msg: "Your request sent successfully",
                      backgroundColor: Colors.teal);

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
              }, builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return BlocBuilder<ShareRecordCubit,
                              ShareRecordState>(builder: (context, state) {
                            return AlertDialog(
                              title: state is ShareRecordLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(
                                      "You want to share this record with ${snapshot.data!.docs[index]['name']}"),
                              actions: state is ShareRecordLoading
                                  ? []
                                  : [
                                      ElevatedButton(
                                          onPressed: () {
                                            BlocProvider.of<ShareRecordCubit>(
                                                    context)
                                                .shareRecord(
                                                    context: context,
                                                    recordId: recordModel.id,
                                                    patientName:
                                                        recordModel.patientName,
                                                    receiverDoctorName: snapshot
                                                        .data!
                                                        .docs[index]['name'],
                                                    receiverDoctorID: snapshot
                                                        .data!
                                                        .docs[index]['id'],
                                                    diagnosis:
                                                        recordModel.diagnosis,
                                                    isSharedBefore:
                                                        isSharedBefore,
                                                    recordDate:
                                                        convertStringToTimestamp(
                                                            recordModel.date),
                                                    doctorIds: isSharedBefore
                                                        ? recordModel.doctorsId
                                                        : [
                                                            snapshot.data!
                                                                    .docs[index]
                                                                ['id'],
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                          ]);
                                          },
                                          child: Text("Yes")),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("No")),
                                    ],
                            );
                          });
                        });
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]['image']),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.docs[index]['name'],
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                ),
                                Text(snapshot.data!.docs[index]
                                    ['medicalSpecialization'])
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }
}
