import 'package:dnpp/viewModel/SettingScreen_ViewModel.dart';
import 'package:dnpp/statusUpdate/loginStatusUpdate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/moveToOtherScreen.dart';
import '../models/userProfile.dart';
import '../statusUpdate/googleAnalytics.dart';
import '../statusUpdate/CurrentPageProvider.dart';
import '../statusUpdate/profileUpdate.dart';

class SettingScreen extends StatelessWidget {
  static String id = '/SettingScreenID';

  @override
  Widget build(BuildContext defaultContext) {
    final viewModel = SettingScreenViewModel();

    // final currentPageProvider = Provider.of<CurrentPageProvider>(defaultContext, listen: false);
    // currentPageProvider.setCurrentPage('SettingScreen');

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await appBuildNumber();
    });

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: const ValueKey("SettingScreen"),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Consumer<ProfileUpdate>(
                builder: (context, profileUpdate, child) {
                  if (profileUpdate.userProfile !=
                      UserProfile.emptyUserProfile) {
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(40.0)),
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
                                Text(
                                  Provider.of<ProfileUpdate>(context,
                                          listen: false)
                                      .userProfile
                                      .selfIntroduction,
                                  maxLines: 2,
                                ),
                                Text(
                                  Provider.of<ProfileUpdate>(context,
                                          listen: false)
                                      .userProfile
                                      .email,
                                  style: TextStyle(color: Colors.grey),
                                ),
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
                                        debugPrint('Clicked on index $index');
                                        switch (index) {
                                          case 0:
                                            debugPrint('프로필 수정');
                                            await MoveToOtherScreen().initializeGASetting(
                                                context, 'ProfileScreen').then((value) async {
                                              await viewModel
                                                  .settingScreenProfile(context).then((value) async {
                                                await MoveToOtherScreen().initializeGASetting(
                                                    context, 'SettingScreen');
                                              });
                                            });

                                          case 1:
                                            debugPrint('오픈소스 라이센스');

                                            await MoveToOtherScreen().initializeGASetting(
                                                context, 'OssLicenseScreen').then((value) async {
                                              await viewModel
                                                  .settingScreenOss(context).then((value) async {
                                                await MoveToOtherScreen().initializeGASetting(
                                                    context, 'SettingScreen');
                                              });

                                            });

                                            break;
                                          case 2:
                                            debugPrint('이용약관');
                                            await viewModel
                                                .settingTermsOfUse(context);
                                            break;
                                          case 3:
                                            debugPrint('개인정보처리방침');
                                            await viewModel
                                                .settingPrivacy(context);
                                            break;
                                          case 4:
                                            debugPrint('운영정책');
                                            await viewModel
                                                .settingOperationPolicy(
                                                    context);
                                            break;
                                          case 5:
                                            debugPrint('스토어 평점 남기기');
                                            await viewModel
                                                .settingMoveToStore(context);
                                            break;
                                          case 6:
                                            debugPrint('문의');
                                            await viewModel
                                                .settingEnquire(context);
                                            break;
                                          case 7:
                                            debugPrint('로그아웃');
                                            await viewModel
                                                .settingScreenLogout(context);
                                            break;
                                          case 8:
                                            debugPrint('회원 탈퇴');
                                            await viewModel
                                                .settingScreenRemoveData(
                                                    context);
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
                                SizedBox(
                                    width: 80,
                                    height: 80,
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'images/logo.png') as ImageProvider<Object>,
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
                                            viewModel.LoggedOutsettingMenuList[
                                                index],
                                            style: kSettingMenuTextStyle,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        debugPrint('Clicked on index $index');

                                        switch (index) {
                                          case 0:
                                            debugPrint('로그인');

                                            await viewModel
                                                .settingScreenLogin(context);
                                          //break;
                                          case 1:
                                            debugPrint('오픈소스 라이센스');
                                            await viewModel
                                                .settingScreenOss(context);

                                          case 2:
                                            debugPrint('이용약관');
                                            await viewModel
                                                .settingTermsOfUse(context);
                                            break;
                                          case 3:
                                            debugPrint('개인정보처리방침');
                                            await viewModel
                                                .settingPrivacy(context);

                                            break;
                                          case 4:
                                            debugPrint('운영정책');
                                            await viewModel
                                                .settingOperationPolicy(
                                                    context);
                                            break;
                                          case 5:
                                            debugPrint('문의');
                                            await viewModel
                                                .settingEnquire(context);
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
                  // 앱 빌드 번호
                  future: appBuildNumber(),
                  builder: (builder, snapshot) {
                    if (snapshot.hasData) {
                      debugPrint('앱 버전 data: ${snapshot.data}');
                      final data = snapshot.data;

                      final appData = snapshot.data as Map<String, String>;
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 25.0, bottom: 25.0),
                        child: Row(
                          children: [
                            Text(
                              '${appData['appName']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '버전: ${appData['version']}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  })
            ],
          ),
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
