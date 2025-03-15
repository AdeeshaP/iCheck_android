// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/checkIn_checkOut/checkin/preview_screen.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/constants.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/home2.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/responsive.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:camera/camera.dart';
// import 'package:facesdk_plugin/facedetection_interface.dart';
// import 'package:facesdk_plugin/facesdk_plugin.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/api_access/api_service.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/utils/dialogs.dart';
// import 'package:jiffy/jiffy.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert' as convert;
// import 'package:device_info_plus/device_info_plus.dart';

// // ignore: must_be_immutable
// class CheckinCaptureScreen extends StatefulWidget {
//   FaceDetectionViewController? faceDetectionViewController;

//   CheckinCaptureScreen({super.key});

//   @override
//   State<StatefulWidget> createState() => CheckinCaptureScreenState();
// }

// class CheckinCaptureScreenState extends State<CheckinCaptureScreen>
//     with WidgetsBindingObserver {
//   late SharedPreferences _storage;
//   double lat = 0.0;
//   double long = 0.0;
//   dynamic userObj = new Map<String, String>();
//   String date = "";
//   String time = "";
//   String name = "";
//   String locationAddress = "";
//   String locationId = "";
//   double locationDistance = 0.0;
//   // CameraController? _cameraController;
//   // Future<void>? _initializeControllerFuture;
//   CameraDescription? firstCamera;
//   Position? _currentPosition;
//   bool _regDeficeInfoPassed = false;
//   bool _deficeInfoRetrieved = false;
//   List<dynamic> registeredDevices = [];
//   String deviceModel = "";
//   String deviceVersion = "";
//   late var timer2;
//   int cameraLens1 = 1;
//   bool _frontCam = true;
//   File? imageFile2;
//   Uint8List? memoryImg;
//   double livelevel = 0;
//   String faceDetectedOnScreen = "no";
//   dynamic _faces = null;
//   double _livenessThreshold = 0.8;
//   final _facesdkPlugin = FacesdkPlugin();
//   FaceDetectionViewController? faceDetectionViewController;

//   @override
//   void setState(fn) {
//     if (mounted) {
//       super.setState(fn);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     faceRecognitionStart();
//     getSharedPrefs();
//     WidgetsBinding.instance.addObserver(this);
//     if (mounted)
//       timer2 = new Timer.periodic(
//         Duration(microseconds: 10),
//         (_) => setState(() {
//           time = Jiffy.now().format(pattern: "hh:mm:ss a");
//         }),
//       );
//     // initCamera();
//     memoryImg = null;
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     // _cameraController!.dispose();
//     timer2.cancel();
//     super.dispose();
//   }

//   Future<void> getSharedPrefs() async {
//     await getUserCurrentPosition();

//     _storage = await SharedPreferences.getInstance();

//     userObj = jsonDecode(_storage.getString('user_data')!);
//     if (mounted) {
//       setState(() {
//         name = userObj["FirstName"] + " " + userObj["LastName"];
//       });
//     }

//     bool? deficeInfoRetrieved = _storage.getBool('DeficeInfoRetrieved');
//     setState(() {
//       _deficeInfoRetrieved = deficeInfoRetrieved ?? false;
//     });
//     if (deficeInfoRetrieved == false || deficeInfoRetrieved == null) {
//       getDeviceInfo();
//     }

//     locationId = _storage.getString('LocationId') ?? "";
//     locationDistance = _storage.getDouble('LocationDistance') ?? 0.0;
//     setState(() {
//       date = Jiffy.now().yMMMMd;
//     });

//     bool? regDeficeInfoPassed = _storage.getBool('RegDeficeInfoPassed');
//     setState(() {
//       _regDeficeInfoPassed = regDeficeInfoPassed ?? false;
//     });

//     if (regDeficeInfoPassed == false || regDeficeInfoPassed == null) {
//       await getRegisteredDevicesAndPassData();
//     }
//   }

//   // Future<void> initCamera() async {
//   //   if (cameras.length > 1) {
//   //     firstCamera = cameras[1];
//   //   } else {
//   //     firstCamera = cameras.first;
//   //   }
//   //   _cameraController = CameraController(firstCamera!, ResolutionPreset.medium,
//   //       enableAudio: false);
//   //   _cameraController!.addListener(() {
//   //     setState(() {});
//   //   });
//   //   _initializeControllerFuture = _cameraController!.initialize();
//   // }

