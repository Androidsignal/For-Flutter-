import 'package:flutter/material.dart';
import 'package:anil/values/Images.dart';
import 'package:anil/values/Strings.dart';
import 'package:anil/widget/Buttons.dart';
import 'package:anil/widget/TextUtils.dart';

class NoInternetPage extends StatefulWidget {
  final GestureTapCallback onPressRetry;

  NoInternetPage({this.onPressRetry});

  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              Images.earth,
              height: 100.0,
              width: 100.0,
            ),
            SizedBox(height: 20.0),
            SubHeadText(text: Strings.noInternet),
            SizedBox(height: 10.0),
            Body2Text(text: Strings.enableInternet),
            SizedBox(height: 20.0),
            RaisedBtn(text: Strings.retry.toUpperCase(), onPressed: widget.onPressRetry)
          ],
        ),
      ),
    );
  }
}
