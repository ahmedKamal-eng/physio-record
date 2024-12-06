import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pd;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:physio_record/PdfGenerator/followup_pdf.dart';
import 'package:physio_record/PdfGenerator/generate_pdf.dart';

import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import 'package:physio_record/AddFollowUpItem/add_follow_up_item.dart';
import 'package:physio_record/FollowUpScreen/widgets/follow_up_item.dart';
import 'package:physio_record/SearchForDoctorsScreen/search_for_doctors_screen.dart';

import 'package:physio_record/models/patient_record.dart';

import 'package:path/path.dart';

import '../ShareWithFriendScreen/share_with_friend_screen.dart';
import 'package:path/path.dart' as p;

class FollowUPScreen extends StatefulWidget {
  final PatientRecord patientRecord;
  final bool internetConnection;
  FollowUPScreen(
      {required this.patientRecord, required this.internetConnection});

  @override
  State<FollowUPScreen> createState() => _FollowUPScreenState();
}

class _FollowUPScreenState extends State<FollowUPScreen> {
  late ScrollController _scrollController;

  // checkConnectivity() async {
  //   final List<ConnectivityResult> connectivityResult =
  //       await (Connectivity().checkConnectivity());
  //   if (!connectivityResult.contains(ConnectivityResult.none)) {
  //     internetConnection = true;
  //     setState(() {});
  //   } else {
  //     internetConnection = false;
  //     setState(() {});
  //   }
  // }

