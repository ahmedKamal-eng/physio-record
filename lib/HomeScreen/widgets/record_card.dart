import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/HomeScreen/DeleteRecordCubit/delete_record_States.dart';
import 'package:physio_record/HomeScreen/DeleteRecordCubit/delete_record_cubit.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/pdf/generate_pdf.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/patient_record.dart';

import '../../FollowUpScreen/follow_up_screen.dart';
import '../../SearchForDoctorsScreen/search_for_doctors_screen.dart';
import '../../ShareWithFriendScreen/share_with_friend_screen.dart';
import '../FetchAllRecord/fetch_record_cubit.dart';
import 'package:path/path.dart' as path;




class RecordCard extends StatefulWidget {
  PatientRecord patient;
  bool internetConnection;
  bool fromCenter;
  bool isAdmin;
  int patientIndex;
   RecordCard({
     required this.fromCenter,
     this.isAdmin=false,
   required this.patient,
    required this.patientIndex,
    required this.internetConnection
  });

  @override
  State<RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.0,vertical: 2),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FollowUPScreen(
                    fromCenter: widget.fromCenter,
                    isAdmin:widget.isAdmin,
                    patientRecord: widget.patient,
                  )));
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.patientName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.patient.diagnosis,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.patient.date,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if(!widget.isAdmin)
              PopupMenuButton(
                  child: Icon(Icons.more_vert,size: 30,),
                  iconColor: Colors.blue,
                  iconSize: 50,
                  itemBuilder: (context) => [

                    //delete
                    PopupMenuItem(
                        child: BlocProvider(
                          create: (context) =>DeleteRecordCubit(),
                          child: BlocBuilder<DeleteRecordCubit,DeleteRecordState>(
                              builder: (context,state) {
                                return GestureDetector(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final List<ConnectivityResult>
                                      connectivityResult = await (Connectivity()
                                          .checkConnectivity());

                                      if (!connectivityResult
                                          .contains(ConnectivityResult.none)) {
                                        showDialog(
                                            barrierDismissible: !(state is DeleteRecordLoading),
                                            context: context,
                                            builder: (context) {
                                              return BlocProvider(
                                                create: (context)=>DeleteRecordCubit(),
                                                child: BlocConsumer<DeleteRecordCubit,DeleteRecordState>(
                                                    listener: (context, state){
                                                      if(state is DeleteRecordSuccess)
                                                      {
                                                        if(Navigator.canPop(context))
                                                        {
                                                          Navigator.pop(context);
                                                        }
                                                      }

                                                      if(state is DeleteRecordError)
                                                      {
                                                        print('DeleteRecord Error) ${state.error}');
                                                        Fluttertoast.showToast(msg: 'An error occur',backgroundColor: Colors.red,textColor: Colors.white);
                                                        if(Navigator.canPop(context))
                                                          Navigator.pop(context);
                                                      }

                                                    },
                                                    builder: (context,state) {
                                                      return AlertDialog(

                                                        title: state is DeleteRecordLoading ? Center(child: CircularProgressIndicator()): Text(
                                                            "Are you sure you want to delete this item"),
                                                        actions:state is DeleteRecordLoading ?[]: [
                                                          ElevatedButton(
                                                              onPressed: () async {
                                                                BlocProvider.of<DeleteRecordCubit>(context).deleteRecord(widget.patient, widget.patientIndex, context);
                                                              },
                                                              child: Text('Yes')),
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text('cancel')),
                                                        ],
                                                      );
                                                    }
                                                ),
                                              );
                                            });
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Please check Your enternet connection'),
                                                actions: [],
                                              );
                                            });
                                      }
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        "delete",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ));
                              }
                          ),
                        )),

                    // share
                    PopupMenuItem(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            final List<ConnectivityResult> connectivityResult =
                            await (Connectivity().checkConnectivity());

                            if (connectivityResult
                                .contains(ConnectivityResult.none)) {
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      elevation: 10,
                                      backgroundColor: Colors.blue[50],
                                      title: Center(
                                        child: Column(
                                          children: [
                                            Icon(Icons.share, size: 40, color: Colors.blue),
                                            SizedBox(height: 10),
                                            Text(
                                              "Share this record",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ShareWithFriendScreen(
                                                              doctorIds: widget.patient
                                                                  .doctorsId,
                                                              recordModel:
                                                              widget.patient,
                                                              isSharedBefore:
                                                              widget.patient
                                                                  .isShared!,
                                                            )));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                backgroundColor: Colors.blue,
                                                elevation: 5,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.people),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Share with Colleagues",
                                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                             ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(

                                              onPressed: () {
                                                Navigator.pop(context);
                                                showSearch(
                                                    context: context,
                                                    delegate:
                                                    UserSearchDelegate(
                                                        patientRecord:
                                                        widget.patient,
                                                        isSharedBefore:
                                                        widget.patient
                                                            .isShared,
                                                        doctorsIds: widget.patient
                                                            .doctorsId));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                backgroundColor: Colors.purple,
                                                elevation: 5,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.person_search),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Search for doctors",
                                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                             ),
                                        ],
                                      ),
                                    );
                                  });
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Text("share",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )),

                    //edit
                    PopupMenuItem(
                        child: GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => RecordDetailsScreen(
                                        patientRecord: widget.patient)));
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Text("edit",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )),

                    // pdf record
                    PopupMenuItem(
                        child: GestureDetector(
                          onTap: () {
                            if(widget.internetConnection)
                            {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => GeneratePdfScreen(
                                        patientId: widget.patient.id)));}
                              else{
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }

                                showDialog(context: context, builder:(context)
                                {
                                  return AlertDialog(
                                    title:Text("Please Check Your Internet Connection") ,
                                  );
                                });
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Text("pdf record",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )),

                  ],

               ),

            ],
          ),
        ),
      ),
    );
  }
}



