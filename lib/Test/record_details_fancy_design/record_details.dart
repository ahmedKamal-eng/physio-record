import 'package:flutter/material.dart';

// class PatientRecordScreen extends StatelessWidget {
//   final PatientRecord patientRecord;
//   final Function(String value, BuildContext context, String field, bool isMultiline) _showEditDialog;
//
//   const PatientRecordScreen({Key? key, required this.patientRecord, required this._showEditDialog}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[50], // Light blue background for modern feel
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         elevation: 5,
//         title: Text(
//           patientRecord.date,
//           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // **Patient Basic Info**
//             _buildSectionTitle("Patient Information"),
//             _buildEditableTile("Name", patientRecord.patientName, "name", context, Icons.person),
//             _buildEditableTile("Age", patientRecord.age.toString(), "age", context, Icons.cake),
//             _buildStaticTile("Gender", patientRecord.gender ?? "", Icons.male),
//
//             // **Medical Details**
//             _buildSectionTitle("Medical Details"),
//             _buildEditableTile("Diagnosis", patientRecord.diagnosis, "diagnosis", context, Icons.local_hospital),
//             _buildEditableTile("Phone Number", patientRecord.phoneNumer.toString(), "phoneNumber", context, Icons.phone),
//             _buildEditableTile("Condition Assessment", patientRecord.conditionAssessment ?? "", "conditionAssessment", context, Icons.assessment),
//             _buildEditableTile("Reason for Visit", patientRecord.reasonForVisit ?? "", "reasonForVisit", context, Icons.event_note),
//
//             // **Job Info**
//             _buildSectionTitle("Occupation"),
//             _buildEditableTile("Job", patientRecord.job ?? "", "job", context, Icons.work),
//
//             // **Medical Conditions & Programs**
//             _buildSectionTitle("Medical Conditions"),
//             _buildEditableListTile("Other Medical Conditions", patientRecord.mc, "mc", context, Icons.sick),
//             _buildEditableListTile("Programs", patientRecord.program, "program", context, Icons.list),
//             _buildEditableListTile("Known Allergies", patientRecord.knownAllergies, "knownAllergies", context, Icons.warning),
//
//             // **Medical History & Medications**
//             _buildSectionTitle("Medical History"),
//             _buildEditableListTile("Medical History", patientRecord.medicalHistory, "medicalHistory", context, Icons.history),
//             _buildEditableListTile("Medications", patientRecord.medication, "medication", context, Icons.medication),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // **Reusable Section Title**
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16, bottom: 8),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]),
//       ),
//     );
//   }
//
//   // **Reusable Editable ListTile**
//   Widget _buildEditableTile(String title, String value, String field, BuildContext context, IconData icon) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(value, style: const TextStyle(fontSize: 16)),
//         trailing: IconButton(
//           icon: const Icon(Icons.edit, color: Colors.blue),
//           onPressed: () => _showEditDialog(value, context, field, false),
//         ),
//       ),
//     );
//   }
//
//   // **Reusable Non-Editable ListTile**
//   Widget _buildStaticTile(String title, String value, IconData icon) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(value, style: const TextStyle(fontSize: 16)),
//       ),
//     );
//   }
//
//   // **Reusable Editable List Tile for Multiple Items**
//   Widget _buildEditableListTile(String title, List<String> items, String field, BuildContext context, IconData icon) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: items.map((item) => Text("• $item", style: const TextStyle(fontSize: 16))).toList(),
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.edit, color: Colors.blue),
//           onPressed: () => _showEditDialog(items.join('\n'), context, field, true),
//         ),
//       ),
//     );
//   }
// }
