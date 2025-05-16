import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/HomeScreen/widgets/record_card.dart';
import 'package:physio_record/SearchRecordInCenter/search_record_in_center.dart';
import 'package:physio_record/models/medical_center_model.dart';
import '../../models/patient_record.dart';

class CenterRecordsList extends StatefulWidget {
  final MedicalCenterModel centerModel;
  CenterRecordsList({required this.centerModel});
  @override
  State<CenterRecordsList> createState() => _CenterRecordsListState();
}

class _CenterRecordsListState extends State<CenterRecordsList> {

  Stream<QuerySnapshot>? recordsStream;
  bool isFiltered=false;
  DateTime? dateTimeFilter;

  @override
  void initState() {
    recordsStream = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.centerModel.adminId)
        .collection('medical_centers')
        .doc(widget.centerModel.centerId)
        .collection('records')
        .orderBy('date', descending: true)
        .snapshots();
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Column(
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
                         .doc(widget.centerModel.adminId)
                         .collection('medical_centers')
                         .doc(widget.centerModel.centerId)
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
                 showSearch(context: context, delegate: SearchRecordInCenter(centerModel: widget.centerModel));
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
                .doc(widget.centerModel.adminId)
                .collection('medical_centers')
                .doc(widget.centerModel.centerId)
                .collection('records')
                .orderBy('date', descending: true)
                .snapshots();

          }, child: Text("Clear Filter\n${DateFormat('d-M-y').format(dateTimeFilter!)}")),
        StreamBuilder<QuerySnapshot>(
            stream: recordsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if(snapshot.data!.docs.length== 0)
                {
                 return const Text("No data founded");
                }


              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder:(context,index){
                return RecordCard(isAdmin:true, fromCenter: true, patient: PatientRecord.fromFirestore(snapshot.data!.docs[index]), patientIndex: index, internetConnection: true);
              },
              itemCount: snapshot.data!.docs.length,
              );


            })
      ],
    );
  }
}
