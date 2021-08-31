import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendor_application_client/app_theme.dart';

import 'account.dart';
import 'categories.dart';
import 'home.dart';
import 'main.dart';
import 'orders.dart';

class NavigationDrawerBottom extends StatefulWidget {
  @override
  _NavigationDrawerBottomState createState() => _NavigationDrawerBottomState();
}

class _NavigationDrawerBottomState extends State<NavigationDrawerBottom> {
  int selectedIndex = 0;
  List<Widget> navigationOptions = <Widget>[HomePage() , CategoriesPage() , OrdersPage() , AccountPage()] ;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
            backgroundColor: Theme.of(context).secondaryHeaderColor),
        BottomNavigationBarItem(
            icon: Icon(Icons.category, color: Colors.white),
            label: 'Categories',
            backgroundColor: Theme.of(context).secondaryHeaderColor),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag, color: Colors.white),
            label: 'My Orders',
            backgroundColor: Theme.of(context).secondaryHeaderColor),
        BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Accounts',
            backgroundColor: Theme.of(context).secondaryHeaderColor),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Theme.of(context).accentColor,
      onTap: onItemTapped,
    );
  }
}

Widget navDrawerBottom() {
  NavigationDrawerBottom navigationDrawerBottom = new NavigationDrawerBottom() ;
  return navigationDrawerBottom ;
}