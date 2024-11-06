import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/ShareWithFriendScreen/share_with_friend_screen.dart';
import 'package:physio_record/SharedRecordScreen/DeleteSharedRecordCubit/delete_user_from_shared_record_cubit.dart';
import 'package:physio_record/SharedRecordScreen/DeleteSharedRecordCubit/delete_user_from_shared_record_states.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:physio_record/models/shared_record_model.dart';

import '../SearchForDoctorsScreen/search_for_doctors_screen.dart';
import '../SharedRecordDetailsScreen/shared_record_details_screen.dart';

class SharedRecordScreen extends StatelessWidget {
  SharedRecordScreen({super.key});

  final Stream<QuerySnapshot> _shareRecordStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('sharedRecords')
      .orderBy('date', descending: true)
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
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(
                            'Share',
                            style: TextStyle(color: Colors.teal),
                          ),
                          onTap: () async {
                            final List<ConnectivityResult> connectivityResult =
                                await (Connectivity().checkConnectivity());

                            if (connectivityResult
                                .contains(ConnectivityResult.none)) {
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
                                      title: Center(
                                          child: Text("Share this record")),
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
                                                              doctorIds: List<
                                                                  String>.from(snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index][
                                                                  'doctorsIds']),
                                                              recordModel: SharedRecordModel
                                                                  .fromFirestore(
                                                                      snapshot
                                                                          .data!
                                                                          .docs[index]),
                                                              isSharedBefore:
                                                                  true,
                                                            )));
                                              },
                                              child: Text(
                                                "Share with friend doctors",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal),
                                              onPressed: () {
                                                Navigator.pop(context);

                                                showSearch(
                                                    context: context,
                                                    delegate:
                                                        UserSearchDelegate(
                                                            patientRecord:
                                                                PatientRecord
                                                                    .fromFirestore(
                                                              snapshot.data!
                                                                  .docs[index],
                                                            ),
                                                            isSharedBefore:
                                                                true,
                                                            doctorsIds: List<
                                                                String>.from(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                [
                                                                'doctorsIds'])));
                                              },
                                              child: Text(
                                                "Search for doctors",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ],
                                      ),
                                    );
                                  });
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.teal),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return BlocProvider(
                                      create: (context) =>
                                          DeleteUserFromSharedRecordCubit(),
                                      child: BlocConsumer<
                                              DeleteUserFromSharedRecordCubit,
                                              DeleteUserFromSharedRecordState>(
                                          listener: (context, state) {
                                        if (state
                                            is DeleteSharedRecordSuccess) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'this record deleted successfully');
                                          Navigator.pop(context);
                                        }
                                      }, builder: (context, state) {
                                        return AlertDialog(
                                          title: state
                                                  is DeleteSharedRecordLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : Text(
                                                  "Are you sure You want to Delete ${snapshot.data!.docs[index]['patientName']} record from your shared records"),
                                          actions:
                                              state is DeleteSharedRecordLoading
                                                  ? []
                                                  : [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            BlocProvider.of<
                                                                        DeleteUserFromSharedRecordCubit>(
                                                                    context)
                                                                .deleteUserFromSharedRecord(
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        ['id'],
                                                                    List<
                                                                        String>.from(snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        'doctorsIds']));
                                                          },
                                                          child: Text('Yes')),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('No')),
                                                    ],
                                        );
                                      }));
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
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
