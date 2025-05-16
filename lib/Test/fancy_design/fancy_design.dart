
import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Patient Records',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//       ),
//       home: PatientListScreen(),
//     );
//   }
// }

class PatientListScreen extends StatelessWidget {
  final List<Map<String, String>> patients = [
    {
      'name': 'John Doe',
      'diagnosis': 'Hypertension',
      'date': '2023-10-01',
    },
    {
      'name': 'Jane Smith',
      'diagnosis': 'Diabetes',
      'date': '2023-09-25',
    },
    // Add more patients here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Records'),
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          return PatientCard(
            patientName: patients[index]['name']!,
            diagnosis: patients[index]['diagnosis']!,
            date: patients[index]['date']!,
            onTap: () {
              // Navigate to another screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(patient: patients[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final String patientName;
  final String diagnosis;
  final String date;
  final VoidCallback onTap;

  const PatientCard({
    required this.patientName,
    required this.diagnosis,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
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
                      patientName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      diagnosis,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert,size: 40, color: Colors.blue),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientDetailScreen extends StatelessWidget {
  final Map<String, String> patient;

  const PatientDetailScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${patient['name']}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Diagnosis: ${patient['diagnosis']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Date: ${patient['date']}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}