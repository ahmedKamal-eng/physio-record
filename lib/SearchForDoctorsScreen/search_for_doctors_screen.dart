import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_cubit.dart';
import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_state.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';

class UserSearchDelegate extends SearchDelegate<String> {
  final PatientRecord patientRecord;
  List<String> doctorsIds;
  final isSharedBefore;
  UserSearchDelegate(
      {required this.patientRecord,
      required this.isSharedBefore,
      required this.doctorsIds});

  // Firestore reference
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Override the `buildSuggestions` method to show the results while typing
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Start typing to search...'));
    }

    return FutureBuilder<QuerySnapshot>(
      future: usersCollection
          .where("id", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('userNameLowerCase',
              isGreaterThanOrEqualTo: query.toLowerCase())
          .where('userNameLowerCase',
              isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No results found.'));
        }

        var results = snapshot.data!.docs;
        // if (isSharedBefore) {
        //   FirebaseFirestore.instance
        //       .collection('users')
        //       .doc(FirebaseAuth.instance.currentUser!.uid)
        //       .collection('sharedRecords')
        //       .doc(patientRecord.id)
        //       .get()
        //       .then((val) {
        //         List<String> ids= val.data()!['doctorsIds'];
        //         for(int i=0;i< results.length;i++)
        //           {
        //             if(ids.contains(results[i]['id']))
        //               {
        //                 results.removeAt(i);
        //               }
        //           }
        //
        //   });
        // }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var user = results[index];

            if (doctorsIds.contains(user['id'])) {
              return Container();
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocConsumer<ShareRecordCubit, ShareRecordState>(
                  listener: (context, state) {
                if (state is ShareRecordSuccess) {
                  Fluttertoast.showToast(
                      msg: "Your request sent successfully",
                      backgroundColor: Colors.teal);

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }

                // if (state is ShareRecordLoading) {
                //   showDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Center(
                //           child: CircularProgressIndicator(),
                //         ),
                //       );
                //     },
                //   );
                // }
              }, builder: (context, state) {
                return InkWell(
                  onTap: () {
                    showDialog(
                        barrierDismissible: false,
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
                                      "You want to share this record with ${user['userName']}"),
                              actions: state is ShareRecordLoading
                                  ? []
                                  : [
                                      ElevatedButton(
                                          onPressed: () {
                                            BlocProvider.of<ShareRecordCubit>(
                                                    context)
                                                .shareRecord(
                                                    context: context,
                                                    recordId: patientRecord.id,
                                                    patientName: patientRecord
                                                        .patientName,
                                                    receiverDoctorName:
                                                        user['userName'],
                                                    receiverDoctorID:
                                                        user['id'],
                                                    diagnosis:
                                                        patientRecord.diagnosis,
                                                    isSharedBefore:
                                                        isSharedBefore,
                                                    recordDate:
                                                        convertStringToTimestamp(
                                                            patientRecord.date),
                                                    doctorIds: isSharedBefore
                                                        ? patientRecord
                                                            .doctorsId
                                                        : [
                                                            user['id'],
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user['imageUrl']),
                            radius: 40,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                user['userName'],
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Text(user['email']),
                              Text(user['medicalSpecialization'])
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );

            // return ListTile(
            //   leading: CircleAvatar(
            //     radius: 100,
            //     backgroundImage: NetworkImage(user['imageUrl']),
            //   ),
            //   title: Text(user['userName']),
            //   subtitle: Text(user['email']),
            //   onTap: () {
            //
            //   },
            // );
          },
        );
      },
    );
  }

  // Override the `buildResults` method to show the selected result
  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Selected user: $query'),
      ),
    );
  }

  // Optional: Provide actions for the AppBar like clearing the query
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  // Provide a leading icon (typically a back arrow)
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
}
