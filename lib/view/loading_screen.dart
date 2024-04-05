import 'dart:io';
import 'package:dnpp/statusUpdate/loadingUpdate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../viewModel/LoadingScreen_ViewModel.dart';
import 'home_screen.dart';

class LoadingScreen extends StatelessWidget {
  static String id = '/';

  var messageString = "";

  late LoadingScreenViewModel viewModel;

  Future<void> _initializeViewModel(BuildContext context) async {
    print('_initializeViewModel 실행');
    await viewModel.initialize(context);
  }

  // @override
  @override
  Widget build(BuildContext context) {

    viewModel = Provider.of<LoadingScreenViewModel>(context, listen: false);

    return Consumer<LoadingScreenViewModel>(
        builder: (context, loadingScreenViewModel, child) {
        return Material(
          child: FutureBuilder(
              future: _initializeViewModel(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: kMainColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('images/핑퐁플러스 로고.png')
                                  as ImageProvider<Object>,
                                ) //가져온 이미지를 화면에 띄워주는 코드
                            ),
                          ),
                          SizedBox(height: 15.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.loadingMessage,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0
                                ),
                              ),
                              SizedBox(width: 20.0,),
                              CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                              ),
                            ],
                          ),
                        ],
                      )
                  );
          
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => HomeScreen()),
                  // );
                  print("Storage에서 지금 종료됨");
                  return FutureBuilder(
          
                      future: Provider.of<LoadingUpdate>(context, listen: false)
                          .loadData(context, true, '', '')
                          .timeout(
                        Duration(seconds: 20),
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
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('images/핑퐁플러스 로고.png')
                                        as ImageProvider<Object>,
                                      ) //가져온 이미지를 화면에 띄워주는 코드
                                  ),
                                ),
                                SizedBox(height: 15.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      viewModel.loadingMessage,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0
                                      ),
                                    ),
                                    SizedBox(width: 20.0,),
                                    CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                                    ),
                                  ],
                                ),
                              ],
                            )
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.connectionState == ConnectionState.done) {
                        return HomeScreen();
                      } else {
                        return Container(
                          color: Colors.black,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        );
                      }
                    }
                  );
                } else {
                  return Container(
                    color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  );
                }
              }),
        );
      }
    );
  }
}
