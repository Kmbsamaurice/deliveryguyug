import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/templates/bottom_navigation.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';

class ConfirmShopOrder extends StatefulWidget {

  String paymentMode, destination, receiverName, receiverPhone, orderTotal, deliveryFee;
  double totalFare;
  ConfirmShopOrder({this.paymentMode, this.destination, this.receiverName, this.receiverPhone, this.orderTotal, this.deliveryFee, this.totalFare});

  @override
  _ConfirmShopOrderState createState() => _ConfirmShopOrderState();
}

class _ConfirmShopOrderState extends State<ConfirmShopOrder> {
  ProgressDialog pr;
  SharedPreferences prefs;
  String userId = "";
  String userName = "";
  String userPhone = "";
  final formatter = new NumberFormat("#,###");
  DatabaseHelper databaseHelper;
  int itemCount = 0;

  var orders = [];

@override
void initState() {
  super.initState();
  this.getItemCount();
  this.checkLoginStatus();

  DatabaseHelper.instance.queryAllRows().then((value) {
    orders = value;
      
    }).catchError((error) {
      print(error);
    });
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
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,);

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFF3783b5),
                title: Text('Confirm Order'),

                actions: <Widget>[
            _shoppingCartBadge(),

              ],
                
                ),
                body: getBody(),
              
            );
          }
        
          Future <void> sendData() async {
            var url = Uri.parse(Connections.URL_SHOP_ORDER);
            var sending = await http.post(url, body: {
              "store_id": userId,
              "payment_mode": widget.paymentMode,
              "amount_paid": widget.deliveryFee,
              "amount_collected": widget.orderTotal,
              "order_total": widget.orderTotal,
              "receiver_name": widget.receiverName,
              "receiver_phone": widget.receiverPhone,
              "destination": widget.destination,
              "JSONArray": jsonEncode(orders),
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
        Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => ShoppingCart()),(Route<dynamic> route) => false,);
        },
      ),
    );
  }
  Widget getBody(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Text("Order Summary",
                        style: TextStyle(
                          color: Color(0xFF3783b5),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),),
                              ],
                          ),),
                          SizedBox(height: 20),
                          Container(
                            child: Row(
                              children: [
                                Text("Payment Mode"),
                                Spacer(),
                                Text(widget.paymentMode),
                              ],
                          ),),
                          SizedBox(height: 20),
                          Container(
                            child: Row(
                              children: [
                                Text("Destination"),
                                Spacer(),
                                Flexible(child: Text(widget.destination)),
                              ],
                          ),),
                          SizedBox(height: 20),
        
                          Container(
                            color: Colors.grey,
                            height: 1,
                          ),
        
                          SizedBox(height: 20),
                          Container(
                            child: Row(
                              children: [
                                Text("Order Total"),
                                Spacer(),
                                Text("UGX: " + formatter.format(int.parse(widget.orderTotal))),
                              ],
                          ),),
                          SizedBox(height: 20),
                          Container(
                            child: Row(
                              children: [
                                Text("Delivery Fee"),
                                Spacer(),
                                Text("UGX: " + formatter.format(widget.totalFare.toInt()), style: TextStyle(decoration: TextDecoration.lineThrough)),
                                SizedBox(width: 10,),
                                Text("UGX: " + formatter.format(int.parse(widget.deliveryFee))),
                              ],
                          ),),
                          SizedBox(height: 20),
        
                          Container(
                            color: Colors.grey,
                            height: 1,
                          ),
        
                          SizedBox(height: 20),
                          Container(
                            child: Row(
                              children: [
                                Text("Receiver"),
                                Spacer(),
                                Text(widget.receiverName),
                              ],
                          ),),
                          SizedBox(height: 20),
                          Container(
                            child: Row(
                              children: [
                                Text("Phone Number"),
                                Spacer(),
                                Text(widget.receiverPhone),
                              ],
                          ),),
                        ],),
                    ),
                  ),
        
                  SizedBox(height: 20),
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
                ],
              ),
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

Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: (){},
        child: AlertDialog(
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
                DatabaseHelper.instance.clearTable();
                Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => BottomNavigate()),(Route<dynamic> route) => false,);
              },
            ),
          ],
        ),
      );
    },
  );
}
}