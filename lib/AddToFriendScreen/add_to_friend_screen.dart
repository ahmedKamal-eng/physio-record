import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/AddToFriendScreen/AddToFriendCubit/add_to_friend_cubit.dart';
import 'package:physio_record/AddToFriendScreen/AddToFriendCubit/add_to_friend_states.dart';

class AddToFriendScreen extends SearchDelegate<String> {
  List<String> friendIds;
  AddToFriendScreen({required this.friendIds});

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

            if (friendIds.contains(user['id'])) {
              return Container();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocConsumer<AddToFriendCubit, AddToFriendState>(
                  listener: (context, state) {
                if (state is AddToFriendSuccess) {

                  Fluttertoast.showToast(
                      msg:
                          "Dr.${user['userName']} added to your friends successfully",
                      backgroundColor: Colors.teal);
                  if(Navigator.canPop(context))
                    {
                      Navigator.pop(context);

                    }
                }
              }, builder: (context, state) {
                return InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return BlocBuilder<AddToFriendCubit,AddToFriendState>(
                            builder: (context,state) {
                              return AlertDialog(
                                title: state is AddToFriendLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Text(
                                        "You want to add Dr.${user['userName']} to your Colleagues"),
                                actions: state is AddToFriendLoading
                                    ? []
                                    : [
                                        ElevatedButton(
                                            onPressed: () {
                                              BlocProvider.of<AddToFriendCubit>(
                                                      context)
                                                  .addUserToFriend(
                                                      id: user['id'],
                                                      name: user['userName'],
                                                      img: user['imageUrl'],
                                                      medicalSpecialization: user[
                                                          'medicalSpecialization']);
                                            },
                                            child: Text("Yes")),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("No")),
                                      ],
                              );
                            }
                          );
                        });
                  },
                  child: Card(

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user['imageUrl']),
                            radius: 40,
                          ),
                          SizedBox(width: 20,),

                          Flexible(
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
