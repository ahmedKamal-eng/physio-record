import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physio_record/ShareRequestScreen/AcceptRequestCubit/accept_request_cubit.dart';
import 'package:physio_record/ShareRequestScreen/AcceptRequestCubit/accept_request_states.dart';
import 'package:physio_record/models/share_request_model.dart';



class ShareRequestCard extends StatelessWidget {
  final ShareRequestModel requestModel;
  ShareRequestCard({required this.requestModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(requestModel.doctorImage),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                    width: 200,
                    child: Text(
                      "Dr.${requestModel.doctorName} want's to share ${requestModel.patientName} record with You \n diagnosis:${requestModel.diagnosis}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
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
                BlocConsumer<AcceptRequestCubit, AcceptRequestState>(
                    listener: (context, state) {
                  if (state is AcceptRequestError) {
                    Fluttertoast.showToast(
                      msg: state.error,
                      backgroundColor: Colors.redAccent,
                    );
                    print(state.error +
                        "33333333333333333333333333333333333333333333333");
                  }

                  if (state is AcceptRequestSuccess) {
                    Fluttertoast.showToast(
                        msg: "${requestModel.patientName} record added to shared record section",
                        timeInSecForIosWeb: 4,
                        backgroundColor: Colors.teal,
                        textColor: Colors.white);

                    Navigator.pop(context);
                  }


                },
                    builder: (context, state) {
                  return ElevatedButton(
                      onPressed: () {
                        showDialog(
                            barrierDismissible:
                                state is AcceptRequestLoading ? false : true,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: state is AcceptRequestLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Text(
                                        "Are you sure you want to accept this request"),
                                actions: state is AcceptRequestLoading
                                    ? []
                                    : [
                                        ElevatedButton(
                                            onPressed: () {
                                              BlocProvider.of<
                                                          AcceptRequestCubit>(
                                                      context)
                                                  .addSharedRecord(
                                                      requestModel).whenComplete((){
                                                        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('shareRequests').doc(requestModel.requestId).delete();
                                                        FirebaseFirestore.instance.collection('users').doc(requestModel.senderId).collection('submittedRequests').doc(requestModel.requestId).update(
                                                            {"status":"accept"});

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
                            });
                      },
                      child: Text(
                        "Accept",
                        style: TextStyle(color: Colors.teal),
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
                                          .doc(requestModel.senderId)
                                          .collection('submittedRequests')
                                          .doc(requestModel.requestId)
                                          .update({"status": "refuse"});

                                      FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('shareRequests')
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
                      style: TextStyle(color: Colors.teal),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
