import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/Constants.dart';
import 'package:google_maps/login_wit_sqlite_database/LogInPage.dart';
import 'package:google_maps/sqlite_curd_operations/StudentPage.dart';
import 'package:google_maps/firebase_database/listview_note.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'put_marker_in_map/LatLongModel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: ListViewNote(),
    );
  }
}

