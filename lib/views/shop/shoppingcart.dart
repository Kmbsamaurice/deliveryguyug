import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thedeliveryguyug/helpers/dbHelper.dart';
import 'package:thedeliveryguyug/models/cart.dart';
import 'package:thedeliveryguyug/views/shop/categories.dart';
import 'package:thedeliveryguyug/views/shop/search_products.dart';
import 'package:thedeliveryguyug/views/shop/shopdeliverydetails.dart';
class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final formatter = new NumberFormat("#,###");
  // ignore: deprecated_member_use
  List<Cart> cartList = new List();
  var grandTotal = "0";
  int itemCount = 0;
  bool setVisibility = false;

  // ignore: deprecated_member_use
 
  @override
  void initState() {
    super.initState();
    this.getItemCount();
    this.fetchItems();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Color(0xFF3783b5),
        title: Text('Shopping Cart'),
        actions: <Widget>[
            IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => SearchProducts()),);
            }),
            _shoppingCartBadge(),
          ],
        ),

        body: (setVisibility == true) ? getBody(): emptyCart(),
        
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

        },
      ),
    );
  }
Widget emptyCart(){
  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/cart_error.png',
          height: 100,),
          SizedBox(height: 15),
          Text("Your cart is empty"),
          SizedBox(height: 15),
              MaterialButton(
                height: 45.0,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
                color: Colors.grey[100],
                textColor: Colors.grey,
                child: Text('Continue Shopping'),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => CategoryActivity()),
                  );
                }, 
              ),
        ],)
    ),
  );
}
  Widget getBody(){
   return Container(
    color: Colors.grey[300],
    width: double.infinity,
    height: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
        child: Container(
          child: cartList.isEmpty
          ? Container()
          : ListView.builder(itemBuilder: (ctx, index) {
            if (index == cartList.length) return null;
              String qty = cartList[index].sold_quantity.toString();
              int subTotal = int.parse(cartList[index].price) * cartList[index].sold_quantity;
            return Container(
              child: Card(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [ 
                    Row(
                      children: [
                        Expanded(
                        flex: 25,
                        child: Hero(
                          tag: "image${cartList[index].image.toString()}",
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/images/icon.png",
                            image: cartList[index].image,
                            width: double.infinity,
                            fit: BoxFit.fill,),
                            ),
                          ),
                        
                        Expanded(
                          flex: 75,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cartList[index].product, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                SizedBox(height:5),
                                Text('UGX: ' + formatter.format(int.parse(cartList[index].price))),
                                SizedBox(height:5),
                                Row(
                                  children: [
                                    Text('Subtotal'),
                                    Spacer(),
                                    Text('UGX: ' + formatter.format(subTotal)),
                                  ],
                                )
                        ],
                      ),
                          ),
                  )
              ],
            ),
            Container (
              width: double.infinity,
              height: 1,
              color: Colors.grey,
            ),
            Row(
              children: [
                  Row(
                    children: [
                      IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey,),
                      onPressed: () { 
                        _deleteTask(cartList[index].id);
                        getItemCount();
                      
                      },
                      ),
                      Text('Delete')
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.grey,), 
                      onPressed: (){
                        if (cartList[index].sold_quantity != 1) {
                          cartList[index].sold_quantity--;

                          setState(() { 
                          qty = cartList[index].sold_quantity.toString();
                          DatabaseHelper.instance.updateItemQuantity(cartList[index].sold_quantity, cartList[index].product);
                          calcTotal();
                          });
                        }     
                      }),

                      Text(qty),

                      IconButton(icon: Icon(Icons.add_circle_outline), color: Colors.grey, 
                      onPressed: (){
                        cartList[index].sold_quantity++;
                       setState(() { 
                          qty = cartList[index].sold_quantity.toString();
                          DatabaseHelper.instance.updateItemQuantity(cartList[index].sold_quantity, cartList[index].product);
                          calcTotal();
                          });

                      }),
                    ],
                    
                  ),
              ],
            )
            ],
                ),
          ),
        );
        }),
        ),
        ),

        Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                  Spacer(),
                  Text("UGX: " + formatter.format(int.parse(grandTotal)), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3783b5)),)
                ],
              ),
              SizedBox(height: 10),
              MaterialButton(
                height: 45.0,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
                color: Color(0xFF3783b5),
                textColor: Colors.white,
                child: Text('Place your order'),
                      
                  onPressed: (){
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => ShopDeliveryDetails(orderTotal: grandTotal,)),
                  );
                }, 
              ),
              SizedBox(height: 10),

              MaterialButton(
                height: 45.0,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFF3783b5), width: 2),
                borderRadius: BorderRadius.circular(5)
                ),
                color: Colors.white,
                textColor: Color(0xFF3783b5),
                child: Text('Buy more Products'),
                      
                  onPressed: (){
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => CategoryActivity()),);
                }, 
              ),
              SizedBox(height: 10),
            ],),
        )
    ],

  ),
    
);
}

void fetchItems(){
    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          cartList.add(Cart(
            id: element['id'], 
            product_id: element['itemId'],
            vendor_id: element['vendor_id'],
            product: element['product'],
            image: element['image'],
            price: element['price'],
            sold_quantity: element['sold_quantity']
            
            ));
        });
      });
    }).catchError((error) {
      print(error);
    });

}
void calcTotal() {
      DatabaseHelper.instance.getTotal().then((value) {
      //print(value);
      setState(() {
        grandTotal = value;
      });
    }).catchError((error) {
      print(error);
    });

}

void _deleteTask(int id) async {
    await DatabaseHelper.instance.delete(id);
    setState(() {
      cartList.removeWhere((element) => element.id == id);
    });
  }

    void getItemCount() {
      DatabaseHelper.instance.getCount().then((value) {
        if(value != 0){
          setState(() {
            itemCount = value;
            setVisibility = true;
            calcTotal();
          });   
        }else {
          setState(() {
            setVisibility = false;
            itemCount = value;
          });
        }
    }).catchError((error) {
      print(error);
    });
}


}