import 'dart:async';

import 'package:earthquake_app/core/components/appbar/custom_app_bar.dart';
import 'package:earthquake_app/core/components/distance/custom_distance_calculate.dart';
import 'package:earthquake_app/features/model/earthquake.dart';
import 'package:earthquake_app/features/model/earthquake_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart' as location;
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_map/components/cameraUpdate.dart';
import 'package:huawei_map/components/components.dart';
import 'package:huawei_map/map.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late HuaweiMapController mapController;
  late LatLng _latLng = LatLng(41.012959, 28.997438);
  late List<Earthquake?>? response;

  final PermissionHandler _permissionHandler = PermissionHandler();
  final FusedLocationProviderClient _locationProviderClient =
      FusedLocationProviderClient();

  Set<Marker> markers = {};
  BitmapDescriptor? _markerIcon;
  int earthQuakeCount = 10;

  @override
  void initState() {
    requestPermission();
    getData();
    super.initState();
  }

  requestPermission() async {
    bool hasPermission = await _permissionHandler.hasLocationPermission();
    if (!hasPermission) {
      try {
        bool status = await _permissionHandler.requestLocationPermission();
        print("Is permission granted $status");
      } catch (e) {
        print(e.toString());
      }
    }
    bool backgroundPermission =
        await _permissionHandler.hasBackgroundLocationPermission();
    if (!backgroundPermission) {
      try {
        bool backStatus =
            await _permissionHandler.requestBackgroundLocationPermission();
        print("Is background permission granted $backStatus");
      } catch (e) {
        print(e.toString);
      }
    }
    try {
      bool requestLocStatus =
          await _permissionHandler.requestLocationPermission();
      print("Is request location permission granted $requestLocStatus");
    } catch (e) {
      print(e.toString);
    }
  }

  Future<EarthquakeResponseData> getData() async {
    final response = await http.get(Uri.parse(
        'https://api.orhanaydogdu.com.tr/deprem/live.php?limit=$earthQuakeCount'));
    return EarthquakeResponseData.fromJson(response.body);
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Recent Earthquakes',
      ),
      body: _earthquakeScreenBody,
      floatingActionButton: _floatingActionButton,
    );
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      await BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/marker.png')
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  Container get _earthquakeScreenBody => Container(
        child: Column(
          children: [
            _createHuaweiMap,
            Expanded(
              flex: 2,
              child: _instantEarthquakeLists,
            )
          ],
        ),
      );

  Expanded get _createHuaweiMap => Expanded(
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 3)),
              child: HuaweiMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _latLng,
                  zoom: 10,
                ),
                onClick: (location) {
                  _addMarker();
                },
                mapType: MapType.normal,
                tiltGesturesEnabled: true,
                buildingsEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: true,
                rotateGesturesEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                trafficEnabled: true,
                minMaxZoomPreference: MinMaxZoomPreference(0, 10),
                markers: markers,
              ),
            )),
      );

  void _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  void _addMarker() {
    String markerId = "${_latLng.lat}-${_latLng.lng}";
    Marker marker = new Marker(
      markerId: MarkerId(markerId),
      position: _latLng,
      infoWindow: InfoWindow(
        title: 'Title',
        snippet: 'Desc: $markerId',
      ),
      clickable: true,
      onClick: () {
        print("Marker clicked: $markerId");
      },
      icon: _markerIcon!,
    );

    setState(() {
      markers.add(marker);
    });
  }

  FutureBuilder<EarthquakeResponseData> get _instantEarthquakeLists =>
      FutureBuilder<EarthquakeResponseData>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return _showCircularProgressWhileWaitingForDataReturn;
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return _listViewBuilder(snapshot);
              }
          }
        },
      );

  Center get _showCircularProgressWhileWaitingForDataReturn => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Datas are loading...'),
            SizedBox(
              height: 50,
            ),
            CircularProgressIndicator(),
          ],
        ),
      );

  ListView _listViewBuilder(AsyncSnapshot<EarthquakeResponseData> snapshot) {
    return ListView.builder(
        itemCount: snapshot.data!.result!.length,
        itemBuilder: (context, index) {
          response = snapshot.data!.result;
          Earthquake? item = response![index];

          return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: _inkWell(item, context, index));
        });
  }

  Widget _inkWell(Earthquake? item, BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        location.Location currentLocation =
            await _locationProviderClient.getLastLocation();
        LatLng myLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);

        setState(() {
          _latLng = myLocation;
        });
        double distance = Haversine.haversine(
            myLocation.lat, myLocation.lng, item!.lat, item.lng);
        if (distance < 500) {
          ScaffoldMessenger.of(context).showSnackBar(_snackBar(item, distance));
        }

        _latLng = LatLng(item.lat!, item.lng!);
        CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(_latLng, 18);
        mapController.animateCamera(cameraUpdate);
      },
      child: _listTile(index, item),
    );
  }

  SnackBar _snackBar(Earthquake item, double distance) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        "Earthquake ${item.title} is $distance  kilometers away from you.",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
            color: Colors.purple),
      ),
    );
  }

  ListTile _listTile(int index, Earthquake? item) {
    return ListTile(
      leading: Text(
        (index + 1).toString(),
        style: TextStyle(fontSize: 18),
      ),
      title: Text(
        item!.title!,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      trailing: Text(
        item.mag.toString(),
        style: TextStyle(fontSize: 16),
      ),
      subtitle: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          item.date!,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  FloatingActionButton get _floatingActionButton => FloatingActionButton(
        onPressed: () {
          setState(() {
            earthQuakeCount += 5;
          });
        },
        backgroundColor: Colors.purple,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      );
}
