import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_states.dart';
import 'package:physio_record/HiveService/user_functions.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/models/medical_center_model.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../widgets/custom_text_field.dart';

class AddRecordScreen extends StatefulWidget {
  bool fromCenter;
  MedicalCenterModel? centerModel;
  AddRecordScreen({Key? key, required this.fromCenter, this.centerModel})
      : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  String? patientName,
      diagnosis,
      gender,
      job,
      reasonForVisit,
      conditionAssessment;
  String? phoneNumber, age;
  List<String> program = [],
      mc = [],
      medicalHistory = [],
      medication = [],
      knownAllergies = [];
  TextEditingController programController = TextEditingController();
  TextEditingController mcController = TextEditingController();
  TextEditingController medicalHistoryController = TextEditingController();
  TextEditingController medicationController = TextEditingController();
  TextEditingController knownAllergiesController = TextEditingController();
  String? programItem;
  PatientRecord? patient;

  Future<void> _addRecord(PatientRecord patientRecord) async {
    try {
      BlocProvider.of<AddRecordCubit>(context).addRecord(patientRecord,
          imagePaths, docPaths, widget.fromCenter, widget.centerModel);
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

  int _selectedGenderIndex = 0; // 0 = Male, 1 = Female
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
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          backgroundColor: Colors.blue,
          title: Text(
            'Add Record',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        hint: 'Patient Full Name',
                        onChanged: (v) {
                          patientName = v;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        hint: 'Diagnosis',
                        onChanged: (v) {
                          diagnosis = v;
                        },
                      ),

                      // age
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        hint: 'Age',
                        onChanged: (v) {
                          age = v;
                        },
                      ),
                      // end age field

                      const SizedBox(
                        height: 10,
                      ),

                      // Choose gender section
                      const Text(
                        "Select Gender",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ToggleButtons(
                        isSelected: [
                          _selectedGenderIndex == 0,
                          _selectedGenderIndex == 1
                        ],
                        onPressed: (index) {
                          setState(() {
                            _selectedGenderIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        fillColor: Colors.blueAccent,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.male),
                                SizedBox(width: 8),
                                Text("Male")
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.female),
                                SizedBox(width: 8),
                                Text("Female")
                              ],
                            ),
                          ),
                        ],
                      ),
                      // End Choose gender section

                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        '*optional fields',
                        style: TextStyle(color: Colors.teal),
                      ),

                      // phone number
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        isRequired: false,
                        hint: 'Phone Number',
                        onChanged: (v) {
                          phoneNumber = v;
                        },
                      ),
                      //end phone number

                      //Job
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        hint: 'Job',
                        isRequired: false,
                        onChanged: (v) {
                          job = v;
                        },
                      ),
                      // end Job

                      //Reason For Visit
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        hint: 'Reason For Visit',
                        isRequired: false,
                        onChanged: (v) {
                          reasonForVisit = v;
                        },
                      ),
                      // End Reason For Visit

                      //condition Assessment
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        hint: 'Condition Assessment',
                        isRequired: false,
                        onChanged: (v) {
                          conditionAssessment = v;
                        },
                      ),
                      // end condition Assessment

                      // other medical conditions section
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        suffixButton: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.zero),
                            onPressed: () {
                              if (mcController!.text.isNotEmpty) {
                                mc.add(mcController!.text.trim()!);
                                mcController!.clear();
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.add)),
                        controller: mcController,
                        hint: 'Other Medical Conditions',
                        isRequired: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (mc.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 15),
                              child: Row(
                                children: [
                                  Text('-  ' + mc[index]),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        mc.removeAt(index);
                                        mcController!.clear();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.blue,
                                      ))
                                ],
                              ),
                            );
                          },
                          itemCount: mc.length,
                        ),
                      // end Other medical conditions section

                      //medical history section
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        suffixButton: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.zero),
                            onPressed: () {
                              if (medicalHistoryController!.text.isNotEmpty) {
                                medicalHistory.add(
                                    medicalHistoryController!.text.trim()!);
                                medicalHistoryController!.clear();
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.add)),
                        controller: medicalHistoryController,
                        hint: 'Medical History',
                        isRequired: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (medicalHistory.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 15),
                              child: Row(
                                children: [
                                  Text('-  ' + medicalHistory[index]),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        medicalHistory.removeAt(index);
                                        medicalHistoryController!.clear();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.blue,
                                      ))
                                ],
                              ),
                            );
                          },
                          itemCount: medicalHistory.length,
                        ),
                      // end medical history section

                      // medication
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        suffixButton: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.zero),
                            onPressed: () {
                              if (medicationController!.text.isNotEmpty) {
                                medication
                                    .add(medicationController!.text.trim()!);
                                medicationController!.clear();
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.add)),
                        controller: medicationController,
                        hint: 'medication',
                        isRequired: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (medication.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 15),
                              child: Row(
                                children: [
                                  Text('-  ' + medication[index]),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        medication.removeAt(index);
                                        medicationController!.clear();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.blue,
                                      ))
                                ],
                              ),
                            );
                          },
                          itemCount: medication.length,
                        ),
                      // end medication

                      // known allergies
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        suffixButton: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.zero),
                            onPressed: () {
                              if (knownAllergiesController!.text.isNotEmpty) {
                                knownAllergies.add(
                                    knownAllergiesController!.text.trim()!);
                                knownAllergiesController!.clear();
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.add)),
                        controller: knownAllergiesController,
                        hint: 'Known Allergies',
                        isRequired: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (knownAllergies.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 15),
                              child: Row(
                                children: [
                                  Text('-  ' + knownAllergies[index]),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        knownAllergies.removeAt(index);
                                        knownAllergiesController!.clear();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.blue,
                                      ))
                                ],
                              ),
                            );
                          },
                          itemCount: knownAllergies.length,
                        ),
                      // end known allergies

                      //Program Section
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        enabled: state is AddRecordLoading ? false : true,
                        isRequired: false,

                        controller: programController,
                        suffixButton: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.zero),
                            onPressed: () {
                              if (programController!.text.isNotEmpty) {
                                program.add(programController!.text.trim()!);
                                programController!.clear();
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.add)),
                        // maxLines: null,
                        hint: 'Program',
                        // onChanged: (v) {
                        //   programItem = v;
                        // },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (program.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 15),
                              child: Row(
                                children: [
                                  Text('-  ' + program[index]),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        program.removeAt(index);
                                        programController!.clear();
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.blue,
                                      ))
                                ],
                              ),
                            );
                          },
                          itemCount: program.length,
                        ),
                      // end Program Section

                      SizedBox(
                        height: 10,
                      ),
                      if (imagePaths != [])
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                      backgroundColor:
                                          Colors.grey.withOpacity(.5),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
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
                                IconButton(
                                    onPressed: () {
                                      docPaths!.removeAt(index);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.close))
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
                              child: Chip(
                                  label: Row(
                                children: [
                                  Text("Add Imaging"),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              )),
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: TextButton(
                                        onPressed: () {
                                          if (Navigator.canPop(context))
                                            Navigator.pop(context);

                                          _choosePdfFile();
                                        },
                                        child: Text('pdf'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                        child: TextButton(
                                            onPressed: () {
                                              if (Navigator.canPop(context))
                                                Navigator.pop(context);

                                              _pickImage(ImageSource.camera);
                                            },
                                            child: Text('camera'))),
                                    PopupMenuItem(
                                        child: TextButton(
                                            onPressed: () {
                                              if (Navigator.canPop(context))
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
                    ],
                  ),
                ),
              ),
              Divider(
                thickness: 2,
                height: 0,
              ),
              Container(
                color: Colors.blue[100],
                width: double.infinity,
                height: 100,
                child: state is AddRecordLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        color: Colors.blue,
                      ))
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18.0, horizontal: 50),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                          ),
                          onPressed: state is AddRecordLoading
                              ? null
                              : () async {
                                  final List<ConnectivityResult>
                                      connectivityResult = await (Connectivity()
                                          .checkConnectivity());

                                  if (connectivityResult
                                          .contains(ConnectivityResult.none) &&
                                      widget.fromCenter) {
                                    Fluttertoast.showToast(
                                        msg: 'Check Your Internet Connection');
                                  } else {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();

                                      var currentDate = DateTime.now();

                                      var formattedCurrentDate =
                                          DateFormat('hh:mm d-M-y')
                                              .format(currentDate);

                                      var uuid = Uuid();
                                      String recordId = uuid.v4();
                                      patient = PatientRecord(
                                        doctorName: getCurrentUser()!.userName,
                                        doctorImage: getCurrentUser()!.imageUrl,
                                        patientName: patientName!,
                                        id: recordId,
                                        date: formattedCurrentDate,
                                        diagnosis: diagnosis!,
                                        mc: mc ?? [],
                                        program: program ?? [],
                                        followUpList: [],
                                        rayImages: imagePaths ?? [],
                                        raysPDF: docPaths ?? [],
                                        onlyInLocal: false,
                                        followUpOnlyInLocal: [],
                                        followUpIdsUpdatedOnlyInLocal: [],
                                        doctorsId: [],
                                        //new Args
                                        age: int.parse(age!),
                                        gender: _selectedGenderIndex == 0
                                            ? 'Male'
                                            : "Female",
                                        medicalHistory: medicalHistory ?? [],
                                        medication: medication ?? [],
                                        knownAllergies: knownAllergies ?? [],
                                        phoneNumer:
                                            int.parse(phoneNumber ?? "0"),
                                        job: job ?? '',
                                        reasonForVisit: reasonForVisit ?? '',
                                        conditionAssessment:
                                            conditionAssessment ?? '',
                                      );

                                      _addRecord(patient!).whenComplete(() {
                                        // Navigator.pop(context);
                                      });
                                    } else {
                                      autovalidateMode =
                                          AutovalidateMode.always;
                                      setState(() {});
                                    }
                                  }
                                },
                          child: state is AddRecordLoading
                              ? Center(child: CircularProgressIndicator())
                              : Text(
                                  'Add Record',
                                  style: TextStyle(fontSize: 20),
                                ),
                        ),
                      ),
              ),
            ],
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
      // }

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
