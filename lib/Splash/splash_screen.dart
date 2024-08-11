
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:physio_record/LoginScreen/login_screen.dart';
import 'package:physio_record/sign_up_screen/sign_up_screen.dart';

import '../HomeScreen/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  double paddingVal=.4;


  @override
  void initState() {



    Future.delayed(Duration(milliseconds: 400),(){
      paddingVal=0.05;

      setState(() {
      });


      Future.delayed(Duration(seconds: 2),(){
        if(FirebaseAuth.instance.currentUser == null)
          {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));
          }
        else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:MainAxisAlignment.center,

          children: [
           CircleAvatar(
                radius: screenWidth * .34,
                child: ClipOval(child: SvgPicture.asset('assets/images/splashimage.svg',fit: BoxFit.cover,width: screenWidth *.7,)),
              ),
            AnimatedPadding(padding: EdgeInsets.only(top:screenHeight * paddingVal ), duration: Duration(seconds: 1),
              child: Text("Physio Record",style: Theme.of(context).textTheme.headlineLarge,),
            ),

          ],
        ),
      ),
    );
  }
}
