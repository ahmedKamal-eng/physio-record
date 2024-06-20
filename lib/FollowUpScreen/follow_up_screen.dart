
import 'package:flutter/material.dart';
import 'package:physio_record/AddFollowUpItem/add_follow_up_item.dart';
import 'package:physio_record/models/patient_record.dart';

class FollowUPScreen extends StatelessWidget {

  final PatientRecord patientRecord;
  FollowUPScreen({required this.patientRecord});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(patientRecord.patientName +" Follow Up"),),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFollowUPItemScreen(patientRecord: patientRecord,)));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
