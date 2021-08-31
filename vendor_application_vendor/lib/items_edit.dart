import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'package:vendor_application_vendor/utilities_functions/input_utilities.dart';
import 'package:vendor_application_vendor/utilities_functions/widgit_utilities.dart';
import 'database_functions/vendor_functions.dart';
import 'database_models/item.dart';
import 'database_models/vendor.dart';
import 'database_models/shop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_models/category.dart' ;
import 'package:cool_alert/cool_alert.dart';

class ItemsEditPage extends StatefulWidget {
  final Item item ;
  ItemsEditPage({Key  key , this.item}) : super(key : key) ;

  @override
  _ItemsEditPageState createState() => _ItemsEditPageState();
}

class _ItemsEditPageState extends State<ItemsEditPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  Category currentCategory ;
  List<Category> categories = <Category> [] ;
  List<String> quantities = ['kg' , 'liter' , 'pack' , 'set' ] ;
  String quantity = 'kg' ;
  Vendor vendor ;
  Shop currentShop ;
  List<Shop> shops = <Shop>[] ;
  bool initData = true  ;
  String imageUrl ;
  Item oldItem ;
  String currentShopId ;
  File image ;
  TextEditingController itemName = new TextEditingController() ;
  TextEditingController itemDescription = new TextEditingController() ;
  TextEditingController qty = new TextEditingController() ;
  TextEditingController mrp = new TextEditingController() ;
  TextEditingController bestPrice = new TextEditingController() ;
  bool progressIndicatorValue = true ;
  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(indicatorType: Indicator.ballRotateChase , color: Theme.of(context).primaryColor ))) ;
  }

  Future getImage({bool isCamera}) async {
    var imagePicker;
    if (isCamera == true) {
      imagePicker = await ImagePicker().getImage(source: ImageSource.camera , imageQuality: 30);
    } else {
      imagePicker = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 30);
    }
    setState(() {
      image = File(imagePicker.path);
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      /// both default to 16
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.remove,
      buttonSize: 56.0,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => null,
      onClose: () => null,
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.camera,
            color: Colors.white,
          ),
          backgroundColor: Colors.purple,
          label: 'Camera',
          labelStyle: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
          onTap: () => getImage(isCamera: true),
          onLongPress: () => getImage(isCamera: true),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.image,
            color: Colors.white,
          ),
          backgroundColor: Colors.purple,
          label: 'Gallery',
          labelStyle: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
          onTap: () => getImage(isCamera: false),
          onLongPress: () => getImage(isCamera: false),
        ),
      ],
    );
  }

  Future<void> saveChanges() async {
    print('Item Details : ') ;
    print('Image : ' + image.toString()) ;
    print('Category : ' + currentCategory.categoryName) ;
    print('Item Name : ' + itemName.text) ;
    print('Description : ' + itemDescription.text) ;
    print('Quantity : ' + qty.text) ;
    print('Quantity Type : '  + quantity) ;
    print('MRP Price : ' + mrp.text) ;
    print('Best Price : ' + bestPrice.text ) ;

    bool val = await validation();
    if (val) {
      String itemNameValue = capitalize(itemName.text.trim()) ;
      String descriptionValue = capitalize(itemDescription.text.trim()) ;
      int qtyValue = int.parse(qty.text.trim()) ;
      double mrpValue = double.parse(mrp.text.trim()) ;
      double bestValue ;
      if (bestPrice.text.trim().length == 0 ){
        bestValue = double.parse(mrp.text.trim()) ;
      }
      else {
        bestValue = double.parse(bestPrice.text.trim()) ;
      }
      // Database Update
      Item newItem = new Item.custom(
        vendorId: FirebaseAuth.instance.currentUser.uid ,
        shopId : currentShop.shopId ,
        category: currentCategory.categoryName ,
        productName: itemNameValue ,
        productDescription: descriptionValue ,
        quantity: qtyValue ,
        quantityType: quantity ,
        originalPrice: mrpValue ,
        discountPrice: bestValue ,
      ) ;
      newItem.itemId = widget.item.itemId ;
      bool val = await updateItem(newItem: newItem , oldItem: widget.item) ;
      if(val && image != null) {
        await updateImageItem(item: newItem , image: image) ;
      }
      if (val) {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            text: "Item updated Successfully !",
            onConfirmBtnTap: () {
              Navigator.pop(context) ;
              Navigator.pop(context) ;
            }
        );
      }else {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: 'Item is not updated ! Please Try Again' ,
            onConfirmBtnTap: () {
              Navigator.pop(context) ;
            }
        );
      }
    }
  }

  Future<bool> validation() async {
    // Product Name can't be null
    if (itemName.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Item Name Input Field',
        content: 'Please enter a valid item name \n It can\'t be left null',
      );
      return false;
    }
    // Product Description can't be null
    if (itemDescription.text.trim().length == 0 ) {
      await warningDialog(
        context: context,
        title: 'Item Description Input Field',
        content: 'Please enter a good description so that it would be able to describe its features \n It can\'t be left null',
      );
      return false;
    }
    // Quantity value should have any integer value
    try{
      int.parse(qty.text.trim()) ;
    }catch(error) {
      await warningDialog(
        context: context,
        title: 'Quantity Input Field',
        content: 'Quantity should be in integer format \n It can\'t be left null',
      );
      return false;
    }
    // MRP Price
    try{
      double.parse(mrp.text.trim());
    }catch(error) {
      await warningDialog(
        context: context,
        title: 'MRP Input Field',
        content: 'MRP Price should be in decimal format 1,1.23,2.5,etc \n It can\'t be left null',
      );
      return false;
    }
    // Best Price && can't be left null
    try{
      if(bestPrice.text.trim().length != 0 ) {
        double.parse(bestPrice.text.trim()) ;
      }
    }catch(error) {
      await warningDialog(
        context: context,
        title: 'Best Price Input Field',
        content: 'Best Price should be in decimal format 1,1.23,2.5,etc \n It can\'t be left null',
      );
      return false;
    }
    // MRP price and Best Price value should be less than 1 lakh
    if (mrp.text.trim().length != 0 && int.parse(mrp.text.trim()) <= 100000) {
      await warningDialog(
        context: context,
        title: 'MRP Input Field',
        content: 'MRP should be in decimal format and always be less than 1 lakh amount',
      );
      return false;
    }
    if (bestPrice.text.trim().length != 0 && int.parse(bestPrice.text.trim()) <= 100000) {
      await warningDialog(
        context: context,
        title: 'Best Price Input Field',
        content: 'Best Price should be in decimal format and always be less than 1 lakh amount',
      );
      return false;
    }
    // Best Price should be less than or equal to MRP Price
    if (bestPrice.text.trim().length != 0 ) {
      if (int.parse(bestPrice.text.trim()) > int.parse(mrp.text.trim())) {
        await warningDialog(
          context: context,
          title: 'Logic Error',
          content: 'Best Price should be less than or equal to MRP',
        );
        return false;
      }
    }
    if (image == null) {
      await warningDialog(
        context: context,
        title: 'Image Field',
        content: 'Please give a unique image to be recognized ',
      );
      return false;
    }
    return true ;
  }

  loadInitData() async {
    if (initData) {
      // Loaded all the categories
      categories = await loadCategory() ;
      currentCategory = categories.elementAt(0) ;
      // Loading all the shops
      shops = await getVendorShops(uid : FirebaseAuth.instance.currentUser.uid ) ;
      currentShop = shops.elementAt(0) ;
      //
      imageUrl = widget.item.image ;
      //currentCategory = await loadingCategoryByName(widget.item.category) ;
      //currentShop = await loadingShopById(uid: FirebaseAuth.instance.currentUser.uid , id : widget.item.shopId) ;
      for (int i = 0 ; i < categories.length ; i++) {
        if (widget.item.category == categories.elementAt(i).categoryName) {
          currentCategory = categories.elementAt(i) ;
        }
      }
      for (int i = 0 ; i < shops.length ; i++) {
        if (widget.item.shopId == shops.elementAt(i).shopId) {
          currentShop = shops.elementAt(i) ;
        }
      }
      itemName.text = widget.item.productName ;
      itemDescription.text = widget.item.productDescription ;
      qty.text = widget.item.quantity.toString() ;
      quantity = widget.item.quantityType ;
      mrp.text = widget.item.originalPrice.toString() ;
      bestPrice.text = widget.item.discountPrice.toString() ;
      initData = false  ;
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
    // Loading the data
    return FutureBuilder(
        future: loadInitData() ,
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title: Text('Edit Item'),
                ),
                body: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      image == null
                          ? imageUrl == null ? CircleAvatar(
                        radius: 60.0,
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        child: CircleAvatar(
                          radius: 58.0,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                              'assets/images/person_profile_photo.jpg'),
                        ),
                      ) : CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        child: CircleAvatar(
                          radius: 48.0,
                          backgroundColor: Colors.white,
                          backgroundImage:NetworkImage(imageUrl),
                        ),
                      )
                          : Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.fill, image: FileImage(image)),
                              border: Border.all(color: Colors.black, width: 2))),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: AutoSizeText('Category' , style: GoogleFonts.lato(
                                fontStyle: FontStyle.normal ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                                fontSize: 16
                            ), maxLines: 1,),
                          ),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<Category>(
                              isExpanded: true,
                              value: currentCategory ,
                              items: categories.map((Category category) {
                                return new DropdownMenuItem<Category>(
                                  value: category,
                                  child: AutoSizeText(category.categoryName , style: GoogleFonts.lato(
                                      fontStyle: FontStyle.normal ,
                                      fontWeight: FontWeight.bold ,
                                      color: Colors.black,
                                      fontSize: 12
                                  ), maxLines: 1,),
                                );
                              }).toList(),
                              onChanged: (Category c) {
                                setState(() {
                                  currentCategory = c ;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      shops != null ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text('Shop' , style: GoogleFonts.lato(
                                fontStyle: FontStyle.normal ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                                fontSize: 16
                            ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: DropdownButton<Shop>(isExpanded: true,
                              value: currentShop ,
                              items: shops.map((Shop shop) {
                                return new DropdownMenuItem<Shop>(
                                  value: shop,
                                  child: new AutoSizeText(shop.shopName , style: GoogleFonts.lato(
                                      fontStyle: FontStyle.normal ,
                                      fontWeight: FontWeight.bold ,
                                      color: Colors.black,
                                      fontSize: 12
                                  ),),
                                );
                              }).toList(),
                              onChanged: (Shop s ) {
                                setState(() {
                                  currentShop = s ;
                                  currentShopId = s.shopId ;
                                });
                              },
                            ),
                          ),
                        ],
                      ) : SizedBox(
                        height: 2,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Item Name',
                            hintText: 'Item Name',
                          ),
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          controller: itemName,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Description',
                            hintText: 'Description',
                          ),
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          controller: itemDescription,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Quantity',
                                  hintText: 'Enter Qty',
                                ),
                                style: GoogleFonts.lato(
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                controller: qty,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: DropdownButton<String>(
                              value: quantity,
                              items: quantities.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value , style: GoogleFonts.lato(
                                      fontStyle: FontStyle.normal ,
                                      fontWeight: FontWeight.bold ,
                                      color: Colors.black,
                                      fontSize: 16
                                  ),),
                                );
                              }).toList(),
                              onChanged: (String v) {
                                setState(() {
                                  quantity = v ;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'MRP Price',
                            hintText: 'MRP Price',
                          ),
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          controller: mrp,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Best Price',
                            hintText: 'Best Price',
                          ),
                          style: GoogleFonts.lato(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          controller: bestPrice,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: FlatButton(
                          onPressed: () {
                            saveChanges() ;
                          },
                          color: Theme.of(context).secondaryHeaderColor,
                          child: Text(
                            'UPDATE PRODUCT',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: buildSpeedDial()
            );
          }
          else {
            return progressIndicator() ;
          }

        }
    );
  }
}

