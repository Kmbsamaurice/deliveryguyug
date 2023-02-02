import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:intl/intl.dart';
class Support extends StatefulWidget {
  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Support'),
        ),

        body: getBody(),
      
    );
  }

Widget getBody(){
  return Container (
    margin: EdgeInsets.symmetric(vertical: 10),
    width: double.infinity,
    height: double.infinity,
    child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('1st Floor, Suit 42 Shumuk House Plot 2 Colville Street\nP.O.Box 4030, Kampala, Uganda', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){

                  },
                  ),
                  ListTile(
                    leading: Icon(Icons.call),
                    title: Text('+256 759 443 714', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){
                    _callNumber('+256759443714');
                  },
                  ),
                  ListTile(
                    leading: Icon(Icons.call),
                    title: Text('+256 772 344 532', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){
                    _callNumber('+256772344532');
                  },
                  ),

                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('thedeliveryguyug@gmail.com', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: () async{
                  // Android: Will open mail app or show native picker.
                  // iOS: Will open mail app if single mail app found.
                  var result = await OpenMailApp.openMailApp();

                  // If no mail apps found, show error
                  if (!result.didOpen && !result.canOpen) {
                    showNoMailAppsDialog(context);

                    // iOS: if multiple mail apps found, show dialog to select.
                    // There is no native intent/default app system in iOS so
                    // you have to do it yourself.
                  } else if (!result.didOpen && result.canOpen) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return MailAppPickerDialog(
                          mailApps: result.options,
                          
                        );
                      },
                    );
                  }
                  },
                  ),
                ],),
  );
  }
   _callNumber(String phoneNumber) async {
  String number = phoneNumber;
  await FlutterPhoneDirectCaller.callNumber(number);
}

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}