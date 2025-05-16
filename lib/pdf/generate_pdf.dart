import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../models/patient_record.dart';
import 'package:path/path.dart' as p;

class GeneratePdfScreen extends StatefulWidget {
  final String patientId;

  const GeneratePdfScreen({required this.patientId});

  @override
  State<GeneratePdfScreen> createState() => _GeneratePdfScreenState();
}

class _GeneratePdfScreenState extends State<GeneratePdfScreen> {
  Future<void> generatePdf() async {
    // Fetch patient data from Firestore
    final patientDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('records')
        .doc(widget.patientId)
        .get();
    final patientRecord = PatientRecord.fromFirestore(patientDoc);

    // Fetch follow-up data from Firestore
    final followUpSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('records')
        .doc(widget.patientId)
        .collection('followUp')
        .get();
    final followUpList = followUpSnapshot.docs
        .map((doc) => FollowUp.fromFirestore(doc))
        .toList();

    // Load the app logo
    final logoImage = await _loadImage(
        'assets/images/4033.jpg'); // Replace with your logo path

    // Load all ray images
    final List<pw.MemoryImage> rayImages = [];
    for (final imageUrl in patientRecord.rayImages) {
      rayImages.add(await _loadNetworkImage(imageUrl));
    }

    // Load all follow-up images
    final Map<String, List<pw.MemoryImage>> followUpImages = {};
    for (final followUp in followUpList) {
      if (followUp.image != null && followUp.image!.isNotEmpty) {
        final List<pw.MemoryImage> images = [];
        for (final imageUrl in followUp.image!) {
          images.add(await _loadNetworkImage(imageUrl));
        }
        followUpImages[followUp.id] = images;
      }
    }

    // Create a PDF document
    final pdf = pw.Document();

    // Add the first page with the app logo and name
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(logoImage),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Physio Record App',
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add the second page with main patient data
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.Text('Patient Name:',
                    style: pw.TextStyle(color: PdfColors.grey)),
                pw.Text(patientRecord.patientName),
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Text('Date:', style: pw.TextStyle(color: PdfColors.grey)),
                pw.Text(patientRecord.date),
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Text('Diagnosis:',
                    style: pw.TextStyle(color: PdfColors.grey)),
                pw.Text(patientRecord.diagnosis),
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Text('Age:', style: pw.TextStyle(color: PdfColors.grey)),
                pw.Text(patientRecord.age.toString()),
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Text('Gender: ', style: pw.TextStyle(color: PdfColors.grey)),
                pw.Text(patientRecord.gender!),
              ]),
              pw.SizedBox(height: 10),
              if (patientRecord.phoneNumer != 0)
                pw.Row(children: [
                  pw.Text('Phone Number: ',
                      style: pw.TextStyle(color: PdfColors.grey)),
                  pw.Text(patientRecord.phoneNumer.toString()),
                ]),
              if (patientRecord.phoneNumer != 0) pw.SizedBox(height: 10),
              if (patientRecord.job!.isNotEmpty)
                pw.Row(children: [
                  pw.Text('Job: ', style: pw.TextStyle(color: PdfColors.grey)),
                  pw.Text(patientRecord.job!.toString()),
                ]),
              if (patientRecord.job!.isNotEmpty) pw.SizedBox(height: 10),
              if (patientRecord.conditionAssessment!.isNotEmpty)
                pw.Row(children: [
                  pw.Text('Condition Assessment: ',
                      style: pw.TextStyle(color: PdfColors.grey)),
                  pw.Text(patientRecord.conditionAssessment!.toString()),
                ]),
              if (patientRecord.conditionAssessment!.isNotEmpty)
                pw.SizedBox(height: 10),
              if (patientRecord.reasonForVisit!.isNotEmpty)
                pw.Row(children: [
                  pw.Text('Reason For Visit: ',
                      style: pw.TextStyle(color: PdfColors.grey)),
                  pw.Text(patientRecord.reasonForVisit!.toString()),
                ]),
              if (patientRecord.reasonForVisit!.isNotEmpty)
                pw.SizedBox(height: 10),
              if (patientRecord.raysPDF.isNotEmpty)
                pw.Text('Ray PDFs:', style: pw.TextStyle(fontSize: 18)),
              for (int i = 0; i < patientRecord.raysPDF!.length; i++)
                pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.UrlLink(
                    destination: patientRecord.raysPDF![i],
                    child: pw.Text(
                      'PDF: ${p.basename(Uri.decodeComponent(Uri.parse(patientRecord.raysPDF![i]).path))}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.blue,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    if (patientRecord.mc.isNotEmpty ||
        patientRecord.program.isNotEmpty ||
        patientRecord.knownAllergies.isNotEmpty) {
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginLeft: 50, // Left margin
            marginRight: 50, // Right margin
            marginTop: 50, // Top margin
            marginBottom: 50, // Bottom margin
          ),
          build: (pw.Context context) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Medical Conditions"),
                  pw.SizedBox(height: 30),
                  if (patientRecord.mc.isNotEmpty)
                    pw.Text('Other Medical Conditions: ',
                        style: pw.TextStyle(color: PdfColors.grey)),
                  if (patientRecord.mc.isNotEmpty)
                    pw.Container(
                      width: PdfPageFormat.a4.width - 100,
                      child: pw.Paragraph(text: patientRecord.mc.join(', ')),
                    ),

                  if (patientRecord.mc.isNotEmpty) pw.SizedBox(height: 10),

                  //program section
                  if (patientRecord.program.isNotEmpty)
                    pw.Text('Program:',
                        style: pw.TextStyle(color: PdfColors.grey)),
                  if (patientRecord.program.isNotEmpty)
                    pw.Container(
                       width: PdfPageFormat.a4.width -100,
                       child: pw.Paragraph(text: patientRecord.program.join(', ')),
                    ),
                  if (patientRecord.program.isNotEmpty) pw.SizedBox(height: 10),


                  if (patientRecord.knownAllergies.isNotEmpty)
                    pw.Text('Known Allergies: ',
                          style: pw.TextStyle(color: PdfColors.grey)),
                  if (patientRecord.knownAllergies.isNotEmpty)
                    pw.Container(
                        width: PdfPageFormat.a4.width -100,
                        child: pw.Paragraph(
                            text: patientRecord.knownAllergies.join(', ')),
                      ),
                  if (patientRecord.knownAllergies.isNotEmpty)
                    pw.SizedBox(height: 10),


                ]);
          }));
    }

    if (patientRecord.medicalHistory.isNotEmpty ||
        patientRecord.medication.isNotEmpty) {
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginLeft: 50, // Left margin
            marginRight: 50, // Right margin
            marginTop: 50, // Top margin
            marginBottom: 50, // Bottom margin
          ),
          build: (pw.Context context) {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
          pw.Text("Medical History"),
          pw.SizedBox(height: 30),
          if (patientRecord.medicalHistory.isNotEmpty)
              pw.Text('Medical History: ',
                  style: pw.TextStyle(color: PdfColors.grey)),
          if (patientRecord.medicalHistory.isNotEmpty)
              pw.Container(
                width:  PdfPageFormat.a4.width -100,
                child:pw.Paragraph(text: patientRecord.medicalHistory.join(', ')),
              ),
          if (patientRecord.medicalHistory.isNotEmpty) pw.SizedBox(height: 10),


          if (patientRecord.medication.isNotEmpty)
              pw.Text('Medication:',
                  style: pw.TextStyle(color: PdfColors.grey)),
          if(patientRecord.medication.isNotEmpty)
            pw.Container(
             child: pw.Paragraph(text: patientRecord.medication.join(', ')),
            ),
          if (patientRecord.medication.isNotEmpty) pw.SizedBox(height: 10),
        ]);
      }));
    }

    if (rayImages.isNotEmpty) {
      for (final image in rayImages) {
        pdf.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        }));
      }
    }

    // Add pages for each follow-up session
    for (final followUp in followUpList) {
      if (followUpImages.containsKey(followUp.id)) {
        // Iterate over each image in the follow-up session
        for (final image in followUpImages[followUp.id]!) {
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4.copyWith(
                marginLeft: 50, // Left margin
                marginRight: 50, // Right margin
                marginTop: 50, // Top margin
                marginBottom: 50, // Bottom margin
              ),
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(children: [
                      pw.Text('Dr.:',
                          style: const pw.TextStyle(color: PdfColors.grey),),
                      pw.Text(followUp.doctorName!),
                    ]),
                    pw.SizedBox(height: 20),
                    // Display the follow-up date

                    pw.Row(children: [
                      pw.Text('Date:',
                          style: const pw.TextStyle(color: PdfColors.grey)),
                      pw.Text(followUp.date),
                    ]),
                    pw.SizedBox(height: 20),

                    pw.Text('Note:',
                        style: const pw.TextStyle(color: PdfColors.grey)),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      width: PdfPageFormat.a4.width -
                          100, // Adjust width based on page margins
                      child: pw.Paragraph(
                        text: '${followUp.text ?? ''}',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ),

                    pw.SizedBox(height: 20),
                    // Display the image
                    pw.Center(
                      child: pw.Image(image,
                          fit: pw.BoxFit
                              .contain), // Resize the image to fit the page
                    ),
                  ],
                );
              },
            ),
          );
        }
      } else {
        // If there are no images, add a page with just the follow-up date and notes
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginLeft: 50, // Left margin
              marginRight: 50, // Right margin
              marginTop: 50, // Top margin
              marginBottom: 50, // Bottom margin
            ),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Text('Dr.:', style: pw.TextStyle(color: PdfColors.grey)),
                    pw.Text(followUp.doctorName!),
                  ]),
                  pw.SizedBox(height: 20),
                  pw.Row(children: [
                    pw.Text('Date:',
                        style: pw.TextStyle(color: PdfColors.grey)),
                    pw.Text(followUp.date),
                  ]),
                  pw.SizedBox(height: 20),
                  pw.Text('Note:', style: pw.TextStyle(color: PdfColors.grey)),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    width: PdfPageFormat.a4.width -
                        100, // Adjust width based on page margins
                    child: pw.Paragraph(
                      text: '${followUp.text}',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                  ),
                  // pw.Row(children: [
                  //   pw.Text('Note:',
                  //       style: pw.TextStyle(color: PdfColors.grey)),
                  //   pw.Paragraph(text: followUp.text),
                  // ]),
                ],
              );
            },
          ),
        );
      }

      // Add PDF links if they exist
      if (followUp.docPath != null && followUp.docPath!.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Text('Date:',
                        style: pw.TextStyle(color: PdfColors.grey)),
                    pw.Text(followUp.date),
                  ]),
                  pw.SizedBox(height: 10),
                  pw.Text('PDFs:', style: pw.TextStyle(fontSize: 18)),
                  for (int i = 0; i < followUp.docPath!.length; i++)
                    pw.Padding(
                      padding: pw.EdgeInsets.all(10),
                      child: pw.UrlLink(
                        destination: followUp.docPath![i],
                        child: pw.Text(
                          'PDF: ${p.basename(Uri.decodeComponent(Uri.parse(followUp.docPath![i]).path))}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      }
    }


    // Save and share the PDF
    final Uint8List pdfBytes = await pdf.save();
    await Printing.sharePdf(
        bytes: pdfBytes, filename: '${patientRecord.patientName}.pdf');
  }

  Future<pw.MemoryImage> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    return pw.MemoryImage(bytes);
  }

  Future<pw.MemoryImage> _loadNetworkImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;
    return pw.MemoryImage(bytes);
  }

  bool isPdfGenerated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate PDF'),
      ),
      body: isPdfGenerated
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () async {
                  isPdfGenerated = true;
                  setState(() {});

                  await generatePdf().whenComplete(() {
                    isPdfGenerated = false;
                    setState(() {});
                  });
                },
                child: Text('Generate PDF'),
              ),
            ),
    );
  }
}
