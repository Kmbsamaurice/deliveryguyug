import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thedeliveryguyug/views/deliveries/delivery.dart';

import 'dart:math';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';


class UpCountry extends StatefulWidget {

  String districtName, districtTarriff;

  UpCountry({this.districtName, this.districtTarriff});

  @override
  _UpCountryState createState() => _UpCountryState();
}
const kGoogleApiKey = "AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q";

class _UpCountryState extends State<UpCountry> {
  final formatter = new NumberFormat("#,###");

  TextEditingController pickUp = new TextEditingController();
  TextEditingController packageName = new TextEditingController();
  TextEditingController receiverName = new TextEditingController();
  TextEditingController receiverPhone = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Order Details'),
        ),
        body: getBody()
    );
  }

  Widget getBody(){
   return Container(
    width: double.infinity,
    height: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height:10),
                Text('Delivery Details',
                textAlign: TextAlign.left,
                ),
                SizedBox(height:10),
                TextFormField(
                  readOnly: true,
                  controller: pickUp,
                  onTap: () {
                     _fetchPickupPoint();
                    },
                  // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Pickup point is Required';
                      } if (value.length < 3) {
                        return 'Enter valid  location';
                        
                      }
                    },
                  keyboardType: TextInputType.text,
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
                    textInputAction: TextInputAction.next,
                    enabled: false,
                    controller: TextEditingController(
                      text: widget.districtName
                      ),
                    keyboardType: TextInputType.text,
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
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    enabled: false,
                  controller: TextEditingController(
                    text: 'UGX: ' + formatter.format(int.parse(widget.districtTarriff))),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: ('Enter Delivery Fee'),
                    labelText: ('Delivery Fee'),
                    labelStyle: TextStyle(
                      color: Color(0xFF3783b5),
                      fontSize: 12),
                      border: OutlineInputBorder(),
                      ),
                      obscureText: false,
                  ),

                  SizedBox(height:20),

                  Container(               
                    height:1.0,
                    width: double.infinity,
                    color: Colors.grey,
                  ),

                  SizedBox(height:20),

                  Text('Package'),

                  SizedBox(height:10),

                  TextFormField(
                    textInputAction: TextInputAction.next,
                    // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Package Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid  Package Name';
                        
                      }
                    },
                    controller: packageName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                      hintText: ('Enter Package Name'),
                      labelText: ('Package'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                    ),

                  SizedBox(height:20),

                  Container(               
                    height:1.0,
                    width: double.infinity,
                    color: Colors.grey,
                  ),

                  SizedBox(height:20),

                  Text('Receiver'),
                  SizedBox(height:10),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Receiver Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid  name';
                        
                      }
                    },
                    controller: receiverName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: ('Enter Recever Name'),
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
                    // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Phone Number is Required';
                      } if (value.length != 10) {
                        return 'Enter valid  number eg (0784912802)';   
                      } 
                      String pattern = r'((070|075|077|078|071|079|074|076|072)[0-9]{7})';
                      RegExp regExp = new RegExp(pattern);
                      if (!regExp.hasMatch(value)) {
                        return 'Enter valid  number eg (0784912802)'; 
                      }
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.call),
                      hintText: ('Enter Receiver Number'),
                      labelText: ('Phone Number'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                    ),
                  SizedBox(height:20),
                  MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      height: 55.0,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                      color: Color(0xFF3783b5),
                      textColor: Colors.white,
                      child: Text('Next'),
                      onPressed: (){
                        if (!_formKey.currentState.validate()) {
                          return;
                          
                        } else {
                                Navigator.push(context, 
                                MaterialPageRoute(builder: (context) => Delivery(
                                  pickUp: pickUp.text.toString(),
                                  destination: widget.districtName,
                                  deliveryFee: widget.districtTarriff,
                                  destinationDesc: "Upcountry",
                                  amountCollected: "0",
                                  packageName: packageName.text.toString(),
                                  packageType: "Small",
                                  receiverName: receiverName.text.toString(),
                                  phoneNumber: receiverPhone.text.toString(),
                                  totalFare: double.parse(widget.districtTarriff),
                                  discount: 0.0,

                                )
                                ),
                              );
                              }
                    }, 
              ),
              SizedBox(height:20),
              ],
          ),
            ),
        )
   );
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

