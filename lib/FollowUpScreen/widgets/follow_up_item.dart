import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'expandable_text.dart';

class FollowUpItemCard extends StatelessWidget {
  FollowUp followUp;
  bool internetConnection;
  String recordId;

  bool isShared;
  FollowUpItemCard({required this.followUp,required this.internetConnection,required this.isShared,required this.recordId});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 20,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if(isShared)
              Text('Dr.'+followUp.doctorName!,style: TextStyle(color: Colors.blue,fontSize: 26,fontWeight: FontWeight.bold),),

              SizedBox(height: 10,),

            Text(
              followUp.date,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: 20,
            ),
            if (followUp.text != "")
              ExpandableText(
                text: followUp.text,
              ),
            // Text(
            //   followUp.text,
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            const SizedBox(height: 15,),

            if (followUp.image!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(internetConnection: internetConnection, imageUrlList: followUp.image!,)));
                },
                child: Container(
                  height: 200,
                  child: PhotoViewGallery.builder(
                    backgroundDecoration:
                        BoxDecoration(color: Colors.transparent),
                    scrollPhysics: BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {

                      if (internetConnection) {
                        return PhotoViewGalleryPageOptions(imageProvider: NetworkImage(followUp.image![index]),
                          initialScale: PhotoViewComputedScale.contained,
                          heroAttributes: PhotoViewHeroAttributes(tag: followUp.image![index])
                        );
                        // return PhotoViewGalleryPageOptions(
                        //   imageProvider: NetworkImage(widget
                        //       .patientRecord.rayImages[index]),
                        //   initialScale:
                        //   PhotoViewComputedScale.contained,
                        //   heroAttributes: PhotoViewHeroAttributes(
                        //       tag: widget
                        //           .patientRecord.rayImages![index]),
                        // );
                      }

                      return PhotoViewGalleryPageOptions(
                        imageProvider: FileImage(File(followUp.image![index])),
                        initialScale: PhotoViewComputedScale.contained,
                        heroAttributes: PhotoViewHeroAttributes(
                            tag: followUp.image![index]),
                      );
                    },
                    itemCount: followUp.image!.length,
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 8,),
            SizedBox(
              height: 30,
              child: Stack(
                children: [
                  Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if(internetConnection)
                          {
                            return Image(image: NetworkImage(followUp.image![index]));
                          }
                        return Image.file(
                          // width:(screenWidth-60) / followUp.image!.length,
                          File(followUp.image![index]),
                        );
                      },
                      itemCount: followUp.image!.length,
                    ),
                  ),
                  Center(child: Text("${followUp.image!.length} Images")),
                ],
              ),
            ),


            if (followUp.docPath!.isNotEmpty)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {

                  if(internetConnection)
                    {
                      print("pdf Name::::"+followUp.docPath![index]);
                      Uri uri = Uri.parse(followUp.docPath![index]);
                      String decodedPath = Uri.decodeComponent(uri.path);

                      // Extract the base name using path package
                      String baseName = p.basename(decodedPath);
                      return  TextButton(
                          onPressed: () async{

                            await launchUrl(Uri.parse(followUp.docPath![index]));

                            // if (await canLaunchUrl(uri)) {
                            //   await launchUrl(
                            //     uri,
                            //     mode: LaunchMode
                            //         .externalApplication, // Ensures it opens in an external app
                            //   );
                            //   // OpenFile.open(
                            //   //     widget.patientRecord.raysPDF![index]);
                            // }

                            // OpenFile.open(followUp.docPath![index]);
                          },
                          child: Text(baseName));
                    }



                  return TextButton(
                      onPressed: ()async {
                        PatientRecord? currentRecord =await getPatientFromLocalById(recordId);
                        FollowUp currentFollowUp= await getFollowUpFromLocalById(currentRecord, followUp.id);
                        print(currentFollowUp.docPath![index]);
                        final result= await OpenFile.open(currentFollowUp.docPath![index]);
                        print(result.message);
                      },
                      child: Text(p.basename(followUp.docPath![index])));
                },
                itemCount: followUp.docPath!.length,
              ),
            // TextButton(
            //     onPressed: () {
            //       OpenFile.open(followUp.docPath![0]);
            //     },
            //     child: Text(p.basename(followUp.docPath![0])))
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
   List<String> imageUrlList;
   bool internetConnection;



  FullScreenImage({required this.imageUrlList,required this.internetConnection});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {

        if (internetConnection) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrlList[index]),
            initialScale:
            PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(
                tag: imageUrlList[index]),
          );
        }
        else {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(imageUrlList![index])),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrlList![index]),
          );
        }
        },
      itemCount: imageUrlList!.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(),
        ),
      ),
    ));
  }
}
