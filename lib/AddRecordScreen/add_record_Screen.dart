import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:uuid/uuid.dart';

import '../widgets/custom_text_field.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddRecordScreen extends StatefulWidget {
  AddRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  String? patientName, diagnosis, mc, program;
  PatientRecord? patient;

  Future<void> _addRecord(PatientRecord patientRecord) async {
    try {
      BlocProvider.of<AddRecordCubit>(context).addRecord(patientRecord);
    } catch (e) {
      print(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddRecordCubit, AddRecordState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Record'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              autovalidateMode: autovalidateMode,
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  CustomTextField(
                    hint: 'Patient Name',
                    onChanged: (v) {
                      patientName = v;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomTextField(
                    hint: 'Diagnosis',
                    onChanged: (v) {
                      diagnosis = v;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomTextField(
                    hint: 'MC',
                    onChanged: (v) {
                      mc = v;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomTextField(
                    hint: 'program',
                    onChanged: (v) {
                      program = v;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        var currentDate = DateTime.now();

                        var formattedCurrentDate =
                            DateFormat('hh:mm d-M-y').format(currentDate);

                        var uuid = Uuid();
                        String recordId = uuid.v4();
                        patient = PatientRecord(
                            patientName: patientName!,
                            id: recordId,
                            date: formattedCurrentDate,
                            diagnosis: diagnosis!,
                            mc: [mc!],
                            program: program!,
                            followUpList: [],
                            onlyInLocal: false, followUpIdsOnlyInLocal: [], followUpIdsUpdatedOnlyInLocal: []);

                        _addRecord(patient!).whenComplete(() {
                          // Navigator.pop(context);


                        });
                      } else {
                        autovalidateMode = AutovalidateMode.always;
                        setState(() {});
                      }
                    },
                    child: Text(
                      'Add Record',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }, listener: (context, state) {
      // if (state is AddRecordLoading) {
      //   showDialog(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           content: Center(
      //             child: CircularProgressIndicator(),
      //           ),
      //         );
      //       });
      // } else

        if (state is AddRecordError) {
        Fluttertoast.showToast(
            msg: "${state.error}", backgroundColor: Colors.redAccent);
        print(state.error);
      } else if (state is AddRecordSuccess) {
          BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
        Fluttertoast.showToast(
            msg: "Record Added successfully",
            backgroundColor: Colors.tealAccent,
            textColor: Colors.black);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RecordDetailsScreen(patientRecord: patient!)));

      }
    });
  }
}
