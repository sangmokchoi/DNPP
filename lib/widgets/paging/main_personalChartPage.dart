import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';
import 'graphWidget.dart';

class MainPersonalChartPageView extends StatelessWidget {

  MainPersonalChartPageView({
    required this.pageController,
    required this.currentPersonal,
    required this.indexPersonal,
    required this.courtTitle,
    required this.courtRoadAddress
  });

  final PageController pageController;

  bool isPersonal = false;
  int currentPersonal;
  int indexPersonal;

  bool isRefresh = false;

  String courtTitle;
  String courtRoadAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          child: PageView.builder(
            onPageChanged: (int newPage) async {

              if (newPage != currentPersonal) {
                currentPersonal = newPage;
                debugPrint('_currentPersonal: $currentPersonal');

                // 요일 버튼 눌린 것이 초기화 되어야 함
                Provider.of<PersonalAppointmentUpdate>(context, listen: false).resetSelectedList();

                if (currentPersonal != 0) {
                  indexPersonal = currentPersonal - 1;
                  isPersonal = false;

                } else {
                  indexPersonal = currentPersonal;
                  isPersonal = true;
                }

                courtTitle = Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?[indexPersonal]
                    .title ?? '';
                courtRoadAddress = Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?[indexPersonal]
                    .roadAddress ?? '';

                await Provider.of<PersonalAppointmentUpdate>(context, listen: false).daywiseDurationsCalculate(
                    false, isPersonal, courtTitle, courtRoadAddress);
                await Provider.of<PersonalAppointmentUpdate>(context, listen: false).personalCountHours(
                    false, isPersonal, courtTitle, courtRoadAddress);

              }
            },

            controller: pageController,
            itemCount: (Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?.length != 0)
                ? Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt!.length + 1
                : 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: kRoundedRectangleBorder,
                    //color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    //index: index, // index == 0
                    titleText: '전체 연습 일정',
                    backgroundColor:
                        kMainColor,
                      number: 0, // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                  ),
                );
              } else if (index + 1 == Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?.length) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: kRoundedRectangleBorder,
                    //color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    //index: index,
                    titleText: Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt![index - 1].title,
                    //ChartBasicList[index].text,
                    backgroundColor:
                        Colors.lightBlue,
                    number: 0, // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                  ),
                );
              } else {
                return Container(
                  //color: Colors.grey,
                  child: GraphsWidget(
                    //index: index,
                    titleText: Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt![index - 1].title,
                    //ChartBasicList[index].text,
                    backgroundColor:
                        Colors.lightBlue,
                    number: 0, // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
