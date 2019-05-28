import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_ui/data_model/DataEntry.dart';

class Maps extends StatefulWidget {
  final List<DataEntry> dataEntries;
  Maps({@required this.dataEntries});
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _getCameraPosition() {
    return CameraPosition(
      target: LatLng(widget.dataEntries.first.location.latitude,
          widget.dataEntries.first.location.longitude),
      zoom: 19.151926040649414,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _getCameraPosition(),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _getMarkers()),
    );
  }

  Set<Marker> _getMarkers() {
    int id = 1;
    return widget.dataEntries
        .map((dataEntry) => Marker(
              markerId: MarkerId((id++).toString()),
              position: LatLng(
                  dataEntry.location.latitude, dataEntry.location.longitude),
              infoWindow: InfoWindow(
                title: dataEntry.systemName + " : " + dataEntry.deviceId,
                snippet: dataEntry.fieldName,
              ),
              icon: BitmapDescriptor.defaultMarker,
            ))
        .toSet();
  }
}
