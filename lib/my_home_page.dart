import 'dart:io';
import 'dart:math' show cos, sqrt, asin;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _currentPosition;

  GoogleMapController controller;
  static final CameraPosition _sabinas = CameraPosition(
    target: LatLng(27.8594592, -101.127766),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  Marker destinationMarker = Marker(
    markerId: MarkerId("destination"),
    position: LatLng(27.8420066, -101.1068363),
    infoWindow: InfoWindow(title: "Destination", snippet: "Mi casa"),
    icon: BitmapDescriptor.defaultMarker,
  );
  List<LatLng> polylineCoordinates = [];

  String title = "";

  @override
  void initState() {
    super.initState();
    _checkLocation();
    title = widget.title;
    _getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _sabinas,
        onMapCreated: (GoogleMapController controller) {
          this.controller = controller;
        },
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  void _checkLocation() async {
    //region Check Service
    try {
      print("_MyHomePageState_TAG: checkLocation: ");
      _serviceEnabled = await location.serviceEnabled();
      print(
          "_MyHomePageState_TAG: checkLocation: serviceEnabled: $_serviceEnabled");
      if (!_serviceEnabled) {
        print("_MyHomePageState_TAG: checkLocation: requestService");
        _serviceEnabled = await location.requestService();
        print(
            "_MyHomePageState_TAG: checkLocation: serviceEnabled: $_serviceEnabled");
        if (!_serviceEnabled) {
          print("_MyHomePageState_TAG: checkLocation: service not enabled");
          return;
        }
      }
    } catch (e) {
      print(
          "_MyHomePageState_TAG: _checkLocation: checkService: exception: $e");
    }
    //endregion

    //region check permissions
    try {
      print("_MyHomePageState_TAG: checkLocation: requestPermission");
      _permissionGranted = await location.hasPermission();
      print(
          "_MyHomePageState_TAG: checkLocation: permission: $_permissionGranted");
      if (_permissionGranted == PermissionStatus.denied) {
        print("_MyHomePageState_TAG: checkLocation: requestPermission 2");
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print("_MyHomePageState_TAG: checkLocation: permission not granted");
          return;
        }
      }
    } catch (e) {
      print(
          "_MyHomePageState_TAG: _checkLocation: checkPermissions: exception: $e");
    }
    //endregion

    //region settings
    try {
      location.enableBackgroundMode(enable: true);
      location.changeSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 30000,
      );

      location.onLocationChanged.listen(onCurrentLocationChanged);
    } catch (e) {
      print("_MyHomePageState_TAG: _checkLocation: settings: $e");
    }
    //endregion

    try {
      print("_MyHomePageState_TAG: _checkLocation: requestLocation");
      _currentPosition = await location.getLocation();

      print(
          "_MyHomePageState_TAG: checkLocation: locationData: ${_currentPosition.latitude}, ${_currentPosition.longitude}");

      moveToCurrentPosition();
    } catch (e) {
      print("_MyHomePageState_TAG: _checkLocation: getLocation: $e");
    }
  }

  void onCurrentLocationChanged(LocationData currentLocation) async {
    print(
        "_MyHomePageState_TAG: onCurrentLocationChanged: ${currentLocation.latitude}, ${currentLocation.longitude}");

    MarkerId markerId = MarkerId("myLocation");
    Marker marker = generateCurrentMarker(markerId);

    // Defining an ID
    /*PolylineId polylineId = PolylineId('poly');
    Polyline polyline = await generatePolyline(polylineId, marker);

    double distanceInMeters = _coordinateDistance(
      marker.position.latitude,
      marker.position.longitude,
      destinationMarker.position.latitude,
      destinationMarker.position.longitude,
    );

    String distance = distanceInMeters.toStringAsFixed(
        distanceInMeters.truncateToDouble() == distanceInMeters ? 0 : 2);

    print("_MyHomePageState_TAG: onCurrentLocationChanged: distanceInMeters: " +
        distance);*/

    setState(() {
      markers[markerId] = marker;
      // markers[destinationMarker.markerId] = destinationMarker;
      // polylines[polylineId] = polyline;

      // title = distance + " mts.";
    });
  }

  Marker generateCurrentMarker(MarkerId markerId) {
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        _currentPosition.latitude,
        _currentPosition.longitude,
      ),
      infoWindow: InfoWindow(
        title: "Current Position",
        snippet: "*",
      ),
      onTap: () => onCurrentPositionTapped,
    );
    return marker;
  }

  Future<Polyline> generatePolyline(
      PolylineId polylineId, Marker marker) async {
    PolylinePoints polylinePoints = PolylinePoints();
    String googleAPIKey = "AIzaSyDGUyD_GZaMfBuLa0Kf9b1pg1y6lRcxhCM";
    PointLatLng origin =
        PointLatLng(marker.position.latitude, marker.position.longitude);
    PointLatLng destination = PointLatLng(destinationMarker.position.latitude,
        destinationMarker.position.longitude);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      origin,
      destination,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    return polyline;
  }

  void moveToCurrentPosition() {
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
          zoom: 17,
        ),
      ),
    );
  }

  void onCurrentPositionTapped() {
    print("_MyHomePageState_TAG: onCurrentPositionTapped: ");
    moveToCurrentPosition();
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Device model: ${androidInfo.model}');
        print('Android ID: ${androidInfo.androidId}');
        print('Android UUID: ${androidInfo.id}');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Device model: ${iosInfo.utsname.machine}');
        print('Device name: ${iosInfo.name}');
        print('iOS UUID: ${iosInfo.identifierForVendor}');
      }
    } catch (e) {
      print(e);
    }
  }
}
