import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/shop/cofirmshoporder.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';
import 'package:http/http.dart' as http;

import 'dart:math';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class ShopDeliveryDetails extends StatefulWidget {

  String orderTotal;
  ShopDeliveryDetails({this.orderTotal});

  @override
  _ShopDeliveryDetailsState createState() => _ShopDeliveryDetailsState();
}

const kGoogleApiKey = "AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q";

class _ShopDeliveryDetailsState extends State<ShopDeliveryDetails> {
  int itemCount = 0;
  TextEditingController receiverName = new TextEditingController();
  TextEditingController receiverPhone = new TextEditingController();
  TextEditingController destination = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final formatter = new NumberFormat("#,###");

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  double _originLat = 0.3136;
  double _originLng = 32.5839;
  double _destinationLat;
  double _destinationLng;
  double kiloMeters;

  String deliveryFee = '0';
  double totalFare = 0.0;
  double baseFare;
  double discount;
  double pricePerKm;
  double minFare;
  bool isLoading = false;

 @override
  void initState() {
    super.initState();
    this.getItemCount();
    this.fetchPricing();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Delivery Details'),

        actions: <Widget>[
            _shoppingCartBadge(),

          ],
        ),

        body: getBody(),
    );
  }

 Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topEnd(top: 0, end: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(itemCount.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Icon(Icons.shopping_cart),
      onPressed: () {
        Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => ShoppingCart()));
        },
      ),
    );
  }
  
  Widget getBody(){
    if(isLoading){
      return loader();
    }
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
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: receiverName,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,

                    // ignore: missing_return
                  validator: (value){
                      if (value.isEmpty) {
                        return 'Receiver Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid  name';
                        
                      }
                    },
                    decoration: InputDecoration(
                      hintText: ('Enter Receiver Name'),
                      labelText: ('Receiver Name'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                  ),
                  SizedBox(height:10),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: receiverPhone,
                    keyboardType: TextInputType.phone,
                    // ignore: missing_return
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
                      hintText: ('Enter Receiver Phone'),
                      labelText: ('Phone Number'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        prefixIcon: Icon(Icons.call),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                  ),
                  SizedBox(height:10),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: destination,
                    readOnly: true,
                    onTap: () {
                      _fetchDestinationPoint();
                        },
                    // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Destination is Required';
                      } if (value.length < 3) {
                        return 'Enter valid  location';
                        
                      }
                    },
                    decoration: InputDecoration(
                      hintText: ('Enter Destination'),
                      labelText: ('Destination'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        prefixIcon: Icon(Icons.place),
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
                  Row(
                    children: [
                      Text('Delivery Fee'),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text('UGX: ' + formatter.format(totalFare.toInt()), style: TextStyle(decoration: TextDecoration.lineThrough),),
                          Text('UGX: ' + formatter.format(int.parse(deliveryFee))),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height:15),

                  Text('Payment Mode', style: TextStyle(
                    color: Color(0xFF3783b5)),),

                  SizedBox(height:15),

                  new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                 new Radio(
                                value: 1,
                                groupValue: 1,
                                activeColor: Color(0xFF3783b5),
                                onChanged: (val){

                                },
                              ),
                              new Text(
                                  'Cash on Delivery',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                ],
                              ),
                            ),
                          /*  Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [

                                new Radio(
                                  value: 0,
                                  groupValue: 1,
                                  activeColor: Color(0xFF3783b5),
                                  onChanged: (val){

                                  },
                                ),

                                new Text(
                                  'Mobile Money',
                                  style: new TextStyle(fontSize: 16.0),
                                ), 
                                ],
                              ),) */
                         
                        ],
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

                        if(!_formKey.currentState.validate()){
                          return;
                        }else {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ConfirmShopOrder(
                                  paymentMode: "Cash on Delivery",
                                  destination: destination.text.toString(),
                                  receiverName: receiverName.text.toString(),
                                  receiverPhone: receiverPhone.text.toString(),
                                  orderTotal: widget.orderTotal, deliveryFee: deliveryFee, totalFare: totalFare,
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

    void getItemCount() {
      DatabaseHelper.instance.getCount().then((value) {
        print(value);
        setState(() {
        itemCount = value;
      });
    }).catchError((error) {
      print(error);
    });
}

void onError(PlacesAutocompleteResponse response) {
  homeScaffoldKey.currentState.showSnackBar(
    SnackBar(content: Text(response.errorMessage)),
  );
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
    getDistance();
    
    /*scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );*/
  }
}


getDistance() async{
    final request = Uri.parse("https://maps.googleapis.com/maps/api/distancematrix/json?origins=$_originLat,$_originLng&destinations=$_destinationLat,$_destinationLng&key=AIzaSyA-Fcs6hlGYage-rgW5NoEPxT7ALzP7T9Q");
    final response = await http.get(request);

    if(response.statusCode == 200){
    Map values = jsonDecode(response.body);
    String dist = values['rows'][0]['elements'][0]['distance']['text'];
    String totalDist = dist.substring(0, dist.length - 3);

   double _kiloMeters = double.parse(totalDist);

   setState(() {
     kiloMeters = _kiloMeters;
     estimateFares();

   });
}}
  fetchPricing() async{
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Connections.URL_SHOP_DELIVERY_FEE);
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

      });
    }else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void estimateFares() {
  double percentageDiscount = discount/100;

  double distanceFare = pricePerKm * kiloMeters;
  totalFare = baseFare + distanceFare;

  double discountedAmt = totalFare * percentageDiscount;
  double finalFare = totalFare - discountedAmt;
  
  String delFee = finalFare.toStringAsFixed(0);
  String extraFigure = delFee.substring(delFee.length -3);

  print(kiloMeters);
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