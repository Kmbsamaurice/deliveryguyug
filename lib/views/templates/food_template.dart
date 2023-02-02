import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/views/shop/categories.dart';
import 'package:thedeliveryguyug/views/deliveries/homeactivity.dart';
import 'package:thedeliveryguyug/views/shop/product_by_categories.dart';
import 'package:thedeliveryguyug/views/deliveries/upcountrytariffs.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  var cardTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white);
  SharedPreferences prefs;
  List adverts = [];
  bool isLoading = false;


@override
  void initState() {
    _checkVersion();
    this.fetchSliders();
    super.initState();
  }

    fetchSliders() async{
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Connections.URL_ADS);
    var response = await http.get(url);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        adverts = items;
        isLoading = false;
      });
    }else {
      setState(() {
        adverts = [];
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {

  return Scaffold(
  appBar: AppBar(
      title: Text("The Delivery Guy Ug"),
      backgroundColor: Color(0xFF3783b5),
    ),
    //drawer: NavDrwaer(),
    body: getBody(),
  );
  }
  Widget getBody(){
    return Container(
    color: Colors.grey[200],
    width: double.infinity,
    height: double.infinity,
    child: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          _carouselImages(),
         // _digitalClock(),
          _services(),
      ],),
    
  ),
);
}

Widget _digitalClock(){
  return Container(
            height: 150,
            color: Color(0xFF3783b5),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DigitalClock(
                  is24HourTimeFormat: false,
                          areaDecoration: BoxDecoration(
                            color: Colors.transparent,
                            ),
                            hourMinuteDigitTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                            ),
                            amPmDigitTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),   
                 ),
                
                Text(DateFormat("MM-dd-yyyy").format(DateTime.now()),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),)
              ],
            ),
        );
}
Widget _services(){
  return Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                        color: Color(0xFF3783b5),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => HomeActivity()));
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/images/quick.jpg'),
                              SizedBox(height: 10),
                              Text(
                                  'Quick Delivery',
                                  style: cardTextStyle),
                                  SizedBox(height: 10),
                            ],),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                        color: Color(0xFF3783b5),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => UpcountryTariffs()));
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/images/upcountry.jpg'),
                              SizedBox(height: 10),
                              Text(
                                  'Upcountry',
                                  style: cardTextStyle),
                              SizedBox(height: 10),
                            ],),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        ),
                        color: Color(0xFF3783b5),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => CategoryActivity()));
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/images/shop.jpg'),
                              SizedBox(height: 10),
                              Text(
                                  'Shop',
                                  style: cardTextStyle),
                              SizedBox(height: 10),
                            ],),
                        ),
                      ),
                    )
                ],),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          ),
                          color: Color(0xFF3783b5),
                          child: InkWell(
                            onTap: (){
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => CategoryActivity()));
                          },
                            child: Column(
                              children: [
                                Image.asset('assets/images/kfc.jpeg',),
                                SizedBox(height: 10),
                                Text(
                                    'Food Delivery',
                                    style: cardTextStyle),
                                    SizedBox(height: 10),
                              ],),
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Text(
                                  'CALL TO ORDER',
                                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text('Difficulty placing order? Please call us',
                              textAlign: TextAlign.center,
                              ),
                                  
                              SizedBox(height: 5),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        _callNumber("+256772344532");
                                      },
                                      child: Column(children: [
                                          Icon(Icons.call_outlined, color: Colors.grey,),
                                          SizedBox(height: 5),
                                          Text("MTN",
                                          style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold))

                                        ],),
                                      
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: (){
                                        _callNumber("+256759443714");
                                      },
                                      child: Column(children: [
                                          Icon(Icons.call_outlined, color: Colors.grey,),
                                          SizedBox(height: 5),
                                          Text("Airtel",
                                          style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold))
                                        ],
                                        ),
                                      
                                    )
                                  ],
                                ),
                              )
                            ],),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                Row(
                  children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/kfc.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height:55,
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text("KFC Chicken",style: TextStyle(color: Colors.white),),
                              Text("UGX: 35,000", style: TextStyle(color: Colors.redAccent),),
                              ],
                            ),
                          ),
                        ],)  /* add child content here */,
                                  ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/1.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height:55,
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text("Pizza Friday",style: TextStyle(color: Colors.white),),
                              Text("UGX: 40,000", style: TextStyle(color: Colors.redAccent,)),
                              ],
                            ),
                          ),
                        ],)  /* add child content here */,
                                  ),
                  ),
                  ],
                )
            ],),

        );
}


Widget _carouselImages(){

  if(adverts.contains(null) || adverts.length < 0 || isLoading){
      return loader();
    }
  return CarouselSlider(
    options: CarouselOptions(
      height: 200.0,
      aspectRatio: 16/9,
      viewportFraction: 0.8,
      initialPage: 0,
      enableInfiniteScroll: true,
      reverse: false,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 4),
      autoPlayAnimationDuration: Duration(milliseconds: 1000),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: false,
      //onPageChanged: callbackFunction,
      scrollDirection: Axis.horizontal,
      ),
    items: adverts.map((index) {
      return Builder(
        builder: (BuildContext context) {
          return InkWell(
            onTap: (){
              Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => ProductByCategory(categoryName: index['category'], categoryId: index['catid']
              )));
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                  child: Image.network(index["image"], width: double.infinity,fit: BoxFit.fill,),
                ),
              ),
            ),
          );
        },
      );
    }).toList(),
  );
}
 _callNumber(String phoneNumber) async {
  String number = phoneNumber;
  await FlutterPhoneDirectCaller.callNumber(number);
}

void _checkVersion() async {
  final newVersion = NewVersion(
    iOSId: "284882215",
    androidId: "com.thedeliveryguyug",
  );
  final status = await newVersion.getVersionStatus();
  if(status.localVersion == status.storeVersion){
  } else {
    newVersion.showUpdateDialog(
    context: context,
    versionStatus: status,
    dialogTitle: 'UPDATE!!!',
    dismissButtonText: "Maybe Later",
    dialogText: "Please update The Delivery Guy Ug from " + "${status.localVersion}" + " to " + "${status.storeVersion}",
    dismissAction: (){
      SystemNavigator.pop();
    },
    updateButtonText: "Update Now",
    
    );
    }
}

Widget loader(){
    return Container(
            width: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        SizedBox(height: 20, ),

                      Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        color: Colors.grey[300],
                        height: 200,
                      ),
                      
                      ]
                    )
                    
                  ],
                ),
            );
  }

}

