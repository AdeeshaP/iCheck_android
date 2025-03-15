import 'dart:async';
import 'package:icheck_android/Visits/capture_screen.dart';
import 'package:icheck_android/attendance-dashboard/dashboard.dart';
import 'package:icheck_android/checkin-checkout/checkin_capture_screen.dart';
import 'package:icheck_android/checkin-checkout/checkout_capture_screen.dart';
import 'package:icheck_android/enroll/code_verification.dart';
import 'package:icheck_android/constants.dart';
import 'package:icheck_android/menu/help.dart';
import 'package:icheck_android/profile/profile_home.dart';
import 'package:icheck_android/providers/appstate_provieder.dart';
import 'package:icheck_android/providers/loxcation_provider.dart';
import 'package:icheck_android/responsive.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icheck_android/menu/about_us.dart';
import 'package:icheck_android/menu/terms_conditions.dart';
import 'package:icheck_android/utils/custom_error_dialog.dart';
import 'package:icheck_android/utils/dialogs.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../api_access/api_service.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../location_restrictions/validate_location.dart';
import '../main.dart';
import '../menu/contact_us.dart';
import '../leaves_screen/leaves.dart';
import 'package:intl/intl.dart';
import 'package:app_version_update/app_version_update.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.index2}) : super(key: key);

  final int index2;

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  String employeeCode = "";
  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> forthTabNavKey = GlobalKey<NavigatorState>();
  CupertinoTabController? tabController;
  int ix = 0;
  String userData = "";
  AppState appState = AppState();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    appState = Provider.of<AppState>(context, listen: false);
    getSharedPrefs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    _storage = await SharedPreferences.getInstance();

    _storage.setBool('userInHomeScreen', true);

    userData = _storage.getString('user_data')!;
    employeeCode = _storage.getString('employee_code') ?? "";

    userObj = jsonDecode(userData);

    setState(() {
      ix = widget.index2;
    });

    if (mounted) {
      appState.checkIsSupervsor(userData);
    }

    tabController = CupertinoTabController(initialIndex: ix);

    getSupervisorLeaveRequests();
  }

