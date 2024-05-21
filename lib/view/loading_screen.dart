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
      body: Builder(
        builder: (context) {
          // viewModel을 초기화하여 필요 데이터를 로드하는 함수 호출
          debugPrint('viewModel.howToUseMapMain: ${viewModel.howToUseMapMain}');
          debugPrint('viewModel.textMapHowToUse: ${viewModel.textMapHowToUse}');

          //if (viewModel.howToUseMapMain.isEmpty || viewModel.textMapHowToUse.isEmpty) {

            return FutureBuilder(
              future: _initializeViewModel(context),
              builder: (context, snapshot) {
                debugPrint('로딩 화면에서 홈스크린 불림1');

                return Stack(
                  children: [
                    HomeScreen(),

                    if (snapshot.connectionState == ConnectionState.waiting)
                      PreviewWidget(
                        height: height,
                        width: width,
                        sectionColor: sectionColor,
                        contrastSectionColor: contrastSectionColor,
                        loadingMessage: viewModel.loadingMessage,
                      ),
                  ],
                );

              },
            );

        },
      ),
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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
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
