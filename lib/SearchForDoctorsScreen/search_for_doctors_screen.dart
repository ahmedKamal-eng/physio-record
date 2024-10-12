import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_cubit.dart';
import 'package:physio_record/SearchForDoctorsScreen/ShareRecordCubit/share_record_state.dart';
import 'package:physio_record/models/patient_record.dart';

class UserSearchDelegate extends SearchDelegate<String> {
  final PatientRecord patientRecord;
  UserSearchDelegate({required this.patientRecord});

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
          .where("id",isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
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

        


        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var user = results[index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocConsumer<ShareRecordCubit, ShareRecordState>(
                listener: (context,state){
                  if(state is ShareRecordSuccess)
                    {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Your request sent successfully",backgroundColor: Colors.teal);
                }

                  },
                  builder: (context, state) {


                return InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:state is ShareRecordLoading?Center(child: CircularProgressIndicator(),): Text(
                                "You want to share this record with ${user['userName']}"),
                            actions:state is ShareRecordLoading?[]: [
                              ElevatedButton(
                                  onPressed: () {
                                    BlocProvider.of<ShareRecordCubit>(context)
                                        .shareRecord(
                                      context: context,
                                            recordId: patientRecord.id,
                                            patientName:
                                                patientRecord.patientName,
                                             receiverDoctorName: user['userName'],
                                            receiverDoctorID: user['id'],
                                            diagnosis: patientRecord.diagnosis);
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
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user['imageUrl']),
                            radius: 70,
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          Column(
                            children: [
                              Text(
                                user['userName'],
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Text(user['email'])
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
