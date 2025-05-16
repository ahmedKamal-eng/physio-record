

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/AddDoctorToCenter/AddDoctorToCenterCubit/add_doctor_to_center_cubit.dart';
import 'package:physio_record/AddDoctorToCenter/AddDoctorToCenterCubit/add_doctor_to_center_states.dart';
import 'package:physio_record/models/medical_center_model.dart';

import '../models/patient_record.dart';

class AddDoctorToCenterScreen extends SearchDelegate<String> {

  List<String> doctorsIds;
  List<String> doctorsWantsToJoin;
  MedicalCenterModel centerModel;

  AddDoctorToCenterScreen(
      {required this.centerModel,
        required this.doctorsIds,required this.doctorsWantsToJoin});

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
          physics: BouncingScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            var user = results[index];

            if (doctorsIds.contains(user['id'])) {
              return Container();
            }

            if (doctorsWantsToJoin.contains(user['id'])) {
              return Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text("Already send joining request to Dr.${user['userName']}",style: TextStyle(color: Colors.teal),),
                      Divider(color: Colors.teal,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user['imageUrl']),
                            radius: 40,
                          ),
                          SizedBox(width: 20,),
                          Expanded(
                            child: Column(
                              // mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  maxLines: 3,

                                  overflow: TextOverflow.ellipsis,
                                  user['userName'],
                                  style:
                                  Theme.of(context).textTheme.headlineMedium,

                                ),
                                Text(user['email']),
                                Text(user['medicalSpecialization']),

                              ],
                            ),
                          )
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   children: [
                          //     Text(
                          //       user['userName'],
                          //       style:
                          //           Theme.of(context).textTheme.headlineMedium,
                          //     ),
                          //     Text(user['email']),
                          //     Text(user['medicalSpecialization'])
                          //   ],
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            return BlocConsumer<AddDoctorToCenterCubit,AddDoctorToCenterStates>(
              listener: (context,state){
                if (state is SendToDoctorSuccess) {
                  Fluttertoast.showToast(
                      msg: "Your request sent successfully",
                      backgroundColor: Colors.teal);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                }
              },
              builder: (context,state) {
                return InkWell(
                  onTap: (){
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {

                          return BlocBuilder<AddDoctorToCenterCubit,
                              AddDoctorToCenterStates>(builder: (context, state) {
                            return AlertDialog(
                              title: state is SendToDoctorLoading
                                  ? Center(
                                child: CircularProgressIndicator(),
                              )
                                  : Text(
                                  "You want to add Dr.${user['userName']} to Your Center"),
                              actions: state is SendToDoctorLoading
                                  ? []
                                  : [
                                ElevatedButton(
                                    onPressed: () {
                                      BlocProvider.of<AddDoctorToCenterCubit>(
                                          context)
                                          .sendJoiningRequestToDoctor(doctorId: user['id'],doctorName: user['userName'], centerModel: centerModel);
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
                          SizedBox(width: 20,),
                          Expanded(
                            child: Column(
                              // mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  maxLines: 3,
                
                                  overflow: TextOverflow.ellipsis,
                                  user['userName'],
                                  style:
                                  Theme.of(context).textTheme.headlineMedium,
                
                                ),
                                Text(user['email']),
                                Text(user['medicalSpecialization']),
                
                              ],
                            ),
                          )
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   children: [
                          //     Text(
                          //       user['userName'],
                          //       style:
                          //           Theme.of(context).textTheme.headlineMedium,
                          //     ),
                          //     Text(user['email']),
                          //     Text(user['medicalSpecialization'])
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
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
