import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/add_record_Screen.dart';
import 'package:physio_record/Cubits/DeleteSharedRecordFromLocal/delete_shared_record_cubit.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/FetchRecordFromFireStore/fetch_record_from_fire_store_screen.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_state.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';

import 'package:physio_record/SearchScreen/search_screen.dart';
import 'package:physio_record/Splash/splash_screen.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';
import 'package:physio_record/models/user_model.dart';
import 'package:physio_record/widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isEndTimePassed = false;
   bool internetConnection=true;
   bool isFiltered=false;
  // List<ConnectivityResult>? connectivityResult;
  //
  // initialConnectivity() async {
  //   connectivityResult = await (Connectivity().checkConnectivity());
  // }

  // late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivityAndUpload();
    });
    // _scrollController = ScrollController();
    // // Optionally, you can jump to the start position
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });


  }

  _checkConnectivityAndUpload() async {

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      internetConnection=true;

      await BlocProvider.of<GetUserDataCubit>(context).getUserData();

      UserModel currentUser =
          BlocProvider.of<GetUserDataCubit>(context).userModel!;

      isEndTimePassed =
          hasTimestampPassed(convertStringToTimestamp(currentUser.endTime));
      setState(() {});

      try {
        await BlocProvider.of<FetchRecordCubit>(context)
            .uploadLocalRecordsToFirestore();
      }catch(e)
    {
      print("+++++++++Upload local error::"+e.toString());
    }
      await BlocProvider.of<FetchRecordCubit>(context)
          .updateRecordInFirestore();


    } else{
      internetConnection=false;
      setState(() {
      });
    }

    await BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _scrollController.dispose();
    super.dispose();
  }

   Stream<QuerySnapshot> recordStream =  FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .orderBy('date', descending: true)
      .snapshots();



   Stream<QuerySnapshot> sharedRecordStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .where('isShared', isEqualTo: true)
      .orderBy('date', descending: true)
      .snapshots();

   Stream<QuerySnapshot> notSharedRecordStream = FirebaseFirestore
      .instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('records')
      .where('isShared', isEqualTo: false)
      .orderBy('date', descending: true)
      .snapshots();




  @override
  Widget build(BuildContext context) {



    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return isEndTimePassed
        ? Scaffold(
            body: Center(
              child: Text('Your subscription has expired.'),
            ),
          )
        : Scaffold(
            drawer: MyDrawer(),
            appBar: AppBar(

              title: Text(
                "Physio Record",
                style: TextStyle(color: Colors.teal),
              ),

              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Record Filter"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          DateTime? dateTime =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2024),
                                                  lastDate: DateTime(2100));
                                          if (dateTime != null) {
                                            if(internetConnection){
                                              // Get the start and end of the day
                                              final startOfDay = Timestamp.fromDate(
                                                DateTime(dateTime.year, dateTime.month, dateTime.day),
                                              );
                                              final endOfDay = Timestamp.fromDate(
                                                DateTime(dateTime.year, dateTime.month, dateTime.day + 1),
                                              );

                                              // Firestore query for records in the specific day
                                              recordStream  = FirebaseFirestore.instance
                                              .collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
                                                  .collection('records')
                                                  .where('date', isGreaterThanOrEqualTo: startOfDay)
                                                  .where('date', isLessThan: endOfDay)
                                              .snapshots();
                                              Navigator.pop(context);
                                              setState(() {

                                                isFiltered=true;

                                              });

                                            }else{
                                            BlocProvider.of<FetchRecordCubit>(
                                                    context)
                                                .filterPatientsByDate(dateTime);
                                            Navigator.pop(context);
                                          }
                                          }
                                        },
                                        child:
                                            const Text("choose specific day")),
                                    TextButton(onPressed: (){
                                      if(internetConnection)
                                        {
                                              recordStream=sharedRecordStream;
                                              setState(() {
                                                isFiltered=true;
                                              });
                                              if(Navigator.canPop(context))
                                              Navigator.pop(context);
                                        }
                                      else
                                      {
                                        BlocProvider.of<FetchRecordCubit>(
                                            context)
                                            .filterSharedPatient();
                                        Navigator.pop(context);

                                      }
                                    }, child: Text('Shared Records')),
                                    TextButton(onPressed: (){
                                      if(internetConnection)
                                      {
                                             recordStream=notSharedRecordStream;
                                             setState(() {
                                               isFiltered=true;
                                             });
                                             if(Navigator.canPop(context))
                                               Navigator.pop(context);
                                      }
                                      else
                                      {
                                        BlocProvider.of<FetchRecordCubit>(
                                            context)
                                            .filterNotSharedPatient();
                                        Navigator.pop(context);

                                      }
                                    }, child: Text('Not Shared Records'))
                                  ],
                                ),
                              );
                            });
                      },
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 35,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: IconButton(
                      onPressed: () {
                        showSearch(context: context, delegate: RecordSearch());
                      },
                      icon: const Icon(
                        Icons.search,
                        size: 35,
                      )),
                ),
              ],
            ),

            body: internetConnection
                ? Column(
                  children: [
                    if (isFiltered)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .1,
                        child: TextButton(
                            onPressed: () async {
                              recordStream = await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('records')
                                  .orderBy('date', descending: true)
                                  .snapshots();

                              isFiltered=false;
                              setState(() {
                              });
                            },
                            child: Text("Clear filter")),
                      ),
                    StreamBuilder<QuerySnapshot>(
                        stream: recordStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("something went wrong");
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data = snapshot.data!.docs[index]
                                    .data() as Map<String, dynamic>;
                            
                                print(data['rayImages']);
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RecordCard(
                                    internetConnection: true,
                                      patient: PatientRecord.fromFirestore(
                                          snapshot.data!.docs[index]),
                                      patientIndex: index),
                                );
                              },
                              itemCount: snapshot.data!.docs.length,
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 70,)
                  ],
                )
                : BlocBuilder<FetchRecordCubit, FetchRecordState>(
                    builder: (BuildContext context, FetchRecordState state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (BlocProvider.of<FetchRecordCubit>(context)
                              .isFiltered)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .1,
                              child: TextButton(
                                  onPressed: () {
                                    BlocProvider.of<FetchRecordCubit>(context)
                                        .clearFilter();
                                  },
                                  child: Text("Clear filter")),
                            ),
                          if (BlocProvider.of<FetchRecordCubit>(context)
                              .isFiltered)
                            SizedBox(
                              height: BlocProvider.of<FetchRecordCubit>(context)
                                          .filteredPatientRecords!
                                          .length <=
                                      3
                                  ? MediaQuery.of(context).size.height * .6
                                  : MediaQuery.of(context).size.height * .6,
                              child: ListView.builder(
                                // controller: _scrollController,
                                padding: EdgeInsets.zero,
                                // reverse: true,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: RecordCard(

                                          patient: BlocProvider.of<
                                                  FetchRecordCubit>(context)
                                              .filteredPatientRecords![index],
                                          patientIndex: index,
                                          internetConnection: false,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                itemCount:
                                    BlocProvider.of<FetchRecordCubit>(context)
                                        .filteredPatientRecords!
                                        .length,
                              ),
                            ),
                          if (!BlocProvider.of<FetchRecordCubit>(context)
                              .isFiltered)
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.all(10),
                                    child: RecordCard(
                                      internetConnection: false,
                                      patient:
                                          BlocProvider.of<FetchRecordCubit>(
                                                  context)
                                              .patientRecords![index],
                                      patientIndex: index,
                                    ),
                                  );
                                },
                                itemCount:
                                    BlocProvider.of<FetchRecordCubit>(context)
                                        .patientRecords!
                                        .length,
                              ),
                            )
                          // : Expanded(
                          //     child: PaginateFirestore(
                          //       shrinkWrap: true,
                          //       itemsPerPage: 3,
                          //       isLive: true,
                          //       initialLoader: const Center(
                          //         child: CircularProgressIndicator.adaptive(),
                          //       ),
                          //       onEmpty: Center(
                          //         child: Text("Empty data"),
                          //       ),
                          //       bottomLoader: const Center(
                          //         child: CircularProgressIndicator(),
                          //       ),
                          //       itemBuilder: (context, snapshot, index) {
                          //         PatientRecord patient =
                          //             PatientRecord.fromFirestore(snapshot[index]);
                          //         return Padding(
                          //           padding: const EdgeInsets.all(10.0),
                          //           child: RecordCard(
                          //               patient: patient, patientIndex: index),
                          //         );
                          //       },
                          //       query: FirebaseFirestore.instance
                          //           .collection('users')
                          //           .doc(FirebaseAuth.instance.currentUser!.uid)
                          //           .collection('records'),
                          //       itemBuilderType: PaginateBuilderType.listView,
                          //     ),
                          //   ),
                          ,
                          SizedBox(
                            height: 70,
                          )
                        ],
                      );
                    },
                  ),
            // body:ListView.builder(
            //   physics: BouncingScrollPhysics(),
            //     itemBuilder: (context,index){
            //   return Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: RecordCard(patient: patients[index]),
            //   );
            // },itemCount: 10,),

            floatingActionButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                elevation: 10,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () async {
                var recordBox =
                    await Hive.box<PatientRecord>('patient_records');
                int x = BlocProvider.of<FetchRecordCubit>(context)
                    .patientRecords!
                    .length;
                print(x);
                print(recordBox.values.length.toString());

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddRecordScreen()));
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
                    Icons.person_add_alt_1_outlined,
                    color: Colors.white,
                  )
                ],
              ),
            ),

            // FloatingActionButton(
            //
            //   child:WideIconButton(
            //     child: Text("Add Record") ,
            //     padding: 20,
            //   ),
            //   onPressed: (){

            //     },
            // ),
          );
  }
}

class WideIconButton extends StatelessWidget {
  final Widget child;
  final double padding;

  const WideIconButton({required this.child, this.padding = 8.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: child,
    );
  }
}
