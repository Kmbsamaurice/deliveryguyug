import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/views/shop/search_products.dart';
import 'package:thedeliveryguyug/views/shop/shoppingcart.dart';
import 'package:thedeliveryguyug/views/shop/subcategories.dart';

class  CategoryActivity extends StatefulWidget {
  @override
  _CategoryActivityState createState() => _CategoryActivityState();
}

class _CategoryActivityState extends State<CategoryActivity> {
  List categories = [];
  bool isLoading = false;
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    this.getItemCount();
    this.fetchCategories();
  }

  fetchCategories() async{
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Connections.URL_CATEGORY);
    var response = await http.get(url);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        categories = items;
        isLoading = false;
      });
    }else {
      setState(() {
        categories = [];
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Shops"),
      backgroundColor: Color(0xFF3783b5),
      
      actions: <Widget>[
            IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){
               Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => SearchProducts()));
            }),
            _shoppingCartBadge(),

          ],
      ),
    body: getBody(),
      
    );
  }
  Widget getBody(){
    if(categories.contains(null) || categories.length < 0 || isLoading){
      return loader();
    }
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          ),
      itemCount: categories.length,
      itemBuilder: (context, index){
      return getCategories(categories[index]);
    });

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
              ),
            );
  }
  Widget getCategories(index){
    var categoryName = index['category'];
    var categoryId = index['catid'];
    var thumbnailUrl = index['image'];
    var status = index['status'];
    return 
    InkWell(
          child: Container(
          margin: EdgeInsets.all(5),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: 
              <Widget>[
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF3783b5),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      padding: EdgeInsets.all(5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Hero(
                        tag: "image11",
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/images/icon.png",
                          image: thumbnailUrl.toString(),
                          width: 70,
                          height: 70,
                          fit: BoxFit.fill,),),
                          )
                    ),
                    SizedBox(height:10),
                    Text(categoryName.toString(), textAlign: TextAlign.center,),
                  ],
                ),
             
              ]
            ),
          ),
        onTap: (){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => SubCategories(thumbnailUrl: thumbnailUrl, categoryName: categoryName, categoryId: categoryId)));
        },
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