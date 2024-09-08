


import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          SizedBox(height: 100,),

          CircleAvatar(radius: 50,),

          SizedBox(height: 100,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Profile",style: Theme.of(context).textTheme.titleLarge,),
                Icon(Icons.person,size: 30,)
              ],
            ),
          ),

          Divider(thickness: 2,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Messages",style: Theme.of(context).textTheme.titleLarge,),
                Icon(Icons.message_rounded,size: 30,)
              ],
            ),
          ),

          Divider(thickness: 2,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Shared Record",style: Theme.of(context).textTheme.titleLarge,),
                Icon(Icons.file_copy_sharp,size: 30,)
              ],
            ),
          ),

          Divider(thickness: 2,),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Favorite",style: Theme.of(context).textTheme.titleLarge,),
                Icon(Icons.favorite_border,size: 30,)
              ],
            ),
          ),

          Divider(thickness: 2,),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Search for doctors",style: Theme.of(context).textTheme.titleMedium,),
                Icon(Icons.search_off,size: 30,)
              ],
            ),
          ),

          Divider(thickness: 2,),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Logout",style: Theme.of(context).textTheme.titleLarge,),
                Icon(Icons.logout,size: 30,)
              ],
            ),
          ),

          Divider(thickness: 2,),


        ],
      ),
    );
  }
}
