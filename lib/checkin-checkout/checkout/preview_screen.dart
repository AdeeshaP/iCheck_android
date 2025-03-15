// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/api_access/api_service.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/checkIn_checkOut/checkout/capture_screen.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/Home2.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/constants.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/responsive.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/utils/dialogs.dart';
// import 'package:auto_size_text/auto_size_text.dart';
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

// class CheckoutPreviewScreen extends StatefulWidget {
//   const CheckoutPreviewScreen({super.key, required this.image});

//   final File image;

//   @override
//   _CheckoutPreviewScreenState createState() => _CheckoutPreviewScreenState();
// }

// class _CheckoutPreviewScreenState extends State<CheckoutPreviewScreen>
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
//   String actionText = "Slide to check out";
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
//     await getUserCurrentPosition();

//     _storage = await SharedPreferences.getInstance();

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

//     return Scaffold(
//       body: new Column(
//         children: <Widget>[
//           Stack(
//             children: [
//               Container(
//                 alignment: Alignment.center,
//                 width: size.width,
//                 height: size.height,
//                 child: Container(
//                   height: size.height * 0.64,
//                   width: size.width,
//                   child: Image.file(
//                     scale: 1,
//                     widget.image,
//                     filterQuality: FilterQuality.high,
//                     fit: BoxFit.fitHeight,
//                     alignment: Alignment.center,
//                     repeat: ImageRepeat.noRepeat,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 40,
//                 left: 10,
//                 child: Container(
//                   color: Colors.white24,
//                   child: Text(
//                     date,
//                     style: TextStyle(
//                       fontSize: Responsive.isMobileSmall(context) ||
//                               Responsive.isMobileMedium(context) ||
//                               Responsive.isMobileLarge(context)
//                           ? 12
//                           : Responsive.isTabletPortrait(context)
//                               ? 22
//                               : 18,
//                       fontWeight: FontWeight.bold,
//                       color: normalTextColor,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 65,
//                 left: 10,
//                 child: Container(
//                   color: Colors.white24,
//                   child: Text(
//                     name,
//                     style: TextStyle(
//                       fontSize: Responsive.isMobileSmall(context) ||
//                               Responsive.isMobileMedium(context) ||
//                               Responsive.isMobileLarge(context)
//                           ? 14
//                           : Responsive.isTabletPortrait(context)
//                               ? 24
//                               : 19,
//                       fontWeight: FontWeight.bold,
//                       color: normalTextColor,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 40,
//                 right: 10,
//                 child: Container(
//                   color: Colors.white24,
//                   child: Text(
//                     time,
//                     style: TextStyle(
//                       fontSize: Responsive.isMobileSmall(context) ||
//                               Responsive.isMobileMedium(context) ||
//                               Responsive.isMobileLarge(context)
//                           ? 12
//                           : Responsive.isTabletPortrait(context)
//                               ? 22
//                               : 18,
//                       fontWeight: FontWeight.bold,
//                       color: normalTextColor,
//                     ),
//                   ),
//                 ),
//               ),
//               // CAMERA CAPTURE BUTTON
//               Positioned(
//                 bottom: Responsive.isMobileSmall(context)
//                     ? 5
//                     : Responsive.isMobileMedium(context) ||
//                             Responsive.isMobileLarge(context)
//                         ? 10
//                         : Responsive.isTabletPortrait(context)
//                             ? 10
//                             : 5,
//                 right: 10,
//                 child: ClipOval(
//                   child: Material(
//                     color: Colors.blue[900], // button color
//                     child: InkWell(
//                       splashColor: Colors.grey, // inkwell color
//                       child: SizedBox(
//                         width: Responsive.isMobileSmall(context)
//                             ? 50
//                             : Responsive.isMobileMedium(context) ||
//                                     Responsive.isMobileLarge(context)
//                                 ? 60
//                                 : Responsive.isTabletPortrait(context)
//                                     ? 80
//                                     : 80,
//                         height: Responsive.isMobileSmall(context)
//                             ? 50
//                             : Responsive.isMobileMedium(context) ||
//                                     Responsive.isMobileLarge(context)
//                                 ? 60
//                                 : Responsive.isTabletPortrait(context)
//                                     ? 80
//                                     : 80,
//                         child: Icon(
//                           Icons.camera_alt_outlined,
//                           color: Colors.white,
//                           size: Responsive.isMobileSmall(context)
//                               ? 20
//                               : Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 30
//                                   : 40,
//                         ),
//                       ),
//                       onTap: () async {
//                         if (!mounted)
//                           return;
//                         else
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CheckoutCaptureScreen(),
//                             ),
//                             (route) => false,
//                           );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               // DEVICE LOCATION
//               Positioned(
//                 bottom: Responsive.isMobileSmall(context)
//                     ? 65
//                     : Responsive.isMobileMedium(context)
//                         ? 75
//                         : Responsive.isMobileLarge(context)
//                             ? 90
//                             : Responsive.isTabletPortrait(context)
//                                 ? 95
//                                 : 88,
//                 left: 5,
//                 right: 0,
//                 child: Container(
//                   color: Colors.white24,
//                   child: new Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.my_location,
//                         color: Colors.grey[900],
//                         size: Responsive.isMobileSmall(context)
//                             ? 21
//                             : Responsive.isMobileMedium(context) ||
//                                     Responsive.isMobileLarge(context)
//                                 ? 24
//                                 : Responsive.isTabletPortrait(context)
//                                     ? 32
//                                     : 35,
//                         semanticLabel: '',
//                       ),
//                       SizedBox(width: 5),
//                       Expanded(
//                         child: AutoSizeText(
//                           locationAddress,
//                           style: TextStyle(
//                               fontSize: Responsive.isMobileSmall(context) ||
//                                       Responsive.isMobileMedium(context) ||
//                                       Responsive.isMobileLarge(context)
//                                   ? 14
//                                   : 19),
//                           maxLines: 2,
//                           softWrap: true,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Slider Button
//               Positioned(
//                 bottom: Responsive.isMobileSmall(context)
//                     ? 5
//                     : Responsive.isMobileMedium(context) ||
//                             Responsive.isMobileLarge(context)
//                         ? 10
//                         : Responsive.isTabletPortrait(context)
//                             ? 10
//                             : 5,
//                 left: 10,
//                 child: locationAddress != ""
//                     ? SliderButton(
//                         width: Responsive.isMobileSmall(context) ||
//                                 Responsive.isMobileMedium(context) ||
//                                 Responsive.isMobileLarge(context)
//                             ? 245
//                             : Responsive.isTabletPortrait(context)
//                                 ? MediaQuery.of(context).size.width * 0.4
//                                 : MediaQuery.of(context).size.width * 0.3,
//                         height: Responsive.isMobileSmall(context) ||
//                                 Responsive.isMobileMedium(context) ||
//                                 Responsive.isMobileLarge(context)
//                             ? 60
//                             : Responsive.isTabletPortrait(context)
//                                 ? 80
//                                 : 70,
//                         action: () {
//                           try {
//                             saveAction(widget.image.path,
//                                 userObj['FaceCheckAccuracy'], "No");
//                           } catch (e) {
//                             print(e);
//                           }
//                         },
//                         label: Text(
//                           actionText,
//                           style: TextStyle(
//                             color: Color(0xff4a4a4a),
//                             fontWeight: FontWeight.w500,
//                             fontSize: Responsive.isMobileSmall(context) ||
//                                     Responsive.isMobileMedium(context) ||
//                                     Responsive.isMobileLarge(context)
//                                 ? 20
//                                 : 25,
//                           ),
//                           textAlign: TextAlign.left,
//                         ),
//                         icon: Icon(
//                           Icons.keyboard_arrow_right,
//                           color: Colors.blue,
//                           size: 50.0,
//                           semanticLabel: '',
//                         ),
//                       )
//                     : CircularProgressIndicator(),
//               ),
//               // ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void saveAction(imagePath, accuracy, hignAccuracy) async {
//     showProgressDialog(context);
//     String? uniqueID = await UniqueIdentifier.serial;
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
//     String? lastCheckInData = _storage!.getString('last_check_in');
//     Map<String, dynamic> lastCheckIn = convert.jsonDecode(lastCheckInData!);
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
//     request.fields['action'] = 'checkout';
//     request.fields['lat'] = lat.toString();
//     request.fields['long'] = long.toString();
//     request.fields['itemId'] = lastCheckIn['Id'];
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
//     closeDialog(context);
//     if (r.statusCode == 200) {
//       await getSuccessAttendanceConfirmationDialog(
//         context,
//         "",
//         Jiffy.now().format(pattern: "EEEE") + ", " + Jiffy.now().yMMMMd,
//         Jiffy.now().format(pattern: "hh:mm:ss a"),
//         "Check Out",
//         userObj["ProfileImage"],
//         userObj["FirstName"] +
//             " " +
//             (userObj["LastName"] != null ? userObj["LastName"] : ""),
//         "Checkout successfully registered",
//         // reTryRecognition,
//         okRecognition,
//       ).then((val) {});
//     } else if (r.statusCode == 1001) {
//       var dialogResult = await showAlertDialog(
//           context,
//           'No images identified in the image',
//           'Error occured',
//           'failed',
//           null,
//           false);
//       print(dialogResult);
//     } else {
//       r.stream.transform(utf8.decoder).join().then((String content) async {
//         if (content.indexOf('people matched') > 0) {
//           // {"error": {"message": "Sorry, we can not found any people matched with your face image, try another image"}}
//           await showAlertDialog2(
//             context,
//             'Sorry, we cannot find any faces that match your face image. Please try another image.',
//             'No Matching Faces Detected.!',
//             MdiIcons.faceRecognition,
//             'failed',
//             reTryRecognition,
//             true,
//             moveToCheckoutCamera,
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
//             moveToCheckoutCamera,
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
//             moveToCheckoutCamera,
//           );
//         }
//       });
//     }
//     // } catch (ex) {
//     //   closeDialog(context);
//     //   showAlertDialog(context, 'Error occured - $ex', 'Error occured', 'failed',
//     //       null, false);
//     // }
//   }

