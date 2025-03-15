// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/api_access/api_service.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/checkIn_checkOut/checkin/capture_screen.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/constants.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/home2.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/responsive.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/utils/dialogs.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:jiffy/jiffy.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:slider_button/slider_button.dart';
// import 'package:unique_identifier/unique_identifier.dart';
// import 'dart:convert' as convert;

// class CheckinPreviewScreen extends StatefulWidget {
//   const CheckinPreviewScreen({super.key, required this.image});

//   final File image;

//   @override
//   _CheckinPreviewScreenState createState() => _CheckinPreviewScreenState();
// }

// class _CheckinPreviewScreenState extends State<CheckinPreviewScreen>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   String locationAddress = "";
//   String locationId = "";
//   double locationDistance = 0.0;
//   Position? _currentPosition;
//   SharedPreferences? _storage;
//   double lat = 0.0;
//   double long = 0.0;
//   dynamic userObj = new Map<String, String>();
//   String date = "";
//   String time = "";
//   String name = "";
//   String actionText = "Slide to check-in";
//   late var timer2;

//   @override
//   void setState(fn) {
//     if (mounted) {
//       super.setState(fn);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getSharedPrefs();
//     WidgetsBinding.instance.addObserver(this);
//     if (mounted)
//       timer2 = new Timer.periodic(
//         Duration(microseconds: 10),
//         (_) => setState(() {
//           time = Jiffy.now().format(pattern: "hh:mm:ss a");
//         }),
//       );
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     timer2.cancel();
//     super.dispose();
//   }

//   Future<void> getSharedPrefs() async {
//     _storage = await SharedPreferences.getInstance();
//     await getUserCurrentPosition();

//     userObj = jsonDecode(_storage!.getString('user_data')!);
//     if (mounted) {
//       setState(() {
//         name = userObj["FirstName"] + " " + userObj["LastName"];
//       });
//     }

//     locationId = _storage!.getString('LocationId') ?? "";
//     locationDistance = _storage!.getDouble('LocationDistance') ?? 0.0;
//     setState(() {
//       date = Jiffy.now().yMMMMd;
//     });
//   }

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

//   Future<bool> handleLocationPermssion() async {
//     bool serviceEnabled;
//     LocationPermission permisision;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       showOkDialog2(
//         context,
//         "Enable Location Service",
//         "Please enable location service before trying this operation",
//         Icon(
//           Icons.warning,
//           color: Colors.red,
//           size: 50,
//         ),
//         switchOnLocation,
//       );

