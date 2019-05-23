import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_ui/data_model/DataEntry.dart';

class Maps extends StatefulWidget {
  //final Set<Marker> markers;
  DataEntry dataEntry;
  Maps({@required this.dataEntry});
  @override
  _MapsState createState() => _MapsState(dataEntry);
}

class _MapsState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  DataEntry _dataEntry;
  static LatLng _position;

  _MapsState(this._dataEntry) {
    _position = LatLng(_dataEntry.location.item1, _dataEntry.location.item2);
  }

  static final CameraPosition _getCameraPosition = CameraPosition(
    target: _position,
    zoom: 19.151926040649414,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _getCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId(_dataEntry.toString()),
            position: _position,
            infoWindow: InfoWindow(
              title: _dataEntry.systemName + " : " + _dataEntry.deviceId,
              snippet: _dataEntry.fieldName,
            ),
            icon: BitmapDescriptor.defaultMarker,
          )
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
