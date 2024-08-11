import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pd;
import 'package:physio_record/PdfGenerator/generate_pdf.dart';

import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import 'package:physio_record/AddFollowUpItem/add_follow_up_item.dart';
import 'package:physio_record/FollowUpScreen/widgets/follow_up_item.dart';

import 'package:physio_record/models/patient_record.dart';

import 'package:path/path.dart';

class FollowUPScreen extends StatefulWidget {
  final PatientRecord patientRecord;
  FollowUPScreen({required this.patientRecord});

  @override
  State<FollowUPScreen> createState() => _FollowUPScreenState();
}

class _FollowUPScreenState extends State<FollowUPScreen> {
  // Future<void> _captureAndConvertToPdf() async {
  //   try {
  //     // Ensure the context and render object are not null
  //     final RenderRepaintBoundary? boundary =
  //     _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  //     if (boundary == null) {
  //       print('RenderRepaintBoundary is null');
  //       return;
  //     }
  //
  //     // Capture the scrollable content as an image
  //     final image = await boundary.toImage(pixelRatio: 3.0);
  //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     if (byteData == null) {
  //       print('ByteData is null');
  //       return;
  //     }
  //     final pngBytes = byteData.buffer.asUint8List();
  //
  //     // Create a PDF document and add the captured image
  //     final pdf = pw.Document();
  //     final imageProvider = pw.MemoryImage(pngBytes);
  //     pdf.addPage(pw.Page(build: (context) {
  //       return pw.Center(child: pw.Image(imageProvider));
  //     }));
  //
  //     // Save the PDF file locally
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/scrollable_content.pdf');
  //     await file.writeAsBytes(await pdf.save());
  //
  //     print("PDF saved at ${file.path}");
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    // Optionally, you can jump to the start position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  _showShareDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you want to share this record"),
            actions: [
              ElevatedButton(
                  onPressed: () async{
                      File pdfRecord= await SimplePdfApi.generateSimplePdf(widget.patientRecord);
                      OpenFile.open(pdfRecord.path);
                  },
                  child: Text("Yes")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("no")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {


    bool isDark=  Theme.of(context).brightness == Brightness.dark?true:false;

    return BlocBuilder<AddFollowUpCubit, AddFollowUpState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.patientRecord.patientName + " Follow Up"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  elevation: 10,
                  backgroundColor: Colors.teal),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddFollowUPItemScreen(
                              patientRecord: widget.patientRecord,
                            )));
              },
              child: Text(
                "Add To FollowUp",
                style: TextStyle(fontSize: 18,color:Colors.white),
              ),
            ),
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Colors.grey),
                  ),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${widget.patientRecord.patientName}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Diagnosis: ${widget.patientRecord.diagnosis}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'MC: ${widget.patientRecord.mc[0]}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Program: ${widget.patientRecord.program}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _scrollController,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                return FollowUpItemCard(
                    followUp: widget.patientRecord.followUpList[index]);
              },
              itemCount: widget.patientRecord.followUpList.length,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.share),
          onPressed: () {
            _showShareDialog(context);
          },
        ),

        // FloatingActionButton(
        //   onPressed: (){
        //   },
        //   child: Icon(Icons.add),
        // ),
      );
    });
  }
}
