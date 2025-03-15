import 'dart:io';
import 'package:icheck_android/home/home_screen.dart';
import 'package:icheck_android/no_permisisons.dart';
import 'package:icheck_android/providers/appstate_provieder.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Enroll/code_verification.dart';

final navigatorKey = GlobalKey<NavigatorState>();
List<CameraDescription> cameras = <CameraDescription>[];

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();
  // await FirebaseApi().initNotifications();

  cameras = await availableCameras();

  Map<Permission, PermissionStatus> permissions = await [
    Permission.camera,
    Permission.location,
  ].request();

  HttpOverrides.global = new PostHttpOverrides();

  if ((permissions[Permission.camera] == PermissionStatus.granted ||
          permissions[Permission.camera] == PermissionStatus.restricted ||
          permissions[Permission.camera] ==
              PermissionStatus.permanentlyDenied) &&
      (permissions[Permission.location] == PermissionStatus.granted ||
          permissions[Permission.location] == PermissionStatus.restricted ||
          permissions[Permission.location] ==
              PermissionStatus.permanentlyDenied)) {
    SharedPreferences storage = await SharedPreferences.getInstance();

    runApp(
      ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),
          home: MyApp(storage),
        ),
      ),
    );
  } else {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: NoPermissionGranted(),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  SharedPreferences storage;
  MyApp(this.storage);
  @override
  Widget build(BuildContext context) {
    String? employeeCode = storage.getString('employee_code');
    bool? isGoToHomeScreen = storage.getBool('userInHomeScreen');

    if (employeeCode == null || employeeCode == '') {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ICheck',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CodeVerificationScreen(),
      );
    } else if (isGoToHomeScreen == false || isGoToHomeScreen == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ICheck',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CodeVerificationScreen(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ICheck',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(index2: 0),
        // routes: {
        //   HomeScreen.route: (context) => HomeScreen(index2: 0),
        //   Leaves.route: (context) => Leaves(
        //         index3: 0,
        //         user: null,
        //       ),
        // },
      );
    }
  }
}