//       return false;
//     }
//     permisision = await Geolocator.checkPermission();
//     if (permisision == LocationPermission.denied) {
//       permisision = await Geolocator.requestPermission();
//       if (permisision == LocationPermission.denied) {
//         showOkDialog2(
//           context,
//           "Enable Location Service",
//           "Location permission was denied. Please enable location service before trying this operation.",
//           Icon(
//             Icons.warning,
//             color: Colors.red,
//             size: 50,
//           ),
//           switchOnLocation,
//         );
//         return false;
//       }
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

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) {
//             return CheckinCaptureScreen();
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
//                 Container(
//                   alignment: Alignment.center,
//                   height: size.height,
//                   width: size.width,
//                   child: Container(
//                     height: size.height * 0.64,
//                     width: size.width,
//                     child: Image.file(
//                       scale: 1,
//                       widget.image,
//                       filterQuality: FilterQuality.high,
//                       fit: BoxFit.fitHeight,
//                       alignment: Alignment.center,
//                       repeat: ImageRepeat.noRepeat,
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
//                                 ? 22
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
//                                 ? 22
//                                 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: normalTextColor,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // CAMERA CAPTURE UTTON
//                 Positioned(
//                     bottom: Responsive.isMobileSmall(context)
//                         ? 5
//                         : Responsive.isMobileMedium(context) ||
//                                 Responsive.isMobileLarge(context)
//                             ? 10
//                             : Responsive.isTabletPortrait(context)
//                                 ? 10
//                                 : 7,
//                     right: 10,
//                     child: ClipOval(
//                       child: Material(
//                         color: actionBtnColor, // button color
//                         child: InkWell(
//                           splashColor: Colors.grey, // inkwell color
//                           child: SizedBox(
//                             width: Responsive.isMobileSmall(context)
//                                 ? 50
//                                 : Responsive.isMobileMedium(context) ||
//                                         Responsive.isMobileLarge(context)
//                                     ? 60
//                                     : Responsive.isTabletPortrait(context)
//                                         ? 80
//                                         : 80,
//                             height: Responsive.isMobileSmall(context)
//                                 ? 50
//                                 : Responsive.isMobileMedium(context) ||
//                                         Responsive.isMobileLarge(context)
//                                     ? 60
//                                     : Responsive.isTabletPortrait(context)
//                                         ? 80
//                                         : 80,
//                             child: Icon(
//                               Icons.camera_alt_outlined,
//                               color: Colors.white,
//                               size: Responsive.isMobileSmall(context) ||
//                                       Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 30
//                                   : 40,
//                             ),
//                           ),
//                           onTap: () async {
//                             if (!mounted)
//                               return;
//                             else
//                               Navigator.pushAndRemoveUntil(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => CheckinCaptureScreen(),
//                                 ),
//                                 (route) => false,
//                               );
//                           },
//                         ),
//                       ),
//                     )),
//                 // DEVICE LOCATION
//                 Positioned(
//                   bottom: Responsive.isMobileSmall(context)
//                       ? 65
//                       : Responsive.isMobileMedium(context)
//                           ? 75
//                           : Responsive.isMobileLarge(context)
//                               ? 90
//                               : Responsive.isTabletPortrait(context)
//                                   ? 95
//                                   : 88,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
//                     color: Colors.white24,
//                     child: new Row(
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
//                           child: Text(
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
//                 // SLIDER BUTTON
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
//                   child: locationAddress != ""
//                       ? SliderButton(
//                           width: Responsive.isMobileSmall(context)
//                               ? 230
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 240
//                                   : Responsive.isTabletPortrait(context)
//                                       ? MediaQuery.of(context).size.width * 0.4
//                                       : MediaQuery.of(context).size.width *
//                                           0.28,
//                           height: Responsive.isMobileSmall(context) ||
//                                   Responsive.isMobileMedium(context) ||
//                                   Responsive.isMobileLarge(context)
//                               ? 60
//                               : Responsive.isTabletPortrait(context)
//                                   ? 80
//                                   : 70,
//                           action: () {
//                             try {
//                               saveAction(widget.image.path,
//                                   userObj['FaceCheckAccuracy'], "No");
//                             } catch (e) {
//                               print(e);
//                             }
//                           },
//                           label: Text(
//                             actionText,
//                             style: TextStyle(
//                               color: Color(0xff4a4a4a),
//                               fontWeight: FontWeight.w500,
//                               fontSize: Responsive.isMobileSmall(context)
//                                   ? 18
//                                   : Responsive.isMobileMedium(context) ||
//                                           Responsive.isMobileLarge(context)
//                                       ? 20
//                                       : 25,
//                             ),
//                             textAlign: TextAlign.left,
//                           ),
//                           icon: Icon(
//                             Icons.keyboard_arrow_right,
//                             color: Colors.blue,
//                             size: 50.0,
//                             semanticLabel: '',
//                           ),
//                         )
//                       : CircularProgressIndicator(),
//                 ),
//                 // ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void saveAction(imagePath, accuracy, hignAccuracy) async {
//     showProgressDialog(context);
//     String? uniqueID = await await UniqueIdentifier.serial;
//     MultipartRequest request = MultipartRequest(
//       'POST',
//       Uri.parse(
//           'http://icheck-face-recognition-stelacom.us-east-2.elasticbeanstalk.com/api/recognize'),
//     );

//     request.files.add(
//       await MultipartFile.fromPath(
//         'file',
//         File(imagePath).path,
//         contentType: MediaType('application', 'png'),
//       ),
//     );
//     var now = new DateTime.now();
//     request.fields['year'] = now.year.toString();
//     request.fields['month'] = now.month.toString();
//     request.fields['day'] = now.day.toString();
//     request.fields['hour'] = now.hour.toString();
//     request.fields['minute'] = now.minute.toString();
//     request.fields['second'] = now.second.toString();
//     request.fields['name'] = userObj["Id"];
//     request.fields['userId'] = userObj["Id"];
//     request.fields['customerId'] = userObj["CustomerId"];
//     request.fields['phoneId'] = uniqueID!;
//     request.fields['deviceId'] = uniqueID;
//     request.fields['action'] = 'checkin';
//     request.fields['lat'] = lat.toString();
//     request.fields['long'] = long.toString();
//     request.fields['itemId'] = '';
//     request.fields['address'] = locationAddress;
//     request.fields['data1'] = '';
//     request.fields['data2'] = '';
//     request.fields['data3'] = '';
//     request.fields['data4'] = '';
//     request.fields['highAccuracy'] = hignAccuracy;
//     request.fields['accuracy'] = accuracy.toString();
//     request.fields['LocationId'] = locationId;
//     request.fields['LocationDistance'] = locationDistance.toString();
//     StreamedResponse r = await request.send();

//     print(r.statusCode);

//     closeDialog(context);
//     if (r.statusCode == 200) {
//       await getSuccessAttendanceConfirmationDialog(
//         context,
//         "",
//         Jiffy.now().format(pattern: "EEEE") + ", " + Jiffy.now().yMMMMd,
//         Jiffy.now().format(pattern: "hh:mm:ss a"),
//         "Check In",
//         userObj["ProfileImage"],
//         userObj["FirstName"] +
//             " " +
//             (userObj["LastName"] != null ? userObj["LastName"] : ""),
//         "Checkin successfully registered",
//         okRecognition,
//       ).then((val) {});
//     } else if (r.statusCode == 1001) {
//       var dialogResult = await showAlertDialog(
//         context,
//         'No images identified in the image',
//         'Error occured',
//         'failed',
//         null,
//         false,
//       );
//       print(dialogResult);
//     } else {
//       r.stream.transform(utf8.decoder).join().then((String content) async {
//         print("content $content");

//         if (content.indexOf('people matched') > 0) {
//           await showAlertDialog2(
//             context,
//             'Sorry, we cannot find any faces that match your face image. Please try another image.',
//             'No Matching Faces Detected.!',
//             MdiIcons.faceRecognition,
//             'failed',
//             reTryRecognition,
//             true,
//             moveToCheckinCamera,
//           );
//         } else if (content.indexOf('There are no faces') > 0 ||
//             content.indexOf('Error occurred') > 0 ||
//             content.indexOf('Could not find any faces') > 0 ||
//             content.indexOf('list index out of range') > 0) {
//           await showAlertDialog2(
//             context,
//             'Could not find any faces in the image. Please try another image.',
//             'No Faces Detected.!',
//             MdiIcons.faceRecognition,
//             'failed',
//             reTryRecognition,
//             true,
//             moveToCheckinCamera,
//           );
//         } else {
//           showServerErrorAlert(
//             context,
//             'Something went wrong with the connection to the server. Please make sure your internet connection is enabled, or if the issue still persists, please contact ICheck.',
//             'Error Occured!',
//             MdiIcons.serverNetwork,
//             'failed',
//             null,
//             true,
//             moveToCheckinCamera,
//           );
//         }
//       });
//     }
//   }

//   void okRecognition() {
//     closeDialog(context);
//     updateLastCheckDataInLocalStorage();
//   }

//   void reTryRecognition() {
//     closeDialog(context);
//     saveAction(widget.image.path, userObj['FaceCheckReTryAccuracy'], "Yes");
//   }

//   void moveToCheckinCamera() {
//     closeDialog(context);
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) {
//         return CheckinCaptureScreen();
//       }),
//     );
//   }

//   void updateLastCheckDataInLocalStorage() async {
//     try {
//       showProgressDialog(context);
//       String userId = userObj['Id'];
//       String customerId = userObj['CustomerId'];

//       print("userId $userId");
//       print("customerId $customerId");
//       var response =
//           await ApiService.getTodayCheckInCheckOut(userId, customerId);

//       print("resposne " + response.body);
//       if (response != null && response.statusCode == 200) {
//         dynamic item = convert.jsonDecode(response.body);
//         print("item $item");

//         if (item != null) {
//           _storage!.setString('last_check_in', convert.jsonEncode(item));
//         }
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) {
//         //     return Home();
//         //   }),
//         // );
//         closeDialog(context);
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Home2(),
//           ),
//           (route) => false,
//         );
//       } else {
//         response.stream.transform(utf8.decoder).join().then((String content) {
//           if (content.indexOf('people matched') > 0) {
//             showAlertDialog(
//                 context,
//                 'Sorry, we can not find any faces match with your face image. Please try another image',
//                 'Error occured',
//                 'failed',
//                 reTryRecognition,
//                 true);
//           } else {
//             showAlertDialog(
//                 context,
//                 'Something went wrong with the connection to the server. Please make sure your internet connection is enabled, or if the issue still persists, please contact ICheck.',
//                 'Error occured',
//                 'failed',
//                 null,
//                 false);
//           }
//         });
//         closeDialog(context);
//       }
//     } catch (ex) {
//       closeDialog(context);
//       showAlertDialog(context, 'Face verification failed. Please try again.',
//           'Error', 'failed', null, false);
//     }
//   }
// }
