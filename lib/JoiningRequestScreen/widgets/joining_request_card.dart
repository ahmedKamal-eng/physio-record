
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/models/joining_reuest_model.dart';

import '../AcceptJoiningRequestCubit/accept_joining_request_cubit.dart';
import '../AcceptJoiningRequestCubit/accept_joining_request_states.dart';

class JoiningRequestCard extends StatelessWidget {
  final JoiningRequestModel requestModel;
  JoiningRequestCard({required this.requestModel});


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: Column(
          children: [
            Align(alignment: Alignment.topCenter,child: Text(requestModel.date)),
            const SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(requestModel.adminImage),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                    width: 200,
                    child: Text(
                      "Dr.${requestModel.adminName} want's you to join the ${requestModel.centerName} center",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                      maxLines: 15,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BlocConsumer<AcceptJoiningRequestCubit, AcceptJoiningRequestState>(
                    listener: (context, state) {
                      if (state is AcceptJoiningRequestError) {
                        Fluttertoast.showToast(
                          msg: state.error,
                          backgroundColor: Colors.redAccent,
                        );
                        print(state.error + "33333333333333333333333");
                        if(Navigator.canPop(context))
                          Navigator.pop(context);
                      }

                      if (state is AcceptJoiningRequestSuccess) {
                        Fluttertoast.showToast(
                            msg:
                            "You Joined ${requestModel.centerName} center",
                            timeInSecForIosWeb: 4,
                            backgroundColor: Colors.teal,
                            textColor: Colors.white);

                        if(Navigator.canPop(context))
                        {
                          Navigator.pop(context);
                        }
                      }
                    }, builder: (context, state) {
                  return ElevatedButton(
                      onPressed: () {
                        showDialog(
                            barrierDismissible:
                            state is AcceptJoiningRequestLoading ? false : true,
                            context: context,
                            builder: (context) {
                              return BlocBuilder<AcceptJoiningRequestCubit,AcceptJoiningRequestState>(
                                  builder: (context,state) {
                                    return AlertDialog(

                                      title: state is AcceptJoiningRequestLoading
                                          ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                          : Text("Are you sure you want to accept this request"),

                                      actions: state is AcceptJoiningRequestLoading
                                          ? []
                                          : [
                                        ElevatedButton(
                                            onPressed: () {
                                              BlocProvider.of<
                                                  AcceptJoiningRequestCubit>(
                                                  context)
                                                  .acceptJoiningRequest(requestModel,context)
                                                  .whenComplete(() {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance
                                                    .currentUser!.uid)
                                                    .collection('joining_requests')
                                                    .doc(requestModel.requestId)
                                                    .delete();
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(requestModel.adminId)
                                                    .collection(
                                                    'submittedRequests')
                                                    .doc(requestModel.requestId)
                                                    .update(
                                                    {"status": "accept"});
                                              });
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
                      child: Text(
                        "Accept",
                      ));
                }),
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "Are You sure You want to refuse this request"),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(requestModel.adminId)
                                          .collection('submittedRequests')
                                          .doc(requestModel.requestId)
                                          .update({"status": "refuse"});

                                      FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                          .collection('joining_requests')
                                          .doc(requestModel.requestId)
                                          .delete();

                                      Navigator.pop(context);
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
                    child: Text(
                      "refuse",
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
