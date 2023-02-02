
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otp_screen/otp_screen.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/views/templates/bottom_navigation.dart';
import 'package:thedeliveryguyug/views/account/registeruser.dart';

class OtpVerification extends StatefulWidget {
  String otpNumber, phoneNumber;

  OtpVerification({this.otpNumber, this.phoneNumber});

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  ProgressDialog pr;

Future<String> validateOtp(String otp) async {
  await Future.delayed(Duration(milliseconds: 2000));

  if (otp == widget.otpNumber){
    return null;
  }else {
    return "The entered OTP is wrong";
  }
}
  void moveToNextScreen(context) {
     setState(() {
       pr.show();
     });
     signIn("+256" + widget.phoneNumber.substring(1));
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
        print("${jResponse['message']}");

        Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => RegisterUser(userPhone: "+256" + widget.phoneNumber.substring(1))),
                  (Route<dynamic> route) => false,
            );
      }      
      
    } else {
      pr.hide();
      print(response.body);
    }
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

      body: Container(
        child: OtpScreen.withGradientBackground(
          otpLength: 4,
          validateOtp: validateOtp, 
          routeCallback: moveToNextScreen, 
          titleColor: Colors.white,
          topColor: Color(0xFF753a88), 
          bottomColor: Color(0xFF3783b5),
          title: "Phone Number Verification",
          subTitle: "Enter the  code sent to \n+256 " + widget.phoneNumber.substring(1),   
          icon: Image.asset('assets/images/bik.png',
          fit: BoxFit.fill,),
        ),
      ),
    );
  }
}