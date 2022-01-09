import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  Widget build(BuildContext context) {
    _checkLocation();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FlutterMap(
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
      ),
    );
  }

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

      location.onLocationChanged.listen((LocationData currentLocation) {
        print(
            "_MyHomePageState_TAG: checkLocation: currentLocation: ${currentLocation.latitude}, ${currentLocation.longitude}");
        setState(() {

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
    } catch (e) {
      print("_MyHomePageState_TAG: _checkLocation: getLocation: $e");
    }
  }
}
