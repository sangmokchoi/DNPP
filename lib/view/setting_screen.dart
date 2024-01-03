import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/viewModel/loginStatusUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../viewModel/profileUpdate.dart';

class SettingScreen extends StatefulWidget {
  static String id = '/SettingScreenID';

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<String> settingMenuList = ['프로필 수정', '오픈소스 라이센스', '이용약관', '개인정보 처리방침', '광고 문의', '로그아웃'];

  @override
  Widget build(BuildContext context) {

    //final UserProfile userProfile = Provider.of<ProfileUpdate>(context, listen: false).userProfile;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Text('${userProfile.nickName}'),
          Text('userProfile.nickName'),
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
                        case 5:
                          print('로그아웃 구현');
                          await Provider.of<LoginStatusUpdate>(context, listen: false).logout();
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
