import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/models/cart.dart';
import 'package:thedeliveryguyug/views/shop/search_products.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';

// ignore: must_be_immutable
class ProductDetails extends StatefulWidget {
  String productId, vemdorId, productDesc, productName, productPrice, productImage1, productImage2, subcategoryId, status, discount;

  ProductDetails({this.productId, this.vemdorId, this.productDesc, this.productName, this.productPrice, this.productImage1, this.productImage2, this.subcategoryId, this.status, this.discount });
  
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final formatter = new NumberFormat("#,###");
  FlutterToast flutterToast;
  List products = [];
  int _n = 1;
  int itemCount = 0;
  bool isLoading = false;
  int newPrice;

  // ignore: deprecated_member_use
  List<Cart> cartList = new List();
 
   @override
  void initState() {
    super.initState();
    this.getItemCount();
    this.calcDiscount();
    this.fetchRelatedProducts();
    flutterToast = FlutterToast(context);
  
  }

  calcDiscount() {
    int priceValue = int.parse(widget.productPrice.toString());
    double discountValue = (int.parse(widget.discount.toString()) / 100) * priceValue;
    newPrice = priceValue - discountValue.toInt();
  }

  fetchRelatedProducts() async{
    setState(() {
      isLoading = true;
    });
      Map subid = {"subid": widget.subcategoryId};
    var response = await http.post(Uri.parse(Connections.URL_RELATED_PRODUCTS), body: subid);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        products = items;
        isLoading = false;
      });
    }else {
      setState(() {
        products = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text(widget.productName),

        actions: <Widget>[
            IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){
              Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => SearchProducts()),);
            }),
            _shoppingCartBadge(),

          ],
        ),

        body: getBody(),

        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF3783b5),
          elevation: 0,
          child: _shoppingCartBadge(),
          onPressed: () { print('Clicked'); },
        ),
    );
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
        Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => ShoppingCart()));
        },
      ),
    );
  }

 Widget getBody(){
   return Container(
  width: double.infinity,
  height: double.infinity,
  child: SingleChildScrollView(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10.0),
              height: 300.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)
                      ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 300.0,
                      height: 300.00,
                      child: Hero(
                        tag: "image${widget.productImage1}",
                        child: FadeInImage.assetNetwork(
                        placeholder: "assets/images/icon.png",
                        image: widget.productImage1,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,),
                      ),
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)
                      ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 300.0,
                      height: 300.0,
                      child: Hero(
                        tag: "image${widget.productImage2}",
                        child: FadeInImage.assetNetwork(
                        placeholder: "assets/images/placeholder.png",
                        image: widget.productImage2,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,),
                      ),
                      
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal:5),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)
                  ),
                  
                  child: Column(children: [
                    Container(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.productDesc),
                    SizedBox(height: 10),
                    Text(widget.productName,style: TextStyle(fontSize: 20),),
                    SizedBox(height: 5),
                     if (widget.discount != "0")
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(5),
                            ),
                            height: 25,
                            width: 45,
                            padding: EdgeInsets.all(5),
                            child: Center(child: Text("-" + widget.discount + "%", style: TextStyle(color: Colors.white),)),),
                          Row(
                            children: [
                              Text("UGX: " + formatter.format(int.parse(widget.productPrice)), style: TextStyle(fontSize: 15, color: Colors.grey,
                          decoration: TextDecoration.lineThrough,),),
                          SizedBox(width: 10,),
                          Text("UGX: " + formatter.format(newPrice), style: TextStyle(fontSize: 28, color: Colors.red),
                          
                          ),
                            ],
                          )
                        ],
                      )
                      else
                    Text("UGX: " + formatter.format(int.parse(widget.productPrice)),
                        style: TextStyle(color: Colors.red, fontSize: 28),),
                  ],

              ),
          )
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: new Row( 
              children: [
                Row(
                  children: [
                  IconButton(icon: Icon(Icons.remove_circle_outline), 
                          onPressed: minus),
                
                 Text('$_n',
                    style: new TextStyle(fontSize: 30.0)),

                 IconButton(icon: Icon(Icons.add_circle_outline), 
                          onPressed: add),
                  ],
                ),
                Spacer(),
                (widget.status == "1") ? MaterialButton(
                      height: 40.0,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                      color: Color(0xFF3783b5),
                      textColor: Colors.white,
                      child: Text('Buy'),
                          
                      onPressed: (){
                          checkIfProductsExists();
                    }, 
                  ):Image.asset("assets/images/outofstock.png", width: 100,),
                
                
                
              ],
          ),
        ),
         ],),),
            ),
        relatedProducts()
      ],
    ),
  ),  
);
}

Widget loader(){
    return Container(
            width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    
                    horizontalLoader(),
                      
                      ]
                    )
                    
                  ],
                ),
            );
}

