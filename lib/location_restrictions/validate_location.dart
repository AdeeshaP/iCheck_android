import 'dart:math';
import 'package:icheck_android/checkin-checkout/checkin_capture_screen.dart';
import 'package:icheck_android/checkin-checkout/checkout_capture_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:icheck_android/api_access/api_service.dart';
import 'package:icheck_android/constants.dart';
import 'package:icheck_android/enroll/code_verification.dart';
import 'package:icheck_android/home/home_screen.dart';
import 'package:icheck_android/menu/about_us.dart';
import 'package:icheck_android/menu/contact_us.dart';
import 'package:icheck_android/menu/help.dart';
import 'package:icheck_android/menu/terms_conditions.dart';
import 'package:icheck_android/providers/appstate_provieder.dart';
import 'package:icheck_android/providers/loxcation_provider.dart';
import 'package:icheck_android/responsive.dart';
import 'package:icheck_android/utils/custom_error_dialog.dart';
import 'package:icheck_android/utils/dialogs.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValidateLocation extends StatefulWidget {
  final int index3;

  ValidateLocation(this.index3);

  @override
  State<ValidateLocation> createState() => _ValidateLocationState();
}

class _ValidateLocationState extends State<ValidateLocation> {
  final textController = TextEditingController();
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  bool shouldShowAlert = true;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  LocationRestrictionState locationRestrictionState =
      LocationRestrictionState();
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    locationRestrictionState =
        Provider.of<LocationRestrictionState>(context, listen: false);

    getSharedPrefs();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    _storage = await SharedPreferences.getInstance();

    String? userData = _storage.getString('user_data');
    userObj = jsonDecode(userData!);
    showProgressDialog(context);
    var response = await ApiService.getAllLocationRestritions(
        userObj!["Code"], userObj!["CustomerId"]);

