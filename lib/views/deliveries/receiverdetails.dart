import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:thedeliveryguyug/views/deliveries/paymentdetails.dart';

class ReceiverDetails extends StatefulWidget {

  String pickUp, destination, packageName, destinationDesc, deliveryFee;
  double originLat, originLng, destinationLat, destinationLng, totalFare, discount;

  ReceiverDetails({this.pickUp, this.destination, this.packageName, this.destinationDesc, this.deliveryFee, this.originLat, this.originLng, this.destinationLat, this.destinationLng, this.totalFare, this.discount});

  @override
  _ReceiverDetailsState createState() => _ReceiverDetailsState();
}

final String androidKey = 'AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q';
final String iosKey = 'AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q';
final apiKey = Platform.isAndroid ? androidKey : iosKey;

String _mapStyle;

  double totalDistance = 0.0;
// Markers to show points on the map
  Map<MarkerId, Marker> markers = {}; 

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

class _ReceiverDetailsState extends State<ReceiverDetails> {
  TextEditingController receiverName = new TextEditingController();
  TextEditingController receiverPhone = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  
  // Google Maps controller
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  // Configure map position and zoom
  CameraPosition _kGooglePlex; 

  

@override
  void initState() {
    rootBundle.loadString('assets/map_style.txt').then((string) {
    _mapStyle = string;
  });

  _kGooglePlex = CameraPosition(
    target: LatLng(widget.originLat, widget.originLng),
    zoom: 12,
  ); 
    _getPolyline();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Receiver Details'),
        ),

      body: getBody(),
      
    );
  }

Widget getBody(){
   return Container(
  color: Colors.grey[300],
  height:  MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  child: SingleChildScrollView(
    child: Column(
      children: [
        Container(
          height:  MediaQuery.of(context).size.height/2.0,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                trafficEnabled: false,
                polylines: Set<Polyline>.of(polylines.values),
                markers: _createMarker(),
                onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;
                mapController.setMapStyle(_mapStyle);
            },
                  
            ),
        ),
        Container(
          margin: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
              child: Column(
              children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: receiverName,
                    keyboardType: TextInputType.text,
                    // ignore: missing_return
                        validator: (value){
                          if (value.isEmpty) {
                            return 'Receiver name is required';
                          }if (value.length < 3) {
                            return 'Enter valid name';
                          }
                        },
                      decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: ('Enter Receiver Name'),
                      labelText: ('Receiver Name'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                  ),

                  SizedBox(height:10),

                  TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: receiverPhone,
                    keyboardType: TextInputType.phone,
                    // ignore: missing_return
                        validator: (value){
                          if (value.isEmpty) {
                            return 'Phone number is required';
                          }if (value.length != 10) {
                            return 'Enter valid phone';
                          }
                          String pattern = r'((070|075|077|078|071|079|074|076|072)[0-9]{7})';
                          RegExp regExp = new RegExp(pattern);
                          if (!regExp.hasMatch(value)) {
                            return 'Enter valid  number eg (0784912802)'; 
                            }
                        },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.call),
                        hintText: ('Enter Receiver Phone'),
                        labelText: ('Receiver Phone'),
                        labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                  ),

                  SizedBox(height:10),

                  MaterialButton(
                      minWidth: double.infinity,
                      height: 55.0,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                      color: Color(0xFF3783b5),
                      textColor: Colors.white,
                      child: Text('Next'),
                      onPressed: (){

                        if (!_formKey.currentState.validate()) {
                               return; 
                        }else {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => PaymentDetails(
                              pickUp: widget.pickUp,
                              destination: widget.destination,
                              packageName: widget.packageName,
                              destinationDesc: widget.destinationDesc,
                              receiverName: receiverName.text.toString(),
                              receiverPhone: receiverPhone.text.toString(),
                              deliveryFee: widget.deliveryFee,
                              originLat: widget.originLat,
                              originLng: widget.originLng,
                              destinationLat: widget.destinationLat,
                              destinationLng: widget.destinationLng,
                              totalFare: widget.totalFare,
                              discount: widget.discount,
                            )
                              ),
                               );
                        }
                    }, 
              ),
              ],),
          ),

        ),
      ],),
    
  ),
);
}

Set<Marker> _createMarker() {
  return {
    Marker(
        markerId: MarkerId("marker_1"),
        position: LatLng(widget.originLat, widget.originLng),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Pick Up')),
    Marker(
      
      markerId: MarkerId("marker_2"),
      infoWindow: InfoWindow(title: 'Destination',),
      icon: BitmapDescriptor.defaultMarkerWithHue(90),
      position: LatLng(widget.destinationLat, widget.destinationLng),
    ),
  };
}
_addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 5,
      color: Color(0xFF3783b5),
    );
    polylines[id] = polyline;
    setState(() {
    });
  }

void _getPolyline() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(widget.originLat, widget.originLng),
      PointLatLng(widget.destinationLat, widget.destinationLng),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }
}