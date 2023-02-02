import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/views/templates/bottom_navigation.dart';
class Delivery extends StatefulWidget {

  String pickUp, destination, destinationDesc, deliveryFee, amountCollected, packageName, packageType, receiverName, phoneNumber;
  double  totalFare, discount;

  Delivery({this.pickUp, this.destination, this.destinationDesc, this.deliveryFee, this.amountCollected, this.packageName, this.packageType, this.receiverName, this.phoneNumber, this.totalFare, this.discount});

  @override
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  ProgressDialog pr;
  SharedPreferences prefs;
  String userId = "";
  String userName = "";
  String userPhone = "";
  final formatter = new NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
      this.checkLoginStatus();
  }


 checkLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('store_id') ?? '';
      userName = prefs.getString('first_name') ?? '';
      userPhone = prefs.getString('phone_number') ?? '';
      
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
     pr.style(
      message: 'Please wait...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 3.0,
      padding: EdgeInsets.all(10),
      insetAnimCurve: Curves.easeInOut,);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Order Summary'),
        ),

        body: getBody()
      
    );
  }

  Future <void> sendData() async {
    var url = Uri.parse(Connections.URL_DELIVERY);
    var sending = await http.post(url, body: {
      "store_id": userId,
      "pickup": widget.pickUp,
      "destination": widget.destination,
      "package": widget.packageName,
      "description": widget.destinationDesc,
      "amount_paid": widget.deliveryFee,
      "amount_collected": widget.amountCollected,
      "receiver_name": widget.receiverName,
      "receiver_phone": widget.phoneNumber,
      "package_type": widget.packageType,
    });

    if (sending.statusCode == 200) {
      pr.hide();
      _showMyDialog();
      smsNotification();
    }else{
      setState(() {
        print('failed to place order');
      });
    }

  }

  Future <void> smsNotification() async {
    var url = Uri.parse(Connections.URL_SMS);
    var sending = await http.post(url, body: {
      "message": "The Delivery Guy Ug\nThere is a new order from $userName : $userPhone",
      "recipients": "+256759443714",
    });

    if (sending.statusCode == 200) {
      print('received');
    }else{
      setState(() {
        print('failed to place order');
      });
    }

  }

   Widget getBody(){
   return Container(
    width: double.infinity,
    height: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height:10),
              Text('Delivery Details',
              textAlign: TextAlign.left,
              ),
              SizedBox(height:10),
              TextField(
                enabled: false,
                controller: TextEditingController(
                  text: widget.pickUp
                ),
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
                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: widget.destination
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
                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: widget.destinationDesc
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.place),
                  hintText: ('Enter Destination'),
                  labelText: ('Exact Destination'),
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

                Text("Payment Details"),

                SizedBox(height:10),

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
                       // Text('UGX: ' + formatter.format(int.parse(widget.totalFare.toStringAsFixed(0))), style: TextStyle(decoration: TextDecoration.lineThrough),),
                        Text('UGX: ' + formatter.format(int.parse(widget.deliveryFee)), style: TextStyle(fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),

               /* SizedBox(height:10),

                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: 'UGX: ' + formatter.format(int.parse(widget.deliveryFee))
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  hintText: ('Enter Delivery Fee'),
                  labelText: ('Delivery Fee'),
                  labelStyle: TextStyle(
                    color: Color(0xFF3783b5),
                    fontSize: 12),
                    border: OutlineInputBorder(),
                    ),
                    obscureText: false,
                ),*/
                
                SizedBox(height:10),

                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: 'UGX: ' + formatter.format(int.parse(widget.amountCollected))
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  hintText: ('Enter Total Amount'),
                  labelText: ('Amount to Collect'),
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

                Text('Package'),

                SizedBox(height:10),

                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: widget.packageType
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  hintText: ('Enter Package Type'),
                  labelText: ('Package Size'),
                  labelStyle: TextStyle(
                    color: Color(0xFF3783b5),
                    fontSize: 12),
                    border: OutlineInputBorder(),
                    ),
                    obscureText: false,
                ),

                SizedBox(height:10),

                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: widget.packageName
                ),
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
                  color: Color(0xFF3783b5),
                ),

                SizedBox(height:20),

                Text('Receiver'),
                SizedBox(height:10),
                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: widget.receiverName
                ),
                keyboardType: TextInputType.name,
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
                TextField(
                  enabled: false,
                  controller: TextEditingController(
                  text: widget.phoneNumber
                ),
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
                    child: Text('Confirm'),
                    onPressed: (){
                      pr.show();
                      sendData();
                  }, 
            ),
            SizedBox(height:20),
            ],
          ),
        )
   );
  }
Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Container(
          width: double.infinity,
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Icon(Icons.check, color: Colors.green,),
              ),
              SizedBox(width: 5),
              Text('Received', style: TextStyle(color: Colors.green),),
            ],
          )),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              SizedBox(height: 10),
              Text('Let us proceed with your delivery',),
              SizedBox(height: 10),
              Text('Thank you!', style: TextStyle(color: Colors.green),),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3783b5)),),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => BottomNavigate()),(Route<dynamic> route) => false,);
            },
          ),
        ],
      );
    },
  );
}
}