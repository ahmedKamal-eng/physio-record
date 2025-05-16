import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/AddDoctorToCenter/add_doctor_to_center_screen.dart';
import 'package:physio_record/CenterDoctorDetails/center_doctor_details.dart';
import 'package:physio_record/MedicalCenterDetails/widgets/center_records_list.dart';
import 'package:physio_record/MedicalCenterDetails/widgets/doctor_card.dart';
import 'package:physio_record/NoInterNetScreen/no_internet_screen.dart';
import 'package:physio_record/models/medical_center_model.dart';

import '../AddRecordScreen/add_record_Screen.dart';
import '../HomeScreen/widgets/record_card.dart';
import '../models/patient_record.dart';

class MedicalCenterDetailsScreen extends StatefulWidget {
  MedicalCenterModel centerModel;
  MedicalCenterDetailsScreen({required this.centerModel});

  @override
  State<MedicalCenterDetailsScreen> createState() =>
      _MedicalCenterDetailsScreenState();
}

class _MedicalCenterDetailsScreenState
    extends State<MedicalCenterDetailsScreen> {
  int _selectedIndex = 0;
  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool internetConnection = false;
  bool _isCheckingConnection = true;
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

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

 Stream<QuerySnapshot>? recordsStream;
  Stream<QuerySnapshot>? doctorsStream;


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results)
  async{
    setState(() {
      internetConnection= results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);

      _isCheckingConnection =false;

      if(internetConnection) {
        recordsStream = FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('records')
            .where('centerId', isEqualTo: widget.centerModel.centerId)
            .orderBy('date', descending: true)
            .snapshots();

        doctorsStream = FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('medical_centers')
            .doc(widget.centerModel.centerId)
            .collection('doctors')
            .snapshots();

      }

    });
  }

  void _retryConnection(){
    initConnectivity();
  }

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription=Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);



    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(internetConnection){
      return Scaffold(
        backgroundColor: Colors.blue[50],
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.blue[50],
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.centerModel.name,style: TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0,), // position of the shadow (x, y)
                      blurRadius: 1.0,          // how blurry the shadow is
                      color: Colors.white,       // shadow color
                    ),
                  ],
                ),),
                background: CachedNetworkImage(
                  imageUrl: widget.centerModel.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.teal[100]),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Info Card

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                  widget.centerModel.adminImage),
                              backgroundColor: Colors.grey[200],
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Center Admin',
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.centerModel.adminName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    widget.centerModel.adminSpecialization,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    FirebaseAuth.instance.currentUser!.uid ==
                        widget.centerModel.adminId
                        ? _selectedIndex==0?  Text(
                      'Doctors (${widget.centerModel.doctorCount - 1})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ):Text(
                      'records (${widget.centerModel.recordCount})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : Text(
                      'Your Records',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(thickness: 1,),
                  ],
                ),
              ),
            ),

            // StreamBuilder(stream: stream, builder: builder)
            // Doctors List
            FirebaseAuth.instance.currentUser!.uid == widget.centerModel.adminId
                ? _selectedIndex== 0? StreamBuilder<QuerySnapshot>(
                stream: doctorsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                        child: Text("something went wrong"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return DoctorCard(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c)=>CenterDoctorDetailsScreen(doctorName: snapshot.data!.docs[index]['name']!, specialization: snapshot.data!.docs[index]
                            ['medicalSpecialization']!, doctorId:  snapshot.data!.docs[index]['id']!, centerId: widget.centerModel.centerId, doctorImage: snapshot.data!.docs[index]['image']!)));
                          },
                          name: snapshot.data!.docs[index]['name']!,
                          imageUrl: snapshot.data!.docs[index]['image']!,
                          specialization: snapshot.data!.docs[index]
                          ['medicalSpecialization']!,
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  );
                }):SliverToBoxAdapter(
              child:CenterRecordsList(centerModel:widget.centerModel),
            )
                : StreamBuilder<QuerySnapshot>(
                stream: recordsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                        child: Text("something went wrong"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Padding(
                          padding: snapshot.data!.docs.length == index + 1
                              ? const EdgeInsets.only(
                              top: 3.0, right: 3, left: 3, bottom: 80)
                              : const EdgeInsets.all(3.0),
                          child: RecordCard(
                            fromCenter: true,
                              internetConnection: true,
                              patient: PatientRecord.fromFirestore(
                                  snapshot.data!.docs[index]),
                              patientIndex: index),
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  );
                })
          ],
        ),
        floatingActionButton:
        FirebaseAuth.instance.currentUser!.uid == widget.centerModel.adminId
            ?  _selectedIndex ==1?null: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            elevation: 10,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            showSearch(
                context: context,
                delegate: AddDoctorToCenterScreen(
                    centerModel: widget.centerModel,
                    doctorsIds: widget.centerModel.doctorsIds,
                    doctorsWantsToJoin: widget.centerModel.wantToJoin));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Doctors",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.health_and_safety,
                color: Colors.white,
              )
            ],
          ),
        )
            : ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            elevation: 10,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddRecordScreen(
                      fromCenter: true,
                      centerModel: widget.centerModel,
                    )));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Record",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.person_add,
                color: Colors.white,
              )
            ],
          ),
        ),

        bottomNavigationBar: FirebaseAuth.instance.currentUser!.uid == widget.centerModel.adminId ?BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,

          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Doctors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Records',
            ),
          ],
        ):null
      );

    }else{
      return NoInternetScreen(onRetry: (){
        _retryConnection();
      });
    }
  }
}
