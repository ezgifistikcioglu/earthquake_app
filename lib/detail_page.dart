import 'dart:async';

import 'package:earthquake_app/custom_app_bar.dart';
import 'package:earthquake_app/distance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_map/components/cameraUpdate.dart';
import 'package:huawei_map/components/components.dart';
import 'package:huawei_map/map.dart';
import 'earthquake_response.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  HuaweiMapController mapController;
  LatLng latLng;
  List<Earthquake> response;
  Set<Marker> markers = {};
  BitmapDescriptor _markerIcon;
  PermissionHandler permissionHandler;
  FusedLocationProviderClient locationProviderClient;
  int earthQuakeCount = 10;

  @override
  void initState() {
    permissionHandler = PermissionHandler();
    requestPermission();
    locationProviderClient = FusedLocationProviderClient();
    getData();
    super.initState();
  }

  void _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  requestPermission() async {
    bool hasPermission = await permissionHandler.hasLocationPermission();
    if (!hasPermission) {
      try {
        bool status = await permissionHandler.requestLocationPermission();
        print("Is permission granted $status");
      } catch (e) {
        print(e.toString());
      }
    }
    bool backgroundPermission =
        await permissionHandler.hasBackgroundLocationPermission();
    if (!backgroundPermission) {
      try {
        bool backStatus =
            await permissionHandler.requestBackgroundLocationPermission();
        print("Is background permission granted $backStatus");
      } catch (e) {
        print(e.toString);
      }
    }
    try {
      bool requestLocStatus =
          await permissionHandler.requestLocationPermission();
      print("Is request location permission granted $requestLocStatus");
    } catch (e) {
      print(e.toString);
    }
  }


  Future<EartquakeResponseData> getData() async {
    final response = await http.get(
        'https://api.orhanaydogdu.com.tr/deprem/live.php?limit=$earthQuakeCount');
    return eartquakeResponseDataFromJson(response.body);
  }

  void addMarker() {
    String markerId = "${latLng.lat}-${latLng.lng}";
    Marker marker = new Marker(
      markerId: MarkerId(markerId),
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Title',
        snippet: 'Desc: $markerId',
      ),
      clickable: true,
      onClick: () {
        print("Marker clicked: $markerId");
      },
      icon: _markerIcon,
    );

    setState(() {
      markers.add(marker);
    });
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/marker.png')
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: "Recent Earthquakes",
      ),
      body: Container(
        child: Column(
          children: [
            // Create HuaweiMap
            Expanded(
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: latLng != null
                      ? Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.purple, width: 3)),
                          child: HuaweiMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: latLng,
                              zoom: 10,
                            ),
                            onClick: (location) {
                              addMarker();
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
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.purple,
                          ),
                        )),
            ),
            Expanded(
              flex: 2,
              child: FutureBuilder<EartquakeResponseData>(
                future: getData(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
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
                      break;
                    default:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data.result.length,
                            itemBuilder: (context, index) {
                              response = snapshot.data.result;
                              Earthquake item = response[index];

                              return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 5),
                                  child: InkWell(
                                    onTap: () async {
                                      Location currentLocation =
                                          await locationProviderClient
                                              .getLastLocation();
                                      LatLng myLocation = LatLng(
                                          currentLocation.latitude,
                                          currentLocation.longitude);

                                      setState(() {
                                        latLng = myLocation;
                                      });
                                      if (myLocation != null) {
                                        double distance = Haversine.haversine(
                                            myLocation.lat,
                                            myLocation.lng,
                                            item.lat,
                                            item.lng);
                                        if (distance < 500) {
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                                backgroundColor: Colors.black,
                                            content: Text(
                                                "Earthquake ${item.title} is $distance  kilometers away from you.",
                                                 style: TextStyle( fontSize: 18,fontWeight: FontWeight.bold, backgroundColor: Colors.white, color:Colors.purple ),),
                                          ));
                                        }
                                      }

                                      latLng = LatLng(item.lat, item.lng);
                                      CameraUpdate cameraUpdate =
                                          CameraUpdate.newLatLngZoom(
                                              latLng, 18);
                                      mapController.animateCamera(cameraUpdate);
                                    },
                                    child: ListTile(
                                      leading: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      title: Text(
                                        item.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      trailing: Text(
                                        item.mag.toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          item.date,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ));
                            });
                      }
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            earthQuakeCount += 5;
          });
        },
        backgroundColor: Colors.purple,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
