import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'package:physio_record/AddFollowUpItem/AddFollowUpCubit/add_follow_up_states.dart';
import 'package:physio_record/AddFollowUpItem/add_follow_up_item.dart';
import 'package:physio_record/FollowUpScreen/widgets/follow_up_item.dart';
import 'package:physio_record/FollowUpScreen/widgets/user_card.dart';
import 'package:physio_record/HiveService/user_functions.dart';
import 'package:physio_record/NoInterNetScreen/no_internet_screen.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import '../global_vals.dart';

class FollowUPScreen extends StatefulWidget {
   PatientRecord patientRecord;
  final bool internetConnection;
  final bool fromCenter;
   bool isAdmin;
  FollowUPScreen(
      {required this.patientRecord, required this.internetConnection,required this.fromCenter,this.isAdmin=false});

  @override
  State<FollowUPScreen> createState() => _FollowUPScreenState();
}

class _FollowUPScreenState extends State<FollowUPScreen> {


  bool internetConnection = false;
  bool _isCheckingConnection = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<void> initConnectivity() async {
    setState(() {
      _isCheckingConnection = true;
    });

    List<ConnectivityResult> results;

    try {
      results = await Connectivity().checkConnectivity();
    } catch (e) {
      print("________:Can not Check Connectivity${e.toString()}");
      results = [ConnectivityResult.none];
    }

    return _updateConnectionStatus(results);
  }
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results)

  async{
    final patientBox = await Hive.openBox<PatientRecord>('patient_records');

    setState(()  {
      internetConnection= results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);

      if(internetConnection) {
        _storeFollowUpOnlyInFireStoreInLocal();
      }else{
        final currentPatient = patientBox.values.firstWhere((p) => p.id == widget.patientRecord.id);
        widget.patientRecord=currentPatient;

      }
      _isCheckingConnection =false;

    });
  }

  @override
  void initState() {


    initConnectivity();
    _connectivitySubscription=Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  void _retryConnection(){
    initConnectivity();
  }


  Future<void> _storeFollowUpOnlyInFireStoreInLocal() async {
    try {
      var recordBox = await Hive.box<PatientRecord>('patient_records');

      // Use `orElse` to handle the case where no matching record is found
      PatientRecord? currentRecord = recordBox.values.firstWhere(
            (item) => item.id == widget.patientRecord.id,
      );

      // Check if a matching record was found
      if (currentRecord == null) {
        print('No matching record found. Exiting method.');
        return;
      }

      // Fetch follow-up data from Firestore
      final firestore = FirebaseFirestore.instance;
      final followUpSnapshot = await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('records')
          .doc(widget.patientRecord.id)
          .collection('followUp')
          .get();

      // Check if Firestore has more follow-ups than local Hive
      if (followUpSnapshot.docs.length > currentRecord.followUpList.length) {
        List<String> followUpIdsInLocal = currentRecord.followUpList
            .map((followUp) => followUp.id)
            .toList();

        for (var followUpDoc in followUpSnapshot.docs) {
          FollowUp followUp = FollowUp.fromFirestore(followUpDoc);

          // Check if the follow-up is not already in local Hive
          if (!followUpIdsInLocal.contains(followUp.id)) {
            // Fetch and download files if needed
            if (followUp.image!.isNotEmpty) {
              followUp.image = await fetchAndDownloadFiles(
                'images',
                followUpDoc.data()['RecordId'],
                followUpDoc.data()['id'],
              );
            }
            if (followUp.docPath!.isNotEmpty) {
              followUp.docPath = await fetchAndDownloadFiles(
                'docs',
                followUpDoc.data()['RecordId'],
                followUpDoc.data()['id'],
              );
            }

            // Add the follow-up to local Hive
            currentRecord.followUpList.add(followUp);
            await currentRecord.save();
          }
        }
      }
    } catch (e) {
      print('Error in _storeFollowUpOnlyInFireStoreInLocal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
    Theme
        .of(context)
        .brightness == Brightness.dark ? true : false;

    if (!internetConnection && widget.fromCenter) {
      return NoInternetScreen(onRetry: () {
        _retryConnection();
      });
    }
    else {
      return BlocBuilder<AddFollowUpCubit, AddFollowUpState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.blue[50],
              appBar: AppBar(
                backgroundColor: Colors.blue,
                leading: IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Icon(Icons.arrow_back_ios, color: Colors.white,)),
                title: Text(widget.patientRecord.patientName + " Follow Up",
                  style: TextStyle(color: Colors.white),),

              ),
              body: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          const SizedBox(
                            height: 10,
                          ),
                          if (widget.patientRecord.rayImages!.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FullScreenImage(
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
                                    if (internetConnection) {
                                      return PhotoViewGalleryPageOptions(
                                        imageProvider: NetworkImage(widget
                                            .patientRecord.rayImages[index]),
                                        initialScale:
                                        PhotoViewComputedScale.contained,
                                        heroAttributes: PhotoViewHeroAttributes(
                                            tag: widget
                                                .patientRecord
                                                .rayImages![index]),
                                      );
                                    } else {
                                      return PhotoViewGalleryPageOptions(
                                        imageProvider: FileImage(File(widget
                                            .patientRecord.rayImages![index])),
                                        initialScale:
                                        PhotoViewComputedScale.contained,
                                        heroAttributes: PhotoViewHeroAttributes(
                                            tag: widget
                                                .patientRecord
                                                .rayImages![index]),
                                      );
                                    }
                                  },
                                  itemCount:
                                  widget.patientRecord.rayImages!.length,
                                  loadingBuilder: (context, event) =>
                                      Center(
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
                                        if (internetConnection) {
                                          return Image(
                                              image: NetworkImage(widget
                                                  .patientRecord
                                                  .rayImages[index]));
                                        } else {
                                          return Image.file(
                                            // width:(screenWidth-60) / followUp.image!.length,
                                            File(widget
                                                .patientRecord
                                                .rayImages![index]),
                                          );
                                        }
                                      },
                                      itemCount:
                                      widget.patientRecord.rayImages!.length,
                                    ),
                                  ),
                                  Center(
                                      child: Text(
                                          "${widget.patientRecord.rayImages!
                                              .length} Images")),
                                ],
                              ),
                            ),
                          if (widget.patientRecord.raysPDF!.isNotEmpty)
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (!internetConnection) {
                                  return TextButton(
                                    onPressed: () async {
                                      PatientRecord? currentRecord =
                                      await getPatientFromLocalById(
                                          widget.patientRecord.id);

                                      OpenFile.open(
                                          currentRecord!.raysPDF[index]);
                                    },
                                    // child: Text(fileName),

                                    child: Text(p.basename(
                                        widget.patientRecord.raysPDF![index])),
                                    // OpenFile.open(widget.patientRecord.raysPDF[index]);
                                  );
                                }

                                Uri uri = Uri.parse(
                                    widget.patientRecord.raysPDF[index]);
                                String filePath = Uri.decodeComponent(uri.path);
                                String fileName = p.basename(filePath);
                                return TextButton(
                                  onPressed: () async {
                                    await launchUrl(Uri.parse(
                                        widget.patientRecord.raysPDF![index]));

                                  },
                                  child: Text(fileName),

                                  // child: Text(p.basename(widget.patientRecord.raysPDF![index])
                                );
                              },
                              itemCount: widget.patientRecord.raysPDF!.length,
                            ),
                          SizedBox(height: 10,),

                          _buildEditableTile(widget.patientRecord, "Name",
                              widget.patientRecord.patientName, Icons.person),
                          _buildEditableTile(widget.patientRecord, "Age", widget
                              .patientRecord.age.toString(), Icons.cake),
                          _buildEditableTile(
                              widget.patientRecord, "Gender", widget
                              .patientRecord.gender.toString(), Icons.male),
                          _buildEditableTile(widget.patientRecord, "Diagnosis",
                              widget.patientRecord.diagnosis,
                              Icons.local_hospital),

                          if(widget.patientRecord.phoneNumer != 0)
                            _buildEditableTile(
                                widget.patientRecord, "Phone Number", widget
                                .patientRecord.phoneNumer.toString(),
                                Icons.phone),
                          if(widget.patientRecord.conditionAssessment
                              ?.isNotEmpty ?? false)
                            _buildEditableTile(
                                widget.patientRecord, "Condition Assessment",
                                widget.patientRecord.conditionAssessment ?? "",
                                Icons.assessment),
                          if(widget.patientRecord.reasonForVisit?.isNotEmpty ??
                              false)
                            _buildEditableTile(
                                widget.patientRecord, "Reason for Visit", widget
                                .patientRecord.reasonForVisit ?? "",
                                Icons.event_note),

                          if(widget.patientRecord.job?.isNotEmpty ?? false)
                            _buildEditableTile(
                                widget.patientRecord, "Job", widget
                                .patientRecord.job ?? "", Icons.work),

                          if(widget.patientRecord.mc.isNotEmpty)
                            _buildEditableListTile(widget.patientRecord,
                                "Other Medical Conditions", widget.patientRecord
                                    .mc, Icons.sick),
                          if(widget.patientRecord.program.isNotEmpty)
                            _buildEditableListTile(
                                widget.patientRecord, "Programs", widget
                                .patientRecord.program, Icons.list),
                          if(widget.patientRecord.knownAllergies.isNotEmpty)
                            _buildEditableListTile(
                                widget.patientRecord, "Known Allergies", widget
                                .patientRecord.knownAllergies, Icons.warning),

                          if(widget.patientRecord.medicalHistory.isNotEmpty)
                            _buildEditableListTile(
                                widget.patientRecord, "Medical History", widget
                                .patientRecord.medicalHistory, Icons.history),
                          if(widget.patientRecord.medication.isNotEmpty)
                            _buildEditableListTile(
                                widget.patientRecord, "Medications", widget
                                .patientRecord.medication, Icons.medication),


                          if (widget.patientRecord.doctorsId !=null && internetConnection)
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0,top: 18),
                              child: Text("doctors",style: TextStyle(fontSize: 22),),
                            ),

                          const SizedBox(
                            height: 20,
                          ),

                          (widget.patientRecord.isShared ?? false) &&
                              internetConnection?
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return UserCard(userId: widget.patientRecord
                                    .doctorsId[index]);
                              },
                              itemCount: widget.patientRecord.doctorsId.length,

                            ):
                            internetConnection?
                            UserCard(userId: getCurrentUser()!.id):Container()

                        ],
                      ),
                    ),
                  ),
                  internetConnection
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

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return FollowUpItemCard(
                                recordId: widget.patientRecord.id,
                                isShared: widget.patientRecord.isShared ??
                                    false,
                                followUp: FollowUp.fromFirestore(
                                    snapshot.data!.docs[index]),
                                internetConnection: internetConnection);
                          },
                          itemCount: snapshot.data!.docs.length,
                        );
                      })
                      : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    // reverse: true,
                    itemBuilder: (context, index) {
                      return FollowUpItemCard(
                          recordId: widget.patientRecord.id,
                          isShared: widget.patientRecord.isShared ?? false,
                          internetConnection: internetConnection,
                          followUp: widget.patientRecord.followUpList[index]);
                    },
                    itemCount: widget.patientRecord.followUpList.length,
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
              floatingActionButton:widget.isAdmin ?null: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                // child: Icon(Icons.share),

                child: Text(
                  "Add Note +",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  // _showShareDialog(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddFollowUPItemScreen(
                                patientRecord: widget.patientRecord,
                              )));
                },
              ),
            );
          });
    }
  }
}


// **Reusable Editable List Tile for Multiple Items**
Widget _buildEditableListTile(PatientRecord patientRecord,String title, List<String> items, IconData icon) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Text("• $item", style: const TextStyle(fontSize: 16))).toList(),
      ),
    ),
  );
}



// **Reusable Editable ListTile**
Widget _buildEditableTile(PatientRecord patientRecord,String title, String value, IconData icon) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),

    ),
  );
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
