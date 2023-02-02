import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/place_service.dart';
import 'package:thedeliveryguyug/views/templates/address_search.dart';
import 'package:thedeliveryguyug/views/templates/bottom_navigation.dart';
import 'package:thedeliveryguyug/views/account/userlogin.dart';
import 'package:uuid/uuid.dart';

class RegisterUser extends StatefulWidget {

  String userPhone;

  RegisterUser({this.userPhone});

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  ProgressDialog pr;
  bool value = false;
  bool _isLoading = false;
  
  TextEditingController fasNam = new TextEditingController();
  TextEditingController lasNam = new TextEditingController();
  TextEditingController busNam = new TextEditingController();
  TextEditingController busLoc = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => UserLogin()),(Route<dynamic> route) => false,);
                    },
                  ),
        title: Text('Create Account'),
        backgroundColor: Color(0xFF3783b5),
      ),
      
      body: getBody(),
    );
  }

Future <void> smsNotification() async {
   var url = Uri.parse(Connections.URL_SMS);
    var sending = await http.post(url, body: {
      "message": "Dear " + fasNam.text.toString() + "\n" + "Welcome to the Delivery Guy Ug Delivery App",
      "recipients": widget.userPhone,
    });

    if (sending.statusCode == 200) {
      print('received');
    }else{
      setState(() {
        print('Registration failed');
      });
    }

  }

    registerUser(String businessName, String businessLoc, String firstName, String lastName, String phoneNumber, String termsAndConditions) async {
    Map data = {
      "store_name" : businessName,
      "location" : businessLoc,
      "first_name" : firstName,
      "last_name" : lastName,
      "phone_number" : phoneNumber,
      "tcs" : termsAndConditions
    };
    var url = Uri.parse(Connections.URL_REGISTER);
    final response = await http.post(url, body: data);
    setState(() {
      pr.hide();
    });
    
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (response.statusCode == 200) {
      Map jResponse = jsonDecode(response.body);
      if(!jResponse['error'])
      {
        
        smsNotification();

      Map user = jResponse['data'];

      preferences?.setInt("isLoggedIn", 1);
      preferences.setString("store_id", user['store_id']);
      preferences.setString("store_name", user['store_name']);
      preferences.setString("location", user['location']);
      preferences.setString("first_name", user['first_name']);
      preferences.setString("last_name", user['last_name']);
      preferences.setString("phone_number", user['phone_number']);
      preferences.setString("image", user['image']);

      Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => BottomNavigate()),(Route<dynamic> route) => false,);

      }else{
        print("${jResponse['message']}");
      }      
      
    } else {
      _isLoading = false;
      print(response.body);
    }
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
                Text('Personal Details',
                textAlign: TextAlign.left,
                ),
                SizedBox(height:10),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: fasNam,
                  // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'First Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid Name';
                        
                      }
                    },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: ('Enter First Name'),
                    labelText: ('First Name'),
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
                  controller: lasNam,
                  // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Last Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid Name';
                        
                      }
                    },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: ('Enter Last Name'),
                    labelText: ('Last Name'),
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
                    text: widget.userPhone),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.call),
                    hintText: ('Enter Phone Number'),
                    labelText: ('Phone Number'),
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
                    color: Color(0xFF3783b5),
                  ),

                  SizedBox(height:20),

                  Text('Business Details'),

                  SizedBox(height:10),

                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller:  busNam,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.business),
                      hintText: ('Enter Business Name'),
                      labelText: ('Business Name (Optional)'),
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
                    controller: busLoc,
                    readOnly: true,
                    onTap: () async {
                      // generate a new token here
                      final sessionToken = Uuid().v4();
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                        );

                        if (result != null) {
                                var addresses = await Geocoder.local.findAddressesFromQuery(result.description);
                                var first = addresses.first;

                                setState(() {
                                  busLoc = result.description as TextEditingController ; first.coordinates.longitude;

                                });
                              }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.place),
                      hintText: ('Enter Business Location'),
                      labelText: ('Business Location'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                    ),

                  SizedBox(height:20),

                  Row(
                      children: [
                        Checkbox(
                          value: this.value,
                          onChanged: (bool value) {
                            setState(() {
                              this.value = value;
                            });
                          }),
                        Text('I agree to the Terms & Conditions'),
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
                      child: Text('Register'),
                      onPressed: (){
                        if (!_formKey.currentState.validate()) {
                          return;
                          
                        } else {
                          setState(() {
                            pr.show();
                        });
                        registerUser(busNam.text.toString(), busLoc.text.toString(), fasNam.text.toString(), lasNam.text.toString(), widget.userPhone, "1");
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
}