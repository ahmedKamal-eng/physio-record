import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:physio_record/RecordDetailsScreen/widgets/follow_up_list_item.dart';
import 'package:physio_record/models/patient_record.dart';

class RecordDetailsScreen extends StatefulWidget {
  PatientRecord patientRecord;
  RecordDetailsScreen({Key? key, required this.patientRecord})
      : super(key: key);

  @override
  State<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends State<RecordDetailsScreen> {


  @override
  Widget build(BuildContext context) {

    TextEditingController textController=TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientRecord.patientName),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diagnosis: ${widget.patientRecord.diagnosis}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'MC: ${widget.patientRecord.mc[0]}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Program: ${widget.patientRecord.program}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 3,
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.2),
                      border: Border.all(
                        width: 2,
                        color: Colors.blue
                      ),
                    ),
                    child: Text(
                      'Follow Up',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )),
              const SizedBox(height: 20,),
              ListView.separated(
                physics:NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return FollowUPListItem( followUp: widget.patientRecord.followUpList[index],);
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      thickness: 1,
                    );
                  },
                  itemCount: widget.patientRecord.followUpList.length),

              const SizedBox(height: 20,),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  suffix: ElevatedButton(
                    onPressed: (){
                      var formattedCurrentDate =
                      DateFormat('d-M-y').format(DateTime.now());
                      widget.patientRecord.followUpList.add(FollowUp(date: formattedCurrentDate, text: textController.text.trim()));
                      widget.patientRecord.save();
                      setState(() {

                      });
                    },
                    child: Text('add'),
                  ),
                  label: Text('text'),
                  border: OutlineInputBorder()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


