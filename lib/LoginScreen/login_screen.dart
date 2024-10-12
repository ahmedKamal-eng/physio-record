import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:physio_record/FetchRecordFromFireStore/fetch_record_from_fire_store_screen.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/sign_up_screen/sign_up_screen.dart';

import '../Cubits/DeleteSharedRecordFromLocal/delete_shared_record_cubit.dart';
import '../global_vals.dart';
import '../models/patient_record.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  _fetchRecordsThatNotStoredLocally()async{
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('records');
    QuerySnapshot snapshot= await collectionRef.get();

    int numberOfRecordOnline=snapshot.docs.length;
    var recordBox = Hive.box<PatientRecord>('patient_records');
    int numberOfRecordsLocally=recordBox.values.length;
    if(numberOfRecordOnline>numberOfRecordsLocally)
      {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FetchRecordFromFireStoreScreen()));
      }else{
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.trim(),
          password: _password.trim(),
        );

        // Navigate to the home screen upon successful login
        await _fetchRecordsThatNotStoredLocally();

      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred';
        if (e.code == 'user-not-found') {
          message = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {

        if(FirebaseAuth.instance.currentUser != null) {
          await BlocProvider.of<DeleteSharedRecordCubit>(context).getSharedRecordAndAcceptedRequestsIds();
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  Future<UserCredential> signInWithGoogle() async {
    setState(() {
      _isLoading=true;
    });
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in to Firebase with the obtained credential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user already exists in Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

    if (!userDoc.exists) {
      Timestamp currentDate=Timestamp.now();
      // User doesn't exist, create a new user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'id': FirebaseAuth.instance.currentUser!.uid,
        'status':"approved",
        'registrationTime':currentDate,
        'startTime':currentDate,
        'endTime':getTimeAfterXMonth(time: currentDate.toDate(), x: 2),
        'userName':userCredential.user!.displayName,
        'email':_email.trim()
      });
    }

    // Once signed in, return the UserCredential
    return userCredential;
  }

  // Future<User?> _signInWithGoogle() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //
  //   if (googleUser != null) {
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     try {
  //       final UserCredential userCredential =
  //           await FirebaseAuth.instance.signInWithCredential(credential);
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return userCredential.user;
  //
  //     } catch (e) {
  //       print(e);
  //       // Handle error
  //     }
  //   }
  //
  //   setState(() {
  //     _isLoading = false;
  //   });
  //
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child:  Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: size.height * .1,),
                      Text("Login",
                          style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: size.height * 0.1),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
              
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                      ),
                      SizedBox(height: size.height * 0.07),
              
                      // SignInButton(Buttons.Google, onPressed: ()async  {
                      //
                      //   UserCredential? user=await signInWithGoogle();
                      //   if(user != null)
                      //     {
                      //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                      //     }
                      //
                      // }),
              
                      TextButton(
                          onPressed: () {}, child: Text("Forget Password")),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account"),
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUpScreen()));
                              },
                              child: Text("Sign up"))
                        ],
                      )
                    ],
                  ),
                ),
            ),
      ),
    );
  }
}
