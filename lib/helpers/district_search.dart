import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/views/deliveries/upcountry.dart';

class  SearchDistrict extends StatefulWidget {
  @override
  _SearchDistrictState createState() => _SearchDistrictState();
}

class _SearchDistrictState extends State<SearchDistrict> {
  List districts = [];
  bool isLoading = false;
  final formatter = new NumberFormat("#,###");


  fetchDistricts(String query) async{
    setState(() {
      isLoading = true;
    });
    Map searchQuery = {"searchQuery": query};
    var url = Uri.parse(Connections.URL_SEARCH_UPCOUNTRY);
    var response = await http.post(url, body: searchQuery);
    if(response.statusCode == 200){
      var items = json.decode(response.body);
      setState(() {
        districts = items;
        isLoading = false;
      });
    }else {
      setState(() {
        districts = [];
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Find District"),
      backgroundColor: Color(0xFF3783b5),

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
                decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: ('Search district here...'),
                border: InputBorder.none,),
                obscureText: false,
                onChanged: (text){
                fetchDistricts(text);
          },
        ),
              ],
            ),
  );
}

  Widget getBody(){
    /*if(districts.contains(null) || districts.length < 0 || isLoading){
      return Center(child: CircularProgressIndicator());
    }*/
    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: ListView.separated(
            itemCount: districts.length,
            separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
            itemBuilder: (context, index){
            return getDistricts(districts[index]);
          }),
        ),
      ],
    );
  }
  Widget getDistricts(index){
    var districtName = index['district'];
    var districtTarriff = index['tariff'];
    return InkWell(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(districtName.toString()),
                Text('UGX: ' + formatter.format(int.parse(districtTarriff.toString())),),
              ]
            ),
          ),
        ),
      ),
      onTap: (){
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => UpCountry(districtName: districtName, districtTarriff: districtTarriff
              )));
        },
    );
  }
}