import 'package:flutter/material.dart';
import 'package:thedeliveryguyug/views/deliveries/delivery_orders.dart';
import 'package:thedeliveryguyug/views/shop/shop_orders.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> with TickerProviderStateMixin{
  TabController _tabController;

    @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text("My Orders"),
        backgroundColor: Color(0xFF3783b5),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.orangeAccent,
          tabs: <Tab>[
            new Tab(
              text: "Deliveries",
              icon: new Icon(Icons.delivery_dining),),
              
            new Tab(
              text: "Shop Orders",
              icon: new Icon(Icons.shopping_cart),),
                ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
         body: TabBarView(
        children: [
          DeliveryOrders(),
          ShopOrders(),
        ],
        controller: _tabController,
      ),

      
    );
  }
}