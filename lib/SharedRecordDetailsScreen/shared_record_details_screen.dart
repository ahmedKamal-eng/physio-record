import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/AddFollowAppToSharedRecord/add_follow_up_to_shared_record.dart';
import 'package:physio_record/SharedRecordDetailsScreen/widgets/shared_follow_up_item.dart';
import 'package:physio_record/models/shared_follow_up_model.dart';
import 'package:physio_record/models/shared_record_model.dart';

class SharedRecordDetailsScreen extends StatefulWidget {
  final SharedRecordModel sharedRecordModel;

  SharedRecordDetailsScreen({required this.sharedRecordModel});

  @override
  State<SharedRecordDetailsScreen> createState() =>
      _SharedRecordDetailsScreenState();
}

class _SharedRecordDetailsScreenState extends State<SharedRecordDetailsScreen> {
  late Stream<QuerySnapshot> _followUpStream;
  @override
  void initState() {
    _followUpStream = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('sharedRecords')
        .doc(widget.sharedRecordModel.id)
        .collection('followUp')
         .orderBy('date',descending: false)
        .snapshots();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sharedRecordModel.patientName + " record"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${widget.sharedRecordModel.patientName}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Diagnosis: ${widget.sharedRecordModel.diagnosis}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'MC: ${widget.sharedRecordModel.mc[0]}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Program: ${widget.sharedRecordModel.program}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        widget.sharedRecordModel.doctorsIds.length.toString() +
                            " doctors shared this record",
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _followUpStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      SharedFollowUpModel followUp =
                          SharedFollowUpModel.fromFirestore(
                              snapshot.data!.docs[index]);
                      return SharedFollowUpItem(followUp: followUp);
                    });
              }),
          SizedBox(height: 100,)
        ],
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
        ),
        // child: Icon(Icons.share),

        child: Text(
          "Add To FollowUp",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddFollowUpItemToSharedRecord(
                      sharedRecordModel: widget.sharedRecordModel)));
        },
      ),
    );
  }
}
