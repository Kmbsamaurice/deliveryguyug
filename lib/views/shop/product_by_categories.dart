import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_loading_widget.dart';
import 'package:flutter_shimmer_widget/templates_shimmer_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/shop/product_details.dart';
import 'package:thedeliveryguyug/views/shop/search_products.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';

class  ProductByCategory extends StatefulWidget {
  String categoryName, categoryId;

  ProductByCategory({this.categoryName, this.categoryId});

  @override
  _ProductByCategoryState createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> {
  int itemCount = 0;
  final formatter = new NumberFormat("#,###");
  List products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.getItemCount();
    this.fetchProducts();
  }

  fetchProducts() async{
    setState(() {
      isLoading = true;
    });
      Map catid = {"catid": widget.categoryId};
    var response = await http.post(Uri.parse(Connections.URL_PRODUCTS_BY_CATEGORY), body: catid);
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(widget.categoryName),
      backgroundColor: Color(0xFF3783b5),

      actions: <Widget>[
            IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){
              Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => SearchProducts()),);
            }),
            _shoppingCartBadge(),

          ],
  
      ),
    body: getBody(),

      );
    }
  
Widget loader(){
    return Container(
            height: double.infinity,
            width: double.infinity,
              child: SingleChildScrollView(
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
                     //   SimpleTextPlaceholder(),
                     // CardPlaceHolderWithAvatar(),
                    //  CardPlaceHolderWithAvatar(),
                    
                    horizontalLoader(),
                    horizontalLoader(),
                    horizontalLoader(),
                      
                      ]
                    )
                    
                  ],
                ),
              ),
            );
}

Widget horizontalLoader(){
  return Row(
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
                    );
                    }
  Widget getBody(){
    if(products.contains(null) || products.length < 0 || isLoading){
      return loader();
    }
    return GridView.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width /
          500),
          itemBuilder: (context, index) {
          return getProducts(products[index]);
                    });
  }
  Widget getProducts(index){
    var productDesc = index['description'];
    var productName = index['product'];
    var productPrice = index['price'];
    var vendorId = index['vendor_id'];
    var thumbnailUrl = index['image1'];
    var thumbnailUrl2 = index['image2'];
    var productId = index['product_id'];
    var subcategoryId = index['subid'];
    var status = index['status'];
    var discount = index['discount'];
    int priceValue = int.parse(productPrice.toString());
    double discountValue = (int.parse(discount.toString()) / 100) * priceValue;
    double newPrice = priceValue - discountValue;
    return InkWell(
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
                        child:  Stack(
                          children:[ Center(
                            child: Hero(
                              tag: "image${'image1'}",
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
                      Text("UGX: " + formatter.format(priceValue), style: TextStyle(fontSize: 12, color: Color(0xFF3783b5)),),
                    ]
                  ),
                ),
            ),
          ),
      onTap: (){
         if (status.toString() == "1") {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => ProductDetails(productId: productId, vemdorId: vendorId ,productDesc: productDesc,productName: productName,productPrice: productPrice, productImage1: thumbnailUrl,
              productImage2: thumbnailUrl2, subcategoryId: subcategoryId, status: status, discount: discount
              )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Product Out Of Stock"),
    ));
        }},
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

}