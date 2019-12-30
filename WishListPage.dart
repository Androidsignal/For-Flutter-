import 'package:flutter/material.dart';
import 'package:anil/gloabal/Config.dart';
import 'package:anil/gloabal/Constants.dart';
import 'package:anil/model/RestaurantModel.dart';
import 'package:anil/pages/BottomNavigatorPage.dart';
import 'package:anil/pages/ErrorPage.dart';
import 'package:anil/pages/ListItems/BigImageListItem.dart';
import 'package:anil/pages/LoadingHomePage.dart';
import 'package:anil/pages/NoInternetPage.dart';
import 'package:anil/pages/RestaurantDetailPage.dart';
import 'package:anil/parser/get/CheckFavoriteRestaurant.dart';
import 'package:anil/parser/get/GetWishListParser.dart';
import 'package:anil/values/AppColor.dart';
import 'package:anil/values/Strings.dart';
import 'package:anil/widget/AnimationBetweenPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishListPage extends StatefulWidget {
  final RedirectWithOutNavigator redirectWithOutNavigator;
  final BuildContext superContext;

  WishListPage({this.redirectWithOutNavigator, this.superContext});

  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  bool isInternetAvailable;
  bool isLoading;
  bool isError = false;

  SharedPreferences prefs;
  int customerId;

  List<RestaurantModel> wishList = new List<RestaurantModel>();

  @override
  void initState() {
    checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          primaryColor: AppColor.white,
          accentColor: AppColor.primaryColor,
          buttonTheme: ButtonThemeData(
              buttonColor: AppColor.primaryColor,
              textTheme: ButtonTextTheme.primary)),
      child: themApplied(),
    );
  }

  Widget themApplied() {
    if (isInternetAvailable != null && isInternetAvailable) {
      if (isError) {
        return ErrorPage();
      }
      if (isLoading != null && isLoading) {
        callApi();
        return LoadingHomePage();
      } else if (isLoading != null && !isLoading) {
        return layoutMain();
      }
    } else if (isInternetAvailable != null && !isInternetAvailable) {
      return NoInternetPage(onPressRetry: () => checkInternet());
    }
    return LoadingHomePage();
  }

  Widget layoutMain() {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.favorites),
        elevation: 2.0,
        actions: <Widget>[
          // appBarEditItems(),
          SizedBox(
            width: 10.0,
          )
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(),
          child: wishListLayout(),
        );
      }),
    );
  }

  Widget wishListLayout() {
    if (wishList.length != null && wishList.length != 0) {
      return new ListView(
        padding: EdgeInsets.only(top: 8.0),
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        children: List<Widget>.generate(wishList.length, (index) {
          RestaurantModel model = wishList[index];
          String img = "";
          String name = "";
          String averageCost = "";
          String rating = "";
          String discount = "";
          String deliveryTime = "";

          if (model != null && model.imageURl != null) {
            img = model.imageURl;
          }
          if (model != null && model.name != null) {
            name = model.name.toString();
          }

          if (model != null && model.averageCost != null) {
            averageCost = model.averageCost.toString();
          }
          if (model != null && model.rating != null) {
            rating = model.rating.toString();
          }
          if (model != null && model.discount != null) {
            discount = model.discount.toString();
          }
          if (model != null && model.deliveryTime != null) {
            deliveryTime = model.deliveryTime.toString();
          }
          return new Dismissible(
            key: ObjectKey(wishList[index]),
            background: new Container(
              color: Colors.red,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Container(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        new Text(
                          Strings.labelDelete,
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .apply(color: Colors.white),
                        )
                      ],
                    ),
                    padding: EdgeInsets.only(right: 12.0),
                  )
                ],
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              deleteItem(wishList[index].id);
              wishList.removeAt(index);
              setState(() {});
            },
            child: new BigImageListItem(
              margin: index == wishList.length - 1
                  ? EdgeInsets.only(right: 5.0, left: 5.0)
                  : EdgeInsets.only(left: 5.0, right: 5.0),
              imageUrl: img,
              name: name,
              averageCost: averageCost,
              discount: discount,
              rating: rating,
              deliveryTime: deliveryTime,
              width: MediaQuery.of(context).size.width,
              onPress: () {
                onClickStore(wishList[index]);
              },
            ),
          );
        }),
      );
    }
    return noWishList();
  }

  Widget noWishList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.favorite,
          size: 65.0,
          color: AppColor.primaryColor,
        ),
        new Padding(padding: new EdgeInsets.only(top: 20.0)),
        Text(
          Strings.noWishListFound,
          maxLines: 6,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .title
              .copyWith(color: AppColor.primaryColor),
        ),
      ],
    );
  }

  void onClickStore(RestaurantModel model) {
    navigatePush(
        RestaurantDetailPage(
            restaurantId: model.id,
            redirectWithOutNavigator: widget.redirectWithOutNavigator,
            superContext: widget.superContext),
        true);
  }

  Future<Null> callApi() async {
    isInternetAvailable = await Constants.isInternetAvailable();
    if (isInternetAvailable) {
      await getSharedPreferences();
      await getWishList();
      isLoading = false;
      setState(() {});
    } else {
      setState(() {});
    }
  }

  Future getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    customerId = prefs.getInt(Constants.prefUserIdKeyInt);
  }

  Future getWishList() async {
    Map result = await GetWishListParser.getWishListParser(Config.strBaseURL +
        "vendors/getfavoritevendorelist?customerId=" +
        customerId.toString());
    if (!result["isError"]) {
      wishList = result["value"];
    } else {
      isError = true;
    }
  }

  Future deleteItem(deleteId) async {
    Map result = await CheckFavoriteRestaurant.removeFavoriteRestaurant(
        Config.strBaseURL +
            "vendors/addremovefavoritevendor?vendorId=" +
            deleteId.toString() +
            "&customerId=" +
            customerId.toString());
    if (!result["isError"]) {
      setState(() {});
    }
  }

  checkInternet() async {
    isInternetAvailable = await Constants.isInternetAvailable();
    isLoading = isInternetAvailable;
    setState(() {});
  }

  navigatePush(Widget page, bool isHideNav) async {
    if (widget.redirectWithOutNavigator != null && isHideNav) {
      widget.redirectWithOutNavigator.navigatePush(page, context);
    } else {
      await Navigator.push(
          context, AnimationPageRoute(page: page, context: context));
    }
  }

  navigatePushReplacement(Widget page, bool isHideNav) async {
    if (widget.redirectWithOutNavigator != null && isHideNav) {
      widget.redirectWithOutNavigator.navigatePushReplacement(page);
    } else {
      await Navigator.push(
          context, AnimationPageRoute(page: page, context: context));
    }
  }

  navigatePushAndRemove(Widget page, bool isHideNav) async {
    if (widget.redirectWithOutNavigator != null && isHideNav) {
      widget.redirectWithOutNavigator.navigatePushAndRemove(page);
    } else {
      await Navigator.push(
          context, AnimationPageRoute(page: page, context: context));
    }
  }
}
