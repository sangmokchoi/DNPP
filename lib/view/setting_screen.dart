import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/view/main_screen.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/viewModel/loginStatusUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import 'package:dnpp/repository/repository_firebase.dart' as viewModel;

import '../constants.dart';
import '../models/pingpongList.dart';
import '../viewModel/profileUpdate.dart';
import 'home_screen.dart';

class SettingScreen extends StatefulWidget {
  static String id = '/SettingScreenID';

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<String> settingMenuList = [
    '프로필 수정',
    '오픈소스 라이센스',
    '이용약관',
    '개인정보 처리방침',
    '광고 문의',
    '로그아웃',
    '회원 탈퇴'
  ];

  void hideNavBar() {
    PersistentTabController();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 25.0, bottom: 0.0),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn
                            ? NetworkImage(
                                Provider.of<ProfileUpdate>(context,
                                        listen: false)
                                    .userProfile
                                    .photoUrl,
                              )
                            : AssetImage('images/empty_profile_160.png')
                                as ImageProvider<Object>,
                      ) //가져온 이미지를 화면에 띄워주는 코드
                      ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn
                      ? Provider.of<ProfileUpdate>(context, listen: false)
                          .userProfile
                          .nickName
                      : '반갑습니다!',
                  style: kProfileTextStyle,
                ),
                Text(Provider.of<LoginStatusUpdate>(context, listen: false).isLoggedIn
                    ? '${Provider.of<LoginStatusUpdate>(context, listen: false).currentUser.email}'
                    : '로그인이 필요합니다'),
              ],
            ),
          ),
          DataTable(
            //headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.withOpacity(0.2)),
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  '설정',
                  style: kSettingMenuHeaderTextStyle,
                ),
              ),
            ],
            rows: List<DataRow>.generate(
              settingMenuList.length,
              (int index) => DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return null;
                }),
                cells: <DataCell>[
                  DataCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          settingMenuList[index],
                          style: kSettingMenuTextStyle,
                        ),
                        Icon(Icons.arrow_forward_ios_rounded),
                      ],
                    ),
                    onTap: () async {
                      print('Clicked on index $index');
                      switch (index) {
                        case 0:
                          print('프로필 수정');
                          //Navigator.pushNamed(context, ProfileScreen.id);

                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: ProfileScreen(),
                            withNavBar: false,
                            // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );

                          // await Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ProfileScreen()),
                          //     (route) => true);
                          // 받은 데이터 출력
                          setState(() {});
                        case 5:
                          print('로그아웃 구현');

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useRootNavigator: false,
                            builder: (context) {
                              return Center(
                                child: CircularProgressIndicator(), // 로딩 바 표시
                              );
                            },
                          );
                          await Future.delayed(Duration(seconds: 1));
                          await viewModel.FirebaseRepository().signOut();
                          await Future.delayed(Duration.zero);

                          Navigator.pop(context);

                          setState(() {

                          });

                          // await Provider.of<LoginStatusUpdate>(context,
                          //         listen: false)
                          //     .logout();
                          break;
                        case 6:
                          print('회원 탈퇴');
                          await viewModel.FirebaseRepository().deleteUserAccount();
                          //Navigator.pushNamed(context, '/');
                          PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                            context,
                            screen: HomeScreen(),
                            withNavBar: false,
                            // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                            PageTransitionAnimation.fade, settings: RouteSettings(),
                          );
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
