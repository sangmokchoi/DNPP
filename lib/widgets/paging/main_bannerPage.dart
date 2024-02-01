import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repository/launchUrl.dart';

class MainBannerPageView extends StatelessWidget {
  final PageController pageController;

  final Map<String?, Uint8List?> imageMap;
  final Map<String?, String?> urlMap;
  final Map<String, String> refStringList;

  final double width;
  final double height;

  MainBannerPageView({
    required this.pageController,
    required this.width,
    required this.height,
    required this.imageMap,
    required this.urlMap,
    required this.refStringList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Container(
            height: height, // or any desired height
            width: width, // 4:3 aspect ratio
            child: PageView.builder(
              controller: pageController,
              itemCount: refStringList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    print('refStringList: $refStringList');
                    await LaunchUrl().myLaunchUrl("${urlMap[refStringList['$index']]}");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        //refStringList['$index'] 가 파일의 fullpath 추출한 부분을 의미함
                        image: MemoryImage(
                            imageMap[refStringList['$index']] ?? Uint8List(0)),
                        //MemoryImage(imageMap['$index'] ?? Uint8List(0)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}