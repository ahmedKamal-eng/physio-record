
// import 'dart:html';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as p;



class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Future<File> savePdf({required String name, required p.Document pdf}) async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

     final file=File('${root!.path}/$name');
     await file.writeAsBytes(await pdf.save());
     debugPrint('${root.path}/$name');
     return file;
  }

   Future<void> openPdf(File file)async{
    final path=file.path;
    OpenFile.open(path);
  }


  // final GlobalKey _globalKey = GlobalKey();
  //
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
  //     final pdf = .Document();
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
  //
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // create instance of ExportDelegate


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Convert to PDF')),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _captureAndConvertToPdf,
        child: Icon(Icons.picture_as_pdf),
        onPressed: () async {
        //        SimplePdfApi.openPdf(await SimplePdfApi.generateSimplePdf("hello",));
        },
      ),
    );
  }
}
