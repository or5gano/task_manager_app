import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager_app/Screens/task_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ThemeData().colorScheme.copyWith(
            primary: const Color(0xff6318AF),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: TaskTracker.id,
        routes: {
          TaskTracker.id: (context) =>  TaskTracker(),
        });
  }
}
 