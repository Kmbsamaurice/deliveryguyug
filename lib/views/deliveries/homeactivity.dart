import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thedeliveryguyug/views/deliveries/packagedetail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

import 'dart:math';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

final String androidKey = 'AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q';
final String iosKey = 'AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q';
final apiKey = Platform.isAndroid ? androidKey : iosKey;
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();
const kGoogleApiKey = "AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q";

String _mapStyle;

// Starting point latitude
  double _originLatitude = 0.3136027;
// Starting point longitude
  double _originLongitude = 32.5816837;

  double totalDistance = 0.0;
// Markers to show points on the map
  Map<MarkerId, Marker> markers = {}; 


class _HomeActivityState extends State<HomeActivity> {
  final _formKey = GlobalKey<FormState>();
  ProgressDialog pr;
  final destination = TextEditingController();
  final pickUp = TextEditingController();

  double _originLat;
  double _originLng;
  double _destinationLat;
  double _destinationLng;
  
  

 // Google Maps controller
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  // Configure map position and zoom
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(_originLatitude, _originLongitude),
    zoom: 10,
  ); 

  
    @override
  void initState() {
    rootBundle.loadString('assets/map_style.txt').then((string) {
    _mapStyle = string;
  });
    super.initState();
  }
  @override
  void dispose() {
    pickUp.dispose();
    destination.dispose();
    super.dispose();
    }
    
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(
    message: 'Please wait...',
    borderRadius: 10.0,
    backgroundColor: Colors.white,
    progressWidget: CircularProgressIndicator(),
    elevation: 10.0,
    insetAnimCurve: Curves.easeInOut,);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Delivery Details'),
        ),
        body: getBody(),
        );
      }
    
    Widget getBody(){
      return Container(
         height:  MediaQuery.of(context).size.height,
         width: MediaQuery.of(context).size.width,
         child: SingleChildScrollView(
           child: Column(
             children: [
                Container(
                  height:  MediaQuery.of(context).size.height/2.0,
                  width: MediaQuery.of(context).size.width,
                  child:GoogleMap(
                    mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  tiltGesturesEnabled: true,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  trafficEnabled: false,
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
                          controller: pickUp,
                          readOnly: true,
                            onTap: () {
                              _fetchPickupPoint();
                        },
                  
                  // ignore: missing_return
                  validator: (value){
                    if (value.isEmpty) {
                      return 'Pickup point is required';
                      }if (value.length < 3) {
                        return 'Enter valid location';
                        }
                        },
                        
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.place),
                        hintText: ('Enter Pickup Point'),
                        labelText: ('Pickup Point'),
                        labelStyle: TextStyle(
                          color: Color(0xFF3783b5),
                          fontSize: 12),
                          border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                          ),
    
                      SizedBox(height:10),
    
                      TextFormField(
                        controller: destination,
                        onTap: () {
                          _fetchDestinationPoint();
                            },
                          // ignore: missing_return
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Destination point is required';
                            }if (value.length < 3) {
                              return 'Enter valid location';
                            }
                          },
                          readOnly: true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.place),
                            hintText: ('Enter Destination'),
                            labelText: ('Destination'),
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
                                getDist();
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
  getDist() async {
    pr.show();
    final request = Uri.parse("https://maps.googleapis.com/maps/api/distancematrix/json?origins=$_originLat,$_originLng&destinations=$_destinationLat,$_destinationLng&key=AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q");
    final response = await http.get(request);

    if(response.statusCode == 200){
      pr.hide();
    Map values = jsonDecode(response.body);
    String dist = values['rows'][0]['elements'][0]['distance']['text'];
    String totalDist = dist.substring(0, dist.length - 3);

    Navigator.push(context, 
    MaterialPageRoute(builder: (context) => PackageDetails(
      pickUp: pickUp.text.toString(),
      destination: destination.text.toString(), distance: double.parse(totalDist),
      originLat: _originLat, originLng: _originLng, destinationLat: _destinationLat, destinationLng: _destinationLng,
      )),);

  }
}

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _fetchPickupPoint() async {
    Prediction p = await PlacesAutocomplete.show(
      //radius: 1000,
      strictbounds: false, 
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.overlay,
      //language: "en",
      decoration: InputDecoration(  
        hintText: "Search for your pick up location",     
        enabledBorder: UnderlineInputBorder(      
        borderSide: BorderSide(color: Colors.white),   ),  
  
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),),
    
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        ),),
      components: [Component(Component.country, "ug")],
      types: [], 
    );
    _getPickupPoint(p, homeScaffoldKey.currentState);
  }

Future<Null> _getPickupPoint(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    pickUp.text = p.description;
    _originLat = lat;
    _originLng = lng;
    
    /*scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );*/
  }
}

 Future<void> _fetchDestinationPoint() async {
    Prediction p = await PlacesAutocomplete.show(
      //radius: 1000,
      strictbounds: false, 
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.overlay,
      //language: "en",
      decoration: InputDecoration(  
        hintText: "Search for your destination",     
        enabledBorder: UnderlineInputBorder(      
        borderSide: BorderSide(color: Colors.white),   ),  
  
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),),
    
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        ),),
      components: [Component(Component.country, "ug")],
      types: [], 
    );
    _getDestinationPoint(p, homeScaffoldKey.currentState);
  }

Future<Null> _getDestinationPoint(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    destination.text = p.description;
    _destinationLat = lat;
    _destinationLng = lng;
    
    /*scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );*/
  }
}

}
class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
