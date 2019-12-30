import 'dart:async';
import 'dart:convert';

import 'package:anil/gloabal/Config.dart';
import 'package:anil/gloabal/Constants.dart';
import 'package:anil/model/CategoryModel.dart';
import 'package:http/http.dart';

class CategoryListParser {

  static Future getCategoryList(String url) async {

    try {
      final response = await get(Uri.encodeFull(url), headers: Config.httpGetHeader);

      if (response.statusCode == 200) {
        Map body = json.decode(response.body);
        if (body != null) {
          if (body.containsKey("categories")) {
            List categories = body["categories"];
            List<CategoryModel> categoryList = categories.map((c) => new CategoryModel.parseForHomeScreen(c)).toList();
            return Constants.resultInApi(categoryList, false);
          }else{
            return Constants.resultInApi("body doesn't contain code",true);
          }
        }else{
          return Constants.resultInApi("body is null",true);
        }
      }
    } catch (e) {
      return Constants.resultInApi("errorStack = "+e.toString(),true);
    }
  }

}