// ----------------ADD HERE THE FACE LIVENESS DETECTION KBY-AI PLUGIIN init() method---------------

  // GET All the leave requests from supervisor

  Future<void> getSupervisorLeaveRequests() async {
    Map<String, dynamic> userObj3 = jsonDecode(userData);
    var response = await ApiService.getIndividualSupervisorLeaveRequests(
        userObj3["CustomerId"], userObj3["Id"]);
    var response2 = await ApiService.getGroupSupervisorLeaveRequests(
        userObj3["CustomerId"], userObj3["Id"]);

    if (response.statusCode == 200 &&
        response.body != "null" &&
        response2.statusCode == 200 &&
        response2.body != "null") {
      if (mounted) {
        appState.updateSupervisorRequests(
          jsonDecode(response.body),
          jsonDecode(response2.body),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listOfKeys = [
      firstTabNavKey,
      secondTabNavKey,
      thirdTabNavKey,
      forthTabNavKey
    ];

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return !await listOfKeys[tabController!.index].currentState!.maybePop();
      },
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          List homeScreenList = [
            Dashboard(index3: widget.index2),
            AttendacneDashboardScreen(
              user: userObj,
              index3: widget.index2,
            ),
            Leaves(
              user: userObj,
              index3: widget.index2,
              requestAvailable: appState.requestAvailable,
            ),
            ProfileScreen(user: userObj, index3: widget.index2),
          ];
          return CupertinoTabScaffold(
            controller: tabController,
            tabBar: CupertinoTabBar(
              backgroundColor: Colors.red.shade50,
              height: Responsive.isMobileSmall(context)
                  ? 45
                  : Responsive.isMobileMedium(context)
                      ? 50
                      : Responsive.isMobileLarge(context)
                          ? 60
                          : Responsive.isTabletPortrait(context)
                              ? 65
                              : 70,
              activeColor: numberColors,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.window,
                      size: Responsive.isMobileSmall(context)
                          ? 30
                          : Responsive.isMobileMedium(context)
                              ? 32
                              : Responsive.isMobileLarge(context)
                                  ? 35
                                  : Responsive.isTabletPortrait(context)
                                      ? 37
                                      : 37,
                      color: iconColors,
                    ),
                    icon: Icon(
                      Icons.window_rounded,
                      size: Responsive.isMobileSmall(context)
                          ? 23
                          : Responsive.isMobileMedium(context)
                              ? 25
                              : Responsive.isMobileLarge(context)
                                  ? 29
                                  : Responsive.isTabletPortrait(context)
                                      ? 35
                                      : 33,
                      color: Colors.grey[700],
                    ),
                    label: "Dashboard"),
                BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.people,
                      size: Responsive.isMobileSmall(context)
                          ? 30
                          : Responsive.isMobileMedium(context)
                              ? 32
                              : Responsive.isMobileLarge(context)
                                  ? 35
                                  : Responsive.isTabletPortrait(context)
                                      ? 37
                                      : 37,
                      color: iconColors,
                    ),
                    icon: Icon(
                      Icons.people,
                      size: Responsive.isMobileSmall(context)
                          ? 23
                          : Responsive.isMobileMedium(context)
                              ? 25
                              : Responsive.isMobileLarge(context)
                                  ? 29
                                  : Responsive.isTabletPortrait(context)
                                      ? 35
                                      : 33,
                      color: Colors.grey[700],
                    ),
                    label: "Attendance"),
                BottomNavigationBarItem(
                    activeIcon: appState.isSupervisor &&
                            appState.requestAvailable == true
                        ? Badge(
                            smallSize: 7,
                            child: Icon(
                              Icons.calendar_month,
                              size: Responsive.isMobileSmall(context)
                                  ? 30
                                  : Responsive.isMobileMedium(context)
                                      ? 32
                                      : Responsive.isMobileLarge(context)
                                          ? 35
                                          : Responsive.isTabletPortrait(context)
                                              ? 37
                                              : 37,
                              color: iconColors,
                            ),
                          )
                        : Icon(
                            Icons.calendar_month,
                            size: Responsive.isMobileSmall(context)
                                ? 30
                                : Responsive.isMobileMedium(context)
                                    ? 32
                                    : Responsive.isMobileLarge(context)
                                        ? 35
                                        : Responsive.isTabletPortrait(context)
                                            ? 37
                                            : 37,
                            color: iconColors,
                          ),
                    icon: appState.isSupervisor &&
                            appState.requestAvailable == true
                        ? Badge(
                            smallSize: 7,
                            child: Icon(
                              Icons.calendar_month,
                              size: Responsive.isMobileSmall(context)
                                  ? 23
                                  : Responsive.isMobileMedium(context)
                                      ? 25
                                      : Responsive.isMobileLarge(context)
                                          ? 29
                                          : Responsive.isTabletPortrait(context)
                                              ? 35
                                              : 33,
                              color: Colors.grey[700],
                            ),
                          )
                        : Icon(
                            Icons.calendar_month,
                            size: Responsive.isMobileSmall(context)
                                ? 23
                                : Responsive.isMobileMedium(context)
                                    ? 25
                                    : Responsive.isMobileLarge(context)
                                        ? 29
                                        : Responsive.isTabletPortrait(context)
                                            ? 35
                                            : 33,
                            color: Colors.grey[700],
                          ),
                    label: "Leave"),
                BottomNavigationBarItem(
                    activeIcon: Icon(
                      Icons.person,
                      size: Responsive.isMobileSmall(context)
                          ? 30
                          : Responsive.isMobileMedium(context)
                              ? 32
                              : Responsive.isMobileLarge(context)
                                  ? 35
                                  : Responsive.isTabletPortrait(context)
                                      ? 37
                                      : 37,
                      color: iconColors,
                    ),
                    icon: Icon(
                      Icons.person,
                      size: Responsive.isMobileSmall(context)
                          ? 23
                          : Responsive.isMobileMedium(context)
                              ? 25
                              : Responsive.isMobileLarge(context)
                                  ? 29
                                  : Responsive.isTabletPortrait(context)
                                      ? 35
                                      : 33,
                      color: Colors.grey[700],
                    ),
                    label: "Profile"),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoTabView(
                navigatorKey: listOfKeys[index],
                builder: (context) {
                  return homeScreenList[index];
                },
              );
            },
          );
        },
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  Dashboard({super.key, required this.index3});

  final int index3;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  late SharedPreferences _storage;
  Map<String, dynamic>? userObj;
  Map<String, dynamic>? lastCheckIn;
  String workedTime = "";
  late DateTime? lastCheckInTime;
  String employeeCode = "";
  VersionStatus? versionstatus;
  DateTime? NOTIFCATION_POPUP_DISPLAY_TIME;
  String inTime = "";
  String outTime = "";
  String attendanceId = "";
  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  late AppState appState;
  String formattedDuration = "";
  String formattedDate = "";
  String formattedInTime = "";
  String formattedOutTime = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    appState = Provider.of<AppState>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);
    getSharedPrefs();

    Timer.periodic(Duration(milliseconds: 200), (timer) {
      appState.updateOfficeDate(
          Jiffy.now().format(pattern: "EEEE") + ", " + Jiffy.now().yMMMMd);
      appState.updateOfficeTime(Jiffy.now().format(pattern: "hh:mm:ss a"));
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      updateWorkTime();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    await getVersionStatus();

    _storage = await SharedPreferences.getInstance();
    String? userData = _storage.getString('user_data');
    employeeCode = _storage.getString('employee_code') ?? "";

    if (userData == null) {
      await loadUserData();
    } else {
      userObj = jsonDecode(userData);

      if (mounted) appState.updateOfficeAddress(userObj!["OfficeAddress"]);
      await loadLastCheckIn();
    }

    await getLeavesAttendanceNotifcations();

    if (versionstatus != null) {
      Future.delayed(Duration(seconds: 2), () async {
        _verifyVersion();
      });
    }
  }

  // LEAVES NOTIFICATION //

  Future<void> getLeavesAttendanceNotifcations() async {
    String userId = userObj!["Id"];
    String? dt = _storage.getString('lastTimePopupDisplay');

    DateTime popupShownTime = dt == null ? DateTime.now() : DateTime.parse(dt);

    var response = await ApiService.getLeaves(
      userId,
      Jiffy.parseFromDateTime(DateTime(DateTime.now().year, 1, 1))
          .format(pattern: "yyyy-MM-dd"),
      Jiffy.parseFromDateTime(DateTime(DateTime.now().year, 12, 31))
          .format(pattern: "yyyy-MM-dd"),
    );
    List<dynamic> allLeaves = jsonDecode(response.body);

    print("all leaves $allLeaves");

    String todayDay = DateFormat('EEEE').format(DateTime.now());
    DateTime twentyFourHoursAgo = DateTime.now()
        .subtract(Duration(hours: todayDay == "Monday" ? 96 : 24));

    List<dynamic> approvedOrRejectedLeaves = dt == null
        ? allLeaves
            .where((leave) =>
                (leave['Status'] == 'Approved' ||
                    leave['Status'] == 'Rejected') &&
                (DateTime.parse(leave['LastModifiedDate'])
                        .isBefore(DateTime.now()) &&
                    DateTime.parse(leave['LastModifiedDate'])
                        .isAfter(twentyFourHoursAgo)))
            .toList()
        : allLeaves
            .where((leave) =>
                (leave['Status'] == 'Approved' ||
                    leave['Status'] == 'Rejected') &&
                (DateTime.parse(leave['LastModifiedDate'])
                        .isBefore(DateTime.now()) &&
                    DateTime.parse(leave['LastModifiedDate'])
                        .isAfter(popupShownTime)))
            .toList();

    if (approvedOrRejectedLeaves.length > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 8.0,
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 25),
            contentPadding: EdgeInsets.fromLTRB(4, 2, 4, 0),
            scrollable: true,
            title: Padding(
              padding: EdgeInsets.only(bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                      child: Icon(
                        Icons.notifications_on,
                        color: iconColors,
                        size: Responsive.isMobileSmall(context)
                            ? 21
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 25
                                : Responsive.isTabletPortrait(context)
                                    ? 31
                                    : 30,
                      ),
                      alignment: Alignment.center),
                  SizedBox(width: 7),
                  Text(
                    'Leave Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: screenHeadingColor,
                      fontSize: Responsive.isMobileSmall(context)
                          ? 16
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 19
                              : Responsive.isTabletPortrait(context)
                                  ? 25
                                  : 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (approvedOrRejectedLeaves.isNotEmpty) ...[
                  for (var leave in approvedOrRejectedLeaves)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cardColros,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: boxBgColor,
                                child: Icon(
                                  EvaIcons.alertCircle,
                                  color: Colors.deepOrange.shade400,
                                  size: Responsive.isMobileSmall(context)
                                      ? 23
                                      : Responsive.isMobileMedium(context) ||
                                              Responsive.isMobileLarge(context)
                                          ? 25
                                          : Responsive.isTabletPortrait(context)
                                              ? 30
                                              : 30,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        leave['IsFullday'] == 1
                                            ? DateTime.parse(
                                                        leave['LeaveDate']) !=
                                                    DateTime.parse(
                                                        leave['ToDate'])
                                                ? "Your full day leave for ${DateFormat('yyyy-MM-dd').format(DateTime.parse(leave['LeaveDate']))} - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(leave['ToDate']))} was ${leave['Status'].toLowerCase()}."
                                                : "your full day leave for ${DateFormat('yyyy-MM-dd').format(DateTime.parse(leave['LeaveDate']))} was ${leave['Status'].toLowerCase()}."
                                            : "Your half day leave for ${DateFormat('yyyy-MM-dd').format(DateTime.parse(leave['LeaveDate']))} was ${leave['Status'].toLowerCase()}.",
                                        style: TextStyle(
                                          color: normalTextColor,
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
                                              ? 12.5
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? 13.4
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? 16
                                                      : 15,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Jiffy.parse(leave['LastModifiedDate'])
                                          .format(pattern: "dd/MM/yyyy"),
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 10.7
                                            : Responsive.isMobileMedium(
                                                        context) ||
                                                    Responsive.isMobileLarge(
                                                        context)
                                                ? 11.8
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 15
                                                    : 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
            actions: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context) ||
                                Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 14
                            : Responsive.isTabletPortrait(context)
                                ? 17
                                : 16,
                        fontWeight: FontWeight.w700,
                        color: actionBtnTextColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionBtnColor,
                      fixedSize: Size(110, 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {
                      _storage.setString(
                          'lastTimePopupDisplay', DateTime.now().toString());
                      setState(() {
                        NOTIFCATION_POPUP_DISPLAY_TIME = DateTime.now();
                      });
                      print(
                          "POPUP OK PRESSED TIME $NOTIFCATION_POPUP_DISPLAY_TIME");
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

// --------GET App Version Status--------------//
  Future<VersionStatus> getVersionStatus() async {
    NewVersionPlus? newVersion =
        NewVersionPlus(androidId: "com.aura.icheckapp");

    VersionStatus? status = await newVersion.getVersionStatus();
    setState(() {
      versionstatus = status;
    });
    print(newVersion);

    // if (versionstatus != null) {
    return versionstatus!;
    // }
  }

  // VERSION UPDATE

  Future<void> _verifyVersion() async {
    AppVersionUpdate.checkForUpdates(
      appleId: '1581265618',
      playStoreId: 'com.aura.icheckapp',
      country: 'us',
    ).then(
      (result) async {
        if (result.canUpdate!) {
          await AppVersionUpdate.showAlertUpdate(
            appVersionResult: result,
            context: context,
            backgroundColor: Colors.grey[100],
            title: '      Update Available',
            titleTextStyle: TextStyle(
              color: normalTextColor,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.isMobileSmall(context) ||
                      Responsive.isMobileMedium(context) ||
                      Responsive.isMobileLarge(context)
                  ? 24
                  : Responsive.isTabletPortrait(context)
                      ? 28
                      : 27,
            ),
            content:
                "You're currently using iCheck ${versionstatus!.localVersion}, but new version ${result.storeVersion} is now available on the Play Store. Update now for the latest features!",
            contentTextStyle: TextStyle(
                color: normalTextColor,
                fontWeight: FontWeight.w400,
                fontSize: Responsive.isMobileSmall(context) ||
                        Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 16
                    : Responsive.isTabletPortrait(context)
                        ? 25
                        : 24,
                height: 1.5),
            updateButtonText: 'UPDATE',
            updateTextStyle: TextStyle(
              fontSize: Responsive.isMobileSmall(context)
                  ? 14
                  : Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 16
                      : Responsive.isTabletPortrait(context)
                          ? 18
                          : 18,
            ),
            updateButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(actionBtnTextColor),
                backgroundColor: WidgetStateProperty.all(Colors.green[800]),
                minimumSize: Responsive.isMobileSmall(context)
                    ? WidgetStateProperty.all(Size(90, 40))
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? WidgetStateProperty.all(Size(100, 45))
                        : Responsive.isTabletPortrait(context)
                            ? WidgetStateProperty.all(Size(160, 60))
                            : WidgetStateProperty.all(Size(140, 50)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                )),
            cancelButtonText: 'NO THANKS',
            cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(actionBtnTextColor),
                backgroundColor: WidgetStateProperty.all(Colors.red[800]),
                minimumSize: Responsive.isMobileSmall(context)
                    ? WidgetStateProperty.all(Size(90, 40))
                    : Responsive.isMobileMedium(context) ||
                            Responsive.isMobileLarge(context)
                        ? WidgetStateProperty.all(Size(100, 45))
                        : Responsive.isTabletPortrait(context)
                            ? WidgetStateProperty.all(Size(160, 60))
                            : WidgetStateProperty.all(Size(140, 50)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                )),
            cancelTextStyle: TextStyle(
              fontSize: Responsive.isMobileSmall(context)
                  ? 14
                  : Responsive.isMobileMedium(context) ||
                          Responsive.isMobileLarge(context)
                      ? 16
                      : Responsive.isTabletPortrait(context)
                          ? 18
                          : 18,
            ),
          );
        }
      },
    );
  }

  // MOVE TO TURN ON DEVICE LOCATION

  void switchOnLocation() async {
    closeDialog(context);
    bool ison = await Geolocator.isLocationServiceEnabled();
    if (!ison) {
      await Geolocator.openLocationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return Scaffold(
            key: firstTabNavKey,
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: appbarBgColor,
              shadowColor: Colors.grey[100],
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
                  onSelected: choiceAction,
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Time and Date Section
                  Container(
                    height: 180,
                    width: size.width * 0.9,
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          appState.officeTime,
                          style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? 25
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 30
                                    : Responsive.isTabletPortrait(context)
                                        ? 35
                                        : 35,
                            fontWeight: FontWeight.bold,
                            color: screenHeadingColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          appState.officeDate,
                          style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? 16
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 18
                                    : Responsive.isTabletPortrait(context)
                                        ? 20
                                        : 22,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            appState.officeAddress,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Responsive.isMobileSmall(context)
                                  ? 14
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 15.5
                                      : Responsive.isTabletPortrait(context)
                                          ? 18
                                          : 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 20.0),
                    child: Column(
                      children: [
                        //------------- Check In Button-------------
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (lastCheckIn == null ||
                                  lastCheckIn!["OutTime"] != null) {
                                Geolocator.isLocationServiceEnabled()
                                    .then((bool serviceEnabled) {
                                  //check whether user is deactivated or not
                                  if (userObj!['Deleted'] == 0) {
                                    if (serviceEnabled) {
                                      if (userObj!['EnableLocation'] > 0) {
                                        if (userObj![
                                                'EnableLocationRestriction'] ==
                                            1) {
                                          _storage.setString(
                                              'Action', 'checkin');
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider(
                                                create: (context) =>
                                                    LocationRestrictionState(),
                                                child: ValidateLocation(
                                                  widget.index3,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider(
                                                      create: (context) =>
                                                          AppState(),
                                                      child: CheckInCapture()),
                                            ),
                                          );
                                        }
                                      } else {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChangeNotifierProvider(
                                                    create: (context) =>
                                                        AppState(),
                                                    child: CheckInCapture()),
                                          ),
                                        );
                                      }
                                    } else {
                                      Geolocator.checkPermission().then(
                                          (LocationPermission permission) {
                                        if (permission ==
                                                LocationPermission.denied ||
                                            permission ==
                                                LocationPermission
                                                    .deniedForever) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => CustomErrorDialog(
                                                title:
                                                    'Location Service Disabled.',
                                                message:
                                                    'Please enable location service before trying visit.',
                                                onOkPressed: switchOnLocation,
                                                iconData: Icons.error_outline),
                                          );
                                        } else {
                                          if (userObj!['EnableLocation'] > 0) {
                                            if (userObj![
                                                    'EnableLocationRestriction'] ==
                                                1) {
                                              _storage.setString(
                                                  'Action', 'checkin');
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChangeNotifierProvider(
                                                          create: (context) =>
                                                              LocationRestrictionState(),
                                                          child:
                                                              ValidateLocation(
                                                                  widget
                                                                      .index3)),
                                                ),
                                              );
                                            } else {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChangeNotifierProvider(
                                                          create: (context) =>
                                                              AppState(),
                                                          child:
                                                              CheckInCapture()),
                                                ),
                                              );
                                            }
                                          } else {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChangeNotifierProvider(
                                                        create: (context) =>
                                                            AppState(),
                                                        child:
                                                            CheckInCapture()),
                                              ),
                                            );
                                          }
                                        }
                                      });
                                    }
                                  } else {
                                    //Tell user that his account is deactivated
                                    showDialog(
                                      context: context,
                                      builder: (context) => CustomErrorDialog(
                                          title: 'Inactive User',
                                          message:
                                              'This user has been deactivated \nand access to this function is restricted. \nPlease contact the system administrator.',
                                          onOkPressed: () =>
                                              Navigator.of(context).pop(),
                                          iconData: Icons.no_accounts_sharp),
                                    );
                                  }
                                });
                              } else {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (lastCheckIn == null ||
                                      lastCheckIn!["OutTime"] != null)
                                  ? actionBtnColor
                                  : Color(0xFFBDBDBD),
                              foregroundColor: (lastCheckIn == null ||
                                      lastCheckIn!["OutTime"] != null)
                                  ? Colors.white
                                  : Colors.black54,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Check In',
                              style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 16
                                      : Responsive.isMobileMedium(context)
                                          ? 18
                                          : Responsive.isMobileLarge(context)
                                              ? 19
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 20
                                                  : 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // ----------Check Out Button--------------
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if ((lastCheckIn == null ||
                                  lastCheckIn!["OutTime"] != null)) {
                              } else {
                                Geolocator.isLocationServiceEnabled().then(
                                  (bool serviceEnabled) {
                                    //check whether user is deactivated or not
                                    if (userObj!['Deleted'] == 0) {
                                      if (serviceEnabled) {
                                        if (userObj!['EnableLocation'] > 0) {
                                          if (userObj![
                                                  'EnableLocationRestriction'] ==
                                              1) {
                                            _storage.setString(
                                                'Action', 'checkout');
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChangeNotifierProvider(
                                                  create: (context) =>
                                                      LocationRestrictionState(),
                                                  child: ValidateLocation(
                                                    widget.index3,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChangeNotifierProvider(
                                                        create: (context) =>
                                                            AppState(),
                                                        child:
                                                            CheckoutCapture()),
                                              ),
                                            );
                                          }
                                        } else {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider(
                                                create: (context) => AppState(),
                                                child: CheckoutCapture(),
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        Geolocator.checkPermission().then(
                                            (LocationPermission permission) {
                                          if (permission ==
                                                  LocationPermission.denied ||
                                              permission ==
                                                  LocationPermission
                                                      .deniedForever) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => CustomErrorDialog(
                                                  title:
                                                      'Location Service Disabled.',
                                                  message:
                                                      'Please enable location service before trying visit.',
                                                  onOkPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  iconData:
                                                      Icons.error_outline),
                                            );
                                          } else {
                                            if (userObj!['EnableLocation'] >
                                                0) {
                                              if (userObj![
                                                      'EnableLocationRestriction'] ==
                                                  1) {
                                                _storage.setString(
                                                    'Action', 'checkout');
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChangeNotifierProvider(
                                                      create: (context) =>
                                                          LocationRestrictionState(),
                                                      child: ValidateLocation(
                                                          widget.index3),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChangeNotifierProvider(
                                                      create: (context) =>
                                                          AppState(),
                                                      child: CheckoutCapture(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChangeNotifierProvider(
                                                    create: (context) =>
                                                        AppState(),
                                                    child: CheckoutCapture(),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        });
                                      }
                                    } else {
                                      //Tell user that his account is deactivated
                                      showDialog(
                                        context: context,
                                        builder: (context) => CustomErrorDialog(
                                            title: 'Inactive User',
                                            message:
                                                'This user has been deactivated \nand access to this function is restricted. \nPlease contact the system administrator.',
                                            onOkPressed: () =>
                                                Navigator.of(context).pop(),
                                            iconData: Icons.no_accounts_sharp),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (lastCheckIn == null ||
                                      lastCheckIn!["OutTime"] != null)
                                  ? Color(0XFFBDBDBD)
                                  : actionBtnColor,
                              foregroundColor: (lastCheckIn == null ||
                                      lastCheckIn!["OutTime"] != null)
                                  ? Colors.black54
                                  : Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Check Out',
                              style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 16
                                      : Responsive.isMobileMedium(context)
                                          ? 18
                                          : Responsive.isMobileLarge(context)
                                              ? 19
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 20
                                                  : 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        //------------ Visit Button------------------
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Geolocator.isLocationServiceEnabled()
                                  .then((bool serviceEnabled) {
                                if (userObj!['Deleted'] == 0) {
                                  if (serviceEnabled) {
                                    Navigator.of(context, rootNavigator: true)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChangeNotifierProvider(
                                                create: (context) => AppState(),
                                                child: VisitCapture()),
                                      ),
                                    );
                                  } else {
                                    Geolocator.checkPermission()
                                        .then((LocationPermission permission) {
                                      if (permission ==
                                              LocationPermission.denied ||
                                          permission ==
                                              LocationPermission
                                                  .deniedForever) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => CustomErrorDialog(
                                              title:
                                                  'Location Service Disabled.',
                                              message:
                                                  'Please enable location service before trying visit.',
                                              onOkPressed: () =>
                                                  Navigator.of(context).pop(),
                                              iconData: Icons.error_outline),
                                        );
                                      } else {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChangeNotifierProvider(
                                              create: (context) => AppState(),
                                              child: VisitCapture(),
                                            ),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                } else {
                                  //Tell user that his account is deactivated
                                  showDialog(
                                    context: context,
                                    builder: (context) => CustomErrorDialog(
                                        title: 'Inactive User',
                                        message:
                                            'This user has been deactivated \nand access to this function is restricted. \nPlease contact the system administrator.',
                                        onOkPressed: () =>
                                            Navigator.of(context).pop(),
                                        iconData: Icons.no_accounts_sharp),
                                  );
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: actionBtnColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Visit',
                              style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 16
                                      : Responsive.isMobileMedium(context)
                                          ? 18
                                          : Responsive.isMobileLarge(context)
                                              ? 19
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 20
                                                  : 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Work Time Status
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Work Time',
                          style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? 17
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 19
                                    : Responsive.isTabletPortrait(context)
                                        ? 22
                                        : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          workedTime,
                          style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? workedTime == "Not checked in yet"
                                    ? 16
                                    : 20
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? workedTime == "Not checked in yet"
                                        ? 18
                                        : 23
                                    : Responsive.isTabletPortrait(context)
                                        ? workedTime == "Not checked in yet"
                                            ? 22
                                            : 25
                                        : 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Section
                  Container(
                    margin: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: userObj != null &&
                                  userObj!["ProfileImage"] != null
                              ? userObj!["ProfileImage"] !=
                                      "https://0830s3gvuh.execute-api.us-east-2.amazonaws.com/dev/services-file?bucket=icheckfaceimages&image=None"
                                  ? NetworkImage(userObj!["ProfileImage"])
                                  : NetworkImage(
                                      "https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG.png",
                                    )
                              : NetworkImage(
                                  "https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG.png",
                                ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          userObj != null
                              ? userObj!['LastName'] != null
                                  ? userObj!["FirstName"] +
                                      " " +
                                      userObj!["LastName"]
                                  : userObj!['LastName']
                              : "",
                          style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? 18
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 20
                                    : Responsive.isTabletPortrait(context)
                                        ? 25
                                        : 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // GET the status of  the last event type (checkin or CheckoutCapture)

  void updateWorkTime() {
    if (lastCheckIn != null && lastCheckIn!["OutTime"] == null) {
      lastCheckInTime = DateTime.parse(lastCheckIn!["InTime"]);
      Duration duration = DateTime.now().difference(lastCheckInTime!);
      if (!mounted) return;

      setState(() {
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
        workedTime =
            "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
      });
    } else {
      workedTime = "Not checked in yet";
    }
  }

  // LOAD LAST CHECKIN

  Future<void> loadLastCheckIn() async {
    showProgressDialog(context);
    String userId = userObj!['Id'];
    String customerId = userObj!['CustomerId'];
    var response = await ApiService.getTodayCheckInCheckOut(userId, customerId);
    closeDialog(context);
    if (response != null && response.statusCode == 200) {
      dynamic item = jsonDecode(response.body);
      print("item $item");

      if (item != null) {
        if (item["enrolled"] == 'pending' || item["enrolled"] == null) {
          await _storage.clear();
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return MyApp(_storage);
            }),
          );
        } else if (item["Data"] == 'Yes') {
          lastCheckIn = item;
          _storage.setString('last_check_in', jsonEncode(item));
        }
      }
    }
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);

    String formattedDuration = '';

    if (hours > 0) {
      formattedDuration += '${hours.toString().padLeft(2, '0')} hr ';
    }

    if (minutes > 0) {
      formattedDuration += '${minutes.toString().padLeft(2, '0')} min ';
    }

    if (seconds > 0 || (hours == 0 && minutes == 0)) {
      formattedDuration += '${seconds.toString().padLeft(2, '0')} sec';
    }

    return formattedDuration.trim();
  }

  void noHandler() {
    closeDialog(context);
  }

  // LOAD USER DATA

  Future<void> loadUserData() async {
    showProgressDialog(context);
    var response = await ApiService.verifyUserWithEmpCode(employeeCode);
    closeDialog(context);
    if (response != null &&
        response.statusCode == 200 &&
        response.body == "NoRecordsFound") {
      await _storage.clear();
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MyApp(_storage);
          },
        ),
      );
    } else if (response != null && response.statusCode == 200) {
      userObj = jsonDecode(response.body);

      _storage.setString('user_data', response.body);
      String? lastCheckInData = _storage.getString('last_check_in');
      if (lastCheckInData == null) {
        await loadLastCheckIn();
      } else {
        lastCheckIn = jsonDecode(lastCheckInData);
      }
    }
  }

  int calculateDayDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
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
  void choiceAction(String choice) {
    if (choice == _menuOptions[0]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return HelpTwo(
            user: userObj,
            index3: 0,
          );
        }),
      );
    } else if (choice == _menuOptions[1]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AboutUs(
            user: userObj,
            index3: 0,
          );
        }),
      );
    } else if (choice == _menuOptions[2]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return ContactUs(
            user: userObj,
            index3: 0,
          );
        }),
      );
    } else if (choice == _menuOptions[3]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return TermsAndConditions(
            user: userObj,
            index3: 0,
          );
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
}
