


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../HomeScreen/widgets/record_card.dart';
import '../../models/medical_center_model.dart';
import '../../models/patient_record.dart';

class SearchForDoctorRecords extends SearchDelegate {
  final MedicalCenterModel centerModel;
  SearchForDoctorRecords({required this.centerModel});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(child: Text('Start typing to search...'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('records')
          .where('centerId', isEqualTo: centerModel.centerId)
          .where('patientNameLowerCase', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('patientNameLowerCase', isLessThan: query.toLowerCase() + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text('No records found.'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return RecordCard(isAdmin:true, fromCenter: true, patient: PatientRecord.fromFirestore(docs[index]), patientIndex: index, internetConnection: true) ;
          },
        );
      },
    );
  }
}
