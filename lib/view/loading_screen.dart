import 'dart:io';
import 'package:dnpp/statusUpdate/loadingUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../viewModel/LoadingScreen_ViewModel.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  static String id = '/';

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    LoadingScreenViewModel().initialize(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<LoadingUpdate>(context, listen: false)
            .loadData(context, true, '', '')
            .timeout(
          Duration(seconds: 7),
          onTimeout: () {
            // 타임아웃이 발생한 경우에는 알림창 필요
            showDialog(
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
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: kMainColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/핑퐁플러스 로고.png'),
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                    )
                  ],
                )
            );

            // return Container(
            //       decoration: BoxDecoration(
            //         color: kMainColor,
            //         image: DecorationImage(
            //           image: AssetImage('images/핑퐁플러스 로고.png'),
            //           //fit: BoxFit.cover,
            //         ),
            //       ),
            //      );
                // CircularProgressIndicator(
                //   // valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                // )
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomeScreen()),
            // );
            print("지금 종료됨");
            return HomeScreen();
          } else {
            return Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            );
          }
        });
  }
}