    if (response != null &&
        response.statusCode == 200 &&
        response.body != "null") {
      if (mounted) {
        Provider.of<LocationRestrictionState>(context, listen: false)
            .setUserLocationRestrictions(jsonDecode(response.body));
      }

      if (locationRestrictionState.userLocationRestrictions.length == 0) {
        closeDialog(context);
        String? action = _storage.getString('Action');
        _storage.setDouble('Distance', 0);
        if (action == 'checkin') {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => AppState(),
                child: CheckInCapture(),
              ),
            ),
          );
        } else if (action == 'checkout') {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => AppState(),
                child: CheckoutCapture(),
              ),
            ),
          );
        }
      }
      await checkForGeofence();
    }
  }

  checkForGeofence() async {
    _geolocatorPlatform
        .isLocationServiceEnabled()
        .then((bool firstServiceEnabled) {
      if (firstServiceEnabled) {
        _geolocatorPlatform
            .checkPermission()
            .then((LocationPermission permission) {
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            closeDialog(context);
          } else {
            getCordinates();
          }
        });
      } else {
        closeDialog(context);

        showDialog(
          context: context,
          builder: (context) => CustomErrorDialog(
            title: 'Location service disabled.',
            message: 'Please enable location service before try this operation',
            onOkPressed: switchOnLocation,
            iconData: Icons.warning,
          ),
        );
      }
    });
  }

  getCordinates() async {
    try {
      Position position = await _geolocatorPlatform.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        currentPosition = position;
      });

      var lat = position.latitude;
      var long = position.longitude;
      setState(() {
        locationRestrictionState.userLocationRestrictions.forEach((element) {
          // LatLng l1 = LatLng(lat, long);
          // LatLng l2 = LatLng(double.parse(element['InLat']),
          //     double.parse(element['InLong']));

          // num distance = d(l1, l2);
          // print("distance 1 is $distance");
          double distance2 = distanceBetweenToeLocations(lat, long,
              double.parse(element['InLat']), double.parse(element['InLong']));

          // element['Distance'] = distance - element['Radius'];
          element['Distance'] = distance2 * 1000 - element['Radius'];
          print(element['Distance']);

          if (element['Distance'] <= 0) {
            element['DistanceText'] =
                'Inside now (' + (distance2).toStringAsFixed(3) + " KM)";
          } else if (element['AllowedByPass'] == 1) {
            element['DistanceText'] =
                (element['Distance'] / 1000).toStringAsFixed(3) +
                    " KM to go (Allow by pass option enabled)";
          } else {
            element['DistanceText'] =
                (element['Distance'] / 1000).toStringAsFixed(3) +
                    " KM to go or try to enable allow by pass option";
          }
        });
      });
      closeDialog(context);
    } catch (e) {
      closeDialog(context);
      //Alert box for checking location coordinates and inform user to contact iCheck administration.

      showDialog(
        context: context,
        builder: (context) => CustomErrorDialog(
          title: 'Location checking',
          message: 'Something went wrong. Please contact iCheck administrator',
          onOkPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HomeScreen(index2: 0),
              ),
            );
          },
          iconData: Icons.warning,
        ),
      );
      print(e);
    }
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  num _haversin(double radians) => pow(sin(radians / 2), 2);

  double distanceBetweenToeLocations(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6372.8; // Earth radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final lat1Radians = _toRadians(lat1);
    final lat2Radians = _toRadians(lat2);

    final a =
        _haversin(dLat) + cos(lat1Radians) * cos(lat2Radians) * _haversin(dLon);
    final c = 2 * asin(sqrt(a));

    return r * c;
  }

  void switchOnLocation() async {
    Navigator.of(context, rootNavigator: true).pop('dialog');
    bool ison = await Geolocator.isLocationServiceEnabled();
    if (!ison) {
      //if defvice is off
      bool isturnedon = await Geolocator.openLocationSettings();
      if (isturnedon) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return HomeScreen(index2: 0);
          }),
        );
      } else {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                create: (context) => AppState(), child: CheckInCapture()),
          ),
        );
      }
    }
  }

  // SIDE MENU BAR UI
  List<String> _menuOptions = [
    'Help',
    'About Us',
    'Contact Us',
    'T & C',
    'Log Out'
  ];

  // --------- Side Menu Bar Navigation ---------- //
  void onSelect(String choice) {
    if (choice == _menuOptions[0]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return HelpTwo(user: userObj, index3: widget.index3);
        }),
      );
    } else if (choice == _menuOptions[1]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AboutUs(user: userObj, index3: widget.index3);
        }),
      );
    } else if (choice == _menuOptions[2]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return ContactUs(user: userObj, index3: widget.index3);
        }),
      );
    } else if (choice == _menuOptions[3]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return TermsAndConditions(user: userObj, index3: widget.index3);
        }),
      );
    } else if (choice == _menuOptions[4]) {
      if (!mounted)
        return;
      else {
        _storage.clear();
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CodeVerificationScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, dynamic2) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: Consumer<LocationRestrictionState>(
        builder: (context, locationRestrictionState, child) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: appbarBgColor,
              toolbarHeight: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 40
                  : Responsive.isTabletPortrait(context)
                      ? 80
                      : 90,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --------- App Logo ---------- //
                  SizedBox(
                    width: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 90.0
                        : Responsive.isTabletPortrait(context)
                            ? 150
                            : 170,
                    height: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 40.0
                        : Responsive.isTabletPortrait(context)
                            ? 120
                            : 100,
                    child: Image.asset(
                      'assets/images/iCheck_logo_2024.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: size.width * 0.25),
                  // --------- Company Logo ---------- //
                  SizedBox(
                    width: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 90.0
                        : Responsive.isTabletPortrait(context)
                            ? 150
                            : 170,
                    height: Responsive.isMobileSmall(context) ||
                            Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? 40.0
                        : Responsive.isTabletPortrait(context)
                            ? 120
                            : 100,
                    child: userObj != null
                        ? CachedNetworkImage(
                            imageUrl: userObj!['CompanyProfileImage'],
                            placeholder: (context, url) => Text("..."),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Text(""),
                  ),
                ],
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: onSelect,
                  itemBuilder: (BuildContext context) {
                    return _menuOptions.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: Responsive.isMobileSmall(context)
                                ? 15
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 17
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.025
                                        : size.width * 0.018,
                          ),
                        ),
                      );
                    }).toList();
                  },
                )
              ],
            ),
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: screenHeadingColor,
                          size: Responsive.isMobileSmall(context)
                              ? 20
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 24
                                  : Responsive.isTabletPortrait(context)
                                      ? 31
                                      : 35,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          "Location Restrictions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: screenHeadingColor,
                            fontSize: Responsive.isMobileSmall(context)
                                ? 22
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 25
                                    : Responsive.isTabletPortrait(context)
                                        ? 28
                                        : 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(""),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _buildBody(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    // if (locationRestrictionState.userLocationRestrictions.isEmpty) {
    //   return Center(
    //     child: Text('No locations found'),
    //   );
    // }

    return Container(
      height: MediaQuery.of(context).size.width * 1.54,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: locationRestrictionState.userLocationRestrictions.length,
        itemBuilder: (context, index) {
          final locationDistance = locationRestrictionState
              .userLocationRestrictions[index]['Distance'];
          final locationID =
              locationRestrictionState.userLocationRestrictions[index]['Id'];
          final allowByPass = locationRestrictionState
              .userLocationRestrictions[index]['AllowedByPass'];
          final locationName =
              locationRestrictionState.userLocationRestrictions[index]['Name'];
          final distanceText = locationRestrictionState
              .userLocationRestrictions[index]['DistanceText'];

          if (locationDistance != null && allowByPass != null) {
            if (locationRestrictionState.userLocationRestrictions
                        .where((object) =>
                            object['Distance'] > 0 &&
                            object['AllowedByPass'] == 0)
                        .length ==
                    locationRestrictionState.userLocationRestrictions.length &&
                shouldShowAlert) {
              shouldShowAlert = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => CustomErrorDialog(
                    title: 'Error!',
                    message:
                        'Sorry. The system cannot find out the location inside the assigned radius. Please contact the iCheck administrator and ask to access the system using the allow by pass option.',
                    onOkPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(index2: 0),
                        ),
                      );
                    },
                    iconData: Icons.not_listed_location,
                  ),
                );
              });
            }
          }

          // Your existing code for the list items
          // If user is inside the radius he can checkin or checkout
          return GestureDetector(
            onTap: () => _showLocationMap(context,
                locationRestrictionState.userLocationRestrictions[index]),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                border: locationDistance == null || locationDistance > 0
                    ? null
                    : Border.all(color: Colors.green, width: 2),
              ),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    allowByPass == null || allowByPass == 0
                        ? Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: locationDistance == null ||
                                      locationDistance > 0
                                  ? Colors.grey[200]
                                  : Colors.green[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              locationDistance == null || locationDistance > 0
                                  ? Icons.location_off
                                  : Icons.location_on,
                              size: Responsive.isMobileSmall(context)
                                  ? 22
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 25
                                      : Responsive.isTabletPortrait(context)
                                          ? 28
                                          : 30,
                              color: locationDistance == null ||
                                      locationDistance > 0
                                  ? Colors.grey[600]
                                  : Colors.white,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: locationDistance == null ||
                                      locationDistance > 0
                                  ? Colors.orange[200]
                                  : Colors.green[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              locationDistance == null || locationDistance > 0
                                  ? Icons.location_off
                                  : Icons.location_on,
                              size: Responsive.isMobileSmall(context)
                                  ? 22
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 25
                                      : Responsive.isTabletPortrait(context)
                                          ? 28
                                          : 30,
                              color: locationDistance == null ||
                                      locationDistance > 0
                                  ? Colors.grey[50]
                                  : Colors.white,
                            ),
                          ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationName != null ? locationName : '',
                            style: TextStyle(
                              fontSize: Responsive.isMobileSmall(context)
                                  ? 14
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 16
                                      : Responsive.isTabletPortrait(context)
                                          ? 20
                                          : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                              distanceText == null
                                  ? 'Distance checking...'
                                  : (distanceText),
                              style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 12
                                      : Responsive.isMobileMedium(context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 13
                                          : Responsive.isTabletPortrait(context)
                                              ? 18
                                              : 20,
                                  color: distanceText == null
                                      ? Colors.red
                                      : (distanceText).contains("Inside now")
                                          ? Colors.green
                                          : Colors.red)),
                        ],
                      ),
                    ),

                    // ------------ FORWARD ARROW -----------------

                    allowByPass == null || allowByPass == 0
                        ? GestureDetector(
                            onTap: () {
                              if (locationDistance > 0 &&
                                  (allowByPass == null || allowByPass == 0)) {
                                return;
                              }
                              String? action = _storage.getString('Action');
                              print("action is $action");
                              _storage.setDouble('Distance', locationDistance);
                              if (action == 'checkin') {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => CheckInCapture(),
                                  ),
                                );
                              } else if (action == 'checkout') {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutCapture(),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: locationDistance == null ||
                                        locationDistance > 0
                                    ? Colors.grey[200]
                                    : Colors.green[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                locationDistance == null || locationDistance > 0
                                    ? Icons.block
                                    : Icons.arrow_forward_ios,
                                size: Responsive.isMobileSmall(context)
                                    ? 18
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 20
                                        : Responsive.isTabletPortrait(context)
                                            ? 25
                                            : 28,
                                color: locationDistance == null ||
                                        locationDistance > 0
                                    ? Colors.grey[600]
                                    : Colors.grey[100],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _storage.setString("LocationId", locationID);
                              _storage.setDouble(
                                  "LocationDistance", locationDistance);
                              String? action = _storage.getString('Action');
                              print("action2 is $action");

                              if (action == 'checkin') {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => CheckInCapture(),
                                  ),
                                );
                              } else if (action == 'checkout') {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutCapture(),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: locationDistance == null ||
                                        locationDistance > 0
                                    ? Colors.orange[200]
                                    : Colors.green[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: Responsive.isMobileSmall(context)
                                    ? 18
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 20
                                        : Responsive.isTabletPortrait(context)
                                            ? 25
                                            : 28,
                                color: Colors.grey[100],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void okButton() {
    closeDialog(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(index2: 0),
      ),
    );
  }

  void _showLocationMap(BuildContext context, dynamic location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationMapSheet(
        location: location,
        currentPosition: currentPosition,
      ),
    );
  }
}

