import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/AddRecordScreen/add_record_Screen.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/HiveService/user_functions.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_state.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';
import 'package:physio_record/HomeScreen/widgets/trail_status_bar.dart';
import 'package:physio_record/Payment/view/subscription_screen.dart';
import 'package:physio_record/SearchScreen/search_screen.dart';
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
  bool isFiltered = false;
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

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {

      internetConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
      if (internetConnection) {
        await BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
        print('&&&&&&&&&&&&connected');

            await BlocProvider.of<GetUserDataCubit>(context).getUserData().then((v)async{

              UserModel? currentUser =
                  BlocProvider.of<GetUserDataCubit>(context).userModel;
              isEndTimePassed =
                  hasTimestampPassed(convertStringToTimestamp(currentUser!.endTime!));
              print("End Time is::::::::::::::::::::${currentUser.endTime}");
              setState(() {
              });

              await BlocProvider.of<FetchRecordCubit>(context)
                  .uploadFollowUpOnlyInLocal(currentUser.userName);
            });

        try {
          await BlocProvider.of<FetchRecordCubit>(context).uploadLocalRecord();
        } catch (e) {
          print("+++++++++ Upload local error :: " + e.toString());
        }



        await BlocProvider.of<FetchRecordCubit>(context)
            .updateRecordInFirestore();
      }else{
        await BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
      }

      _isCheckingConnection = false;

      setState(() {});

  }



  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _checkConnectivityAndUpload();
    super.initState();
  }

  _checkConnectivityAndUpload() async
  {
    await BlocProvider.of<FetchRecordCubit>(context).fetchAllRecord();
  }




  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Stream<QuerySnapshot> shareRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('shareRequests')
      .snapshots();

  Stream<QuerySnapshot> joiningRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('joining_requests')
      .snapshots();

  Stream<QuerySnapshot> recordStream = FirebaseFirestore.instance
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

  Stream<QuerySnapshot> notSharedRecordStream = FirebaseFirestore.instance
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

    // return isEndTimePassed
    //     ? Scaffold(
    //         body: Center(
    //           child: Text('Your subscription has expired.'),
    //         ),
    //       )
    //     :
   return Builder(
     builder: (context) {
       if(isEndTimePassed)
         {
           Future.delayed(Duration(seconds: 2),(){

             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
               return SubscriptionScreen();
             }));

           });
         }
       return Scaffold(

                 backgroundColor: Colors.blue[50],
                drawer: MyDrawer(),
                drawerScrimColor: Colors.white.withOpacity(.5),

                appBar: AppBar(
                  leading: Builder(
                    builder: (context) {
                      return Stack(
                        children: [
                          IconButton(onPressed: (){
                            Scaffold.of(context).openDrawer();
                          }, icon: Icon(Icons.menu)),
                          if(internetConnection)
                          StreamBuilder<QuerySnapshot>(
                            stream: joiningRequestsStream,
                            builder: (context,snap) {
                              return StreamBuilder<QuerySnapshot>(
                                builder: (context, snapshot) {
                                  if(snapshot.hasData && snapshot.data!.docs.length > 0) {
                                    return Positioned(
                                      bottom: 1,
                                      right: 1,
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 12,
                                          child: Text(
                                            style: TextStyle(color: Colors.white),
                                              (snapshot.data!.docs.length+snap.data!.docs.length).toString()),
                                        ),
                                      ),
                                    );
                                  }else{
                                    return Container();
                                  }
                                }, stream: shareRequestsStream,
                              );
                            }
                          ),
                        ],
                      );
                    }
                  ),
                  iconTheme:  IconThemeData(color: Colors.white, size: 30),
                  backgroundColor: Colors.blue,
                  title: Text(
                    "PatientRecorder",style: TextStyle(fontFamily: 'cairo',fontWeight: FontWeight.bold,color: Colors.white),
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
                                    backgroundColor: Colors.blue[50],
                                    title: Text("Record Filter"),
                                    content: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                                if (internetConnection) {
                                                  // Get the start and end of the day
                                                  final startOfDay =
                                                      Timestamp.fromDate(
                                                    DateTime(
                                                        dateTime.year,
                                                        dateTime.month,
                                                        dateTime.day),
                                                  );
                                                  final endOfDay =
                                                      Timestamp.fromDate(
                                                    DateTime(
                                                        dateTime.year,
                                                        dateTime.month,
                                                        dateTime.day + 1),
                                                  );

                                                  // Firestore query for records in the specific day
                                                  recordStream = FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .collection('records')
                                                      .where('date',
                                                          isGreaterThanOrEqualTo:
                                                              startOfDay)
                                                      .where('date',
                                                          isLessThan: endOfDay)
                                                      .snapshots();
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    isFiltered = true;
                                                  });
                                                } else {
                                                  BlocProvider.of<FetchRecordCubit>(
                                                          context)
                                                      .filterPatientsByDate(
                                                          dateTime);
                                                  Navigator.pop(context);
                                                }
                                              }
                                            },
                                            child:
                                                const Text("choose specific day")),
                                        TextButton(
                                            onPressed: () {
                                              if (internetConnection) {
                                                recordStream = sharedRecordStream;
                                                setState(() {
                                                  isFiltered = true;
                                                });
                                                if (Navigator.canPop(context))
                                                  Navigator.pop(context);
                                              } else {
                                                BlocProvider.of<FetchRecordCubit>(
                                                        context)
                                                    .filterSharedPatient();
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text('Shared Records')),
                                        TextButton(
                                            onPressed: () {
                                              if (internetConnection) {
                                                recordStream =
                                                    notSharedRecordStream;
                                                setState(() {
                                                  isFiltered = true;
                                                });
                                                if (Navigator.canPop(context))
                                                  Navigator.pop(context);
                                              } else {
                                                BlocProvider.of<FetchRecordCubit>(
                                                        context)
                                                    .filterNotSharedPatient();
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text('Not Shared Records'))
                                      ],
                                    ),
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
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
                            color: Colors.white,
                            size: 35,
                          )),
                    ),

                  ],
                ),

                body: internetConnection
                    ? Column(
                        children: [

                          TrialStatusCard(registrationDate:convertStringToTimestamp( getCurrentUser()!.registrationTime).toDate(),endDate: convertStringToTimestamp( getCurrentUser()!.endTime!).toDate(),),
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

                                    isFiltered = false;
                                    setState(() {});
                                  },
                                  child: Text("Clear filter")),
                            ),
                            StreamBuilder<QuerySnapshot>(
                            stream: recordStream,
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

                              return Expanded(
                                child: ListView.builder(
                                  physics:const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> data =
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>;

                                    print(data['rayImages']);
                                    return Padding(
                                      padding:snapshot.data!.docs.length == index+1 ? const EdgeInsets.only(top: 3.0,right: 3,left: 3,bottom: 80) : const EdgeInsets.all(3.0),
                                      child: RecordCard(
                                        fromCenter: false,
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
                        ],
                      )
                    : BlocBuilder<FetchRecordCubit, FetchRecordState>(
                        builder: (BuildContext context, FetchRecordState state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TrialStatusCard(registrationDate:convertStringToTimestamp( getCurrentUser()!.registrationTime).toDate(),endDate: convertStringToTimestamp( getCurrentUser()!.endTime!).toDate()),

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
                                            padding: EdgeInsets.all(4),
                                            child: RecordCard(
                                              fromCenter:false,
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
                                        padding: BlocProvider.of<FetchRecordCubit>(context)
                                            .patientRecords!
                                            .length== index+1 ?EdgeInsets.only(top: 5,left: 5,right: 5,bottom: 80): EdgeInsets.all(5),
                                        child: RecordCard(
                                          fromCenter: false,
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

                              ,
                              // SizedBox(
                              //   height: 70,
                              // )
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
                    backgroundColor: Colors.blue,
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
                        MaterialPageRoute(builder: (context) => AddRecordScreen(fromCenter: false,)));
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
   );
  }
}
