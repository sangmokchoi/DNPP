import 'package:dnpp/repository/firebase_firestore_userData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dnpp/LocalDataSource/firebase_fireStore/DS_Local_userData.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';


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

  ///////////
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

    // int mainBannerCount = 0;
    // int adBannerCount = 0;

    try {
      // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
      ListResult imageListResult = await imageReference.list(); // 광고배너 이미지
      ListResult urlListResult = await urlReference.list(); // 광고배너 링크
      ListResult announcementResult = await announcementReference.list(); // 공지사항 이미지
      ListResult announcementUrlResult = await announcementUrlReference.list(); // 공지사항 링크
      ListResult announcementTextResult = await announcementTextReference.list(); // 공지사항 텍스트

      ListResult howToUseImageResult = await howToUseImageReference.list(); // 이용안내 이미지
      ListResult howToUseTextResult = await howToUseTextReference.list(); // 이용안내 텍스트

      try {

        // 각 리스트를 위한 비동기 작업 시작
        await Future.wait([
          processMainImageListResult(imageListResult.items),
          processMainUrlListResult(urlListResult.items),
          processAnnouncementResult(announcementResult.items),
          processAnnouncementUrlResult(announcementUrlResult.items),
          processAnnouncementTextResult(announcementTextResult.items),
          processHowToUseImageResult(howToUseImageResult.items),
          processHowToUseTextResult(howToUseTextResult.items),
        ]).then((value) {
          notifyListeners();
        });

      } catch (e) {
        print("Error in downloadAllImages Future.wait: $e");
      }
    } catch (e) {
      print("Error in downloadAllImages: $e");
    }

  }

  Future<void> processMainImageListResult(List<Reference> items) async {

    int mainBannerCount = 0;

    for (Reference imageRef in items) {
      try {
        print('main_screen imageRef.fullPath: ${imageRef.fullPath}');
        List<String> parts = imageRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        print('imageListResult Result: $result');
        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await imageRef.getData(oneMegabyte);

        imageMapMain['$result'] = imageData; // 메인 스크린에서 인덱스 순으로 이미지가 들어감
        refStringListMain['$mainBannerCount'] = result;
        mainBannerCount++;

      } catch (e) {
        // Handle any errors.
        print("Error downloading image: $e");
      }
    }
  }
  Future<void> processMainUrlListResult(List<Reference> items) async {

    for (Reference urlRef in items) {
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
  }
  Future<void> processAnnouncementResult(List<Reference> items) async {

    int adBannerCount = 0;

    for (Reference announcementRef in items) {
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
  }
  Future<void> processAnnouncementUrlResult(List<Reference> items) async {

    for (Reference urlRef in items) {
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
  }
  Future<void> processAnnouncementTextResult(List<Reference> items) async {

    for (Reference textRef in items) {
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
  }
  Future<void> processHowToUseImageResult(List<Reference> items) async {


    for (Reference imageRef in items) {
      try {
        print('howToUseImageResult imageRef.fullPath: ${imageRef.fullPath}');
        List<String> parts = imageRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        print('howToUseImageResult Result: $result');
        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await imageRef.getData(oneMegabyte);

        howToUseMapMain['howToUse$result'] = imageData;
        print('imageRef imageData: $imageData');

      } catch (e) {
        // Handle any errors.
        print("Error downloading image: $e");
      }
    }
  }
  Future<void> processHowToUseTextResult(List<Reference> items) async {

    for (Reference textRef in items) {
      try {
        print('howToUseTextResult textRef.fullPath: ${textRef.fullPath}');
        List<String> parts = textRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        print('howToUseTextResult Result: $result');

        final Uint8List? urlData = await textRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        textMapHowToUse['howToUse$result'] = urlContent;
        print('textMapHowToUse[result]: ${textMapHowToUse['howToUse$result']}');
      } catch (e) {
        // Handle any errors.
        print("Error downloading image: $e");
      }
    }
  }

  ///////////

  Future<void> downloadAllImagesInMatchingScreen() async {

    final gsReference =
    FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("matchingScreen_images");
    Reference urlReference = gsReference.child("matchingScreen_urls");

    try {

      // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
      ListResult imageListResult = await imageReference.list();
      ListResult urlListResult = await urlReference.list();

      try {
        // 각 리스트를 위한 비동기 작업 시작
        await Future.wait([
          processMatchingImageListResult(imageListResult.items),
          processMatchingUrlListResult(urlListResult.items),
        ]).then((value) {
          notifyListeners();
        });
      } catch (e) {
        print("Error in downloadAllImagesInMatchingScreen Future.wait: $e");
      }

    } catch (e) {
      print("Error in downloadAllImagesInMatchingScreen: $e");
    }

  }

  Future<void> processMatchingImageListResult(List<Reference> items) async {

    int matchingBannerCount = 0;

    for (Reference imageRef in items) {
      try {
        print('matching_screen imageRef.fullPath: ${imageRef.fullPath}');
        List<String> parts = imageRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        print('matching_screen Result: $result');
        const oneMegabyte = 1024 * 1024;
        final Uint8List? imageData = await imageRef.getData(oneMegabyte);

        imageMapMatchingScreen['$result'] = imageData;

        refStringListMatchingScreen['$matchingBannerCount'] = result;
        matchingBannerCount++;
      } catch (e) {
        // Handle any errors.
        print("Error downloading image: $e");
      }
    }
  }
  Future<void> processMatchingUrlListResult(List<Reference> items) async {

    for (Reference urlRef in items) {
      try {
        print('matching_screen urlRef.fullPath: ${urlRef.fullPath}');
        List<String> parts = urlRef.fullPath.split('/');
        String result = parts.last.substring(0, parts.last.length - 4);
        print('matching_screen Result: $result');

        final Uint8List? urlData = await urlRef.getData();
        // Assuming the content of the text file is UTF-8 encoded
        String? urlContent = utf8.decode(urlData!); // Convert bytes to string

        urlMapMatchingScreen['$result'] = urlContent;
      } catch (e) {
        // Handle any errors.
        print("Error downloading image: $e");
      }
    }
  }

  //////////////////////////

  Future<void> loadData(
      BuildContext context, bool isPersonal, String courtTitle, String courtRoadAddress) async {

    try {

      await Future.wait([
        downloadAllImagesInMainScreen(),
        downloadAllImagesInMatchingScreen(),
      ]).then((value) async {

        try {
          //if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {
          if (FirebaseAuth.instance.currentUser?.uid != '' || FirebaseAuth.instance.currentUser?.uid != null) {
            await RepositoryFirestoreUserData().getFetchUserData(context);

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
          print('loadData Future.wait after e: $e');
        }

        print('await downloadAllImagesInMainScreen(); completed');
        print('await downloadAllImagesInMatchingScreen(); completed');

      });

    } catch (e) {
      print('loadData e: $e');
    }

  }

}