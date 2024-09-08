import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

import '../models/patient_record.dart';
import 'package:http/http.dart' as http;

class FollowupPdf {
  static List<FollowUp> followUpList = [];
  // List<MemoryImage> imagesData = [];

  Future<void> fetchFollowUpList(String recordId) async {
    followUpList = [];
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('records')
        .doc(recordId)
        .collection('followUp')
        .get()
        .then((result) {
      for (var item in result.docs) {
        FollowUp followUp = FollowUp.fromFirestore(item);

        followUpList.add(followUp);
      }
      // print("@@@@@@@@@@@@@@@@@@@@@@@@@"+followUpItems[0].image![0]);
    });
    //     .whenComplete(() {
    //   return followUpItems;
    // });
    //
  }

  static List<Widget> pdfUi = [];

  Future<MemoryImage> convertImageUrlToImageData(String url) async {
    //Download the image data from the network
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }

    var imageData = response.bodyBytes;
    return MemoryImage(imageData);
  }

  Future<void> generatePdfUi() async {
    // List<List<MemoryImage>> images = [];
    //
    // try {
    //   for (int i = 0; i < followUpList.length; i++) {
    //     images.add([]);
    //     if (followUpList[i].image!.isNotEmpty) {
    //       for (var image in followUpList[i].image!) {
    //         var response = await http.get(Uri.parse(image));
    //         var imagesData = response.bodyBytes;
    //         images[i].add(MemoryImage(imagesData));
    //       }
    //     }
    //   }
    // } catch (e) {
    //   print("555555555555555555555555555" + e.toString());
    // }

    for (int i = 0; i < followUpList.length; i++) {
      pdfUi.add(Text(followUpList[i].date));
      pdfUi.add(Text(followUpList[i].text));
      if (followUpList[i].image!.isNotEmpty) {
        for (var image in followUpList[i].image!) {
          pdfUi.add(Image(await convertImageUrlToImageData(image)));
        }
      }
    }

    //
    // try {
    //  pdfUi = [
    //     ...List.generate(
    //       followUpList.length,
    //       (index) {
    //         return Column(children: [
    //           Text(followUpList[index].date),
    //           Text(followUpList[index].text),
    //           if (images[index]!.isNotEmpty)
    //             ...List.generate(images[index].length, (i) {
    //               // return Text("heofhdge");
    //               return Image(
    //                 images[index][i],
    //                 height: 300,
    //               );
    //             }),
    //         ]);
    //       },
    //     ),
    //   ];
    // } catch (e) {
    //   print("111111111111111111111111111111111111" + e.toString());
    // }
  }

  List<MemoryImage> generateImagesData(FollowUp followUp) {
    List<MemoryImage> imagesData = [];
    try {
      if (followUp.image!.isNotEmpty) {
        for (var image in followUp.image!) {
          // Download the image data from the network
          var response;
          http.get(Uri.parse(image)).then((v) {
            response = v;
          }).whenComplete(() {
            if (response.statusCode != 200) {
              throw Exception(
                  'Failed to download image(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((');
            }
            var imageData = response.bodyBytes;
            imagesData.add(MemoryImage(imageData));
          });
        }
      }
    } catch (e) {
      print(e.toString() +
          "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    }

    print("6666666666666666666666666666" + imagesData[0].toString());
    return imagesData;
  }

  Future<File> generateSimplePdf( String fileName) async {
    var pdf = Document();

    //Download the image data from the network
    // final response = await http.get(Uri.parse(
    //     'https://firebasestorage.googleapis.com/v0/b/physio-records.appspot.com/o/images%2F5119b569-2dcf-4c00-96db-ce874157ccc0%2F1ef68064-55dc-6380-9a32-a3de5af2aed3%2FScreenshot_2024-05-28-08-39-19-88_6012fa4d4ddec268fc5c7112cbb265e7.png?alt=media&token=64664329-4608-463c-ab03-3446c5bf370b'));
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to download image');
    // }
    //
    // final imageData = response.bodyBytes;
    //
    // final image = MemoryImage(imageData);

    // generatePdfUi(followItems);

    List<MemoryImage> images = [];

    try {
      if (followUpList[0].image!.isNotEmpty) {
        for (var image in followUpList[0].image!) {
          images.add(await convertImageUrlToImageData(image));
        }
      }
    } catch (e) {
      print(e.toString());
    }

    pdf.addPage(
      MultiPage(
        build: (_) {
          return [
            // Text(followUpList[0].date),
            // Text(followUpList[0].text),

            ...List.generate(images.length, (index) {
              return Image(height: 300, images[index]);
            }),
            // Image(height: 300, image),

            //
            // Column(children:[
            //   Text("idkfbghjpodg"),
            //   Image(image),
            // ]),
            //
            // ...List.generate(100, (index) {
            //   return Text(
            //       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.");
            // })

            // SizedBox(height: )

            // ListView.builder(
            //     itemCount: 20,
            //     itemBuilder: (context, index) {
            //       return Text('Item $index');
            //     }
            // )
          ];
        },
      ),
    );

    return savePdf(name: fileName, pdf: pdf);

  }

  Widget followUpItem(FollowUp followUp, List<MemoryImage> images) {
    //   List<MemoryImage> imagesData = [];
    //   try {
    //     imagesData = generateImagesData(followUp);
    //   } catch (e) {
    //     print(e.toString() + "((((((((((((((((((((((((((((");
    //   }
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(followUp.date),
          if (followUp.text.isNotEmpty) Text(followUp.text),
          if (followUp.image!.isNotEmpty)
            ...List.generate(images.length, (index) {
              return Image(height: 600, images[index]);
            }),
        ]));
  }

  Future<File> savePdf({required String name, required Document pdf}) async {
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
}
