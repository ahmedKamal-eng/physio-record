import 'dart:io';

import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class SimplePdfApi {
  static Future<File> savePdf(
      {required String name, required Document pdf}) async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final file = File('${root!.path}/$name');
    await file.writeAsBytes(await pdf.save());
    // debugPrint('${root.path}/$name');
    return file;
  }

  static Future<void> openPdf(File file) async {
    final path = file.path;
    OpenFile.open(path);
  }

  static Future<File> generateSimplePdf(
    PatientRecord patientRecord) async {
    final pdf = Document();

    // Download the image data from the network
    final response = await http.get(Uri.parse('https://t4.ftcdn.net/jpg/05/70/46/49/360_F_570464993_zCaOcgprClFB2kO9U9qudg5N8pJ4YAvY.jpg'));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }



    final imageData = response.bodyBytes;

    final image = MemoryImage(imageData);
    pdf.addPage(
      MultiPage(
        build: (_) => [
          Image(image),


          // ListView.builder(
          //     itemCount: 20,
          //     itemBuilder: (context, index) {
          //       return Text('Item $index');
          //     }
          // )
        ],
      ),
    );

    return savePdf(name: patientRecord.patientName, pdf: pdf);
  }

  static Future<void> sharePdf(String path) async {
    await Share.shareFiles([path]);
  }
}
