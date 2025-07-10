

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/HiveService/user_functions.dart';
import 'package:physio_record/Payment/view/paymob_service.dart';
import 'package:physio_record/Payment/view/subscribtion_card.dart';
import 'package:physio_record/Splash/splash_screen.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/models/user_model.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {




  //  internet connectivity

  bool internetConnection = false;
  bool _isCheckingConnection = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  //________________________________________


  Future<void> initConnectivity() async {
    setState(() {
      _isCheckingConnection = true;
    });

    List<ConnectivityResult> results;

    try {
      results = await Connectivity().checkConnectivity();
    } catch (e) {
      print("________:Can not Check Connectivity${e.toString()}");
      results = [ConnectivityResult.none];
    }

    return _updateConnectionStatus(results);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results)
  async{
    setState(() {
      internetConnection= results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);

      _isCheckingConnection =false;

    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {

    initConnectivity();
    _connectivitySubscription=Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    getPrices();


    super.initState();
  }






  final PaymobService _paymobService = PaymobService();

  String iframeUrl = '';

  int? subscriptionDuration;

  int? monthly,quarterly,yearly;

  getPrices()async{
    await FirebaseFirestore.instance.collection('plans').doc('monthly').get().then((v){
      monthly=v.data()!['android'];

    });

    await FirebaseFirestore.instance.collection('plans').doc('quarterly').get().then((v){
      quarterly=v.data()!['android'];
    });
    await FirebaseFirestore.instance.collection('plans').doc('yearly').get().then((v){
      yearly=v.data()!['android'];
    });

    setState(() {
    });

  }





  Future<void> initiatePayment(String subscriptionType) async {
    if(subscriptionType == 'monthly'){
      subscriptionDuration=30;
    }
    else if(subscriptionType == 'quarterly')
      {
        subscriptionDuration=90;
      }
    else if(subscriptionType == 'yearly')
      {
        subscriptionDuration=365;
      }
    try {



      final authToken = await _paymobService.getAuthToken();
      print("auth token is:" + authToken);
      final orderId =
          await _paymobService.createOrder(authToken, subscriptionType,monthly!,quarterly!,yearly!);
      final amountCents = subscriptionType == 'monthly'
          ? '${monthly.toString()}'
          : subscriptionType == 'quarterly'
              ? '${quarterly.toString()}'
              : '${yearly.toString()}';
      final paymentKey = await _paymobService.generatePaymentKey(
          authToken, orderId, int.parse(amountCents));

      setState(() {
        iframeUrl =
            'https://accept.paymob.com/api/acceptance/iframes/725859?payment_token=${paymentKey}';
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void onPaymentSuccess() async{
    switch (subscriptionDuration){
      case 30:


        Timestamp currentDate=Timestamp.now();
        Timestamp endDate=convertStringToTimestamp(BlocProvider.of<GetUserDataCubit>(context).userModel!.endTime!);
        bool isEndTimePass=hasTimestampPassed(endDate);

        if(isEndTimePass)
          {

            // end time pass
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
            {"endTime":getTimestampAfterMonths(1),
             "startTime": currentDate
            }).whenComplete((){

          UserModel currentUser = getCurrentUser()!;
          currentUser.startTime=convertTimestampToString(currentDate);
          currentUser.endTime=convertTimestampToString(getTimestampAfterMonths(1));
          currentUser.save();
          BlocProvider.of<GetUserDataCubit>(context).getUserData();
          saveUserData(currentUser);




          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        });
          }else{
          // this when user want to extend plan (click on extend plan on drawer)
          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
              {"endTime":addMonths(endDate.toDate(), 1),
                "startTime": currentDate
              }).whenComplete((){

            UserModel currentUser = getCurrentUser()!;
            currentUser.startTime=convertTimestampToString(currentDate);
            currentUser.endTime=convertTimestampToString(addMonths(endDate.toDate(), 1));
            currentUser.save();
            BlocProvider.of<GetUserDataCubit>(context).getUserData();
            saveUserData(currentUser);




            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          });

        }


        break;

      case 90:
        Timestamp currentDate=Timestamp.now();

        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
            {"endTime":getTimestampAfterMonths(3),
              "startTime": currentDate
            }).whenComplete((){
          UserModel currentUser = getCurrentUser()!;
          currentUser.startTime=convertTimestampToString(currentDate);
          currentUser.endTime=convertTimestampToString(getTimestampAfterMonths(3));
          currentUser.save();
          BlocProvider.of<GetUserDataCubit>(context).getUserData();
          saveUserData(currentUser);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        });
        break;

      case 365:
        Timestamp currentDate=Timestamp.now();

        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
            {"endTime":getTimestampAfterMonths(12),
              "startTime": currentDate
            }).whenComplete((){

          UserModel currentUser = getCurrentUser()!;
          currentUser.startTime=convertTimestampToString(currentDate);
          currentUser.endTime=convertTimestampToString(getTimestampAfterMonths(12));
          currentUser.save();
          BlocProvider.of<GetUserDataCubit>(context).getUserData();
          saveUserData(currentUser);



          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        });
        break;

    }

  }

  void onPaymentFailure() {
    // Handle payment failure logic

    print('Payment failed!');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {

        if(_isCheckingConnection)
          {
            return const Center(child: CircularProgressIndicator());
          }
        else{

          if(internetConnection)
            {
              return  Scaffold(
                backgroundColor: Colors.blue[50],
                appBar: AppBar(
                    backgroundColor: Colors.blue[50],
                    title: Text('Subscription Screen')),
                body: iframeUrl.isEmpty
                    ? Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if(hasTimestampPassed(convertStringToTimestamp(BlocProvider.of<GetUserDataCubit>(context).userModel!.endTime!)))
                        const Text('Your subscription has expired'),
                        const SizedBox(height: 20,),
                        const Text(
                          "Available Plans",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        monthly==null?
                            CircularProgressIndicator():
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SubscriptionCard(
                              planName: "Monthly",
                              price: ((monthly!.toDouble()) / 100.0),
                              duration: "30 Days",
                              onSubscribe: () => initiatePayment('monthly')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SubscriptionCard(
                              planName: "Quarterly",
                              price: 250.00,
                              duration: "90 Days",
                              onSubscribe: () => initiatePayment('quarterly')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SubscriptionCard(
                              planName: "Yearly",
                              price: 800.00,
                              duration: "1 Year",
                              onSubscribe: () => initiatePayment('yearly')),
                        ),
                      ],
                    ),
                  ),
                )
                    : InAppWebView(
                    initialUrlRequest:
                    URLRequest(url: WebUri.uri(Uri.parse(iframeUrl))),
                    onLoadStop: (controller, url) async {
                      print(
                          ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" +
                              url.toString());

                      if (url.toString().contains('success=true')) {
                        // Payment was successful
                        onPaymentSuccess();
                      } else if (url.toString().contains('success=false')) {
                        print(url);
                        // Payment failed
                        onPaymentFailure();
                      }
                    }),
              );
            }
          else{
            return Scaffold(
              appBar: AppBar(title: Text("No Internet Connection"),),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text("Your subscription has expired and there is no internet connection .check your internet connection and subscribe now",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ),
              ),
            );
          }

        }


      }
    );
  }
}
