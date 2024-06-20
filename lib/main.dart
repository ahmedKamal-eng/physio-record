import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physio_record/AddRecordScreen/AddRecordCubit/add_record_cubit.dart';
import 'package:physio_record/HomeScreen/FetchAllRecord/fetch_record_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/patient_record.dart';
import 'Splash/splash_screen.dart';
import 'global_vals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  await Hive.initFlutter();
  // var box= await Hive.openBox('patient_records');

  Hive.registerAdapter(PatientRecordAdapter());
  Hive.registerAdapter(FollowUpAdapter());
  await Hive.openBox<PatientRecord>('patient_records');

  var patient = Hive.box<PatientRecord>("patient_records");
  //final patientRecordsBox = Hive.box<PatientRecord>('patient_records');

  // patient.clear();
  //
  // if(patient.isEmpty) {
  //   for (var p in patients) {
  //     await patient.add(p);
  //   }
  // }
  //

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AddRecordCubit()),
          BlocProvider(create: (context) => FetchRecordCubit()),
        ],
        child: MaterialApp(
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
          themeMode: ThemeMode.system, // Use system theme mode (light or dark)
          home: const SplashScreen(),
        ));
  }
}
