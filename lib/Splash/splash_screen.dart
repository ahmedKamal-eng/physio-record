import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:physio_record/LoginScreen/login_screen.dart';

import '../Cubits/DeleteSharedRecordFromLocal/delete_shared_record_cubit.dart';
import '../HomeScreen/home_screen.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  double paddingVal = .4;


  @override
  void initState() {

    if(FirebaseAuth.instance.currentUser != null) {
      BlocProvider.of<DeleteSharedRecordCubit>(context).getSharedRecordAndAcceptedRequestsIds();
    }

    Future.delayed(Duration(seconds: 2), () {


      paddingVal = 0;





      setState(() {});

       Future.delayed(Duration(seconds: 1), () {

        if (FirebaseAuth.instance.currentUser == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AnimatedPadding(
        duration: Duration(seconds: 1),
        padding:  EdgeInsets.only(bottom: screenHeight * paddingVal),
        child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: screenWidth * .35,
                backgroundColor:Colors.blue,
                child: CircleAvatar(

                  radius: screenWidth * .34,

                  backgroundImage:AssetImage('assets/images/4033.jpg'),

                  // child: ClipOval(
                  //   child: Image.asset(
                  //     ,width: screenWidth * .7,
                  //     fit: BoxFit.cover,
                  //   ),
                  //
                    //   child: SvgPicture.asset(
                    // 'assets/images/splashimage.svg',
                    // fit: BoxFit.cover,
                    // width: screenWidth * .7,
                  // )
                ),
              ),
            Padding(
                // padding: EdgeInsets.only(top: screenHeight * paddingVal),
                padding: EdgeInsets.only(top: screenHeight * .05),
                // duration: Duration(seconds: 2),
                child: Text(
                  "Physio Record",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.blue,fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
