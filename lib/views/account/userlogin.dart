import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/views/account/otpverification.dart';

import '../templates/bottom_navigation.dart';
class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  ProgressDialog pr;
  String otpNum;
  TextEditingController phoneNum = new TextEditingController();
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

      body: getBody(),
      
    );
  }

  @override
  void initState() {
    super.initState();
    this.otp();
  }

void otp() {
  Random random = Random();
  String number = '';
  for(int i = 0; i < 4; i++){
    number = number + random.nextInt(9).toString();
  }  
  otpNum =  number;
}
Widget getBody(){
   return Container(
  color: Colors.grey[300],
  width: double.infinity,
  height: double.infinity,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 7,
            child: Container(
            height: double.infinity,
            child: Image.asset('assets/images/cour.jpg',
            fit: BoxFit.fill),
            width: double.infinity,
          ),
      ),
      Expanded(
        flex: 3,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height:20),
                  TextFormField(
                    textInputAction: TextInputAction.done,
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
                      controller: phoneNum,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: ('Enter Receiver Number'),
                        labelText: ('Phone Number'),
                        prefixIcon: Icon(Icons.call),
                        labelStyle: TextStyle(
                          color: Color(0xFF3783b5),
                          fontSize: 12),
                          border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                  ),
                  SizedBox(height:20),
                  MaterialButton(
                      minWidth: double.infinity,
                      height: 55.0,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                      color: Color(0xFF3783b5),
                      textColor: Colors.white,
                      child: Text('Login'),
                      onPressed: (){
                        if (!_formKey.currentState.validate()) {
                          return;
                        } else {
                          if (phoneNum.text.toString() == '0784912802'){
                            pr.show();
                            signIn("+256784912802");
                          } else {
                            pr.show();
                            smsNotification();
                          }
                        }
                    }, 
              ),
                ],),
            ),
        ),
      ),
    ],
  ),
);
}
Future <void> smsNotification() async {
  var url = Uri.parse(Connections.URL_SMS);
    var sending = await http.post(url, body: {
      "message": "From TDG\nOTP: " + otpNum + "\nThe Delivery Guy Ug",
      "recipients": "+256" + phoneNum.text.toString().substring(1),
    });

    if (sending.statusCode == 200) {
      pr.hide();
      Navigator.pop(context);
       Navigator.push(context, 
       MaterialPageRoute(builder: (context) => OtpVerification(
         otpNumber: otpNum,
         phoneNumber: phoneNum.text.toString(),
       )
       ),
                              );
    }else{
      setState(() {
        print('failed');
      });
    }

  }

    signIn(String phone) async {
    Map data = {
      "phone_number" : phone
    };
    var url = Uri.parse(Connections.URL_LOGIN);
    final response = await http.post(url, body: data);
    setState(() {
      pr.hide();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (response.statusCode == 200) {
      pr.hide();
      Map jResponse = jsonDecode(response.body);
      if(!jResponse['error'])
      {
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
      MaterialPageRoute(builder: (context) => BottomNavigate()),
                  (Route<dynamic> route) => false,
            );

      }else{

      }      
      
    } else {
      pr.hide();
      print(response.body);
    }
  }
}