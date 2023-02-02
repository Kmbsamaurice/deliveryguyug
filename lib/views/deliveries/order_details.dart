import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OrderDetails extends StatefulWidget {
  String deliveryDate, refNo, deliveryPackage, pickupPoint, destinationPoint, detsDesc, amountCollected, deliveryFee, receiverName, receiverPhone, orderStatus;
  
  OrderDetails({this.deliveryDate, this.refNo, this.deliveryPackage, this.pickupPoint, this.destinationPoint, this.detsDesc, this.amountCollected, this.deliveryFee, this.receiverName, this.receiverPhone, this.orderStatus});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final formatter = new NumberFormat("#,###");
  SharedPreferences prefs;

  String firstName = "";
  String lastName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Color(0xFF3783b5),
      ),

      body: getBody(),
      
    );
  }

  @override
  void initState() {
    super.initState();
      checkLoginStatus();
  }
  

   checkLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
    });

  }

  Widget getBody(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.deliveryDate, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3783b5),),),
            SizedBox(height: 15),
            Text(firstName + " " + lastName, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3783b5),),),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("RefNo. " + widget.refNo, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3783b5),),),
                Spacer(),
                Text(widget.orderStatus, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green,),)
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Package", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                Spacer(),
                Text(widget.deliveryPackage, style: TextStyle(color: Colors.grey),),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pick Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,),),
                Spacer(),
                Text(widget.pickupPoint, style: TextStyle(color: Colors.grey),)
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Destination", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                Spacer(),
                Text(widget.destinationPoint, style: TextStyle(color: Colors.grey),)
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Destinatin Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                Spacer(),
                Text(widget.detsDesc, style: TextStyle(color: Colors.grey),)
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Amount Collected", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                Spacer(),
                Text('UGX: ' + formatter.format(int.parse(widget.amountCollected)), style: TextStyle(color: Colors.grey),)
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Delivery Fee", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                Spacer(),
                Text('UGX: ' + formatter.format(int.parse(widget.deliveryFee)), style: TextStyle(color: Colors.grey),)
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Receiver", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                Spacer(),
                Text(widget.receiverName, style: TextStyle(color: Colors.grey),)
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,),),
                Spacer(),
                Text(widget.receiverPhone, style: TextStyle(color: Colors.grey,)),
              ],
            ),
            
          ],
        ) ,),
    );
  }
}