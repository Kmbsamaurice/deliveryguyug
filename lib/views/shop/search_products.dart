import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/shop/product_details.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';

class  SearchProducts extends StatefulWidget {

  @override
  _SearchProductsState createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  int itemCount = 0;
  final formatter = new NumberFormat("#,###");
  List products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.getItemCount();
  }

  fetchProducts(String query) async{
    setState(() {
      isLoading = true;
    });
      Map searchQuery = {"searchQuery": query};
      var url = Uri.parse(Connections.URL_SEARCH_PRODUCTS);
      var response = await http.post(url, body: searchQuery);
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
      title: Text('Find Product'),
      backgroundColor: Color(0xFF3783b5),

      actions: <Widget>[
            _shoppingCartBadge(),
          ],
  
      ),
    body: getBody(),

      );
    }

    Widget _searchBar(){
      return Container(
            height: 80,
            width: double.infinity,
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  autofocus: true,
                decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: ('Search for product...'),
                border: InputBorder.none,),
                obscureText: false,
                onChanged: (text){
                  int len = text.length;
                  if (len >= 3){
                fetchProducts(text);
                  }
          },
        ),
              ],
            ),
  );
}
    
  Widget getBody(){
   /* if(products.contains(null) || products.length < 0 || isLoading){
      return Center(child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.white,
        child: Center(
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Fetching Products..."),

            ],
          ),
        )));
    } */
    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width /
                (500),),
                itemBuilder: (context, index) {
                return getProducts(products[index]);
                          }),
        ),
      ],
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
                        child: Stack(
                            children: [
                              Center(
                                child: Hero(
                                tag: "image${vendorId.toString()}",
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/images/icon.png",
                                  image: thumbnailUrl.toString(),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.fill,),),
                              ),
                              if(status.toString() == "0")
                                Center(
                                    child: Container(
                                      color: Colors.grey[200],
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.only(top: 40),
                                      child: Text("Out of Stock",style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF3783b5) ),)),),                          
                            ],),                     
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
                       Text("UGX: " + formatter.format(priceValue), style: TextStyle(fontSize: 12, color: Color(0xFF3783b5)),
                       ),
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
        }
        },
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