
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatelessWidget {



  const FriendScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Doctor Friends"),),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('friends').snapshots(),
        builder: (context,snapshot)
        {
          if (snapshot.hasError) {
            return Text("something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(itemBuilder: (context,index){
            return  Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 60,
                        backgroundImage:NetworkImage(snapshot.data!.docs[index]['image']),
                      ),
                    SizedBox(width: 30,),
                    Column(
                      children: [
                        Text(snapshot.data!.docs[index]['name'],style: Theme.of(context).textTheme.headlineMedium,),
                        Text(snapshot.data!.docs[index]['medicalSpecialization'])
                      ],
                    )
                  ],
                ),
              ),
            );
          },itemCount: snapshot.data!.docs.length,);
        }
        ,
      ),


    );
  }
}
