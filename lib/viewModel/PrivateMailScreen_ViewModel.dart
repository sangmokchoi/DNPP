
import 'package:flutter/cupertino.dart';

class PrivateMailScreenViewModel extends ChangeNotifier {

  bool isListTileVisible = false;

  ScrollController horizontalScrollController = ScrollController();

  List<String> menuList = ["전체", "공지사항", "안내"];

  int clickedMenu = 0;

  String title = '';
  String body = '';
  String timeline = '';
  String imageUrl = '';
  String langingUrl = '';

  Future<void> updateIsListTileVisible() async {
    isListTileVisible = !isListTileVisible;
    notifyListeners();
  }

  Future<void> updateClickedMenu(int value) async {
    clickedMenu = value;
    notifyListeners();
  }

  Future<void> updateListTileData(String _title, String _body, String _timeline, String _imageUrl, String _langingUrl) async {
    title = _title;
    body = _body;
    timeline = _timeline;
    imageUrl = _imageUrl;
    langingUrl = _langingUrl;
    notifyListeners();
  }

  Future<void> clear() async {

    isListTileVisible = false;

     clickedMenu = 0;

     title = '';
     body = '';
     timeline = '';
     imageUrl = '';
      langingUrl = '';

    debugPrint('privateMailScreenViewModel.clear();');

    notifyListeners();
  }


}