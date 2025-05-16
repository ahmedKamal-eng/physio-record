import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:physio_record/FollowUpScreen/follow_up_screen.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_states.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_cubit.dart';

import 'package:physio_record/models/patient_record.dart';

import '../global_vals.dart';

class RecordDetailsScreen extends StatelessWidget {
  PatientRecord patientRecord;

  RecordDetailsScreen({Key? key, required this.patientRecord})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return BlocBuilder<EditRecordCubit, EditRecordState>(
        builder: (context, state) {
      return Scaffold(
        backgroundColor:
            Colors.blue[50], // Light blue background for modern feel
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 5,
          title: Text(
            patientRecord.date,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Patient Basic Info**
              _buildSectionTitle("Patient Information"),
              _buildEditableTile(patientRecord, "Name",
                  patientRecord.patientName, "name", context, Icons.person),
              _buildEditableTile(patientRecord, "Age",
                  patientRecord.age.toString(), "age", context, Icons.cake),
              _buildStaticTile(
                  "Gender", patientRecord.gender ?? "", Icons.male),

              // **Medical Details**
              _buildSectionTitle("Medical Details"),
              _buildEditableTile(
                  patientRecord,
                  "Diagnosis",
                  patientRecord.diagnosis,
                  "diagnosis",
                  context,
                  Icons.local_hospital),
              _buildEditableTile(
                  patientRecord,
                  "Phone Number",
                  patientRecord.phoneNumer.toString(),
                  "phoneNumber",
                  context,
                  Icons.phone),
              _buildEditableTile(
                  patientRecord,
                  "Condition Assessment",
                  patientRecord.conditionAssessment ?? "",
                  "conditionAssessment",
                  context,
                  Icons.assessment),
              _buildEditableTile(
                  patientRecord,
                  "Reason for Visit",
                  patientRecord.reasonForVisit ?? "",
                  "reasonForVisit",
                  context,
                  Icons.event_note),

              // **Job Info**
              _buildSectionTitle("Occupation"),
              _buildEditableTile(patientRecord, "Job", patientRecord.job ?? "",
                  "job", context, Icons.work),

              // **Medical Conditions & Programs**
              _buildSectionTitle("Medical Conditions"),
              _buildEditableListTile(patientRecord, "Other Medical Conditions",
                  patientRecord.mc, "mc", context, Icons.sick),
              _buildEditableListTile(patientRecord, "Programs",
                  patientRecord.program, "program", context, Icons.list),
              _buildEditableListTile(
                  patientRecord,
                  "Known Allergies",
                  patientRecord.knownAllergies,
                  "knownAllergies",
                  context,
                  Icons.warning),

              // **Medical History & Medications**
              _buildSectionTitle("Medical History"),
              _buildEditableListTile(
                  patientRecord,
                  "Medical History",
                  patientRecord.medicalHistory,
                  "medicalHistory",
                  context,
                  Icons.history),
              _buildEditableListTile(
                  patientRecord,
                  "Medications",
                  patientRecord.medication,
                  "medication",
                  context,
                  Icons.medication),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );

      // return Scaffold(
      //   appBar: AppBar(
      //     leading: IconButton(
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //         icon: Icon(
      //           Icons.arrow_back_ios_new,
      //           color: Colors.black,
      //         )),
      //     centerTitle: true,
      //     title: Text(
      //       patientRecord.date,
      //       style: TextStyle(fontSize: 25),
      //     ),
      //   ),
      //   body: Container(
      //     padding: EdgeInsets.all(20),
      //     width: double.infinity,
      //     child: SingleChildScrollView(
      //       physics: BouncingScrollPhysics(),
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           // Name
      //           Wrap(
      //             children: [
      //               Text(
      //                 "Name: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.patientName,
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.patientName, context, "name", false);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     size: 35,
      //                     color: Colors.blue,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           //+++++++++++
      //           // end name
      //           //_________
      //
      //           Divider(),
      //
      //           // Age
      //           Wrap(
      //             children: [
      //               Text(
      //                 "Age: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.age.toString(),
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.age.toString(), context, "age",false);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     size: 35,
      //                     color: Colors.blue,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           //+++++++++++
      //           // end Age
      //           //_________
      //           Divider(),
      //
      //
      //           //______
      //           //Gender
      //           //______
      //
      //           Wrap(
      //             children: [
      //               Text(
      //                 "Gender: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.gender!,
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               // IconButton(
      //               //     onPressed: () {
      //               //       _showEditDialog(
      //               //           patientRecord.age.toString(), context, "age");
      //               //     },
      //               //     icon: Icon(
      //               //       Icons.edit,
      //               //       size: 35,
      //               //       color: Colors.blue,
      //               //     ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Divider(),
      //           //______
      //           // End Gender
      //           //______
      //
      //           //_________
      //           //Diagnosis
      //           //________
      //           Wrap(
      //             children: [
      //               Text(
      //                 "Diagnosis: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.diagnosis,
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.diagnosis, context, "diagnosis",false);
      //                     // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Divider(),
      //           //_________
      //           //End Diagnosis
      //           //________
      //
      //           // phone Number
      //           Wrap(
      //             children: [
      //               Text(
      //                 "Phone Number: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.phoneNumer.toString(),
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(patientRecord.phoneNumer.toString(),
      //                         context, "phoneNumber",false);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     size: 35,
      //                     color: Colors.blue,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           //+++++++++++
      //           // end phone number
      //           //_________
      //           Divider(),
      //
      //           //_________
      //           //Condition Assessment
      //           //________
      //           Wrap(
      //             children: [
      //               Text(
      //                 "Condition Assessmnet: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.conditionAssessment!,
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.conditionAssessment!, context, "conditionAssessment",false);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Divider(),
      //           //_________
      //           //End Condition Assessment
      //           //________
      //
      //           //_________
      //           //reasonForVisit
      //           //________
      //           Wrap(
      //             children: [
      //               Text(
      //                 "reasonForVisit: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.reasonForVisit ?? '',
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.reasonForVisit ?? "", context, "reasonForVisit",false);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Divider(),
      //           //_________
      //           //End reasonForVisit
      //           //________
      //
      //           //_________
      //           //job
      //           //________
      //           Wrap(
      //             children: [
      //               Text(
      //                 "job: ",
      //                 style: Theme.of(context)
      //                     .textTheme
      //                     .titleLarge!
      //                     .copyWith(color: Colors.grey[500]),
      //               ),
      //               Text(
      //                 patientRecord.job ?? '',
      //                 style: Theme.of(context).textTheme.titleLarge,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.job ?? "", context, "job",false);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 10,
      //           ),
      //           Divider(),
      //           //_________
      //           //End job
      //           //________
      //
      //           //_________
      //           //Start mc
      //           //________
      //           Text(
      //             'Other Medical Conditions:',
      //             style: Theme.of(context)
      //                 .textTheme
      //                 .titleLarge!
      //                 .copyWith(color: Colors.grey[500]),
      //           ),
      //           Wrap(
      //             children: [
      //               ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: NeverScrollableScrollPhysics(),
      //                 itemBuilder: (context, index) {
      //                   return Text(
      //                     '\u2022 ${patientRecord.mc[index]}',
      //                     style: Theme.of(context).textTheme.titleLarge,
      //                   );
      //                 },
      //                 itemCount: patientRecord.mc.length,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.mc.join('\n'), context, "mc",true);
      //                     // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           Divider(),
      //           //_________
      //           //End mc
      //           //________
      //
      //           const SizedBox(
      //             height: 10,
      //           ),
      //
      //           //_____________
      //           //Start Program
      //           //_____________
      //           Text(
      //             'Program:',
      //             style: Theme.of(context)
      //                 .textTheme
      //                 .titleLarge!
      //                 .copyWith(color: Colors.grey[500]),
      //           ),
      //           Wrap(
      //             children: [
      //               ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: NeverScrollableScrollPhysics(),
      //                 itemBuilder: (context, index) {
      //                   return Text(
      //                     '\u2022 ${patientRecord.program[index]}',
      //                     style: Theme.of(context).textTheme.titleLarge,
      //                   );
      //                 },
      //                 itemCount: patientRecord.program.length,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(patientRecord.program.join('\n'),
      //                         context, "program",true);
      //                     // BlocProvider.of<EditRecordCubit>(context).editName(patientRecord, "ahmed");
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           //___________
      //           //End Program
      //           //___________
      //
      //           Divider(),
      //
      //           //_____________
      //           //Start known Allergies
      //           //_____________
      //           Text(
      //             'known Allergies:',
      //             style: Theme.of(context)
      //                 .textTheme
      //                 .titleLarge!
      //                 .copyWith(color: Colors.grey[500]),
      //           ),
      //           Wrap(
      //             children: [
      //               ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: NeverScrollableScrollPhysics(),
      //                 itemBuilder: (context, index) {
      //                   return Text(
      //                     '\u2022 ${patientRecord.knownAllergies[index]}',
      //                     style: Theme.of(context).textTheme.titleLarge,
      //                   );
      //                 },
      //                 itemCount: patientRecord.knownAllergies.length,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.knownAllergies.join('\n'),
      //                         context,
      //                         "knownAllergies",true);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           //___________
      //           //End known Allergies
      //           //___________
      //
      //           Divider(),
      //
      //           //_____________
      //           //Start Medical History
      //           //_____________
      //           Text(
      //             'Medical History:',
      //             style: Theme.of(context)
      //                 .textTheme
      //                 .titleLarge!
      //                 .copyWith(color: Colors.grey[500]),
      //           ),
      //           Wrap(
      //             children: [
      //               ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: NeverScrollableScrollPhysics(),
      //                 itemBuilder: (context, index) {
      //                   return Text(
      //                     '\u2022 ${patientRecord.medicalHistory[index]}',
      //                     style: Theme.of(context).textTheme.titleLarge,
      //                   );
      //                 },
      //                 itemCount: patientRecord.medicalHistory.length,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(
      //                         patientRecord.medicalHistory.join('\n'),
      //                         context,
      //                         "medicalHistory",true);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           //___________
      //           //End Medical History
      //           //___________
      //
      //           Divider(),
      //
      //           //_____________
      //           //Start Medication
      //           //_____________
      //           Text(
      //             'Medication:',
      //             style: Theme.of(context)
      //                 .textTheme
      //                 .titleLarge!
      //                 .copyWith(color: Colors.grey[500]),
      //           ),
      //           Wrap(
      //             children: [
      //               ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: NeverScrollableScrollPhysics(),
      //                 itemBuilder: (context, index) {
      //                   return Text(
      //                     '\u2022 ${patientRecord.medication[index]}',
      //                     style: Theme.of(context).textTheme.titleLarge,
      //                   );
      //                 },
      //                 itemCount: patientRecord.medication.length,
      //               ),
      //               IconButton(
      //                   onPressed: () {
      //                     _showEditDialog(patientRecord.medication.join('\n'),
      //                         context, "medication",true);
      //                   },
      //                   icon: Icon(
      //                     Icons.edit,
      //                     color: Colors.blue,
      //                     size: 35,
      //                   ))
      //             ],
      //           ),
      //           //___________
      //           //End Medication
      //           //___________
      //
      //           SizedBox(
      //             height: 10,
      //           ),
      //           // Divider(
      //           //   thickness: 3,
      //           //   color: Colors.teal,
      //           // ),
      //           // SizedBox(
      //           //   height: 20,
      //           // ),
      //           //
      //           // Center(
      //           //   child: ElevatedButton(
      //           //       onPressed: () {
      //           //         Navigator.push(
      //           //             context,
      //           //             MaterialPageRoute(
      //           //                 builder: (context) => FollowUPScreen(
      //           //                     patientRecord: patientRecord)));
      //           //       },
      //           //       child: Text(
      //           //         "Go To Follow Up Section",
      //           //         style:
      //           //             TextStyle(fontSize: screenSize.width * .06),
      //           //       )),
      //           // ),
      //
      //           // follow up section
      //           // Align(
      //           //     alignment: Alignment.center,
      //           //     child: Container(
      //           //       padding: EdgeInsets.all(6),
      //           //       decoration: BoxDecoration(
      //           //         color: Colors.blue.withOpacity(.2),
      //           //         border: Border.all(
      //           //           width: 2,
      //           //           color: Colors.blue
      //           //         ),
      //           //       ),
      //           //       child: Text(
      //           //         'Follow Up',
      //           //         style: Theme.of(context).textTheme.titleLarge,
      //           //       ),
      //           //     )),
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           // ListView.separated(
      //           //   physics:NeverScrollableScrollPhysics(),
      //           //     shrinkWrap: true,
      //           //     itemBuilder: (context, index) {
      //           //       return FollowUPListItem( followUp: widget.patientRecord.followUpList[index],);
      //           //     },
      //           //     separatorBuilder: (context, index) {
      //           //       return Divider(
      //           //         thickness: 1,
      //           //       );
      //           //     },
      //           //     itemCount: widget.patientRecord.followUpList.length),
      //           //
      //           // const SizedBox(height: 20,),
      //           // TextField(
      //           //   controller: textController,
      //           //   decoration: InputDecoration(
      //           //     suffix: ElevatedButton(
      //           //       onPressed: (){
      //           //         var formattedCurrentDate =
      //           //         DateFormat('d-M-y').format(DateTime.now());
      //           //         widget.patientRecord.followUpList.add(FollowUp(date: formattedCurrentDate, text: textController.text.trim()));
      //           //         widget.patientRecord.save();
      //           //         setState(() {
      //           //
      //           //         });
      //           //       },
      //           //       child: Text('add'),
      //           //     ),
      //           //     label: Text('text'),
      //           //     border: OutlineInputBorder()
      //           //   ),
      //           // ),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
    });
  }
}

