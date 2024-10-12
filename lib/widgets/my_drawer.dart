import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:physio_record/ShareRequestScreen/share_request_screen.dart';
import 'package:physio_record/SharedRecordScreen/shared_record_secreen.dart';
import 'package:physio_record/SubmittedRequestsScreen/submitted_requests_screen.dart';
import 'package:physio_record/models/patient_record.dart';
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
  late UserModel userModel;

  @override
  void initState() {
    userModel = BlocProvider.of<GetUserDataCubit>(context).userModel!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.teal,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userModel.imageUrl),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            userModel.userName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 4,),
          Text(
            userModel.email,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            height: 70,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(
                  Icons.person,
                  size: 30,
                )
              ],
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
                  Icon(
                    Icons.message_rounded,
                    size: 30,
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
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SubmittedRequestsScreen()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SharedRecordScreen()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shared Records",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Icon(
                    Icons.folder_shared,
                    size: 30,
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
                    "Your Doctor Friends",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Icon(
                    Icons.group_rounded,
                    size: 30,
                  )
                ],
              ),
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add to friends",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(
                  Icons.person_search,
                  size: 30,
                )
              ],
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
                                    onPressed: () {
                                      BlocProvider.of<LogoutCubit>(context)
                                          .logOut()
                                          .whenComplete(() {
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
                  )
                ],
              ),
            ),
          ),
          Divider(
            thickness: 2,
          ),
        ],
      ),
    );
  }
}
