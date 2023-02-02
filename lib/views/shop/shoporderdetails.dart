import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/connections.dart';
class ShopOrderDetails extends StatefulWidget {
String destinationPoint, refNo, paymentStatus,deliveryFee,deliveryDate,amountCollected,orderId,receiverName,orderStatus;

ShopOrderDetails({this.destinationPoint, this.refNo, this.paymentStatus, this.deliveryFee, this.deliveryDate, this.amountCollected, this.orderId, this.receiverName, this.orderStatus});

  @override
  _ShopOrderDetailsState createState() => _ShopOrderDetailsState();
}

class _ShopOrderDetailsState extends State<ShopOrderDetails> {
  final formatter = new NumberFormat("#,###");
  List allproducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.fetchAllProducts();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Order List'),
        backgroundColor: Color(0xFF3783b5),
      ),

      body: getOrderItems(),
      
    );
  }

  fetchAllProducts() async{
    setState(() {
      isLoading = true;
    });
    Map order_id = {"order_id": widget.orderId};
    var url = Uri.parse(Connections.URL_ORDER_ITEMS);
    var response = await http.post(url, body: order_id);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        allproducts = items;
        isLoading = false;
      });
    }else {
      setState(() {
        allproducts = [];
        isLoading = false;
      });
    }
  }

  Widget getBody(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ' + widget.deliveryDate, style:TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3783b5))),
            SizedBox(height: 10),
            Text('RefNo. ' + widget.refNo, style:TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3783b5))),
            SizedBox(height: 10),
            Text("Destination: " + widget.destinationPoint, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 10),
            Text('Receiver: ' + widget.receiverName, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 10),
            Text('Order Total: ' + 'UGX: ' + formatter.format(int.parse(widget.amountCollected)), style:TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Order Status: ", style:TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                Spacer(),
                Text(widget.orderStatus, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.grey[300],
              width: MediaQuery.of(context).size.width,
              child: Text("Order Items"),
            ),
            
        ],),
    );
  }

Widget loader(){
    return Container(
      height: double.infinity,
              width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                        ]
                      )
                      
                    ],
                  ),
    );
  }

  Widget getOrderItems(){
    if(allproducts.contains(null) || allproducts.length < 0 || isLoading){
      return loader();
    } 
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 24.0),
        child: ListView.builder(
          itemCount: allproducts.length,
          itemBuilder: (context, index){
          return getOrder(allproducts[index]);
        }),
    );
  }

  Widget getOrder(index){
    var product = index['product'];
    var price = index['price'];
    var quantity = index['sold_quantity'];
    var thumbnail = index['image1'];
    return Expanded(
          child: Container(
        child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "image${'img'}",
                          child: FadeInImage.assetNetwork(
                             placeholder: "assets/images/icon.png",
                             image: thumbnail,
                             width: 80,
                             height: 80,
                             fit: BoxFit.fill,),
                            ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product, style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5,),
                              Text(quantity, style: TextStyle(color: Colors.grey),),
                              SizedBox(height: 5,),
                              Text('UGX: ' + formatter.format(int.parse(price)), style: TextStyle(color: Colors.grey),),
                            ]
                          ),
                        )
                      ],
                    ),
                  )
                ],),
            ),
      ),
    );

  }
}