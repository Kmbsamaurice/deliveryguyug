import 'package:flutter/material.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/views/account/edit_my_account.dart';
import 'package:thedeliveryguyug/views/templates/myorders.dart';
import 'package:thedeliveryguyug/views/account/userlogin.dart';
class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  SharedPreferences prefs;

  String firstName = "";
  String lastName = "";
  String phoneText = "";
  String profile = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      
    );
  }

 @override
  void initState() {
    super.initState();
      checkLoginStatus();
  }
  
  checkLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
      phoneText = prefs.getString('phone_number') ?? '';
      profile = prefs.getString('image') ?? '';
    });

  }

  Widget getBody(){
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              color: Color(0xFF3783b5),
              width: double.infinity,
              child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => EditAccount()
                      ),
                    );
                    },
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [ Stack(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 60,
                          child: ClipOval(child: Hero(
                                    tag: "image${'image'}",
                                    child: FadeInImage.assetNetwork(
                                      placeholder: "assets/images/noimage.png",
                                      image: profile,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.fill,),
                                ),),
                        ),
                        Positioned(bottom: 1, right: 1 ,child: Container(
                          height: 40, width: 40,
                          child: Icon(Icons.add_a_photo, color: Colors.white,),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                        ))
                        
                      ],
                    ),
                    ]
                ),
                  ),
                  SizedBox(height: 20),
                  Text(firstName + " " + lastName, style: TextStyle(
                    fontSize: 20, color: Colors.white,
                  )),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: (){
                       Navigator.push(context,MaterialPageRoute(builder: (context) => EditAccount()
                      ),
                    );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(phoneText, style: TextStyle(
                          fontSize: 15, color: Colors.white,
                        )),
                        SizedBox(width: 15),
                        Icon(Icons.edit, color: Colors.white,)
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            Container(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.delivery_dining),
                    title: Text('My Orders', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => MyOrders()
                      ),
                    );
                  },
                  ),
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Rate Us', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){
                    OpenAppstore.launch(androidAppId: "com.thedeliveryguyug", iOSAppId: "1565302025");

                  },
                  ),

                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Invite friend', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){
                    Share.share("Hello Friend Download The Delivery Guy Ug App and make your deliveries easy\n For Android: https://play.google.com/store/apps/details?id=com.thedeliveryguyug&hl=en \n and iOS: https://apps.apple.com/us/app/the-delivery-guy-ug/id1565302025");
                  },
                  ),

                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('Logout', style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  onTap: (){
                    prefs.clear();
                    prefs.commit();
                    Navigator.push(context,MaterialPageRoute(builder: (context) => UserLogin()
                      ),
                    );
                  },
                  ),
                ],),
            )
          ],
        ),
      ),
    );
  }
  
}