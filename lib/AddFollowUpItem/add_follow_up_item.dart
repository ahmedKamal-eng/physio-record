import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import '../HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import '../models/patient_record.dart';

import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class AddFollowUPItemScreen extends StatefulWidget {
  AddFollowUPItemScreen({Key? key, required this.patientRecord})
      : super(key: key);

  PatientRecord patientRecord;

  @override
  State<AddFollowUPItemScreen> createState() => _AddFollowUPItemScreenState();
}

class _AddFollowUPItemScreenState extends State<AddFollowUPItemScreen> {
  TextEditingController textController = TextEditingController();
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
    return BlocBuilder<AddFollowUpCubit, AddFollowUpState>(
        builder: (context, state) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Container(
                      width: screenSize.width * .78,
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: TextField(
                        controller: textController,
                        onChanged: (v) {
                          setState(() {});
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                            labelText: "text", border: OutlineInputBorder()),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: textController.text.isEmpty &&
                              imagePaths!.isEmpty &&
                              docPaths!.isEmpty
                          ? null
                          : ()async {
                             await BlocProvider.of<AddFollowUpCubit>(context)
                                  .addFollowUpItem(
                                      patientRecord: widget.patientRecord,
                                      text: textController.text.trim(),
                                      imagePaths: imagePaths,
                                      docPaths: docPaths,
                                      context: context
                             )
                                  .whenComplete(() {
                                BlocProvider.of<FetchRecordCubit>(context)
                                    .fetchAllRecord();
                                Navigator.pop(context);
                              });
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FollowUPScreen(patientRecord: widget.patientRecord)));
                            },
                      child:state is AddFollowUpLoading?Center(child: CircularProgressIndicator(),): Text('Save',style: TextStyle(color: Colors.white,fontSize: 16),),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25)),
                    ),
                  ],
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

                // TextButton(
                //     onPressed: () {
                //       openFile();
                //     },
                //     child: Text(docName!)),

                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery);
                    },
                    child: Text("Add Photo from gallery")),
                const SizedBox(height: 40),
                ElevatedButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera);
                    },
                    child: Text("take photo from camera")),
                const SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: () {
                      _choosePdfFile();
                    },
                    child: Text("Add document")),
                const SizedBox(height: 40)
              ],
            ),
          ),
        ),
      );
    });
  }
}

// class PdfScreen extends StatelessWidget {
//   const PdfScreen({
//     super.key,
//     required this.docPath,
//   });
//
//   final String? docPath;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // body: SfPdfViewer.file(File(docPath!)),
//         );
//   }
// }
