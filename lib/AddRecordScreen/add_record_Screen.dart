import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/models/patient_record.dart';

import '../widgets/custom_text_field.dart';

class AddRecordScreen extends StatefulWidget {
  AddRecordScreen({Key? key}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  String? patientName, diagnosis, mc, program;

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
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();

                            var currentDate = DateTime.now();

                            var formattedCurrentDate =
                                DateFormat('hh:mm d-M-y').format(currentDate);

                            PatientRecord patient = PatientRecord(
                                patientName: patientName!,
                                date: formattedCurrentDate,
                                diagnosis: diagnosis!,
                                mc: [mc!],
                                program: program!,
                                followUpList: [
                                  FollowUp(
                                      date: formattedCurrentDate, text: "first",)
                                ]);
                             BlocProvider.of<AddRecordCubit>(context).addRecord(patient);

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
        },
        listener: (context, state) {
          if(state is AddRecordLoading)
            {
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  content: Center(child: CircularProgressIndicator(),),
                );
              });
            }
          else if(state is AddRecordError)
            {
              Fluttertoast.showToast(msg: "${state.error}",backgroundColor: Colors.redAccent);
            }
          else if(state is AddRecordSuccess)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
            Fluttertoast.showToast(msg: "Record Added successfully",backgroundColor: Colors.tealAccent,textColor: Colors.black);
          }
        });
  }
}
