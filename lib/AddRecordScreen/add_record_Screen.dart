import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

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

  String? patientName, diagnosis, program;
  List<String>? mc;
  PatientRecord? patient;

  Future<void> _addRecord(PatientRecord patientRecord) async {
    try {
      BlocProvider.of<AddRecordCubit>(context).addRecord(patientRecord,imagePaths,docPaths);
    } catch (e) {
      print(e.toString());
    }
  }

  final ImagePicker _picker = ImagePicker();
  List<String>? imagePaths = [];

  Future<void> _pickImage(ImageSource imageSource) async {
    final pickedFile = await _picker.pickImage(source: imageSource);
    imagePaths!.add(pickedFile!.path);
    if (pickedFile != null) {
      // await _savePhoto(imagePath);
      setState(() {}); // Call function to save photo
    }
    print(pickedFile.path);
  }

  List<String>? docPaths = [];
  String? docName;
  var pdfFile;

  final _filePicker = FilePicker.platform;
  Future<void> _choosePdfFile() async {
    final result = await _filePicker
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.single;
      final path = file.path!;

      docPaths!.add(path);

      pdfFile = file;
      setState(() {});
    }
  }

  void openFile(String path) async {
    OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
                    hint: 'Patient Full Name',
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
                    hint: 'Other Medical Conditions',
                    maxLines: null,
                    onChanged: (v) {
                      mc = v.split('\n');
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomTextField(
                    hint: 'Program',
                    onChanged: (v) {
                      program = v;
                    },
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  if (imagePaths != [])
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            children: [
                              Image.file(
                                File(imagePaths![index]),
                                width: screenSize.width * .3,
                                height: screenSize.width * .3,
                                fit: BoxFit.cover,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  imagePaths!.removeAt(index);
                                  setState(() {});
                                },
                                child: Icon(Icons.close),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(.5),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: imagePaths!.length,
                    ),

                  const SizedBox(
                    height: 40,
                  ),
                  if (docPaths != [])
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  openFile(docPaths![index]);
                                },
                                child: Text(p.basename(docPaths![index]))),
                            IconButton(onPressed: (){
                              docPaths!.removeAt(index);
                              setState(() {

                              });
                            }, icon:Icon( Icons.close))
                          ],
                        );
                      },
                      itemCount: docPaths!.length,
                    ),
                  Row(
                    children: [
                      Text(
                        '*optional',
                        style: TextStyle(color: Colors.teal),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      PopupMenuButton(
                          enabled: true,
                          child: Chip(label: Text("Add X-Ray")),
                          itemBuilder: (context) => [

                            PopupMenuItem(
                                    child: TextButton(
                                        onPressed: () {

                                           if(Navigator.canPop(context))
                                             Navigator.pop(context);

                                          _choosePdfFile();

                                        }, child: Text('pdf'),
                                    ),
                            ),


                            PopupMenuItem(
                                    child: TextButton(
                                        onPressed: () {
                                          if(Navigator.canPop(context))
                                            Navigator.pop(context);

                                          _pickImage(ImageSource.camera);
                                        },
                                        child: Text('camera'))),


                            PopupMenuItem(
                                    child: TextButton(
                                        onPressed: () {

                                          if(Navigator.canPop(context))
                                            Navigator.pop(context);

                                          _pickImage(ImageSource.gallery);

                                          },
                                        child: Text('gallery'))),
                              ]),
                    ],
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
                            mc: mc!,
                            program: program!,
                            followUpList: [],
                            rayImages: imagePaths ?? [],
                            raysPDF:docPaths ?? [],
                            onlyInLocal: false,
                            followUpIdsOnlyInLocal: [],
                            followUpIdsUpdatedOnlyInLocal: [],
                            doctorsId: []);

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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RecordDetailsScreen(patientRecord: patient!)));
      }
    });
  }
}
