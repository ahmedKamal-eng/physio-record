import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class SimplePdfApi {
  static Future<List<FollowUp>> fetchFollowUp(String recordId) async {
    List<FollowUp> followUpItems = [];
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

        followUpItems.add(followUp);
      }
      // print("@@@@@@@@@@@@@@@@@@@@@@@@@"+followUpItems[0].image![0]);
      return followUpItems;
    });
    //     .whenComplete(() {
    //   return followUpItems;
    // });
    //
    return followUpItems;
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

  Future<File> generateSimplePdf (
      List<FollowUp> followUpList, String fileName) async {
    final pdf = Document();

    // Download the image data from the network
    // final response = await http.get(Uri.parse(
    //     'https://t4.ftcdn.net/jpg/05/70/46/49/360_F_570464993_zCaOcgprClFB2kO9U9qudg5N8pJ4YAvY.jpg'));
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to download image');
    // }
    //
    // final imageData = response.bodyBytes;
    //
    // final image = MemoryImage(imageData);

    pdf.addPage(
      MultiPage(
        build: (_) {
          return [
          ...List.generate(followUpList.length, (index){
              return  followUpItem(followUpList[index]);

          }),
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
        ];},
      ),
    );

    return savePdf(name: fileName, pdf: pdf);
  }






Widget followUpItem(FollowUp followUp)  {
  List<MemoryImage> imagesData = [];

    // Download the image data from the network
    // final response = await http.get(Uri.parse(
    //     'https://t4.ftcdn.net/jpg/05/70/46/49/360_F_570464993_zCaOcgprClFB2kO9U9qudg5N8pJ4YAvY.jpg'));
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to download image');
    // }
    //
    // final imageData = response.bodyBytes;
    //
    // final image = MemoryImage(imageData);


    try {

      if (followUp.image!.isNotEmpty) {
        for (var image in followUp.image!) {
          // Download the image data from the network
          var response;
          http.get(Uri.parse(image)).then((v) {
            response = v;
          }).whenComplete((){
            if (response.statusCode != 200) {
              throw Exception('Failed to download image(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((');
            }
            final imageData = response.bodyBytes;
            imagesData.add(MemoryImage(imageData));
          });

        }
      }
    }catch(e){
      print(e.toString()+"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    }

    return Padding(padding: EdgeInsets.symmetric(horizontal: 20,vertical: 50),child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(followUp.date),
      if (followUp.text.isNotEmpty) Text(followUp.text),
      if (followUp.image!.isNotEmpty)
        ...List.generate(imagesData.length, (index) {
          return Image(imagesData[index]);
        }),
    ]));
  }

  static Future<void> sharePdf(String path) async {
    await Share.shareXFiles([XFile("$path.pdf")]);
  }
}
