import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/LoginScreen/login_screen.dart';
import 'package:physio_record/global_vals.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _userName = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
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
          'endTime':getTimeAfterXMonth(time: currentDate.toDate(), x: 2),
          'userName':_userName.trim(),
          'email':_email.trim()
        }).whenComplete((){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
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
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;

    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(

                  children: <Widget>[
                    SizedBox(height: size.height *.1,),
                    Text("Sign Up",style: Theme.of(context).textTheme.headlineMedium,),
                    SizedBox(height: size.height *.1,),

                    TextFormField(
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
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'UserName'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid User Name address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userName = value!;
                      },
                    ),
                    TextFormField(
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
                      onChanged: (v){
                        _password=v!;

                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
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
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
                    SizedBox(height: size.height *.1,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text("Already have an account"),
                        TextButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                        }, child: Text("Login"))
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
