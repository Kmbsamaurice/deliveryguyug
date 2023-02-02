import 'package:flutter/material.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'package:flutter_shimmer_widget/templates_shimmer_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thedeliveryguyug/helpers/connections.dart';
import 'package:thedeliveryguyug/helpers/district_search.dart';
import 'package:thedeliveryguyug/views/deliveries/upcountry.dart';

class  UpcountryTariffs extends StatefulWidget {
  @override
  _UpcountryTariffsState createState() => _UpcountryTariffsState();
}

class _UpcountryTariffsState extends State<UpcountryTariffs> {
  List districts = [];
  bool isLoading = false;
  final formatter = new NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    this.fetchDistricts();
  }

  fetchDistricts() async{
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Connections.URL_UPCOUNTRY);
    var response = await http.get(url);
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
      title: Text("Upcountry Tariffs"),
      backgroundColor: Color(0xFF3783b5),

      actions: <Widget>[
            IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: (){

          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => SearchDistrict()
              ));
            }),

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
                      children:[
                        SizedBox(height: 20, ),
                        listLoader(),
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
            );
  }

  Widget listLoader() {
    return  Container(
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
    );
  }
  Widget getBody(){
    if(districts.contains(null) || districts.length < 0 || isLoading){
      return loader();
    }
    return ListView.separated(
      itemCount: districts.length,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 1),
      itemBuilder: (context, index){
      return getDistricts(districts[index]);
    });
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