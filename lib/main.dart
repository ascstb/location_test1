import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Location Test Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  GoogleMapController controller;
  static final CameraPosition _sabinas = CameraPosition(
    target: LatLng(27.8594592, -101.127766),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  Widget build(BuildContext context) {
    _checkLocation();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _sabinas,
        onMapCreated: (GoogleMapController controller) {
          this.controller = controller;
        },
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }

  /*FlutterMap buildFlutterMap() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(
          _locationData?.latitude ?? 27.8594592,
          _locationData?.longitude ?? -101.1277665,
        ),
        zoom: 13.0,
      ),
      layers: [
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(
                _locationData?.latitude ?? 27.8594592,
                _locationData?.longitude ?? -101.1277665,
              ),
              builder: (ctx) => Container(
                child: FlutterLogo(),
              ),
            ),
          ],
        ),
      ],
      children: <Widget>[
        TileLayerWidget(
            options: TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'])),
        MarkerLayerWidget(
            options: MarkerLayerOptions(
          markers: [
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(
                _locationData?.latitude ?? 27.8594592,
                _locationData?.longitude ?? -101.1277665,
              ),
              builder: (ctx) => Container(
                child: FlutterLogo(),
              ),
            ),
          ],
        )),
      ],
    );
  }*/

  IconButton getLocationButton() {
    return IconButton(
      icon: Icon(Icons.location_on),
      onPressed: () => _checkLocation(),
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

      location.onLocationChanged.listen((LocationData currentLocation) async {
        print(
            "_MyHomePageState_TAG: checkLocation: currentLocation: ${currentLocation.latitude}, ${currentLocation.longitude}");

        MarkerId markerId = MarkerId("myLocation");
        Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            _locationData.latitude,
            _locationData.longitude,
          ),
          infoWindow: InfoWindow(
            title: "Current Position",
            snippet: "*",
          ),
          onTap: () => onCurrentPositionTapped,
        );

        setState(() {
          markers[markerId] = marker;
        });
      });
    } catch (e) {
      print("_MyHomePageState_TAG: _checkLocation: settings: $e");
    }
    //endregion

    try {
      print("_MyHomePageState_TAG: _checkLocation: requestLocation");
      _locationData = await location.getLocation();

      print(
          "_MyHomePageState_TAG: checkLocation: locationData: ${_locationData.latitude}, ${_locationData.longitude}");

      moveToCurrentPosition();
    } catch (e) {
      print("_MyHomePageState_TAG: _checkLocation: getLocation: $e");
    }
  }

  void moveToCurrentPosition() {
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_locationData.latitude, _locationData.longitude),
          zoom: 17,
        ),
      ),
    );
  }

  void onCurrentPositionTapped() {
    print("_MyHomePageState_TAG: onCurrentPositionTapped: ");
    moveToCurrentPosition();
  }
}
