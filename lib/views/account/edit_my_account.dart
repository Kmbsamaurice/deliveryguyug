import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:thedeliveryguyug/helpers/place_service.dart';
import 'package:thedeliveryguyug/views/templates/address_search.dart';
import 'package:thedeliveryguyug/views/account/userlogin.dart';
import 'package:uuid/uuid.dart';
  
class EditAccount extends StatefulWidget {

  @override
  _EditAccountState createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  ProgressDialog pr;
  bool _isLoading = false;
  SharedPreferences prefs;
  bool value = false;
  final _formKey = GlobalKey<FormState>();

  File uploadimage;
  final picker = ImagePicker();

  String storeId = "";
  String firstName = "";
  String lastName = "";
  String phoneText = "";
  String profile = "";
  String busName = "";
  String busLoc = "";
  String phoneNum = "";


  @override
  void initState() {
    super.initState();
      checkLoginStatus();
  }
  
  
  Future<void> chooseImage() async {
    var choosedimage = await picker.getImage(source: ImageSource.gallery);
        //set source: ImageSource.camera to get image from camera
      setState(() {
          uploadimage = File(choosedimage.path);
           uploadImage();
          //print(uploadimage);
      });
  }

  Future<void> uploadImage() async {
     //show your own loading or progressing code here
     pr.show();

     var uploadurl = Uri.parse(Connections.URL_EDIT_PROFILE_PICTURE);
     //dont use http://localhost , because emulator don't get that address
     //insted use your local IP address or use live URL
     //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    try{
      List<int> imageBytes = uploadimage.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      //convert file image to Base64 encoding
      var response = await http.post(
              uploadurl, 
              body: {
                 'image': baseimage,
                 'store_id': storeId
              }
      );
      if(response.statusCode == 200){
        pr.hide();
        prefs.clear();
        prefs.commit();
        Navigator.push(context,MaterialPageRoute(builder: (context) => UserLogin()),);
        /*
         var jsondata = json.decode(response.body); //decode json data
         if(jsondata["error"]){ //check error sent from server
             print(jsondata["message"]);
             //if error return from server, show message from server
             pr.hide();
         }else{
           pr.hide();
             print("Upload successful");
         }
         */
      }else{
        print(response.body.toString());
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    }catch(e){
      print(e);
       //print("Error during converting to Base64");
       //there is error during converting file image to base64 encoding. 
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(
    message: 'Please wait...',
    borderRadius: 10.0,
    backgroundColor: Colors.white,
    progressWidget: CircularProgressIndicator(),
    elevation: 10.0,
    insetAnimCurve: Curves.easeInOut,);
    return Scaffold(
      appBar: AppBar(
      title: Text('Profile Details'),
      backgroundColor: Color(0xFF3783b5),

      actions: <Widget>[
            TextButton(child: Text('SAVE', style: TextStyle(fontSize: 15, color: Colors.white),), 
            onPressed: (){
              if (!_formKey.currentState.validate()) {
                return;
              } else {
                //uploadImage();
                pr.show();
                editUser();
                        }
            }),

          ],
  
      ),
      body: profileView()// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  checkLoginStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      storeId = prefs.getString('store_id') ?? '';
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
      phoneText = prefs.getString('phone_number') ?? '';
      profile = prefs.getString('image') ?? '';
      busName = prefs.getString('store_name') ?? '';
      busLoc = prefs.getString('location') ?? '';
      phoneNum = '0' + phoneText.substring(4);
    });

  }
 
  Widget profileView() {
    return Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                color: Color(0xFF3783b5),
                height: 250,
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
                        child: InkWell(
                          onTap: (){
                            chooseImage();
                          },
                          child: Icon(Icons.add_a_photo, color: Colors.white,)),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                    SizedBox(height:10),
                     TextFormField(
                       enabled: false,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      controller: TextEditingController(
                        text: firstName),
                      // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'First Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid Name';
                        
                      }
                    },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: ('Enter First Name'),
                        labelText: ('First Name'),
                        labelStyle: TextStyle(
                          color: Color(0xFF3783b5),
                          fontSize: 12),
                          border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                      ),
                      SizedBox(height:10),
                      SizedBox(height:10),

                     TextFormField(
                       enabled: false,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      controller: TextEditingController(
                        text: lastName,),
                      // ignore: missing_return
                    validator: (value){
                      if (value.isEmpty) {
                        return 'Last Name is Required';
                      } if (value.length < 3) {
                        return 'Enter valid Name';
                        
                      }
                    },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: ('Enter Last Name'),
                        labelText: ('Last Name'),
                        labelStyle: TextStyle(
                          color: Color(0xFF3783b5),
                          fontSize: 12),
                          border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                      ),
                      SizedBox(height:10),
                      SizedBox(height:10),
                     TextFormField(
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      controller: new TextEditingController.fromValue(new TextEditingValue(
                        text: phoneNum,
                        selection: new TextSelection.collapsed(
                          offset: phoneNum.length))),
                        
                      onChanged: (val) => phoneNum = val,
                      // ignore: missing_return
                      validator: (value){
                        if (value.isEmpty) {
                          return 'Phone Number is Required';
                        } if (value.length != 10) {
                          return 'Enter valid  number eg (0784912802)';   
                        } 
                        String pattern = r'((070|075|077|078|071|079|074|076|072)[0-9]{7})';
                        RegExp regExp = new RegExp(pattern);
                        if (!regExp.hasMatch(value)) {
                          return 'Enter valid  number eg (0784912802)'; 
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.call),
                        hintText: ('Enter Phone Number'),
                        labelText: ('Phone Number'),
                        labelStyle: TextStyle(
                          color: Color(0xFF3783b5),
                          fontSize: 12),
                          border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                      ),
                      SizedBox(height:10),
                      SizedBox(height:10),
                   TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    controller: new TextEditingController.fromValue(new TextEditingValue(
                        text: busName,
                        selection: new TextSelection.collapsed(
                          offset: busName.length))),
                        
                      onChanged: (val) => busName = val,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.business),
                      hintText: ('Enter Business Name'),
                      labelText: ('Business Name'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                    ),
                    SizedBox(height:10),
                    SizedBox(height:10),
                    
                   TextFormField(
                    textInputAction: TextInputAction.done,
                    readOnly: true,
                    onTap: () async {
                      // generate a new token here
                      final sessionToken = Uuid().v4();
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(sessionToken),
                        );

                        if (result != null) {
                                var addresses = await Geocoder.local.findAddressesFromQuery(result.description);
                                var first = addresses.first;

                                setState(() {
                                  busLoc = result.description ; first.coordinates.longitude;

                                });
                              }
                    },
                    controller: new TextEditingController.fromValue(new TextEditingValue(
                        text: busLoc,
                        selection: new TextSelection.collapsed(
                          offset: busLoc.length))),
                        
                      onChanged: (val) => busLoc = val,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.place),
                      hintText: ('Enter Business Location'),
                      labelText: ('Business Location'),
                      labelStyle: TextStyle(
                        color: Color(0xFF3783b5),
                        fontSize: 12),
                        border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                    ),
                    SizedBox(height:10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

Future <void> editUser() async {
  var url = Uri.parse(Connections.URL_EDIT_PROFILE);
  var sending = await http.post(url, body: {
    "store_id" : storeId,
    "store_name" : busName,
    "location" : busLoc,
    "phone_number" : '+256' + phoneNum.substring(1),
    });
    if (sending.statusCode == 200) {
      pr.hide();
      prefs.clear();
      prefs.commit();
      Navigator.push(context,MaterialPageRoute(builder: (context) => UserLogin()
      ),
      );
      }
    }

}