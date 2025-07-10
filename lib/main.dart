import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:physio_record/AddDoctorToCenter/AddDoctorToCenterCubit/add_doctor_to_center_cubit.dart';
import 'package:physio_record/Cubits/GetUserDataCubit/get_user_data_cubit.dart';
import 'package:physio_record/HiveService/hive_service.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:physio_record/JoiningRequestScreen/AcceptJoiningRequestCubit/accept_joining_request_cubit.dart';
import 'package:physio_record/RecordDetailsScreen/EditRecordCubit/edit_record_cubit.dart';
import 'package:physio_record/ShareRequestScreen/AcceptRequestCubit/accept_request_cubit.dart';
import 'package:physio_record/widgets/LogoutCubit/logout_cubit.dart';
import 'AddFollowUpItem/AddFollowUpCubit/add_follow_up_cubit.dart';
import 'Cubits/DeleteSharedRecordFromLocal/delete_shared_record_cubit.dart';
import 'SearchForDoctorsScreen/ShareRecordCubit/share_record_cubit.dart';
import 'Test/CleanArchitecture/weatherApp/presentation/screens/weather_screen.dart';
import 'models/patient_record.dart';
import 'Splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(PatientRecordAdapter());
  Hive.registerAdapter(FollowUpAdapter());
  Hive.registerAdapter(UserModelAdapter());
  var recordBox = await Hive.openBox<PatientRecord>('patient_records');
  await Hive.openBox<UserModel>('currentUser');
  await Hive.openBox<UserModel>(HiveService.userBoxName);
  HiveService.initializeHive();

  print(recordBox.values.length);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(

      //test
      // MaterialApp(
      //   debugShowCheckedModeBanner: false,
      //   home: WeatherScreen(),
      // )
      // end text

      MultiBlocProvider(
        providers: [
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

    return MaterialApp(


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
