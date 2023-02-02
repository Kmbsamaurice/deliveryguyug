import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/views/deliveries/receiverdetails.dart';
import 'package:http/http.dart' as http;

class PackageDetails extends StatefulWidget {

String pickUp, destination;
double distance;
double originLat, originLng, destinationLat, destinationLng;


PackageDetails({this.pickUp, this.destination, this.distance, this.originLat, this.originLng, this.destinationLat, this.destinationLng});

  @override
  _PackageDetailsState createState() => _PackageDetailsState();
}

final String androidKey = 'AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q';
final String iosKey = 'AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q';
final apiKey = Platform.isAndroid ? androidKey : iosKey;

String _mapStyle;
// Markers to show points on the map
  Map<MarkerId, Marker> markers = {}; 

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};


class _PackageDetailsState extends State<PackageDetails> {
  TextEditingController packageName = new TextEditingController();
  TextEditingController destinationDesc = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String deliveryFee;
  double totalFare;
  double baseFare;
  double discount;
  double pricePerKm;
  double minFare;
  bool isLoading = false;

  // Google Maps controller
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  // Configure map position and zoom
  CameraPosition _kGooglePlex; 
  
  @override
  void initState() {
    fetchPricing();
    //this.calcDeliveryFee();
    print(widget.distance);
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
        title: Text('Package Details'),
        ),

      body: getBody(),
      
    );
  }

  fetchPricing() async{
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Connections.URL_DELIVERY_FEE);
    var response = await http.get(url);
    if(response.statusCode == 200){
      Map jresponse = json.decode(response.body);

      setState(() {
        Map fees = jresponse['data'];
        pricePerKm = double.parse(fees['price']);
        baseFare = double.parse(fees['base_fare']);
        minFare = double.parse(fees['min_amount']);
        discount = double.parse(fees['discount']);
        print(pricePerKm);
        print(baseFare);
        print(minFare);
        print(discount);

        isLoading = false;
        estimateFares();
      });
    }else {
      setState(() {
        isLoading = false;
      });
    }
  }


