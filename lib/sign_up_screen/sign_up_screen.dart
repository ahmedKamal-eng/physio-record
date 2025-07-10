import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physio_record/EmailVerificationScreen/email_verification_screen.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/LoginScreen/login_screen.dart';
import 'package:physio_record/global_vals.dart';
import 'package:path/path.dart' as path;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _userName = '';
  String _password = '';
  String _imageUrl='';
  String _imagePath='';
  String _medicalSpecialization='';
  bool _isLoading = false;

  Future<void> storeImageInFireStorage()async{

    String imageFile = DateTime.now().millisecondsSinceEpoch.toString();

    final fileName = path.basename(imageXFile!.path);
    final storageRef = FirebaseStorage.instance.ref().child('users/$imageFile/$fileName');
    _imagePath='users/$imageFile/$fileName';
    await storageRef.putFile(File(imageXFile!.path));
    _imageUrl = await storageRef.getDownloadURL();
  }

  Future<void> _signUp() async {
    if(imageXFile == null)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('please choose the image first')),
        );
      }
    if (_formKey.currentState!.validate() && imageXFile != null) {

      storeImageInFireStorage().whenComplete(()async{
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email.trim(),
            password: _password.trim(),
          );
          Timestamp currentDate=Timestamp.now();

          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'id': FirebaseAuth.instance.currentUser!.uid,
            'status':"approved",
            'registrationTime':currentDate,
            'startTime':currentDate,
            'endTime':getTimeAfterXMonth(time: currentDate.toDate(), x: freeTrialMonths),
            'userName':_userName.trim(),
            'userNameLowerCase':_userName.trim().toLowerCase(),
            'email':_email.trim(),
            'medicalSpecialization':_medicalSpecialization.trim(),
            "imageUrl":_imageUrl,
            "imagePath":_imagePath

          }).whenComplete((){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmailVerificationScreen()));
          });

          // User registration successful, navigate to home screen or display success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User registered successfully!')),
          );
          // Navigate to another screen if needed

        } on FirebaseAuthException catch (e) {
          String message = 'An error occurred';
          if (e.code == 'email-already-in-use') {
            message = 'This email is already in use';
          } else if (e.code == 'weak-password') {
            message = 'The password provided is too weak';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unknown error occurred')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      });

      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });


    }
  }

  // get image from gallery
  XFile? imageXFile;
  ImagePicker imagePicker = ImagePicker();

  Future<void> getImageFromGallery() async {
    imageXFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }



  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
        
                    children: <Widget>[
                      
                      Text("Sign Up",style: Theme.of(context).textTheme.headlineMedium,),
                      SizedBox(height: size.height *.03,),
                      InkWell(
                        onTap: (){
                             getImageFromGallery();
                        },
                        child: CircleAvatar(
                          radius: size.width * .22,
                          backgroundColor:Colors.white,
                          child: CircleAvatar(
                            backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
                            radius: size.width * .21,
                            backgroundColor: Colors.blue,
                            child: imageXFile== null? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 18,),
                                Text("choose profile photo",style: TextStyle(color: Colors.white),)
                                ,
                                Icon(Icons.photo_camera_front_outlined,color:Colors.white,size:size.width * .2 ,),
                              ],
                            ):null,
                          ),
                        ),
                      ),
        
                      TextFormField(
                        style: TextStyle(color: Colors.white),

                        decoration:const InputDecoration(
                          // Change the default border color when the TextField is enabled
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            // Change the border color when the TextField is focused
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            // Change the border color when there's an error
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            // Optional: Change the border color when the TextField is focused and there's an error
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                            labelText: 'Email',labelStyle: TextStyle(color: Colors.white)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          // Change the default border color when the TextField is enabled
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          // Change the border color when the TextField is focused
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          //

                          labelText: 'Full Name',labelStyle: TextStyle(color: Colors.white),),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid User Name ';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userName = value!;
                        },
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),

                        decoration: InputDecoration(
                          // Change the default border color when the TextField is enabled
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            // Change the border color when the TextField is focused
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            //
                            labelText: 'Medical Specialization',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Medical Specialization ';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _medicalSpecialization = value!;
                        },
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          // Change the default border color when the TextField is enabled
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            // Change the border color when the TextField is focused
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            //
                            labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.white
                          )

                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        onChanged: (v){
                          _password=v!;
        
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration:
                            InputDecoration(
                              // Change the default border color when the TextField is enabled
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                // Change the border color when the TextField is focused
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                //
                                labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: Colors.white)
                            ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
        
                      SizedBox(height: size.height *.05,),
        
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: _signUp,
                        child: Text('Sign Up',style: TextStyle(fontSize: 20,color: Colors.blue,fontWeight: FontWeight.bold),),
                      ),
                      SizedBox(height: size.height *.05,),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
        
                          Text("Already have an account"),
                          TextButton(onPressed: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                          }, child: Text("Login",style: TextStyle(color: Colors.white,fontSize: 20),))
                        ],
                      )
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
