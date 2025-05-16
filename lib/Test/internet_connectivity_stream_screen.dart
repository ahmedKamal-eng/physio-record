
import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  bool internetConnection = false;
  bool _isCheckingConnection = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription=Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

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



   void _retryConnection(){
    initConnectivity();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test'),),
      body: Builder(builder: (BuildContext context){
        if(_isCheckingConnection)
          {
            return const Center(child: CircularProgressIndicator());
          }
        else
          {
            return internetConnection ? Center(child: Text("Connected"),):Center(child: Text("Not Connected"),);
          }
      }),

    );
  }
}
