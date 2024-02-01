import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dnpp/repository/repository_loadData.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../viewModel/courtAppointmentUpdate.dart';
import '../viewModel/loginStatusUpdate.dart';
import '../viewModel/personalAppointmentUpdate.dart';

import '../constants.dart';

class LoadingUpdate extends ChangeNotifier {

  Map<String?, Uint8List?> imageMap = {};
  Map<String?, String?> urlMap = {};
  Map<String, String> refStringList = {};

  Future<void> downloadAllImages() async {


    final gsReference =
    FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("main_images");
    Reference urlReference = gsReference.child("main_urls");

    // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
    ListResult imageListResult = await imageReference.list();
    ListResult urlListResult = await urlReference.list();

    int count = 0;

    try {
      for (Reference imageRef in imageListResult.items) {
        try {
          print('imageRef.fullPath: ${imageRef.fullPath}');
          List<String> parts = imageRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');
          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await imageRef.getData(oneMegabyte);

          imageMap['$result'] = imageData;

          refStringList['$count'] = result;
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

          urlMap['$result'] = urlContent;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }
    } catch (e) {
      print("Error in downloadAllImages: $e");
    }

    print('downloadAllImages 완료');
    print('imageMap: $imageMap');
    print('urlMap: $urlMap');
    print('refStringList: $refStringList');

    print('loadDoc 완료');
    notifyListeners();

  }

  Future<void> loadData(
      BuildContext context, bool isPersonal, String courtTitle, String courtRoadAddress) async {


    try {
      await downloadAllImages();
      print('await downloadAllImages(); completed');

      if (Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn) {
        await LoadData().fetchUserData(context);

        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalDaywiseDurationsCalculate(
            false, isPersonal, courtTitle, courtRoadAddress);
        await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
            .personalCountHours(
            false, isPersonal, courtTitle, courtRoadAddress);

        // await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        //     .personalDaywiseDurationsCalculate(
        //     false, isPersonal, _courtTitle, _courtRoadAddress);
        // await Provider.of<OthersPersonalAppointmentUpdate>(context, listen: false)
        //     .personalCountHours(
        //     false, isPersonal, _courtTitle, _courtRoadAddress);

        await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtDaywiseDurationsCalculate(
            false, false, courtTitle, courtRoadAddress);
        await Provider.of<CourtAppointmentUpdate>(context, listen: false)
            .courtCountHours(false, false, courtTitle, courtRoadAddress);
      } else {}
      print('await fetchUserData(); completed');
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  void openPopUp(BuildContext context) {

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  topLeft: Radius.circular(10.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '이 유저에게 함께 탁구를 쳐보자는 메시지를 보낼까요?',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          //style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey),),
                          style: ElevatedButton.styleFrom(
                            elevation: 3, // 그림자 깊이 조정
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '오늘 다시 보지 않기',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          //style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey),),
                          style: ElevatedButton.styleFrom(
                            elevation: 3, // 그림자 깊이 조정
                          ),
                          onPressed: () {
                            print('');
                          },
                          child: Text(
                            '더보기',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: kMainColor),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );

  }

}