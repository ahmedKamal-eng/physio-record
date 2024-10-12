import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:physio_record/models/shared_follow_up_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../FollowUpScreen/widgets/expandable_text.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';


class SharedFollowUpItem extends StatelessWidget {
  SharedFollowUpModel followUp;
  SharedFollowUpItem({required this.followUp});

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
            Text("Dr." + followUp.doctorName,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(color: Colors.teal)),
            Text(
              followUp.date,
              style: Theme.of(context).textTheme.headlineLarge,
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
            const SizedBox(
              height: 15,
            ),

            if (followUp.images!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(followUp.images!)));
                },
                child: Container(
                  height: 200,
                  child: PhotoViewGallery.builder(
                    backgroundDecoration:
                        BoxDecoration(color: Colors.transparent),
                    scrollPhysics: BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider:NetworkImage(followUp.images![index]),
                        initialScale: PhotoViewComputedScale.contained,
                        heroAttributes: PhotoViewHeroAttributes(
                            tag: followUp.images![index]),
                      );
                    },
                    itemCount: followUp.images!.length,
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
            SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 30,
              child: Stack(
                children: [
                  Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Image.network(followUp.images![index]);
                      },
                      itemCount: followUp.images!.length,
                    ),
                  ),
                  Center(child: Text("${followUp.images!.length} Images")),
                ],
              ),
            ),

            // GridView.builder(
            //   physics: NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 2,
            //       mainAxisSpacing: 20,
            //       crossAxisSpacing: 10
            //   ), itemBuilder: (context,index){
            //   return Image.file(
            //     File(followUp.image![index]),
            //     width: 100.0,
            //     height: 100,
            //     fit: BoxFit.cover,
            //   );
            // },
            //   itemCount: followUp.image!.length,
            // ),

            // GestureDetector(
            //   onTap: (){
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => FullScreenImage(followUp.image![0]),
            //       ),
            //     );
            //   },
            //   child: Hero(tag: followUp.image!,
            //   child: Image.file(File(followUp.image![0]))),
            // ),

            if (followUp.docPaths!.isNotEmpty)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {

                  Uri uri = Uri.parse(followUp.docPaths![index]);
                  String decodedPath = Uri.decodeComponent(uri.path);

                  // Extract the base name using path package
                  String baseName = p.basename(decodedPath);
                  return TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse(followUp.docPaths![index]));
                        // OpenFile.open(followUp.docPaths![index]);
                      },
                      child: Text(baseName));
                },
                itemCount: followUp.docPaths!.length,
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
  final List<String> imageUrlList;

  FullScreenImage(this.imageUrlList);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider:NetworkImage(imageUrlList[index]),
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: imageUrlList![index]),
        );
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

    // Scaffold(
    // body: Container(
    //   constraints: BoxConstraints.expand(
    //     height: MediaQuery.of(context).size.height,
    //   ),
    //   child: PhotoView(
    //     imageProvider: FileImage(File(imageUrl)),
    //     minScale: PhotoViewComputedScale.contained * 0.8,
    //     maxScale: PhotoViewComputedScale.covered * 4,
    //     initialScale: PhotoViewComputedScale.contained,
    //     heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
    //   ),
    // ),
    // );
  }
}
