import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/RecordDetailsScreen/record_details_screen.dart';
import 'package:physio_record/models/patient_record.dart';

import '../FetchAllRecord/fetch_record_cubit.dart';

class RecordCard extends StatelessWidget {
  PatientRecord patient;
  int patientIndex;
  RecordCard({Key? key, required this.patient, required this.patientIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => RecordDetailsScreen(patientRecord: patient)));
      },
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 24, left: 16),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListTile(
              title: Text(patient.patientName,
                  style: Theme.of(context).textTheme.headlineSmall),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(patient.diagnosis,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              trailing: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content:
                              Text("Are you sure you want to delete this item"),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  var box = Hive.box<PatientRecord>(
                                      'patient_records');
                                  box.deleteAt(patientIndex);
                                  BlocProvider.of<FetchRecordCubit>(context)
                                      .fetchAllRecord();
                                  Navigator.pop(context);
                                },
                                child: Text('Yes')),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('cancel')),
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).iconTheme.color,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 20),
              child: Text(
                patient.date,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            )
          ],
        ),
      ),
    );
  }
}
