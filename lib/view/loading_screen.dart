import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dnpp/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../statusUpdate/personalAppointmentUpdate.dart';
import '../statusUpdate/profileUpdate.dart';
import '../viewModel/LoadingScreen_ViewModel.dart';
import '../widgets/paging/main_personalChartPage.dart';
import 'home_screen.dart';

class LoadingScreen extends StatelessWidget {
  static String id = '/';

  var messageString = "";

  late LoadingScreenViewModel viewModel;

  Future<void> _initializeViewModel(BuildContext context) async {

    //Map<String?, Uint8List?> howToUseMapMain = {};
    //   Map<String?, String?> textMapHowToUse = {};
    if (viewModel.howToUseMapMain.isEmpty || viewModel.textMapHowToUse.isEmpty) {
      debugPrint('_initializeViewModel 실행');
      await viewModel.initialize(context).then((value) async {
        await viewModel.loadData(context, true, '', '')
            .timeout(
          Duration(seconds: 30),
          onTimeout: () {
            // 타임아웃이 발생한 경우에는 알림창 필요
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('오류'),
                  content:
                  Text('데이터를 불러오는 데 시간이 걸리고 있습니다.\n네트워크 등에 오류가 있을 수 있습니다'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        exit(0);
                      },
                      child: Text('확인'),
                    ),
                  ],
                );
              },
            );
          },
        );
      });
    } else {
      return;
    }


  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<LoadingScreenViewModel>(context, listen: false);

    double width = MediaQuery.sizeOf(context)
        .width;
    double height = width * 3 / 4;

    Color sectionColor = Theme
        .of(context)
        .brightness == Brightness.light
        ? ThemeData
        .dark()
        .colorScheme
        .background
        : Theme
        .of(context)
        .colorScheme
        .background;

    Color contrastSectionColor = Theme
        .of(context)
        .brightness == Brightness.light
        ? Colors.black
        : Colors.white;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: (viewModel.howToUseMapMain.isEmpty || viewModel.textMapHowToUse.isEmpty) ?
      FutureBuilder(
          future: _initializeViewModel(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              debugPrint('로딩 스크린 로딩중');
              return PreviewWidget(height: height,
                  width: width,
                  sectionColor: sectionColor,
                  contrastSectionColor: contrastSectionColor,
                loadingMessage: viewModel.loadingMessage,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              debugPrint('로딩 스크린 홈스크린 불러옴');
              return HomeScreen();
            } else {
              return Container(
                color: Colors.black,
                width: MediaQuery
                    .sizeOf(context)
                    .width,
                height: MediaQuery
                    .sizeOf(context)
                    .height,
              );
            }
          }
      ) :
      HomeScreen(),
    );
  }
}

class PreviewWidget extends StatelessWidget {
  const PreviewWidget({
    super.key,
    required this.height,
    required this.width,
    required this.sectionColor,
    required this.contrastSectionColor,
    required this.loadingMessage
  });

  final double height;
  final double width;
  final Color sectionColor;
  final Color contrastSectionColor;
  final String loadingMessage;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.7,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 0.0),
                              child: Container(
                                height: height, // or any desired height
                                width: width, // 4:3 aspect ratio
                                color: kMainColor,
                              )
                          ),
                          Center(
                            child: Text(
                              '핑퐁플러스 많은 사랑 부탁드립니다',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      ), // 광고 배너

                      Container(
                        margin: EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 5.0),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                //spreadRadius: 3,
                                blurRadius: 3,
                                offset: Offset(3, 3),
                              ),
                            ],
                            color: sectionColor,
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0))),
                        child: SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('핑퐁플러스 이용을 위해서\n로그인 해주세요', style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: contrastSectionColor),
                                textAlign: TextAlign.end,),
                              SizedBox(width: 15.0,),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.arrow_right_alt, size: 20.0,),
                              ),
                              SizedBox(width: 15.0,)
                            ],
                          ),
                        ),
                      ), // 프로필
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: SizedBox(
                          height: 30.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            //padding: EdgeInsets.only(left: 0.0, right: 3.0),
                            itemCount: Provider
                                .of<PersonalAppointmentUpdate>(context,
                                listen: false)
                                .isSelectedString
                                .length,
                            itemBuilder: (BuildContext context, int index) {
                              var padding = EdgeInsets.only(
                                  left: 3.0, right: 3.0);

                              var margin = EdgeInsets.zero;

                              if (index == 0) {
                                margin = EdgeInsets.only(left: 10.0, right: 0.0);
                              } else if (index ==
                                  Provider
                                      .of<PersonalAppointmentUpdate>(context,
                                      listen: false)
                                      .isSelectedString
                                      .length -
                                      1) {
                                margin = EdgeInsets.only(left: 0.0, right: 10.0);
                              }

                              return Container(
                                width: 130.0,
                                padding: padding,
                                margin: margin,
                                decoration: BoxDecoration(
                                ),
                                child: OutlinedButton(
                                  onPressed: () async {
                                    debugPrint('최근 일자 클릭');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide.none,
                                    foregroundColor:
                                    Provider
                                        .of<PersonalAppointmentUpdate>(
                                        context,
                                        listen: false)
                                        .isSelected[index]
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    backgroundColor:
                                    Provider
                                        .of<PersonalAppointmentUpdate>(
                                        context,
                                        listen: false)
                                        .isSelected[index]
                                        ? Colors.lightBlue.withOpacity(0.9)
                                        : Colors.lightBlue.withOpacity(0.5),
                                    shape: kRoundedRectangleBorder,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      Provider
                                          .of<PersonalAppointmentUpdate>(context,
                                          listen: false)
                                          .isSelectedString[index],
                                      maxLines: 1,
                                      style: TextStyle(
                                        //fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ), // toggleButtons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, left: 35.0),
                            child: Text(
                              '나의 연습 시간은 얼마나 될까?',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: contrastSectionColor
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0, left: 35.0),
                            child: Text(
                              '각 요일을 누르면 해당 요일에 이뤄진 일정들의 시간대가 표현됩니다',
                              style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey
                              ),
                            ),
                          ),

                          MainPersonalChartPageView(
                            pageController: PageController(),
                            currentPersonal: 0,
                            indexPersonal: 0,
                            courtTitle: '_courtTitle',
                            courtRoadAddress: '',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0, left: 35.0),
                            child: Text(
                              '우리 탁구장이 붐비는 시간은 언제일까?',
                              style: kAppointmentTextStyle,
                            ),
                          ), // 탁구장 방문 데이터
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0, left: 35.0),
                            child: Text(
                              '각 요일을 누르면 해당 요일에 이뤄진 일정들의 시간대가 표현됩니다',
                              style: kAppointmentTextStyle.copyWith(
                                color: Colors.grey,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                kCustomCircularProgressIndicator,
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  loadingMessage,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
