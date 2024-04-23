import 'package:dnpp/viewModel/SettingScreen_ViewModel.dart';
import 'package:dnpp/statusUpdate/loginStatusUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/profileUpdate.dart';

class SettingScreen extends StatelessWidget {
  static String id = '/SettingScreenID';

  @override
  Widget build(BuildContext defaultContext) {

    final viewModel = SettingViewModel();

    // final currentPageProvider = Provider.of<CurrentPageProvider>(defaultContext, listen: false);
    // currentPageProvider.setCurrentPage('SettingScreen');

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await GoogleAnalytics().trackScreen(defaultContext, 'SettingScreen');
      await Provider.of<CurrentPageProvider>(defaultContext, listen: false).setCurrentPage('SettingScreen');
      await appBuildNumber();
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: kAppbarTextStyle,
          title: Text(
            'Setting',
            style: Theme.of(defaultContext).brightness == Brightness.light
                ? TextStyle(color: Colors.black)
                : TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child:
              Consumer<LoginStatusUpdate>(builder: (context, taskData, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
                    stream: Provider.of<LoginStatusUpdate>(context, listen: true)
                        .isLoggedInStream(),
                    builder: (context, snapshot) {
                      print("SettingScreen snapshot.data: ${snapshot.data}");
                      print('snapshot.connectionState: ${snapshot.connectionState}');
                        if (snapshot.data == true) {
                          // 로그인 상태이면 로그인된 화면을 표시합니다.
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 15.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(40.0)),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  Provider.of<ProfileUpdate>(context,
                                                      listen: false)
                                                      .userProfile
                                                      .photoUrl,
                                                )) //가져온 이미지를 화면에 띄워주는 코드
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                            .userProfile
                                            .nickName,
                                        style: kProfileTextStyle,
                                      ),

                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(Provider.of<ProfileUpdate>(context,
                                          listen: false)
                                          .userProfile
                                          .selfIntroduction, maxLines: 2,
                                      ),
                                      Text(Provider.of<ProfileUpdate>(context,
                                          listen: false)
                                          .userProfile
                                          .email, style: TextStyle(
                                          color: Colors.grey
                                      ),),
                                    ],
                                  ),
                                ),
                                DataTable(
                                  //headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.withOpacity(0.2)),
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'Pingpong Plus',
                                          style: kSettingMenuHeaderTextStyle,
                                        ),
                                      ),
                                    ],
                                    rows: List<DataRow>.generate(
                                      viewModel.LoggedInsettingMenuList.length,
                                          (int index) => DataRow(
                                        color:
                                        MaterialStateProperty.resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                              return null;
                                            }),
                                        cells: <DataCell>[
                                          DataCell(
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  viewModel
                                                      .LoggedInsettingMenuList[index],
                                                  style: kSettingMenuTextStyle,
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              print('Clicked on index $index');
                                              switch (index) {
                                                case 0:
                                                  print('프로필 수정');
                                                  await viewModel.settingScreenProfile(context);
                                                case 1:
                                                  print('오픈소스 라이센스');
                                                  await viewModel.settingScreenOss(context);
                                                  break;
                                                case 2:
                                                  print('이용약관');
                                                  await viewModel.settingTermsOfUse(context);
                                                  break;
                                                case 3:
                                                  print('개인정보 처리방침');
                                                  await viewModel.settingPrivacy(context);
                                                  break;
                                                case 4:
                                                  print('운영정책');
                                                  await viewModel.settingOperationPolicy(context);
                                                  break;
                                                case 5:
                                                  print('스토어 평점 남기기');
                                                  await viewModel.settingMoveToStore(context);
                                                  break;
                                                case 6:
                                                  print('문의');
                                                  await viewModel.settingEnquire(context);
                                                  break;
                                                case 7:
                                                  print('로그아웃');
                                                  await viewModel.settingScreenLogout(context);

                                                  // showDialog(
                                                  //     context: context,
                                                  //     builder: (builder) {
                                                  //       return AlertDialog(
                                                  //         insetPadding:
                                                  //         EdgeInsets.only(left: 10.0, right: 10.0),
                                                  //         shape: kRoundedRectangleBorder,
                                                  //         title: Text(
                                                  //           '알림',
                                                  //           style: kAppointmentDateTextStyle,
                                                  //           textAlign: TextAlign.center,
                                                  //         ),
                                                  //         content: Text(
                                                  //           '로그아웃을 진행합니다',
                                                  //           style: TextStyle(
                                                  //             fontSize: 14.0,
                                                  //           ),
                                                  //           textAlign: TextAlign.center,
                                                  //         ),
                                                  //         actions: [
                                                  //           Row(
                                                  //             mainAxisAlignment: MainAxisAlignment.end,
                                                  //             children: [
                                                  //               TextButton(
                                                  //                 style: TextButton.styleFrom(
                                                  //                   textStyle: Theme.of(context).textTheme.labelLarge,
                                                  //                 ),
                                                  //                 child: Center(
                                                  //                     child: Text(
                                                  //                       '취소',
                                                  //                       style: kAppointmentTextButtonStyle.copyWith(color: kMainColor),
                                                  //                     )),
                                                  //                 onPressed: () {
                                                  //                   Navigator.of(context, rootNavigator: true).pop();
                                                  //
                                                  //                   // 다이얼로그 닫기는 여기서 호출
                                                  //
                                                  //                 },
                                                  //               ),
                                                  //               TextButton(
                                                  //                 style: TextButton.styleFrom(
                                                  //                   textStyle: Theme.of(context).textTheme.labelLarge,
                                                  //                 ),
                                                  //                 child: Center(
                                                  //                     child: Text(
                                                  //                         '로그아웃',
                                                  //                         style: kAppointmentTextButtonStyle.copyWith(color: kMainColor)
                                                  //                     )),
                                                  //                 onPressed: () async {
                                                  //                   Navigator.of(context, rootNavigator: true).pop();
                                                  //                   await viewModel.settingScreenLogout(context);
                                                  //
                                                  //                 },
                                                  //               ),
                                                  //             ],
                                                  //           ),
                                                  //         ],
                                                  //       );
                                                  //     });
                                                  break;
                                                case 8:
                                                  print('회원 탈퇴');
                                                  await viewModel.settingScreenRemoveData(context);
                                                  break;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          );
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: kCustomCircularProgressIndicator),
                            ],
                          );
                        } else {
                          // 비로그인 상태이면 로그인되지 않은 화면을 표시합니다.
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 25.0, bottom: 25.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(40.0)),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                //'images/empty_profile_${Random().nextInt(5)+1}.png'
                                                  'images/핑퐁플러스 로고.png'
                                              )
                                              as ImageProvider<Object>,
                                            ) //가져온 이미지를 화면에 띄워주는 코드
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        '반갑습니다!',
                                        style: kProfileTextStyle,
                                      ),
                                      Text('로그인이 필요합니다'),
                                    ],
                                  ),
                                ),
                                DataTable(
                                  //headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.withOpacity(0.2)),
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'Pingpong Plus',
                                          style: kSettingMenuHeaderTextStyle,
                                        ),
                                      ),
                                    ],
                                    rows: List<DataRow>.generate(
                                      viewModel.LoggedOutsettingMenuList.length,
                                          (int index) => DataRow(
                                        color:
                                        MaterialStateProperty.resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                              return null;
                                            }),
                                        cells: <DataCell>[
                                          DataCell(
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  viewModel
                                                      .LoggedOutsettingMenuList[index],
                                                  style: kSettingMenuTextStyle,
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              print('Clicked on index $index');

                                              switch (index) {
                                                case 0:
                                                  print('로그인');

                                                  await viewModel.settingScreenLogin(context);
                                              //break;
                                                case 1:
                                                  print('오픈소스 라이센스');
                                                  await viewModel.settingScreenOss(context);

                                                case 2:
                                                  print('이용약관');
                                                  await viewModel.settingTermsOfUse(context);
                                                  break;
                                                case 3:
                                                  print('개인정보 처리방침');
                                                  await viewModel.settingPrivacy(context);

                                                  break;
                                                case 4:
                                                  print('운영정책');
                                                  await viewModel.settingOperationPolicy(context);
                                                  break;
                                                case 5:
                                                  print('문의');
                                                  await viewModel.settingEnquire(context);
                                                  break;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          );
                        }
                    },
                ),
                FutureBuilder(
                    future: appBuildNumber(),
                    builder: (builder, snapshot){
                      if (snapshot.hasData) {
                        print('앱 버전 data: ${snapshot.data}');
                        final data = snapshot.data;

                        final appData = snapshot.data as Map<String, String>;
                        return Padding(
                          padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
                          child: Row(
                            children: [
                              Text(
                                '${appData['appName']}',
                                style: TextStyle(
                                color: Colors.grey
                              ),),
                              SizedBox(width: 10.0,),
                              Text(
                                '버전: ${appData['version']}',
                                style: TextStyle(
                                  color: Colors.grey
                              ),),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                })
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<Map<String, String>> appBuildNumber() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    final returnValue = {
      "appName": appName,
      "packageName": packageName,
      "version": version,
      "buildNumber": buildNumber,
    };

    return returnValue;

  }
}
