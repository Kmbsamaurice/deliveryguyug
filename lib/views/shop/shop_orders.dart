import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/shop/shoporderdetails.dart';

class  ShopOrders extends StatefulWidget {


  @override
  _ShopOrdersState createState() => _ShopOrdersState();
}

class _ShopOrdersState extends State<ShopOrders> {
  SharedPreferences prefs;

  String firstName = "";
  String lastName = "";
  String userId = "";

  List allshoporder = [];
  bool isLoading = false;
  final formatter = new NumberFormat("#,###");
  DatabaseHelper databaseHelper;
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    this.checkLoginStatus();
    
  }


   checkLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
      userId = prefs.getString('store_id') ?? '';
      this.fetchAllShopDeliveries();
      print(userId);
    });

  }

  fetchAllShopDeliveries() async{
    setState(() {
      isLoading = true;
    });
    Map store_id = {"store_id": userId};
    var url = Uri.parse(Connections.URL_SHOP_ORDERS);
    var response = await http.post(url, body: store_id);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        allshoporder = items;
        isLoading = false;
      });
    }else {
      setState(() {
        allshoporder = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: getBody()
    );
  }

 Widget getBody(){
    if(allshoporder.contains(null) || allshoporder.length < 0 || isLoading){
      return loader();
    }
    
    return ListView.separated(
      itemCount: allshoporder.length,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
      itemBuilder: (context, index){
      return getShopOrders(allshoporder[index]);
    });
  }

Widget loader(){
    return SafeArea(
      child: Container(
              height: double.infinity,
              width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          SizedBox(height: 20, ),
                        CardPlaceHolderWithImage(
                          height: 200,
                        ),
                        Container(
                          width: 250,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: FlutterShimmnerLoadingWidget(
                              count: 1,
                              lineHeight: 10,
                              animate: true,
                              color: Colors.grey[200],
                            ),
                          ),
                        ),
                        listLoader(),
                        listLoader(),
                        listLoader(),
                        listLoader(),
                        listLoader(),
                        listLoader(),
                        ]
                      )
                      
                    ],
                  ),
                ),
              ),
    );
  }

   Widget listLoader() {
    return  Container(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FlutterShimmnerLoadingWidget(
          count: 2,
          lineHeight: 10,
          animate: true,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget getShopOrders(index){
    var destinationPoint = index['destination'];
    var refNo = index['payment_method'];
    var paymentStatus = index['payment_status'];
    var deliveryFee = index['amount_paid'];
    var deliveryDate = index['date_created'];
    var detsDesc = index['ref_no'];
    var amountCollected = index['order_total'];
    var orderId = index['order_id'];
    var receiverName = index['receiver_name'];
    var receiverPhone = index['receiver_phone'];
    var orderStatus = index['order_status'];
    return InkWell(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => ShopOrderDetails(deliveryDate: deliveryDate, refNo: refNo, destinationPoint: destinationPoint, receiverName: receiverName, amountCollected: amountCollected, orderStatus: orderStatus, paymentStatus: paymentStatus, orderId: orderId,),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(child: Image.asset("assets/images/noimage.png", 
                      height: 80,
                      width: 80,)),
                      SizedBox(width:10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(deliveryDate, style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),),
                        SizedBox(height:3),
                        Text(amountCollected,style: TextStyle(color: Colors.grey[600]),),
                        SizedBox(height:3),
                        Text(orderStatus,style: TextStyle(color: Colors.green),),

                      ],),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_sharp), 
                        onPressed: null)
                    ],
                  ),
                )
             
              ]
            ),
          ),
        ),
      onTap: (){

        },
    );
  }


}