showEditDialog(PatientRecord patientRecord, String txt, BuildContext context,
    String fieldName, bool isList) {
  TextEditingController editController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey();

  editController.text = txt;
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(fieldName),
          content: Form(
            key: formState,
            child: TextFormField(
              keyboardType: fieldName == 'age' || fieldName == 'phoneNumber'
                  ? TextInputType.number
                  : null,
              inputFormatters: fieldName == 'age'
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ]
                  : fieldName == 'phoneNumber'
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : [],
              maxLines: isList ? null : 1,
              controller: editController,
              decoration: InputDecoration(
                  suffix: ElevatedButton(
                onPressed: () async {
                  if (formState.currentState!.validate()) {
                    final List<ConnectivityResult> connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (!connectivityResult.contains(ConnectivityResult.none)) {
                      DocumentReference recordReference = FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('records')
                          .doc(patientRecord.id);

                      switch (fieldName) {
                        case 'name':
                          await recordReference.update(
                              {"patientName": editController.text.trim()});
                          BlocProvider.of<EditRecordCubit>(context).editName(
                              patientRecord, editController.text.trim());
                          break;
                        case 'diagnosis':
                          await recordReference.update(
                              {"diagnosis": editController.text.trim()});

                          BlocProvider.of<EditRecordCubit>(context)
                              .editDiagnosis(
                                  patientRecord, editController.text.trim());

                          break;
                        case 'mc':
                          await recordReference
                              .update({"mc": editController.text.split('\n')});
                          BlocProvider.of<EditRecordCubit>(context).editMC(
                              patientRecord, editController.text.trim());

                          break;
                        case 'program':
                          await recordReference.update(
                              {"program": editController.text.split('\n')});
                          BlocProvider.of<EditRecordCubit>(context).editProgram(
                              patientRecord, editController.text.trim());
                          break;

                        case 'age':
                          await recordReference
                              .update({'age': int.parse(editController.text)});

                          BlocProvider.of<EditRecordCubit>(context)
                              .editAge(patientRecord, editController.text);

                          break;
                        case 'phoneNumber':
                          await recordReference.update(
                              {'phoneNumber': int.parse(editController.text)});

                          BlocProvider.of<EditRecordCubit>(context)
                              .editPhoneNumber(
                                  patientRecord, editController.text);

                          break;
                        case 'knownAllergies':
                          await recordReference.update({
                            'knownAllergies': editController.text.split('\n')
                          });
                          BlocProvider.of<EditRecordCubit>(context)
                              .editKnownAllergies(
                                  patientRecord, editController.text.trim());

                          break;
                        case 'medicalHistory':
                          await recordReference.update({
                            'medicalHistory': editController.text.split('\n')
                          });

                          BlocProvider.of<EditRecordCubit>(context)
                              .editMedicalHistory(
                                  patientRecord, editController.text.trim());
                          break;
                        case 'medication':
                          await recordReference.update(
                              {'medication': editController.text.split('\n')});

                          BlocProvider.of<EditRecordCubit>(context)
                              .editMedication(
                                  patientRecord, editController.text.trim());

                          break;
                        case 'reasonForVisit':
                          await recordReference.update(
                              {'reasonForVisit': editController.text.trim()});

                          BlocProvider.of<EditRecordCubit>(context)
                              .editReasonForVisit(
                                  patientRecord, editController.text.trim());

                          break;

                        case 'job':
                          await recordReference
                              .update({'job': editController.text.trim()});

                          BlocProvider.of<EditRecordCubit>(context).editJob(
                              patientRecord, editController.text.trim());
                          break;

                        case 'conditionAssessment':
                          await recordReference.update({
                            'conditionAssessment': editController.text.trim()
                          });

                          BlocProvider.of<EditRecordCubit>(context)
                              .editConditionAssessment(
                                  patientRecord, editController.text.trim());
                          break;
                      }

                      BlocProvider.of<FetchRecordCubit>(context)
                          .fetchAllRecord();

                      Navigator.pop(context);
                    } else {
                      switch (fieldName) {
                        case 'name':
                          BlocProvider.of<EditRecordCubit>(context).editName(
                              patientRecord, editController.text.trim());
                          break;

                        case 'diagnosis':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editDiagnosis(
                                  patientRecord, editController.text.trim());
                          break;
                        case 'mc':
                          BlocProvider.of<EditRecordCubit>(context).editMC(
                              patientRecord, editController.text.trim());

                          break;
                        case 'program':
                          BlocProvider.of<EditRecordCubit>(context).editProgram(
                              patientRecord, editController.text.trim());
                          break;

                        case 'age':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editAge(patientRecord, editController.text);

                          break;
                        case 'phoneNumber':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editPhoneNumber(
                                  patientRecord, editController.text);

                          break;
                        case 'knownAllergies':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editKnownAllergies(
                                  patientRecord, editController.text.trim());

                          break;
                        case 'medicalHistory':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editMedicalHistory(
                                  patientRecord, editController.text.trim());
                          break;
                        case 'medication':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editMedication(
                                  patientRecord, editController.text.trim());

                          break;
                        case 'reasonForVisit':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editReasonForVisit(
                                  patientRecord, editController.text.trim());

                          break;

                        case 'job':
                          BlocProvider.of<EditRecordCubit>(context).editJob(
                              patientRecord, editController.text.trim());
                          break;

                        case 'conditionAssessment':
                          BlocProvider.of<EditRecordCubit>(context)
                              .editConditionAssessment(
                                  patientRecord, editController.text.trim());
                          break;
                      }

                      patientRecord.updatedInLocal = true;
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

// **Reusable Section Title**
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      title,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]),
    ),
  );
}

// **Reusable Editable ListTile**
Widget _buildEditableTile(PatientRecord patientRecord, String title,
    String value, String field, BuildContext context, IconData icon) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () =>
            showEditDialog(patientRecord, value, context, field, false),
      ),
    ),
  );
}

// **Reusable Non-Editable ListTile**
Widget _buildStaticTile(String title, String value, IconData icon) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    ),
  );
}

// **Reusable Editable List Tile for Multiple Items**
Widget _buildEditableListTile(PatientRecord patientRecord, String title,
    List<String> items, String field, BuildContext context, IconData icon) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
                (item) => Text("• $item", style: const TextStyle(fontSize: 16)))
            .toList(),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () => showEditDialog(
            patientRecord, items.join('\n'), context, field, true),
      ),
    ),
  );
}
