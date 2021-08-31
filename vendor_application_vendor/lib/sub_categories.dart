import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/items.dart';
import 'package:vendor_application_vendor/sub_categories_add.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'app_theme.dart';
import 'database_models/category.dart';
import 'database_functions/vendor_functions.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SubCategoryPage extends StatefulWidget {
  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchCategories = <String>[];
  List<Category> categories = <Category>[];
  List<Category> currentCategories = <Category>[] ;
  bool progressIndicatorValue = true ;
  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(indicatorType: Indicator.ballRotateChase , color: Theme.of(context).primaryColor ))) ;
  }
  TextEditingController searchBar = new TextEditingController()  ;
  bool initData = true  ;

  searchResult() {
    print(searchBar.text) ;
    List newCurrentCategories = <Category> [] ;
    for (int i = 0 ; i < categories.length ; i++ ) {
      if (categories.elementAt(i).categoryName.startsWith(searchBar.text)) {
        newCurrentCategories.add(categories.elementAt(i)) ;
      }
    }
    setState(() {
      currentCategories = newCurrentCategories ;
    });
  }

  loadInitData() async {
    if (initData) {
      categories = await loadCategory() ;
      for (int i = 0; i < categories.length; i++) {
        searchCategories.add(categories
            .elementAt(i)
            .categoryName);
      }
      currentCategories = categories ;
      print(categories);
      print(searchCategories);
      initData = false ;
    }
  }

  @override
  void initState() {
    super.initState() ;
    print('Home Pages Called') ;
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult now){
      if (now == ConnectivityResult.none) {
        print('Not Connected') ;
        internetStatus = false ;
        noInternetConnectionDialog(context) ;
      }else if (previous == ConnectivityResult.none){
        print('Connected') ;
        if (internetStatus == false ) {
          internetStatus = true ;
          Navigator.pop(context) ;
        }
      }
      previous = now ;
    }) ;
  }

  @override
  void dispose() {
    super.dispose() ;
    connectivitySubscription.cancel() ;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:  loadInitData() ,
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics() ,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: SimpleAutoCompleteTextField(
                          key: null,
                          suggestions: searchCategories,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search Category',
                          ),
                          controller: searchBar,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(
                          Icons.search,
                          color: Theme
                              .of(context)
                              .secondaryHeaderColor,
                          size: 28,
                        ),
                        onPressed: () {
                          searchResult() ;
                        },
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                    primary: false,
                    physics: NeverScrollableScrollPhysics() ,
                    shrinkWrap: true,
                    itemCount: currentCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex : 1,
                                    child: currentCategories
                                        .elementAt(index)
                                        .image == null ?
                                    Image.asset(
                                      'assets/images/bakery_kirana.png', height: 50,
                                      width: 50,) : Image.network(currentCategories
                                        .elementAt(index)
                                        .image,
                                      height: 50, width: 50,),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ItemsPage( category: currentCategories.elementAt(index), )
                                            )
                                        );
                                      },
                                      child: AutoSizeText(currentCategories
                                          .elementAt(index)
                                          .categoryName,
                                        style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black
                                        ), maxLines: 1 ,),
                                    ),
                                  ),

                                ],
                              )
                          ),
                        ),
                      );
                    }),

              ],
            );
          }
          else {
            return progressIndicator() ;
          }

        }
    );
  }
}

