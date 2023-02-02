import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:thedeliveryguyug/views/deliveries/delivery.dart';
import 'package:flutter/services.dart' show rootBundle;

class PaymentDetails extends StatefulWidget {

  String pickUp, destination, packageName, destinationDesc, receiverName, receiverPhone, deliveryFee;
  double originLat, originLng, destinationLat, destinationLng, totalFare, discount;
  

  PaymentDetails({this.pickUp, this.destination, this.packageName, this.destinationDesc, this.receiverName, this.receiverPhone, this.deliveryFee,
  this.originLat, this.originLng, this.destinationLat, this.destinationLng, this.totalFare, this.discount});

  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
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

class _PaymentDetailsState extends State<PaymentDetails> {
  TextEditingController amountCollected = TextEditingController();
  TextEditingController deliveryFee = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final formatter = new NumberFormat("#,###");

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
        title: Text('Payment Details'),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Fee (' + widget.discount.toStringAsFixed(0) + '% Discount)', style: TextStyle(color: Colors.blue, fontSize: 10),),
                SizedBox(height:5),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey,),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monetization_on_outlined, color: Colors.grey,),
                        SizedBox(width: 10),
                      //  Text('UGX: ' + formatter.format(int.parse(widget.totalFare.toStringAsFixed(0))), style: TextStyle(decoration: TextDecoration.lineThrough),),
                        Text('UGX: ' + formatter.format(int.parse(widget.deliveryFee)), style: TextStyle(fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                  /*SizedBox(height:10),
                  TextFormField(
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                    enabled: false,
                      controller: TextEditingController(
                      text: 'UGX: ' + formatter.format(int.parse(widget.deliveryFee)),
                    ),
                        // ignore: missing_return
                        validator: (value){
                          if (value.isEmpty) {
                            return 'Delivery fee is required';
                          }if (value.length < 3) {
                            return 'Enter valid figure';
                          }
                        },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                      hintText: ('Enter Delivery Fee'),
                      labelText: ('Delivery fee'),
                      
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                  ),*/

                  SizedBox(height:10),

                  TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: amountCollected,
                    keyboardType: TextInputType.number,
                    // ignore: missing_return
                        validator: (value){
                          if (value.isEmpty) {
                            return 'Amount to collect is required it can be 0';
                          }
                        },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                      hintText: ('Enter Any Amount to Collect'),
                      labelText: ('Amount to collect (It can be 0)'),
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
                            MaterialPageRoute(builder: (context) => Delivery(
                              pickUp: widget.pickUp,
                              destination: widget.destination,
                              destinationDesc: widget.destinationDesc,
                              packageName: widget.packageName,
                              deliveryFee: widget.deliveryFee,
                              amountCollected: amountCollected.text.toString(),
                              receiverName: widget.receiverName,
                              phoneNumber: widget.receiverPhone,
                              packageType: "Small",
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
      position: LatLng(widget.originLat, widget.destinationLng),
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