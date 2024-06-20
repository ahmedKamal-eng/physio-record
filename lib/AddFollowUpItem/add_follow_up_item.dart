import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


import '../models/patient_record.dart';

import 'package:open_file/open_file.dart';

import 'package:url_launcher/url_launcher.dart';

class AddFollowUPItemScreen extends StatefulWidget {
  AddFollowUPItemScreen({Key? key, required this.patientRecord})
      : super(key: key);

  PatientRecord patientRecord;

  @override
  State<AddFollowUPItemScreen> createState() => _AddFollowUPItemScreenState();
}

class _AddFollowUPItemScreenState extends State<AddFollowUPItemScreen> {

  TextEditingController textController=TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String imagePath="";

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    imagePath=pickedFile!.path;
    if (pickedFile != null) {
      await _savePhoto(imagePath);
      setState(() {

      });// Call function to save photo
    }
  }

  Future<void> _savePhoto(String imagePath) async {
    // final photoBox = Hive.box<PatientRecord>("patient_records");
    // final photo = Photo(imagePath: imagePath, captureDate: DateTime.now());
    // await photoBox.add(photo); //
    // Add photo to the Hive box
    DateTime currentDate = DateTime.now();
    var formattedCurrentDate = DateFormat('hh:mm d-M-y').format(currentDate);
    widget.patientRecord.followUpList.add(
        FollowUp(date: formattedCurrentDate, text: "test", image: imagePath));
    setState(() {});
  }

  String? docPath;
  String? docName;
  var pdfFile;

  final _filePicker = FilePicker.platform;
  Future<void> _choosePdfFile() async {
    final result = await _filePicker
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.single;
      final path = file.path!;
      final name = file.name;
      docPath = path;
      docName = name;
      pdfFile=file;
      setState(() {});
    }
  }

  void openFile() async {
    OpenFile.open(docPath);

  }

  void saveItem() async{
    widget.patientRecord.save();

  }

  @override
  Widget build(BuildContext context) {

   Size screenSize= MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                      onChanged: (v){
                        setState(() {

                        });
                      },
                      maxLines: null,
                      decoration: InputDecoration(labelText: "text",
                      border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: textController.text.isEmpty && imagePath == "" && docName == null ?null: (){
                    saveItem();
                    Navigator.pop(context);
                  }, child: Text('Save'),style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal:20,vertical: 25)),),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if (imagePath !="")
                Image.file(
                  File(widget.patientRecord.followUpList[widget.patientRecord.followUpList.length -1].image!),
                  width: 200.0,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
              const SizedBox(
                height: 40,
              ),
              if (docName != null)
                TextButton(
                    onPressed: () {
                      openFile();
                    },
                    child: Text(docName!)),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    _pickImage();
                  },
                  child: Text("Add Photo")),
              const SizedBox(height: 40),
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
  }
}

class PdfScreen extends StatelessWidget {
  const PdfScreen({
    super.key,
    required this.docPath,
  });

  final String? docPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: SfPdfViewer.file(File(docPath!)),
    );
  }
}