// class RecordCard extends StatefulWidget {
//   PatientRecord patient;
//   bool internetConnection;
//   int patientIndex;
//   RecordCard(
//       {Key? key,
//       required this.patient,
//       required this.patientIndex,
//       required this.internetConnection})
//       : super(key: key);
//
//   @override
//   State<RecordCard> createState() => _RecordCardState();
// }
//
// class _RecordCardState extends State<RecordCard> {
//   // bool deleteLoading=false;
//
//   @override
//   Widget build(BuildContext context) {
//     bool isDark =
//         Theme.of(context).brightness == Brightness.dark ? true : false;
//     return GestureDetector(
//       onTap: () {
//         print(widget.patient.followUpList.length.toString() + ")))))))))))))))))");
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => FollowUPScreen(
//                       patientRecord: widget.patient,
//                       internetConnection: widget.internetConnection,
//                     )));
//       },
//       child: Container(
//         padding: const EdgeInsets.only(top: 4, bottom: 4, left: 6),
//         decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color:
//                     Colors.teal.withOpacity(0.4), // Shadow color with opacity
//                 spreadRadius: 5, // How much the shadow spreads
//                 blurRadius: 5, // How soft or blurred the shadow is
//                 offset: Offset(0, 3), // Offset (horizontal, vertical)
//               ),
//             ],
//             color: isDark ? Colors.black54 : Colors.white,
//             borderRadius: BorderRadius.circular(4)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             ListTile(
//               title: Text(widget.patient.patientName,
//                   style: Theme.of(context).textTheme.headlineSmall!.copyWith(
//                       color: Colors.teal, fontWeight: FontWeight.bold)),
//               subtitle: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 child: Text(widget.patient.diagnosis,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge!
//                         .copyWith(color: Colors.teal)),
//               ),
//               trailing: PopupMenuButton(
//                   iconColor: Colors.teal,
//                   iconSize: 50,
//                   itemBuilder: (context) => [
//                         PopupMenuItem(
//                             child: BlocProvider(
//                               create: (context) =>DeleteRecordCubit(),
//                               child: BlocBuilder<DeleteRecordCubit,DeleteRecordState>(
//                                 builder: (context,state) {
//                                   return TextButton(
//                                       onPressed: () async {
//                                         Navigator.pop(context);
//                                         final List<ConnectivityResult>
//                                             connectivityResult = await (Connectivity()
//                                                 .checkConnectivity());
//
//                                         if (!connectivityResult
//                                             .contains(ConnectivityResult.none)) {
//                                           showDialog(
//                                             barrierDismissible: !(state is DeleteRecordLoading),
//                                               context: context,
//                                               builder: (context) {
//                                                 return BlocProvider(
//                                                   create: (contex)=>DeleteRecordCubit(),
//                                                   child: BlocConsumer<DeleteRecordCubit,DeleteRecordState>(
//                                                     listener: (context, state){
//                                                       if(state is DeleteRecordSuccess)
//                                                         {
//                                                           if(Navigator.canPop(context))
//                                                             {
//                                                               Navigator.pop(context);
//                                                             }
//                                                         }
//
//                                                       if(state is DeleteRecordError)
//                                                         {
//                                                           print('DeleteRecord Error) ${state.error}');
//                                                           Fluttertoast.showToast(msg: 'An error occur',backgroundColor: Colors.red,textColor: Colors.white);
//                                                           if(Navigator.canPop(context))
//                                                             Navigator.pop(context);
//                                                         }
//
//                                                     },
//                                                     builder: (context,state) {
//                                                       return AlertDialog(
//
//                                                         title: state is DeleteRecordLoading ? Center(child: CircularProgressIndicator()): Text(
//                                                             "Are you sure you want to delete this item"),
//                                                         actions:state is DeleteRecordLoading ?[]: [
//                                                           ElevatedButton(
//                                                               onPressed: () async {
//                                                                 BlocProvider.of<DeleteRecordCubit>(context).deleteRecord(widget.patient, widget.patientIndex, context);
//                                                               },
//                                                               child: Text('Yes')),
//                                                           ElevatedButton(
//                                                               onPressed: () {
//                                                                 Navigator.pop(context);
//                                                               },
//                                                               child: Text('cancel')),
//                                                         ],
//                                                       );
//                                                     }
//                                                   ),
//                                                 );
//                                               });
//                                         } else {
//                                           showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return AlertDialog(
//                                                   title: Text(
//                                                       'Please check Your enternet connection'),
//                                                   actions: [],
//                                                 );
//                                               });
//                                         }
//                                       },
//                                       child: Text(
//                                         "delete",
//                                         style: TextStyle(
//                                             color: Colors.teal,
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold),
//                                       ));
//                                 }
//                               ),
//                             )),
//                         PopupMenuItem(
//                             child: TextButton(
//                           onPressed: () async {
//                             Navigator.pop(context);
//                             final List<ConnectivityResult> connectivityResult =
//                                 await (Connectivity().checkConnectivity());
//
//                             if (connectivityResult
//                                 .contains(ConnectivityResult.none)) {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return AlertDialog(
//                                       title: Text(
//                                           "There is no internet connection please try again"),
//                                       actions: [
//                                         ElevatedButton(
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: Text("Ok")),
//                                       ],
//                                     );
//                                   });
//                             } else {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return AlertDialog(
//                                       title: Center(
//                                           child: Text("Share this record")),
//                                       content: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                   backgroundColor: Colors.teal),
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                                 Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             ShareWithFriendScreen(
//                                                               doctorIds: widget.patient
//                                                                   .doctorsId,
//                                                               recordModel:
//                                                                   widget.patient,
//                                                               isSharedBefore:
//                                                                   widget.patient
//                                                                       .isShared!,
//                                                             )));
//                                               },
//                                               child: Text(
//                                                 "Share with friend doctors",
//                                                 style: TextStyle(
//                                                     color: Colors.white),
//                                               )),
//                                           SizedBox(
//                                             height: 20,
//                                           ),
//                                           ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                   backgroundColor: Colors.teal),
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                                 showSearch(
//                                                     context: context,
//                                                     delegate:
//                                                         UserSearchDelegate(
//                                                             patientRecord:
//                                                                 widget.patient,
//                                                             isSharedBefore:
//                                                                 widget.patient
//                                                                     .isShared,
//                                                             doctorsIds: widget.patient
//                                                                 .doctorsId));
//                                               },
//                                               child: Text(
//                                                 "Search for doctors",
//                                                 style: TextStyle(
//                                                     color: Colors.white),
//                                               )),
//                                         ],
//                                       ),
//                                     );
//                                   });
//                             }
//                           },
//                           child: Text("share",
//                               style: TextStyle(
//                                   color: Colors.teal,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold)),
//                         )),
//                         PopupMenuItem(
//                             child: TextButton(
//                           onPressed: () {
//                             if (Navigator.canPop(context)) {
//                               Navigator.pop(context);
//                             }
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (c) => RecordDetailsScreen(
//                                         patientRecord: widget.patient)));
//                           },
//                           child: Text("edit",
//                               style: TextStyle(
//                                   color: Colors.teal,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold)),
//                         )),
//                       ]),
//             ),
//             // Text(
//             //   widget.patient.followUpList.length.toString() +
//             //       "   follow up items      ",
//             //   style: TextStyle(color: Colors.teal),
//             // ),
//             Padding(
//               padding: const EdgeInsets.only(right: 16, top: 10),
//               child: Text(
//                 widget.patient.date,
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleLarge!
//                     .copyWith(color: Colors.teal),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