//   // MOVE TO TURN ON DEVICE LOCATION
//   void switchOnLocation() async {
//     Navigator.of(context, rootNavigator: true).pop('dialog');
//     bool ison = await Geolocator.isLocationServiceEnabled();
//     if (!ison) {
//       await Geolocator.openLocationSettings();
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) {
//           return Home2();
//         }),
//       );
//     }
//   }

//   // GET INSTALLED DEVICE INFORMATION

//   Future<void> getDeviceInfo() async {
//     if (Platform.isAndroid) {
//       final deviceInfoPlugin = DeviceInfoPlugin();

//       var androidInfo = await deviceInfoPlugin.androidInfo;
//       var androidVersion = androidInfo.version.release;
//       var androidModel = androidInfo.model;

//       setState(() {
//         deviceModel = androidModel;
//         deviceVersion = androidVersion;
//       });
//     } else if (Platform.isIOS) {
//       var iosInfo = await DeviceInfoPlugin().iosInfo;
//       var iOSversion = iosInfo.systemVersion;
//       var iOSmodel = iosInfo.model;
//       setState(() {
//         deviceModel = iOSmodel;
//         deviceVersion = iOSversion;
//       });
//     }

//     setState(() {
//       _deficeInfoRetrieved = true;
//       _storage.setBool('DeficeInfoRetrieved', _deficeInfoRetrieved);
//     });
//   }

//   // GET ALREADY REGISTRED DEVICES INFO

//   Future<void> getRegisteredDevicesAndPassData() async {
//     _storage = await SharedPreferences.getInstance();
//     userObj = jsonDecode(_storage.getString('user_data')!);
//     String userId = userObj!["Id"];
//     var response = await ApiService.getRegisteredDeviceInfo(userId);
//     var isAleardyRegistred = false;

//     if (response.statusCode == 200) {
//       registeredDevices = convert.jsonDecode(response.body);

//       for (int x = 0; x < registeredDevices.length; x++) {
//         if (registeredDevices[x]["DeviceModel"] == deviceModel &&
//             registeredDevices[x]["AndroidVersion"] == deviceVersion) {
//           isAleardyRegistred = true;
//         }
//       }
//       if (isAleardyRegistred == false) {
//         int status = 0;
//         String userId = userObj!["Code"];
//         String createdDate = "";
//         String LastModifiedDate = "";
//         String createdBy = userObj!["Code"];
//         String LastModifyBy = "";

//         var response = await ApiService.postRegisteredDeviceInfo(
//           deviceModel,
//           deviceVersion,
//           status,
//           userId,
//           createdDate,
//           LastModifiedDate,
//           createdBy,
//           LastModifyBy,
//         );

//         if (response.statusCode == 200) {
//           print("Suceessfully data passed.");
//         } else if (response.statusCode == 1001) {
//           print("Data not sent");
//         } else {
//           print("failed");
//         }
//       }
//     }
//     setState(() {
//       _regDeficeInfoPassed = true;
//       _storage.setBool('RegDeficeInfoPassed', _regDeficeInfoPassed);
//     });
//   }

//   Future<void> faceRecognitionStart() async {
//     await faceDetectionViewController?.startCamera(cameraLens1);
//   }

//   Future<void> onFaceDetected(faces) async {
//     _storage = await SharedPreferences.getInstance();
//     faceDetectedOnScreen = _storage.getString('face_appear') ?? "no";

//     if (faces != null) {
//       setState(() {
//         _faces = faces;
//       });

//       for (var fc in _faces) {
//         setState(() {
//           memoryImg = fc['faceJpg'];
//           livelevel = fc['liveness'];
//         });
//       }
//     }
//   }

//   Future<void> updateCameraLens(value) async {
//     setState(() {
//       _frontCam = value;
//     });
//   }

//   saveImage() async {
//     if (memoryImg != null &&
//         livelevel > _livenessThreshold &&
//         faceDetectedOnScreen == "yes") {
//       Random random = Random.secure();
//       int randomInt = random.nextInt(100000);

//       String appDocDirectory2 = (await getApplicationDocumentsDirectory()).path;
//       final imagePath2 = '$appDocDirectory2/xyz$randomInt.jpg';
//       imageFile2 = File(imagePath2);
//       await imageFile2!.writeAsBytes(memoryImg!);

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CheckinPreviewScreen(
//             image: imageFile2!,
//           ),
//         ),
//       );
//     } else {
//       memoryImg = null;
//       faceDetectionViewController?.stopCamera();

//       showErrorDialogOne(
//         context,
//         'Could not find any faces in the image. Please try again.',
//         'No Faces Detected.!',
//         Icons.warning,
//         'failed',
//         closePopup,
//       );
//     }
//   }

//   void closePopup() {
//     closeDialog(context);
//     faceDetectionViewController?.startCamera(cameraLens1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     // return _cameraController == null ||
//     //         (!_cameraController!.value.isInitialized)
//     //     ? new Container(
//     //         child: Column(
//     //         children: <Widget>[
//     //           SizedBox(height: size.height / 2),
//     //           Text(
//     //             "Loading...",
//     //             style: GoogleFonts.lato(
//     //               textStyle: Theme.of(context).textTheme.headlineMedium,
//     //               fontSize: 36,
//     //               fontWeight: FontWeight.w700,
//     //               color: Colors.white,
//     //             ),
//     //             textAlign: TextAlign.center,
//     //           ),
//     //         ],
//     //       ))
//     // :
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) {
//             return Home2();
//           }),
//           (route) => false,
//         );
//         return false;
//       },
//       child: Scaffold(
//         body: Column(
//           children: <Widget>[
//             Stack(
//               children: <Widget>[
//                 // Container(
//                 //   alignment: Alignment.center,
//                 //   width: size.width,
//                 //   height: size.height,
//                 //   child: Transform.scale(
//                 //     scale: 1.1,
//                 //     child: AspectRatio(
//                 //       aspectRatio: aspectRatio,
//                 //       child: FutureBuilder<void>(
//                 //         future: _initializeControllerFuture,
//                 //         builder: (context, snapshot) {
//                 //           if (snapshot.connectionState ==
//                 //               ConnectionState.done) {
//                 //             return FaceDetectionView(
//                 //               faceRecognitionViewTwoState: this,
//                 //               camLens: cameraLens1,
//                 //             );
//                 //           } else {
//                 //             return Center(
//                 //               child: CircularProgressIndicator(),
//                 //             );
//                 //           }
//                 //         },
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 Container(
//                   alignment: Alignment.center,
//                   width: size.width,
//                   height: size.height,
//                   child: Transform.scale(
//                     scale: 1.1,
//                     child: AspectRatio(
//                       aspectRatio: aspectRatio,
//                       child: FaceDetectionView(
//                         faceRecognitionViewTwoState: this,
//                         camLens: cameraLens1,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 40,
//                   left: 10,
//                   child: Container(
//                     color: Colors.white24,
//                     child: Text(
//                       date,
//                       style: TextStyle(
//                         fontSize: Responsive.isMobileSmall(context) ||
//                                 Responsive.isMobileMedium(context) ||
//                                 Responsive.isMobileLarge(context)
//                             ? 12
//                             : Responsive.isTabletPortrait(context)
//                                 ? 20
//                                 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: normalTextColor,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 65,
//                   left: 10,
//                   child: Container(
//                     color: Colors.white24,
//                     child: Text(
//                       name,
//                       style: TextStyle(
//                         fontSize: Responsive.isMobileSmall(context) ||
//                                 Responsive.isMobileMedium(context) ||
//                                 Responsive.isMobileLarge(context)
//                             ? 14
//                             : Responsive.isTabletPortrait(context)
//                                 ? 21
//                                 : 19,
//                         fontWeight: FontWeight.bold,
//                         color: normalTextColor,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 40,
//                   right: 10,
//                   child: Container(
//                     color: Colors.white24,
//                     child: Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: Responsive.isMobileSmall(context) ||
//                                 Responsive.isMobileMedium(context) ||
//                                 Responsive.isMobileLarge(context)
//                             ? 12
//                             : Responsive.isTabletPortrait(context)
//                                 ? 20
//                                 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: normalTextColor,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // CAMERA SWITCH OPTION BUTTON
//                 Positioned(
//                   top: 70,
//                   right: 10,
//                   child: ClipOval(
//                     child: Material(
//                       color: actionBtnColor, // button color
//                       child: InkWell(
//                         splashColor: Colors.white, // inkwell color
//                         child: SizedBox(
//                           width: Responsive.isMobileSmall(context)
//                               ? 48
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 56
//                                   : Responsive.isTabletPortrait(context)
//                                       ? 70
//                                       : 80,
//                           height: Responsive.isMobileSmall(context)
//                               ? 48
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 56
//                                   : Responsive.isTabletPortrait(context)
//                                       ? 70
//                                       : 80,
//                           child: Icon(
//                             Icons.switch_camera_sharp,
//                             color: Colors.white,
//                             size: Responsive.isMobileSmall(context)
//                                 ? 25
//                                 : Responsive.isMobileMedium(context) ||
//                                         Responsive.isMobileLarge(context)
//                                     ? 30
//                                     : Responsive.isTabletPortrait(context)
//                                         ? 40
//                                         : 40,
//                           ),
//                         ),
//                         onTap: () async {
//                           if (cameraLens1 == 1) {
//                             setState(() {
//                               cameraLens1 = 0;
//                               _frontCam = false;
//                             });
//                           } else {
//                             setState(() {
//                               cameraLens1 = 1;
//                               _frontCam = true;
//                             });
//                           }
//                           print("camera lens : $cameraLens1");
//                           await faceDetectionViewController
//                               ?.startCamera(cameraLens1);

//                           updateCameraLens(_frontCam);
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 // CAMERA CAPTURE BUTTON
//                 Positioned(
//                   bottom: Responsive.isMobileSmall(context)
//                       ? 5
//                       : Responsive.isMobileMedium(context) ||
//                               Responsive.isMobileLarge(context)
//                           ? 10
//                           : Responsive.isTabletPortrait(context)
//                               ? 10
//                               : 5,
//                   right: 10,
//                   child: locationAddress != ""
//                       ? ClipOval(
//                           child: Material(
//                             color: actionBtnColor, // button color
//                             child: InkWell(
//                               splashColor: Colors.grey,
//                               child: SizedBox(
//                                 width: Responsive.isMobileSmall(context)
//                                     ? 50
//                                     : Responsive.isMobileMedium(context) ||
//                                             Responsive.isMobileLarge(context)
//                                         ? 60
//                                         : 80,
//                                 height: Responsive.isMobileSmall(context)
//                                     ? 50
//                                     : Responsive.isMobileMedium(context) ||
//                                             Responsive.isMobileLarge(context)
//                                         ? 60
//                                         : 80,
//                                 child: Icon(
//                                   Icons.camera_alt_outlined,
//                                   color: Colors.white,
//                                   size: Responsive.isMobileSmall(context)
//                                       ? 26
//                                       : Responsive.isMobileMedium(context) ||
//                                               Responsive.isMobileLarge(context)
//                                           ? 30
//                                           : Responsive.isTabletPortrait(context)
//                                               ? 50
//                                               : 40,
//                                 ),
//                               ),
//                               onTap: () {
//                                 if (livelevel <= 0.0 && memoryImg != null) {
//                                   faceDetectionViewController?.stopCamera();

//                                   showErrorDialogOne(
//                                     context,
//                                     'This is not a real human face.',
//                                     'No Real Faces Detected.!',
//                                     Icons.warning,
//                                     'failed',
//                                     closePopup,
//                                   );
//                                   memoryImg = null;
//                                 } else {
//                                   saveImage();
//                                 }
//                               },
//                             ),
//                           ),
//                         )
//                       : CircularProgressIndicator(),
//                 ),

//                 // BACK BUTTON
//                 Positioned(
//                   bottom: Responsive.isMobileSmall(context)
//                       ? 5
//                       : Responsive.isMobileMedium(context) ||
//                               Responsive.isMobileLarge(context)
//                           ? 10
//                           : Responsive.isTabletPortrait(context)
//                               ? 10
//                               : 5,
//                   left: 10,
//                   child: ClipOval(
//                     child: Material(
//                       color: actionBtnColor, // button color
//                       child: InkWell(
//                         splashColor: Colors.grey, // inkwell color
//                         child: SizedBox(
//                           width: Responsive.isMobileSmall(context)
//                               ? 50
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 60
//                                   : Responsive.isTabletPortrait(context)
//                                       ? 80
//                                       : 70,
//                           height: Responsive.isMobileSmall(context)
//                               ? 50
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 60
//                                   : Responsive.isTabletPortrait(context)
//                                       ? 80
//                                       : 70,
//                           child: Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                             size: Responsive.isMobileSmall(context)
//                                 ? 26
//                                 : Responsive.isMobileMedium(context) ||
//                                         Responsive.isMobileLarge(context)
//                                     ? 30
//                                     : Responsive.isTabletPortrait(context)
//                                         ? 50
//                                         : 40,
//                           ),
//                         ),
//                         onTap: () {
//                           if (!mounted) {
//                             print("NOT MOUNTED");
//                             return;
//                           } else
//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => Home2(),
//                               ),
//                               (route) => false,
//                             );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 // DEVICE LOCATION
//                 Positioned(
//                   bottom: Responsive.isMobileSmall(context)
//                       ? 60
//                       : Responsive.isMobileMedium(context)
//                           ? 75
//                           : Responsive.isMobileLarge(context)
//                               ? 80
//                               : Responsive.isTabletPortrait(context)
//                                   ? 95
//                                   : 88,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                     color: Colors.white38,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.my_location,
//                           color: Colors.grey[900],
//                           size: Responsive.isMobileSmall(context)
//                               ? 21
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 24
//                                   : Responsive.isTabletPortrait(context)
//                                       ? 32
//                                       : 35,
//                           semanticLabel: '',
//                         ),
//                         SizedBox(width: 5),
//                         Expanded(
//                           child: AutoSizeText(
//                             locationAddress,
//                             style: TextStyle(
//                               fontSize: Responsive.isMobileSmall(context)
//                                   ? 13
//                                   : Responsive.isMobileMedium(context) ||
//                                           Responsive.isMobileLarge(context)
//                                       ? 14
//                                       : 19,
//                             ),
//                             maxLines: 2,
//                             softWrap: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _faces != null
//                     ? SizedBox(
//                         width: 300,
//                         height: 600,
//                         child: CustomPaint(
//                           painter: FacePainter(
//                               faces: _faces,
//                               livenessThreshold: _livenessThreshold),
//                         ),
//                       )
//                     : Container(
//                         decoration: BoxDecoration(
//                             color: Colors.blue, border: Border.all(width: 1)),
//                       ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> handleLocationPermssion() async {
//     bool serviceEnabled;
//     LocationPermission permisision;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       faceDetectionViewController?.stopCamera();
//       showOkDialog2(
//         context,
//         "Enable Location Service",
//         "Please enable location service before trying this operation",
//         Icon(
//           Icons.warning,
//           color: Colors.red,
//           size: Responsive.isMobileSmall(context)
//               ? 50
//               : Responsive.isMobileMedium(context) ||
//                       Responsive.isMobileLarge(context)
//                   ? 60
//                   : Responsive.isTabletPortrait(context)
//                       ? 75
//                       : 80,
//         ),
//         switchOnLocation,
//       );

//       return false;
//     }
//     permisision = await Geolocator.checkPermission();
//     if (permisision == LocationPermission.denied) {
//       permisision = await Geolocator.requestPermission();
//       if (permisision == LocationPermission.denied) {
//         faceDetectionViewController?.stopCamera();
//         showOkDialog2(
//           context,
//           "Enable Location Service",
//           "Location permission was denied. Please enable location service before trying this operation.",
//           Icon(
//             Icons.warning,
//             color: Colors.red,
//             size: Responsive.isMobileSmall(context)
//                 ? 50
//                 : Responsive.isMobileMedium(context) ||
//                         Responsive.isMobileLarge(context)
//                     ? 60
//                     : Responsive.isTabletPortrait(context)
//                         ? 75
//                         : 80,
//           ),
//           switchOnLocation,
//         );
//         return false;
//       }
//     }
//     if (permisision == LocationPermission.deniedForever) {
//       showOkDialog2(
//         context,
//         "Enable Location Service",
//         "Location permission was permanently denied. Please enable location service before trying this operation.",
//         Icon(
//           Icons.warning,
//           color: Colors.red,
//           size: Responsive.isMobileSmall(context)
//               ? 50
//               : Responsive.isMobileMedium(context) ||
//                       Responsive.isMobileLarge(context)
//                   ? 60
//                   : Responsive.isTabletPortrait(context)
//                       ? 75
//                       : 80,
//         ),
//         switchOnLocation,
//       );
//       return false;
//     }
//     return true;
//   }

//   Future<void> getUserCurrentPosition() async {
//     final hasPermission = await handleLocationPermssion();
//     if (!hasPermission) return;

//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) {
//       setState(() => _currentPosition = position);
//       placemarkFromCoordinates(
//               _currentPosition!.latitude, _currentPosition!.longitude,
//               localeIdentifier: "en-US")
//           .then((List<Placemark> placemarks) {
//         Placemark place = placemarks[0];
//         setState(() {
//           locationAddress =
//               '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
//         });
//       });
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }
// }

// // ignore: must_be_immutable
// class FaceDetectionView extends StatefulWidget
//     implements FaceDetectionInterface {
//   CheckinCaptureScreenState faceRecognitionViewTwoState;
//   int camLens;

//   FaceDetectionView(
//       {super.key,
//       required this.faceRecognitionViewTwoState,
//       required this.camLens});

//   @override
//   Future<void> onFaceDetected(faces) async {
//     await faceRecognitionViewTwoState.onFaceDetected(faces);
//   }

//   @override
//   State<StatefulWidget> createState() => _FaceDetectionViewState();
// }

// class _FaceDetectionViewState extends State<FaceDetectionView> {
//   @override
//   Widget build(BuildContext context) {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       return AndroidView(
//         viewType: 'facedetectionview',
//         onPlatformViewCreated: _onPlatformViewCreated,
//       );
//     } else {
//       return UiKitView(
//         viewType: 'facedetectionview',
//         onPlatformViewCreated: _onPlatformViewCreated,
//       );
//     }
//   }

//   void _onPlatformViewCreated(int id) async {
//     widget.faceRecognitionViewTwoState.faceDetectionViewController =
//         FaceDetectionViewController(id, widget);

//     await widget.faceRecognitionViewTwoState.faceDetectionViewController
//         ?.initHandler();

//     await widget.faceRecognitionViewTwoState._facesdkPlugin
//         .setParam({'check_liveness_level': 0});

//     await widget.faceRecognitionViewTwoState.faceDetectionViewController
//         ?.startCamera(widget.camLens);
//   }
// }

// class FacePainter extends CustomPainter {
//   dynamic faces;
//   double livenessThreshold;
//   FacePainter({required this.faces, required this.livenessThreshold});

//   @override
//   void paint(Canvas canvas, Size size) {
//     String title = "";
//     SharedPreferences _storage;

//     void setStatusOfFace(bool status) async {
//       _storage = await SharedPreferences.getInstance();

//       if (status == true) {
//         await _storage.setString("face_appear", "yes");
//       } else {
//         await _storage.setString("face_appear", "no");
//       }
//     }

//     if (faces != null) {
//       var paint = Paint();
//       paint.color = Color.fromARGB(0xff, 0xff, 0, 0);
//       paint.style = PaintingStyle.stroke;
//       paint.strokeWidth = 2;

//       for (var face in faces) {
//         double xScale = face['frameWidth'] / size.width * 0.7;
//         double yScale = face['frameHeight'] / size.height * 0.7;

//         Color color = Color.fromARGB(0xff, 0xff, 0, 0);
//         if (face['liveness'] < livenessThreshold) {
//           color = Color.fromARGB(0xff, 0xff, 0, 0);
//           title = "Not Real " + face['liveness'].toString();
//         } else {
//           setStatusOfFace(true);
//           color = Color.fromARGB(0xff, 0, 0xff, 0);
//           title = "Real " + face['liveness'].toString();
//         }

//         TextSpan span =
//             TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
//         TextPainter tp = TextPainter(
//             text: span,
//             textAlign: TextAlign.left,
//             textDirection: TextDirection.ltr);
//         tp.layout();
//         tp.paint(canvas, Offset(face['x1'] / xScale, face['y1'] / yScale - 50));

//         paint.color = color;
//         canvas.drawRect(
//             Offset(face['x1'] / xScale, face['y1'] / yScale) &
//                 Size((face['x2'] - face['x1']) / xScale,
//                     (face['y2'] - face['y1']) / yScale),
//             paint);
//       }

//       if (title != "") {
//         setStatusOfFace(true);
//       } else {
//         setStatusOfFace(false);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
