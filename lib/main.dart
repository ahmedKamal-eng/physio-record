// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/HomeScreen/home_screen.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_cubit.dart';
import 'package:physio_record/global_vals.dart';

import 'AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'models/patient_record.dart';
import 'Splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getTimeAfterXMonth(time: DateTime.now(), x: 9);
  await Firebase.initializeApp();

  // final appDocumentDirectory = await getApplicationDocumentsDirectory();

  await Hive.initFlutter();
  // var box= await Hive.openBox('patient_records');

  Hive.registerAdapter(PatientRecordAdapter());
  Hive.registerAdapter(FollowUpAdapter());
  var recordBox = await Hive.openBox<PatientRecord>('patient_records');
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
      themeMode: ThemeMode.dark, // Use system theme mode (light or dark)
      // initialRoute:  '/',
      home: SplashScreen(),
      // home: TestScreen(),
    );
  }
}
