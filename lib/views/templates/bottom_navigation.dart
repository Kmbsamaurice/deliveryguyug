import 'package:flutter/material.dart';
import 'package:thedeliveryguyug/views/templates/mainactivity.dart';
import 'package:thedeliveryguyug/views/account/myaccount.dart';
import 'package:thedeliveryguyug/views/account/support.dart';
class BottomNavigate extends StatefulWidget {
  @override
  _BottomNavigateState createState() => _BottomNavigateState();
}

class _BottomNavigateState extends State<BottomNavigate> {
  int _selectedPage = 0;
  final _pageOptions = [
  MainActivity(),
  MyAccount(),
  Support(),
];

 
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedPage,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          onTap: (int index) {
            setState((){
              _selectedPage = index;
            });
          },
          items: [
             BottomNavigationBarItem(
               icon: Icon(Icons.home,),
               label: 'Home',
               backgroundColor: Color(0xFF3783b5)),

             BottomNavigationBarItem(
               icon: Icon(Icons.person),
               label: 'My Account',
               backgroundColor: Color(0xFF3783b5)),

             BottomNavigationBarItem(
               icon: Icon(Icons.help),
               label: 'Support',
               backgroundColor: Color(0xFF3783b5)),
          ],
          ),
    );
  }


}