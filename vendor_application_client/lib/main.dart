import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/category_card.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';

import 'app_theme.dart';
import 'cart.dart';
import 'home.dart';
import 'notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart' ;
import 'database_models/user.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print(message.data);
  flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
        ),
      ));
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  AndroidInitializationSettings initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  InitializationSettings initializationSettings = InitializationSettings(android: initialzationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);



  runApp(App());
}

ThemeData theme = themes[0].themeData;

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();

  static void setTheme(BuildContext context, Themes newTheme) {
    _AppState state = context.findAncestorStateOfType();
    state.setState(() {
      theme = newTheme.themeData;
    });
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Project',
      theme: theme,
      home: InitializedWidget() ,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/home' : (context) => HomePage() ,
        '/categories' : (context) => CategoriesPage() ,
        '/orders' : (context) => OrdersPage() ,
        '/account' : (context) => AccountPage() ,
        '/cart' : (context) => CartPage() ,
        '/notification' : (context) => NotificationPage() ,
        '/categoryActivity' : (context) => CategoryCardActivity() ,
      },
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  List<Widget> navigationOptions = <Widget>[HomePage() , CategoriesPage() , OrdersPage() , AccountPage()] ;
  List<String> titles = <String>['Home' , 'Categories' , 'Orders' , 'Account'] ;
  int selectedIndex = 0;
  String title_curr = 'Home';

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      title_curr = titles.elementAt(selectedIndex);
    });
  }

  void _selectTheme(Themes theme) {
    setState(() {
      App.setTheme(context, theme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title_curr ,
        style: GoogleFonts.lato(
          fontSize: 24 ,
          fontWeight: FontWeight.bold ,
          color: Colors.white,
        ),),
        actions: [
          IconButton(
            icon : Icon(Icons.add_alert , color: Colors.white,) ,
            onPressed: () {
              Navigator.pushNamed(context, '/notification') ;
            },
          ),
          IconButton(
            icon : Icon(Icons.shopping_cart, color: Colors.white,) ,
            onPressed: () {
              Navigator.pushNamed(context, '/cart') ;
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert , color : Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 1,
                child : PopupMenuButton(
                  child: Container(
                    child: Row(
                      children: [
                        Text(
                          'Theme',
                        ),
                      ],
                    ),
                  ),
                  elevation: 3.2,
                  initialValue: themes[0],
                  onCanceled: () {
                    print("Nothing  Selected");
                  },
                  onSelected: _selectTheme,
                  itemBuilder: (BuildContext context) {
                    return themes.map((Themes theme) {
                      return PopupMenuItem(
                        value: theme,
                        child: Text(theme.themeName),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),

        ],
      ),
      body: navigationOptions.elementAt(selectedIndex) ,
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}