//   void okRecognition() {
//     closeDialog(context);
//     updateLastCheckDataInLocalStorage();
//   }

//   void reTryRecognition() {
//     closeDialog(context);
//     saveAction(widget.image.path, userObj['FaceCheckReTryAccuracy'], "Yes");
//   }

//   void moveToCheckoutCamera() {
//     closeDialog(context);
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) {
//         return CheckoutCaptureScreen();
//       }),
//     );
//   }

//   void updateLastCheckDataInLocalStorage() async {
//     try {
//       showProgressDialog(context);
//       String userId = userObj['Id'];
//       String customerId = userObj['CustomerId'];
//       var response =
//           await ApiService.getTodayCheckInCheckOut(userId, customerId);

//       if (response != null && response.statusCode == 200) {
//         dynamic item = convert.jsonDecode(response.body);
//         print("item $item");
//         if (item != null) {
//           _storage!.setString('last_check_in', convert.jsonEncode(item));
//         }
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) {
//         //     return Home2();
//         //   }),
//         // );
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Home2(),
//           ),
//           (route) => false,
//         );
//       }
//       closeDialog(context);
//     } catch (ex) {
//       closeDialog(context);
//       showAlertDialog(context, 'Face verification failed. Please try again',
//           'Error', 'failed', null, false);
//     }
//   }
// }