Widget getBody(){
  if(isLoading){
    return loader();
  }
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
                    controller: packageName,
                    keyboardType: TextInputType.text,
                    // ignore: missing_return
                      validator: (value){
                        if (value.isEmpty) {
                          return 'Package name is required';
                        }if (value.length < 3) {
                          return 'Enter valid package Name';
                        }
                      },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                      hintText: ('Enter Package Name'),
                      labelText: ('Package Name (i.e Crate of Soda)'),
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
                    controller: destinationDesc,
                    keyboardType: TextInputType.text,
                    // ignore: missing_return
                      validator: (value){
                        if (value.isEmpty) {
                          return 'Description is required';
                        }if (value.length < 3) {
                          return 'Enter valid Description';
                        }
                      },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.place),
                      hintText: ('Describe Your Destination'),
                      labelText: ('Destination Description (i.e Opposite Fuelex)'),
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
                            }else{
                              Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => ReceiverDetails(
                              pickUp: widget.pickUp,
                              destination: widget.destination,
                              packageName: packageName.text.toString(),
                              destinationDesc: destinationDesc.text.toString(), deliveryFee: deliveryFee,
                              originLat: widget.originLat, originLng: widget.originLng, destinationLat: widget.destinationLat, destinationLng: widget.destinationLng,
                              totalFare: totalFare,
                              discount: discount,
                            )),);
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
        infoWindow: InfoWindow(title: widget.pickUp)),
    Marker(
      
      markerId: MarkerId("marker_2"),
      infoWindow: InfoWindow(title: widget.destination,),
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

void estimateFares() {
  double percentageDiscount = discount/100;

  double distanceFare = pricePerKm * widget.distance;
  totalFare = baseFare + distanceFare;

  double discountedAmt = totalFare * percentageDiscount;
  double finalFare = totalFare - discountedAmt;
  
  String delFee = finalFare.toStringAsFixed(0);
  String extraFigure = delFee.substring(delFee.length -3);

  print(widget.distance);
  print("total fare: " + totalFare.toString());
  print("del fee: " + delFee);
  print("extra figure: " + extraFigure);

  if(int.parse(extraFigure) <= 500){
    int cost = int.parse(delFee) - int.parse(extraFigure) + 500;
    setState(() {
      deliveryFee = cost.toStringAsFixed(0);
      print(deliveryFee);
      if(int.parse(deliveryFee) < minFare){
        int cost2 = minFare.toInt();
        setState(() {
          deliveryFee = cost2.toString();
        print(deliveryFee);
    });
    }
    });
  }

  if(int.parse(extraFigure) > 500){
    int cost = int.parse(delFee) - int.parse(extraFigure) + 1000;
    setState(() {
      deliveryFee = cost.toStringAsFixed(0);
      print(deliveryFee);
      if(int.parse(deliveryFee) < minFare){
        int cost2 = minFare.toInt();
        setState(() {
          deliveryFee = cost2.toString();
        print(deliveryFee);
    });
    }
    });
  }
}

void calcDeliveryFee() {
  int extraDistance;
  int extraCost;
  int totalCost;
  String sFee;
  String sFees;
  String totalFee;
  setState(() {

    if(widget.distance <= 3){
        deliveryFee = "3000";
          }
          else if(widget.distance > 3 && widget.distance <= 5){
            deliveryFee = "5000";
          }
          else if(widget.distance > 5 && widget.distance <= 7){
            deliveryFee = "6000";
            
          }
          else if(widget.distance > 7 && widget.distance <= 9){
            deliveryFee = "7000";
            
          }
          else if(widget.distance > 9 && widget.distance <= 11){
            deliveryFee = "9000";
            
          }
          else if(widget.distance > 11 && widget.distance <= 13){
            deliveryFee = "10000";
            
          }
          else if(widget.distance > 13 && widget.distance <= 15){
            deliveryFee = "12000";
            
          }else if(widget.distance > 15 && widget.distance <= 17){
            deliveryFee = "15000";
            
          }
          else if(widget.distance > 17 && widget.distance <= 19){
            deliveryFee = "16000";
            
          }
          else if(widget.distance > 19 && widget.distance <= 21){
            deliveryFee = "17000";
            
          }
          else if(widget.distance > 21 && widget.distance <= 23){
            deliveryFee = "18000";
          }
          else if(widget.distance > 23 && widget.distance <= 25){
            deliveryFee = "19000";
            
          }
          else if(widget.distance > 25 && widget.distance <= 27){
            deliveryFee = "20000";
            
          }
          else if(widget.distance > 27 && widget.distance <= 30){
            deliveryFee = "21000";
            
          }
          else if(widget.distance > 30 && widget.distance <= 32){
            deliveryFee = "22000";
            
          }
          else if(widget.distance > 32 && widget.distance <= 34){
            deliveryFee = "23000";
            
          }else if(widget.distance > 34 && widget.distance <= 37){
            deliveryFee = "24000";
            
          }
          else if(widget.distance > 37 && widget.distance <= 39){
            deliveryFee = "25000";
            
          }
          else if(widget.distance > 39 && widget.distance <= 41){
            deliveryFee = "26000";
            
          }
          else if(widget.distance > 41 && widget.distance <= 43){
            deliveryFee = "27000";
            
          }
          else if(widget.distance > 43 && widget.distance <= 45){
            deliveryFee = "28000";
            
          }
          else if(widget.distance > 46 && widget.distance <= 50){
            deliveryFee = "30000";
            
          }
          else if (widget.distance > 50){
            extraDistance = widget.distance.toInt() - 50;
            extraCost = extraDistance * 300;
            totalCost = 30000 + extraCost;
            sFee = totalCost.toString();
            sFees = sFee.substring(0, sFee.length - 3);
            int shipping = int.parse(sFees) * 1000;
            deliveryFee = shipping.toString();
            
      }  
      });
      }

Widget loader(){
    return Container(
            height: double.infinity,
            width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Loading...',style: TextStyle(color: Colors.grey),),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                      Container(
                        width: double.infinity,
                        color: Colors.grey[100],
                        height: 350,
                      ), 

                      SizedBox(height: 15,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        color: Colors.grey[100],
                        height: 60,
                      ),
                      SizedBox(height: 15,),
                       Container(
                         margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        color: Colors.grey[100],
                        height: 60,
                      ),
                      SizedBox(height: 15,),
                       Container(
                         margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        color: Colors.grey[100],
                        height: 60,
                      )
                      
                      ]
                    )
                    
                  ],
                ),
              ),
            );
  }
}