Widget horizontalLoader(){
  return Container(
    child: Row(
      children: [
        Expanded(
          child: Column(
            children: [
              CardPlaceHolderWithImage(
                height: 200,
                ),
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FlutterShimmnerLoadingWidget(
                      count: 1,
                      lineHeight: 10,
                      animate: true,
                      color: Colors.grey[200]
                      ),),),
                       ],
                       ),),
                       Expanded(
                            child: Column(
                              children: [
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
                              ],
                            ),
                          )
                        ],
                      ),
  );
                    }
                    
  Widget relatedProducts(){

    if(products.contains(null) || products.length < 0 || isLoading){
      return loader();
    }
    return Container(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 15),
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index){
        return getProducts(products[index]);
      }),
    );
  }

Widget getProducts(index){
    var productDesc = index['description'];
    var productName = index['product'];
    var productPrice = index['price'];
    var vendorId = index['vendor_id'];
    var thumbnailUrl = index['image1'];
    var thumbnailUrl2 = index['image2'];
    var productId = index['product_id'];
    var status = index['status'];
    var discount = index['discount'];
    int priceValue = int.parse(productPrice.toString());
    double discountValue = (int.parse(discount.toString()) / 100) * priceValue;
    double newPrice = priceValue - discountValue;
    return InkWell(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)
                ),
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Stack(
                            children: [
                              Center(
                              child: Hero(
                                tag: "image${vendorId.toString()}",
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/images/icon.png",
                                  image: thumbnailUrl.toString(),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,),
                                                  ),
                            ),
                            if(status.toString() == "0")
                            Center(
                                    child: Container(
                                      color: Colors.grey[200],
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(top: 40),
                                      child: Text("Out of Stock",style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF3783b5) ),)),),
                            ]
                          ),
                        ),
                         if (discount.toString()!= "0")
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(5),
                            ),
                            height: 25,
                            width: 45,
                            padding: EdgeInsets.all(5),
                            child: Center(child: Text("-" + discount.toString() + "%", style: TextStyle(color: Colors.white),)),),
                        ), 

                        Text(productName.toString(), maxLines: 1,
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black),),
                        SizedBox(height: 10),
                        if (discount.toString()!= "0")
                      Column(
                        children: [
                          Text("UGX: " + formatter.format(priceValue), style: TextStyle(fontSize: 12, color: Colors.grey,
                          decoration: TextDecoration.lineThrough,),),
                          Text("UGX: " + formatter.format(newPrice), style: TextStyle(fontSize: 12, color: Color(0xFF3783b5)),
                          
                          ),
                        ],
                      )
                      else
                        Text("UGX: " + formatter.format(priceValue), style: TextStyle(fontSize: 15, color: Color(0xFF3783b5)),),
                      ]
                    ),
                  ),
              ),
          ),
            ),
      onTap: (){
        if (status.toString() == "1") {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => ProductDetails(productId: productId, vemdorId: vendorId ,productDesc: productDesc,productName: productName,productPrice: productPrice, productImage1: thumbnailUrl,
              productImage2: thumbnailUrl2, subcategoryId: widget.subcategoryId, status: status, discount: discount
              )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Product Out Of Stock"),
    ));
        }},
    );
  }

void add() {
  setState(() {
    _n++;
  });
}
void minus() {
  setState(() {
    if (_n != 1) 
      _n--;
  });
}

void _addToCart() async {
    var id = await DatabaseHelper.instance.insert(
      Cart(
        product_id: widget.productId, 
        vendor_id: widget.vemdorId, 
        product: widget.productName, 
        image: widget.productImage1, 
        price: newPrice.toString(), 
        sold_quantity: _n));
    setState(() {
      getItemCount();
      cartList.insert(0, Cart(
        id: id, 
        product_id: widget.productId, 
        vendor_id: widget.vemdorId, 
        product: widget.productName, 
        image: widget.productImage1, 
        price: widget.productPrice, 
        sold_quantity: _n));
    });
  }

  void checkIfProductsExists() {
      DatabaseHelper.instance.productExist(widget.productName).then((value) {
      setState(() {
        if(value < 1){
          _addToCart();
          flutterToast.showToast(
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(Icons.check, color: Colors.white,),
            SizedBox(
            width: 12.0,
            ),
            Text("Product Added to Cart",style: TextStyle(color: Colors.white),),
        ],
        ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
        );
        }else {
          findQty();
        flutterToast.showToast(
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(Icons.check, color: Colors.white,),
            SizedBox(
            width: 12.0,
            ),
            Text("Product Alredy Exists In Your Cart",style: TextStyle(color: Colors.white),),
        ],
        ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
        );
        }
      }); 
    }).catchError((error) {
      print(error);
    });
}

void findQty() {
      DatabaseHelper.instance.oneRow(widget.productName).then((value) {
      print(value);
      setState(() {
      //  grandTotal = value;
      });
    }).catchError((error) {
      print(error);
    });
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

}