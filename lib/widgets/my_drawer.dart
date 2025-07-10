import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physio_record/AddToFriendScreen/add_to_friend_screen.dart';
import 'package:physio_record/JoiningRequestScreen/joining_reuest_screen.dart';
import 'package:physio_record/MedicalCenters/medical_centers_screen.dart';
import 'package:physio_record/Payment/view/subscription_screen.dart';
import 'package:physio_record/ShareRequestScreen/share_request_screen.dart';
import 'package:physio_record/SubmittedRequestsScreen/submitted_requests_screen.dart';
import 'package:physio_record/models/user_model.dart';
import 'package:physio_record/widgets/LogoutCubit/logout_cubit.dart';
import 'package:physio_record/widgets/LogoutCubit/logout_states.dart';
import '../Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import '../FriendScreen/friend_screen.dart';
import '../Splash/splash_screen.dart';



class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool isLoading = false;
  bool internetConnected = false;
  late UserModel userModel;
  List<String> friendIds = [];

  getFriendIds() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friends')
        .get()
        .then((val) {
      for (var friend in val.docs) {
        friendIds.add(friend.data()['id']);
      }
    });
  }

  @override
  void initState() {
    checkConnectivity();
    getFriendIds();
    super.initState();
  }

  checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      internetConnected = false;
      setState(() {
      });
    }else{

      if(BlocProvider.of<GetUserDataCubit>(context).userModel == null) {
        await BlocProvider.of<GetUserDataCubit>(context).getUserData();
      }
      userModel = BlocProvider.of<GetUserDataCubit>(context).userModel!;
      internetConnected = true;
      setState(() {
      });

    }

  }


  Stream<QuerySnapshot> shareRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('shareRequests')
      .snapshots();

  Stream<QuerySnapshot> joiningRequestsStream = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('joining_requests')
      .snapshots();


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue[50],
      child: internetConnected
          ? SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
            child: Column(
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 55,
                    child: CircleAvatar(
                      radius: 53,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(userModel.imageUrl),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    userModel.userName,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold,color: Colors.blue),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    userModel.email,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 4,),
                  Text(userModel.medicalSpecialization),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 2,),
                      Text("Subscription End At: "),
                      Text(userModel.endTime!,style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(onPressed: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>SubscriptionScreen()));
                  }, child: Text("Extend Plan")),
                  SizedBox(height: 25,),
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
            
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShareRequestScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Share Requests",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Stack(
                            children: [
                              Icon(
                                Icons.message_rounded,
                                size: 30,
                                color: Colors.blue,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                builder: (context, snapshot) {
                                  if(snapshot.hasData && snapshot.data!.docs.length > 0) {
                                    return Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 8,
                                          child: Text(
                                              style: TextStyle(color: Colors.white,fontSize: 10),
                                              snapshot.data!.docs.length.toString()),
                                        ),
                                      ),
                                    );
                                  }else{
                                    return Container();
                                  }
                                }, stream: shareRequestsStream,
                              ),
            
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubmittedRequestsScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Submitted Requests",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            Icons.message_outlined,
                            size: 30,
                            color: Colors.blue,
            
                          )
                        ],
                      ),
                    ),
                  ),
            
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Colleagues",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            Icons.group_rounded,
                            size: 30,
                            color: Colors.blue,
            
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      showSearch(
                          context: context,
                          delegate: AddToFriendScreen(friendIds: friendIds));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Colleague",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            Icons.person_search,
                            size: 30,
                            color: Colors.blue,
            
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>JoiningRequestScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Joining Request",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Stack(
                            children: [
                              Icon(
                                Icons.how_to_reg,
                                size: 30,
                                color: Colors.blue,
            
                              ),
                              StreamBuilder<QuerySnapshot>(
                                builder: (context, snapshot) {
                                  if(snapshot.hasData && snapshot.data!.docs.length > 0) {
                                    return Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 8,
                                          child: Text(
                                              style: TextStyle(color: Colors.white,fontSize: 10),
                                              snapshot.data!.docs.length.toString()),
                                        ),
                                      ),
                                    );
                                  }else{
                                    return Container();
                                  }
                                }, stream: joiningRequestsStream,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicalCentersScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Medical Centers",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            Icons.health_and_safety,
                            size: 30,
                            color: Colors.blue,
            
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return BlocBuilder<LogoutCubit, LogoutState>(
                                builder: (context, state) {
                              return AlertDialog(
                                title: state is LogoutLoadingState
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Text("Are you sure you want to logout"),
                                actions: state is LogoutLoadingState
                                    ? []
                                    : [
                                        ElevatedButton(
                                            onPressed: ()async {
                                             await BlocProvider.of<LogoutCubit>(
                                                      context)
                                                  .logOut()
                                                  .then((v) {
                                                Navigator.pop(context);
            
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SplashScreen(),
                                                  ),
                                                );
                                              });
                                            },
                                            child: Text("Yes")),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("No")),
                                      ],
                              );
                            });
                          });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Logout",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Icon(
                            Icons.logout,
                            size: 30,
                            color: Colors.blue,
            
                          )
                        ],
                      ),
                    ),
                  ),

                  Divider(
                    thickness: 2,
                  ),

                  const SizedBox(height: 120,),

                ],
              ),
          )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Please Check Your Internet Connection",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
            ),
    );
  }
}
