import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:physio_record/FollowUpScreen/follow_up_screen.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_states.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_cubit.dart';

import 'package:physio_record/models/patient_record.dart';

class RecordDetailsScreen extends StatelessWidget {
  PatientRecord patientRecord;

  RecordDetailsScreen({Key? key, required this.patientRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    TextEditingController editController = TextEditingController();
    GlobalKey<FormState> formState = GlobalKey();

    _showEditDialog(String txt, BuildContext context, String fieldName) {
      editController.text = txt;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Form(
                key: formState,
                child: TextFormField(
                  maxLines: null,
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "field can not be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: editController,
                  decoration: InputDecoration(
                      suffix: ElevatedButton(
                    onPressed: () async {
                      if (formState.currentState!.validate()) {
                        final List<ConnectivityResult> connectivityResult =
                            await (Connectivity().checkConnectivity());
                        if (!connectivityResult
                            .contains(ConnectivityResult.none)) {
                          if (fieldName == "name") {
                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('records').doc(patientRecord.id).update(
                                {"patientName":editController.text.trim()});
                            BlocProvider.of<EditRecordCubit>(context).editName(
                                patientRecord, editController.text.trim());
                          } else if (fieldName == "diagnosis") {
                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('records').doc(patientRecord.id).update(
                                {"diagnosis":editController.text.trim()});

                            BlocProvider.of<EditRecordCubit>(context)
                                .editDiagnosis(
                                patientRecord, editController.text.trim());
                          } else if (fieldName == "mc") {

                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('records').doc(patientRecord.id).update(
                                {"mc":editController.text.trim()});
                            BlocProvider.of<EditRecordCubit>(context).editMC(
                                patientRecord, editController.text.trim());
                          } else if (fieldName == "program") {
                            FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('records').doc(patientRecord.id).update(
                                {"program":editController.text.trim()});
                            BlocProvider.of<EditRecordCubit>(context)
                                .editProgram(
                                patientRecord, editController.text.trim());
                          }

                          BlocProvider.of<FetchRecordCubit>(context)
                              .fetchAllRecord();

                          Navigator.pop(context);
                        } else {
                          if (fieldName == "name") {
                            BlocProvider.of<EditRecordCubit>(context).editName(
                                patientRecord, editController.text.trim());
                          } else if (fieldName == "diagnosis") {
                            BlocProvider.of<EditRecordCubit>(context)
                                .editDiagnosis(
                                    patientRecord, editController.text.trim());
                          } else if (fieldName == "mc") {
                            BlocProvider.of<EditRecordCubit>(context).editMC(
                                patientRecord, editController.text.trim());
                          } else if (fieldName == "program") {
                            BlocProvider.of<EditRecordCubit>(context)
                                .editProgram(
                                    patientRecord, editController.text.trim());
                          }

                          patientRecord.updatedInLocal=true;
                          patientRecord.save();
                          BlocProvider.of<FetchRecordCubit>(context)
                              .fetchAllRecord();
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text("Edit"),
                  )),
                ),
              ),
            );
          });
    }

    return BlocBuilder<EditRecordCubit, EditRecordState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            patientRecord.date,
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          child: Center(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        children: [
                          Text(
                            'Name: ${patientRecord.patientName}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                              onPressed: () {
                                _showEditDialog(
                                    patientRecord.patientName, context, "name");
                                // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 35,
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      Wrap(
                        children: [
                          Text(
                            'Diagnosis: ${patientRecord.diagnosis}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                              onPressed: () {
                                _showEditDialog(patientRecord.diagnosis,
                                    context, "diagnosis");
                                // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 35,
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        children: [
                          Text(
                            'MC: ${patientRecord.mc[0]}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                              onPressed: () {
                                _showEditDialog(
                                    patientRecord.mc[0], context, "mc");
                                // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 35,
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        children: [
                          Text(
                            'Program: ${patientRecord.program}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                              onPressed: () {
                                _showEditDialog(
                                    patientRecord.program, context, "program");
                                // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 35,
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        thickness: 3,
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FollowUPScreen(
                                          patientRecord: patientRecord)));
                            },
                            child: Text(
                              "Go To Follow Up Section",
                              style:
                                  TextStyle(fontSize: screenSize.width * .06),
                            )),
                      ),

                      // follow up section
                      // Align(
                      //     alignment: Alignment.center,
                      //     child: Container(
                      //       padding: EdgeInsets.all(6),
                      //       decoration: BoxDecoration(
                      //         color: Colors.blue.withOpacity(.2),
                      //         border: Border.all(
                      //           width: 2,
                      //           color: Colors.blue
                      //         ),
                      //       ),
                      //       child: Text(
                      //         'Follow Up',
                      //         style: Theme.of(context).textTheme.titleLarge,
                      //       ),
                      //     )),
                      const SizedBox(
                        height: 20,
                      ),
                      // ListView.separated(
                      //   physics:NeverScrollableScrollPhysics(),
                      //     shrinkWrap: true,
                      //     itemBuilder: (context, index) {
                      //       return FollowUPListItem( followUp: widget.patientRecord.followUpList[index],);
                      //     },
                      //     separatorBuilder: (context, index) {
                      //       return Divider(
                      //         thickness: 1,
                      //       );
                      //     },
                      //     itemCount: widget.patientRecord.followUpList.length),
                      //
                      // const SizedBox(height: 20,),
                      // TextField(
                      //   controller: textController,
                      //   decoration: InputDecoration(
                      //     suffix: ElevatedButton(
                      //       onPressed: (){
                      //         var formattedCurrentDate =
                      //         DateFormat('d-M-y').format(DateTime.now());
                      //         widget.patientRecord.followUpList.add(FollowUp(date: formattedCurrentDate, text: textController.text.trim()));
                      //         widget.patientRecord.save();
                      //         setState(() {
                      //
                      //         });
                      //       },
                      //       child: Text('add'),
                      //     ),
                      //     label: Text('text'),
                      //     border: OutlineInputBorder()
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
