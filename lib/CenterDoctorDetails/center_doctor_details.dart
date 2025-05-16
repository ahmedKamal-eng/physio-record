import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/CenterDoctorDetails/RecordSearch/record_search.dart';
import 'package:physio_record/SearchScreen/search_screen.dart';

import '../HomeScreen/widgets/record_card.dart';
import '../NoInterNetScreen/no_internet_screen.dart';
import '../models/patient_record.dart';

class CenterDoctorDetailsScreen extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final String doctorId;
  final String doctorImage;
  final String centerId;

  CenterDoctorDetailsScreen({
    required this.doctorName,
    required this.specialization,
    required this.doctorId,
    required this.centerId,
    required this.doctorImage,
  });

  @override
  State<CenterDoctorDetailsScreen> createState() =>
      _CenterDoctorDetailsScreenState();
}

class _CenterDoctorDetailsScreenState extends State<CenterDoctorDetailsScreen> {

  bool isFiltered=false;
  DateTime? dateTimeFilter;
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

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  Stream<QuerySnapshot>? recordsStream;

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results)
  async{
    setState(() {
      internetConnection= results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);

      _isCheckingConnection =false;
      if(internetConnection) {
        recordsStream = FirebaseFirestore.instance
            .collection("users")
            .doc(widget.doctorId)
            .collection('records')
            .where('centerId', isEqualTo: widget.centerId)
            .orderBy('date', descending: true)
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
                title: Text(widget.doctorName, style: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0,), // position of the shadow (x, y)
                      blurRadius: 1.0,          // how blurry the shadow is
                      color: Colors.white,       // shadow color
                    ),
                  ],
                ),),
                background: CachedNetworkImage(
                  imageUrl: widget.doctorImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.teal[100]),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    height: 70,
                    color: Colors.blue[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: ()async{
                          dateTimeFilter =
                          await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2100));
                          if (dateTimeFilter != null) {
                            // Get the start and end of the day
                            final startOfDay =
                            Timestamp.fromDate(
                              DateTime(
                                  dateTimeFilter!.year,
                                  dateTimeFilter!.month,
                                  dateTimeFilter!.day),
                            );
                            final endOfDay =
                            Timestamp.fromDate(
                              DateTime(
                                  dateTimeFilter!.year,
                                  dateTimeFilter!.month,
                                  dateTimeFilter!.day + 1),
                            );

                            // Firestore query for records in the specific day
                            recordsStream = FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.doctorId)
                                .collection('records')
                                .where('date',
                                isGreaterThanOrEqualTo:
                                startOfDay)
                                .where('date',
                                isLessThan: endOfDay)
                                .snapshots();
                            // Navigator.pop(context);
                            setState(() {
                              isFiltered=true;
                            });

                          }
                        }, icon:Icon(Icons.tune,size: 36,)),
                        IconButton(onPressed: (){
                          showSearch(context: context, delegate: DoctorRecordsSearch(centerId: widget.centerId, doctorId:widget.doctorId));
                        }, icon:Icon(Icons.search,size: 36,)),
                      ],
                    ),

                  ),
                  if(isFiltered)
                    TextButton(onPressed: (){
                      setState(() {
                        isFiltered=false;
                      });

                      recordsStream = FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.doctorId)
                          .collection('records')
                          .where('centerId', isEqualTo: widget.centerId)
                          .orderBy('date', descending: true)
                          .snapshots();

                    }, child: Text("Clear Filter\n${DateFormat('d-M-y').format(dateTimeFilter!)}")),

                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 30,),
            ),

            StreamBuilder<QuerySnapshot>(
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
                               isAdmin: true,
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
      );

    }else{
      return NoInternetScreen(onRetry: (){
        _retryConnection();
      });
    }
  }
}