  @override
  void initState() {
    // checkConnectivity();
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
            // actions: [
            //   ElevatedButton(
            //       onPressed: () async {
            //         // List<FollowUp> items=[];
            //         //    try {
            //         //       items = await SimplePdfApi
            //         //          .fetchFollowUp(widget.patientRecord.id);
            //         //    }catch(e)
            //         // {
            //         //   print("###########################${e.toString()}");
            //         // }
            //         //
            //         //
            //         //     SimplePdfApi().generateSimplePdf([FollowUp(date: "9 /2/2024", text: "dfkjsngjfiog", id: "dfgjs",image: ['https://firebasestorage.googleapis.com/v0/b/physio-records.appspot.com/o/images%2F5119b569-2dcf-4c00-96db-ce874157ccc0%2F1ef68064-55dc-6380-9a32-a3de5af2aed3%2FScreenshot_2024-05-28-08-39-19-88_6012fa4d4ddec268fc5c7112cbb265e7.png?alt=media&token=64664329-4608-463c-ab03-3446c5bf370b'])],widget.patientRecord.patientName).then((val){
            //         //       SimplePdfApi.openPdf(val);
            //         //
            //         //     });
            //         //
            //         //   // SimplePdfApi.sharePdf(pdfRecord.path);
            //
            //         FollowupPdf()
            //             .fetchFollowUpList(widget.patientRecord.id)
            //             .whenComplete(() {
            //           FollowupPdf()
            //               .generateSimplePdf(widget.patientRecord.patientName)
            //               .then((val) {
            //             FollowupPdf.openPdf(val);
            //           });
            //         });
            //       },
            //       child: Text("Yes")),
            //   ElevatedButton(
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //       child: Text("no")),
            // ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return BlocBuilder<AddFollowUpCubit, AddFollowUpState>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.patientRecord.patientName + " Follow Up"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  elevation: 10,
                  backgroundColor: Colors.teal),
              onPressed: () async {
                final List<ConnectivityResult> connectivityResult =
                    await (Connectivity().checkConnectivity());

                if (connectivityResult.contains(ConnectivityResult.none)) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                              "There is no internet connection please try again"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Ok")),
                          ],
                        );
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Center(child: Text("Share this record")),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShareWithFriendScreen(
                                                  doctorIds: [
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                  ],
                                                  recordModel:
                                                      widget.patientRecord,
                                                  isSharedBefore: false,
                                                )));
                                  },
                                  child: Text(
                                    "Share with friend doctors",
                                    style: TextStyle(color: Colors.white),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showSearch(
                                        context: context,
                                        delegate: UserSearchDelegate(
                                            patientRecord: widget.patientRecord,
                                            isSharedBefore: false,
                                            doctorsIds: []));
                                  },
                                  child: Text(
                                    "Search for doctors",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ],
                          ),
                        );
                      });
                }
              },
              child: Text(
                "Share Record",
                style: TextStyle(fontSize: 18, color: Colors.white),
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
                          "Other Medical Conditions:",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Text(
                              widget.patientRecord.mc[index],
                              style: TextStyle(fontSize: 18),
                            );
                          },
                          itemCount: widget.patientRecord.mc.length,
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Program: ${widget.patientRecord.program}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (widget.patientRecord.isShared!)
                          Text(
                              "doctors in this record: ${widget.patientRecord.doctorsId.length.toString()}"),

                        if (widget.patientRecord.rayImages!.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullScreenImage(
                                            internetConnection:
                                                widget.internetConnection,
                                            imageUrlList:
                                                widget.patientRecord.rayImages!,
                                          )));
                            },
                            child: Container(
                              height: 200,
                              child: PhotoViewGallery.builder(
                                backgroundDecoration:
                                    BoxDecoration(color: Colors.transparent),
                                scrollPhysics: BouncingScrollPhysics(),
                                builder: (BuildContext context, int index) {
                                  if (widget.internetConnection) {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider: NetworkImage(widget
                                          .patientRecord.rayImages[index]),
                                      initialScale:
                                          PhotoViewComputedScale.contained,
                                      heroAttributes: PhotoViewHeroAttributes(
                                          tag: widget
                                              .patientRecord.rayImages![index]),
                                    );
                                  } else {
                                    return PhotoViewGalleryPageOptions(
                                      imageProvider: FileImage(File(widget
                                          .patientRecord.rayImages![index])),
                                      initialScale:
                                          PhotoViewComputedScale.contained,
                                      heroAttributes: PhotoViewHeroAttributes(
                                          tag: widget
                                              .patientRecord.rayImages![index]),
                                    );
                                  }
                                },
                                itemCount:
                                    widget.patientRecord.rayImages!.length,
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
                        if (widget.patientRecord.rayImages!.isNotEmpty)
                          SizedBox(
                            height: 30,
                            child: Stack(
                              children: [
                                Center(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      if (widget.internetConnection) {
                                        return Image(
                                            image: NetworkImage(widget
                                                .patientRecord
                                                .rayImages[index]));
                                      } else {
                                        return Image.file(
                                          // width:(screenWidth-60) / followUp.image!.length,
                                          File(widget
                                              .patientRecord.rayImages![index]),
                                        );
                                      }
                                    },
                                    itemCount:
                                        widget.patientRecord.rayImages!.length,
                                  ),
                                ),
                                Center(
                                    child: Text(
                                        "${widget.patientRecord.rayImages!.length} Images")),
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

                        if (widget.patientRecord.raysPDF!.isNotEmpty)
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              Uri uri = Uri.parse(
                                  widget.patientRecord.raysPDF[index]);
                              String filePath = Uri.decodeComponent(uri.path);
                              String fileName = p.basename(filePath);
                              return TextButton(
                                onPressed: () {
                                  OpenFile.open(
                                      widget.patientRecord.raysPDF![index]);
                                },
                                child: Text(fileName),

                                // child: Text(p.basename(widget.patientRecord.raysPDF![index])
                              );
                            },
                            itemCount: widget.patientRecord.raysPDF!.length,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            widget.internetConnection
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('records')
                        .doc(widget.patientRecord.id)
                        .collection('followUp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("something went wrong");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FollowUpItemCard(
                              followUp: FollowUp.fromFirestore(
                                  snapshot.data!.docs[index]),
                              internetConnection: widget.internetConnection);
                        },
                        itemCount: snapshot.data!.docs.length,
                      );
                    })
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    // reverse: true,
                    itemBuilder: (context, index) {
                      return FollowUpItemCard(
                          internetConnection: widget.internetConnection,
                          followUp: widget.patientRecord.followUpList[index]);
                    },
                    itemCount: widget.patientRecord.followUpList.length,
                  ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
        floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          // child: Icon(Icons.share),

          child: Text(
            "Add To FollowUp",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            // _showShareDialog(context);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddFollowUPItemScreen(
                          patientRecord: widget.patientRecord,
                        )));
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

class FullScreenNetworkImage extends StatelessWidget {
  final List<String> imageUrlList;

  FullScreenNetworkImage(this.imageUrlList);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(imageUrlList[index]),
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
  }
}