class _LocationMapSheet extends StatelessWidget {
  final dynamic location;
  final Position? currentPosition;

  const _LocationMapSheet({
    required this.location,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                // height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location['Name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location['DistanceText'],
                      style: TextStyle(
                        color: (location['DistanceText']).contains("Inside now")
                            ? Colors.green
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red[800],
                          size: 30,
                        ),
                        Text(
                          "Assigned Location",
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[800],
                          size: 30,
                        ),
                        Text(
                          "Your Location",
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _getCenterPosition(),
                    zoom: _getAppropriateZoomLevel(),
                  ),
                  markers: _createMarkers(),
                  circles: _createCircles(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  trafficEnabled: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    // Add target location marker
    markers.add(Marker(
      markerId: MarkerId(location['Name']),
      position: LatLng(
          double.parse(location['InLat']), double.parse(location['InLong'])),
      infoWindow: InfoWindow(
        title: location['Name'],
        snippet: '${location['Radius'] / 1000} KM radius',
      ),
    ));

    // Add current position marker
    if (currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Current Location'),
      ));
    }

    return markers;
  }

  Set<Circle> _createCircles() {
    return {
      Circle(
        circleId: CircleId(
          location['Name'],
        ),
        center: LatLng(
            double.parse(location['InLat']), double.parse(location['InLong'])),
        radius: location['Radius'],
        fillColor: (location['DistanceText']).contains("Inside now")
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        strokeColor: (location['DistanceText']).contains("Inside now")
            ? Colors.green
            : Colors.red,
        strokeWidth: 2,
      ),
    };
  }

  LatLng _getCenterPosition() {
    if (currentPosition == null) {
      return LatLng(
          double.parse(location['InLat']), double.parse(location['InLong']));
    }

    return LatLng(
      (currentPosition!.latitude + double.parse(location['InLat'])) / 2,
      (currentPosition!.longitude + double.parse(location['InLong'])) / 2,
    );
  }

  double _getAppropriateZoomLevel() {
    if (currentPosition == null) {
      return 11;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      double.parse(location['InLat']),
      double.parse(location['InLong']),
    );

    if (distanceInMeters < 100) return 17; // Very close/exact location
    if (distanceInMeters < 1000) return 15; // Within 1km
    if (distanceInMeters < 5000) return 13; // Within 5km
    if (distanceInMeters < 10000) return 12; // Within 5km
    return 9.5;
  }
}
