
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:uuid/uuid.dart';

class AddMedicalCenterScreen extends StatefulWidget {
  @override
  _AddMedicalCenterScreenState createState() => _AddMedicalCenterScreenState();
}

class _AddMedicalCenterScreenState extends State<AddMedicalCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase() async {
    if (_imageFile == null) return '';

    setState(() => _isLoading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('medical_centers')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_imageFile!);
      _imageUrl = await storageRef.getDownloadURL();
      return _imageUrl!;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMedicalUnit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image for the unit')),
      );
      return;
    }

    try {

      var uuid = Uuid();
      String centerId = uuid.v6();

      await _uploadImageToFirebase();

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('medical_centers').doc(centerId).set({
        'name': _nameController.text.trim(),
        'imageUrl': _imageUrl,
        'centerId':centerId,
        'want_to_join':[],
        'adminName':BlocProvider.of<GetUserDataCubit>(context).userModel!.userName,
        'adminImage':BlocProvider.of<GetUserDataCubit>(context).userModel!.imageUrl,
        'adminSpecialization':BlocProvider.of<GetUserDataCubit>(context).userModel!.medicalSpecialization,
        'createdAt': Timestamp.now(),
        'startDate': Timestamp.now(),
        'endDate': Timestamp.now(),
        'doctorCount': 1,
        "recordCount":0,
        'adminId':FirebaseAuth.instance.currentUser!.uid,
        'doctorsIds':[FirebaseAuth.instance.currentUser!.uid]
        // Initialize with 0 doctors
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medical Center added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving unit: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        title: Text('Add Medical Center',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Picker Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200],
                    ),
                    child: _imageFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            size: 50, color: Colors.teal),
                        SizedBox(height: 10),
                        Text('Tap to add Center image',
                            style: TextStyle(color: Colors.teal)),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Unit Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Center Name',
                  prefixIcon: Icon(Icons.medical_services, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Center name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _saveMedicalUnit,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('SAVE Center',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}