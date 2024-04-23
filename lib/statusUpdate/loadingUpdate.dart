import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dnpp/repository/repository_userData.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'courtAppointmentUpdate.dart';
import 'loginStatusUpdate.dart';
import 'personalAppointmentUpdate.dart';

import '../constants.dart';

class LoadingUpdate extends ChangeNotifier {

  // mainScreen 광고 배너
  Map<String?, Uint8List?> imageMapMain = {};
  Map<String, String> refStringListMain = {};
  Map<String?, String?> urlMapMain = {};

  // 공지사항
  Map<String?, Uint8List?> announcementMapMain = {};
  Map<String, String> announcementString = {};
  Map<String?, String?> urlMapAnnouncement = {};
  Map<String?, String?> textMapAnnouncement = {};

  // 이용안내
  Map<String?, Uint8List?> howToUseMapMain = {};
  Map<String?, String?> textMapHowToUse = {};

  // matchingScreen 광고 배너
  Map<String?, Uint8List?> imageMapMatchingScreen = {};
  Map<String?, String?> urlMapMatchingScreen = {};
  Map<String, String> refStringListMatchingScreen = {};

  Future<void> downloadAllImagesInMainScreen() async {

    final gsReference =
    FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("main_images");
    Reference urlReference = gsReference.child("main_urls");
    Reference announcementReference = gsReference.child("announcements");
    Reference announcementUrlReference = gsReference.child("announcement_url");
    Reference announcementTextReference = gsReference.child("announcement_text");
    Reference howToUseImageReference = gsReference.child("howToUse_images");
    Reference howToUseTextReference = gsReference.child("howToUse_text");

    // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
    ListResult imageListResult = await imageReference.list(); // 광고배너 이미지
    ListResult urlListResult = await urlReference.list(); // 광고배너 링크
    ListResult announcementResult = await announcementReference.list(); // 공지사항 이미지
    ListResult announcementUrlResult = await announcementUrlReference.list(); // 공지사항 링크
    ListResult announcementTextResult = await announcementTextReference.list(); // 공지사항 텍스트

    ListResult howToUseImageResult = await howToUseImageReference.list(); // 이용안내 이미지
    ListResult howToUseTextResult = await howToUseTextReference.list(); // 이용안내 텍스트

    int mainBannerCount = 0;
    int adBannerCount = 0;

    try {
      for (Reference imageRef in imageListResult.items) {
        try {
          print('main_screen imageRef.fullPath: ${imageRef.fullPath}');
          List<String> parts = imageRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('imageListResult Result: $result');
          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await imageRef.getData(oneMegabyte);

          imageMapMain['$result'] = imageData;
          refStringListMain['$mainBannerCount'] = result;
          mainBannerCount++;

        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference urlRef in urlListResult.items) {
        try {
          print('Reference urlRef in urlListResult.items: ${urlRef.fullPath}');
          List<String> parts = urlRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('urlListResult Result: $result');

          final Uint8List? urlData = await urlRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          urlMapMain['$result'] = urlContent;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference announcementRef in announcementResult.items) {
        try {
          print('announcementResult urlRef.fullPath: ${announcementRef.fullPath}');
          List<String> parts = announcementRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('announcementResult Result: $result');

          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await announcementRef.getData(oneMegabyte);
          print('announcementResult imageData: $imageData');

          announcementMapMain['$result'] = imageData;
          announcementString['$adBannerCount'] = result;
          adBannerCount++;

        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference urlRef in announcementUrlResult.items) {
        try {
          print('Reference urlRef in announcementUrlResult.items: ${urlRef.fullPath}');
          List<String> parts = urlRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('announcementUrlResult Result: $result');

          final Uint8List? urlData = await urlRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          urlMapAnnouncement['$result'] = urlContent;
          print('urlMapAnnouncement[0]: ${urlMapAnnouncement['0']}');
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference textRef in announcementTextResult.items) {
        try {
          print('Reference textRef in announcementTextResult.items: ${textRef.fullPath}');
          List<String> parts = textRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('announcementTextResult Result: $result');

          final Uint8List? urlData = await textRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          textMapAnnouncement['$result'] = urlContent;
          print('textMapAnnouncement[0]: ${textMapAnnouncement['0']}');
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference imageRef in howToUseImageResult.items) {
        try {
          print('howToUseImageResult imageRef.fullPath: ${imageRef.fullPath}');
          List<String> parts = imageRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('howToUseImageResult Result: $result');
          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await imageRef.getData(oneMegabyte);

          howToUseMapMain['$result'] = imageData;

        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference textRef in howToUseTextResult.items) {
        try {
          print('howToUseTextResult textRef.fullPath: ${textRef.fullPath}');
          List<String> parts = textRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('howToUseTextResult Result: $result');

          final Uint8List? urlData = await textRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          textMapHowToUse['$result'] = urlContent;
          print('textMapHowToUse[result]: ${textMapHowToUse['$result']}');
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

    } catch (e) {
      print("Error in downloadAllImages: $e");
    }

    notifyListeners();

  }

  Future<void> downloadAllImagesInMatchingScreen() async {

    final gsReference =
    FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("matchingScreen_images");
    Reference urlReference = gsReference.child("matchingScreen_urls");

    // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
    ListResult imageListResult = await imageReference.list();
    ListResult urlListResult = await urlReference.list();

    print('imageListResult: $imageListResult');
    print('urlListResult: $urlListResult');

    int count = 0;

    try {
      for (Reference imageRef in imageListResult.items) {
        try {
          print('matching_screen imageRef.fullPath: ${imageRef.fullPath}');
          List<String> parts = imageRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');
          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await imageRef.getData(oneMegabyte);

          imageMapMatchingScreen['$result'] = imageData;

          refStringListMatchingScreen['$count'] = result;
          count++;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference urlRef in urlListResult.items) {
        try {
          print('urlRef.fullPath: ${urlRef.fullPath}');
          List<String> parts = urlRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');

          final Uint8List? urlData = await urlRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          urlMapMatchingScreen['$result'] = urlContent;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }
    } catch (e) {
      print("Error in downloadAllImages: $e");
    }

    notifyListeners();

  }

  Future<void> loadData(
      BuildContext context, bool isPersonal, String courtTitle, String courtRoadAddress) async {

    try {
      await downloadAllImagesInMainScreen();
      await downloadAllImagesInMatchingScreen();
      print('await downloadAllImagesInMainScreen(); completed');
      print('await downloadAllImagesInMatchingScreen(); completed');

      if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {
        await RepositoryUserData().fetchUserData(context);

        // await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        //     .daywiseDurationsCalculate(
        //     false, false, courtTitle, courtRoadAddress);
        // print(1);
        // await Provider.of<CourtAppointmentUpdate>(context, listen: false)
        //     .courtCountHours(false, false, courtTitle, courtRoadAddress);
        //
        // await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        //     .daywiseDurationsCalculate(
        //     false, isPersonal, courtTitle, courtRoadAddress);
        // await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
        //     .personalCountHours(
        //     false, isPersonal, courtTitle, courtRoadAddress);

      } else {

      }

      print('await fetchUserData(); completed');
      notifyListeners();
    } catch (e) {
      print(e);
    }

  }

}