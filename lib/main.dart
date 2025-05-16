// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:physio_record/AddDoctorToCenter/AddDoctorToCenterCubit/add_doctor_to_center_cubit.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/AddToFriendScreen/AddToFriendCubit/add_to_friend_cubit.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/HiveService/hive_service.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/JoiningRequestScreen/AcceptJoiningRequestCubit/accept_joining_request_cubit.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_cubit.dart';
import 'package:physio_record/ShareRequestScreen/AcceptRequestCubit/accept_request_cubit.dart';
import 'package:physio_record/Test/fancy_design/fancy_design.dart';
import 'package:physio_record/global_vals.dart';
import 'package:physio_record/widgets/LogoutCubit/logout_cubit.dart';
import 'AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'Cubits/DeleteSharedRecordFromLocal/delete_shared_record_cubit.dart';
import 'SearchForDoctorsScreen/ShareRecordCubit/share_record_cubit.dart';
import 'models/patient_record.dart';
import 'Splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getTimeAfterXMonth(time: DateTime.now(), x: 9);
  await Firebase.initializeApp();


  await Hive.initFlutter();
  // var box= await Hive.openBox('patient_records');

  Hive.registerAdapter(PatientRecordAdapter());
  Hive.registerAdapter(FollowUpAdapter());
  Hive.registerAdapter(UserModelAdapter());
  var recordBox = await Hive.openBox<PatientRecord>('patient_records');
  HiveService.initializeHive();

  print(recordBox.values.length);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AddRecordCubit()),
          BlocProvider(create: (context) => FetchRecordCubit()),
          BlocProvider(create: (context) => AddFollowUpCubit()),
          BlocProvider(create: (context) => EditRecordCubit()),
          BlocProvider(create: (context) => LogoutCubit()),
          BlocProvider(create: (context) => GetUserDataCubit()),
          BlocProvider(create: (context) => ShareRecordCubit()),
          BlocProvider(create: (context) => AcceptRequestCubit()),
          BlocProvider(create: (context) => DeleteSharedRecordCubit()),
          BlocProvider(create: (context) => AddDoctorToCenterCubit()),
          BlocProvider(create: (context) => AcceptJoiningRequestCubit()),
          BlocProvider(create: (context) => AddToFriendCubit(),),
        ],
        child: MyApp(),
      ),

      // const MyApp()
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final providers = [EmailAuthProvider(),GoogleProvider(clientId: clientId)];
    return MaterialApp(
      // routes: {
      //   '/sign-in': (context) {
      //     return SignInScreen(
      //       providers: providers,
      //       actions: [
      //         AuthStateChangeAction<SignedIn>((context, state) {
      //           Navigator.pushReplacementNamed(context, '/profile');
      //         }),
      //       ],
      //     );
      //   },
      //   "/":(context)=>SplashScreen(),
      //   '/profile': (context) {
      //     return ProfileScreen(
      //       providers: providers,
      //       actions: [
      //         SignedOutAction((context) {
      //           Navigator.pushReplacementNamed(context, '/sign-in');
      //         }),
      //       ],
      //     );
      //   },
      // },

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.blue,
        //   iconTheme: IconThemeData(color: Colors.white)
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: TextStyle(color: Colors.white),
                backgroundColor: Colors.blue,
                elevation: 5)),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        // iconButtonTheme: IconButtonThemeData(
        //   style:IconButton.styleFrom(
        //     foregroundColor: Colors.blue
        //   ),
        // ),

        // Define your light theme here
        brightness: Brightness.light,
        // Other theme properties like colors, fonts, etc.
        // ...
      ),
      darkTheme: ThemeData(
        // Define your dark theme here
        brightness: Brightness.dark,
        // Other theme properties for dark mode
        // ...
      ),
      themeMode: ThemeMode.light, // Use system theme mode (light or dark)
      // initialRoute:  '/',
      home: SplashScreen(),
      // home: PatientListScreen(),
      // home: SubscriptionScreen(),
      // home: TestScreen(),
    );
  }
}
