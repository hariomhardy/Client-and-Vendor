import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/login.dart';
import 'package:vendor_application_vendor/sub_categories.dart';
import 'account.dart';
import 'app_theme.dart';
import 'home.dart';
import 'notification.dart';
import 'orders.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/orders' : (context) => OrdersPage() ,
        '/account' : (context) => AccountPage() ,
        '/notification' : (context) => NotificationPage() ,
        '/login' : (context) => EmailLoginPage() ,
        '/signUp' : (context) => EmailSignUpPage() ,
        '/forgetPassword' : (context) => ResetPassword() ,
      },
      supportedLocales: [
        Locale("af"),
        Locale("am"),
        Locale("ar"),
        Locale("az"),
        Locale("be"),
        Locale("bg"),
        Locale("bn"),
        Locale("bs"),
        Locale("ca"),
        Locale("cs"),
        Locale("da"),
        Locale("de"),
        Locale("el"),
        Locale("en"),
        Locale("es"),
        Locale("et"),
        Locale("fa"),
        Locale("fi"),
        Locale("fr"),
        Locale("gl"),
        Locale("ha"),
        Locale("he"),
        Locale("hi"),
        Locale("hr"),
        Locale("hu"),
        Locale("hy"),
        Locale("id"),
        Locale("is"),
        Locale("it"),
        Locale("ja"),
        Locale("ka"),
        Locale("kk"),
        Locale("km"),
        Locale("ko"),
        Locale("ku"),
        Locale("ky"),
        Locale("lt"),
        Locale("lv"),
        Locale("mk"),
        Locale("ml"),
        Locale("mn"),
        Locale("ms"),
        Locale("nb"),
        Locale("nl"),
        Locale("nn"),
        Locale("no"),
        Locale("pl"),
        Locale("ps"),
        Locale("pt"),
        Locale("ro"),
        Locale("ru"),
        Locale("sd"),
        Locale("sk"),
        Locale("sl"),
        Locale("so"),
        Locale("sq"),
        Locale("sr"),
        Locale("sv"),
        Locale("ta"),
        Locale("tg"),
        Locale("th"),
        Locale("tk"),
        Locale("tr"),
        Locale("tt"),
        Locale("uk"),
        Locale("ug"),
        Locale("ur"),
        Locale("uz"),
        Locale("vi"),
        Locale("zh")
      ],

    );

  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  List<Widget> navigationOptions = <Widget>[HomePage() ,  SubCategoryPage() , OrdersPage() , NotificationPage() , AccountPage()] ;
  List<String> titles = <String>['Home' , 'Categories' , 'Orders' , 'Notification' , 'Account'] ;
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
              icon: Icon(Icons.add_alert, color: Colors.white),
              label: 'Notificaiton',
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
