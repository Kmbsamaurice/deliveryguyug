import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/shop/productactivity.dart';
import 'package:thedeliveryguyug/views/shop/search_products.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';

class  SubCategories extends StatefulWidget {
  String thumbnailUrl, categoryName, categoryId;

  SubCategories({this.thumbnailUrl, this.categoryName, this.categoryId});

  @override
  _SubCategoriesState createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  List subcategories = [];
  bool isLoading = false;
  final formatter = new NumberFormat("#,###");
  DatabaseHelper databaseHelper;
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    this.getItemCount();
    this.fetchSubcategories();
  }

  fetchSubcategories() async{
    setState(() {
      isLoading = true;
    });
    Map catid = {"catid": widget.categoryId};
    var url = Uri.parse(Connections.URL_SUBCATEGORIES);
    var response = await http.post(url, body: catid);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        subcategories = items;
        isLoading = false;
      });
    }else {
      setState(() {
        subcategories = [];
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(widget.categoryName),
      backgroundColor: Color(0xFF3783b5),
      
      actions: <Widget>[
            IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){
               Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => SearchProducts()));
            }),
            _shoppingCartBadge(),

          ],
      ),
    body: getBody()
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
    if(subcategories.contains(null) || subcategories.length < 0 || isLoading){
      return loader();
    }
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: subcategories.length,
      itemBuilder: (context, index){
      return getSubCategories(subcategories[index]);
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
    return  Row(
      children: [
        ClipRect(
          child: Container(
            color: Colors.grey[200],
            width: 50,
            height: 50,
          ),
        ),
        Container(
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
        ),
      ],
    );
  }

  Widget getSubCategories(index){
    var subcategoryName = index['subcategory'];
    var subcategoryId = index['subid'];
    var thumbnail = index['image'];
    return InkWell(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    ClipOval(
                      child: Hero(
                          tag: "image11",
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/images/icon.png",
                            image: thumbnail,
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,),),
                    ),
                    SizedBox(width: 10),
                    Text(subcategoryName.toString()),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios_sharp), 
                      onPressed: null)
                  ],
                )
             
              ]
            ),
          ),
        ),
      onTap: (){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => ProductActivity(subcategoryName: subcategoryName, subcategoryId: subcategoryId
              )));
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