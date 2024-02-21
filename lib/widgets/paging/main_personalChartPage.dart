import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../statusUpdate/personalAppointmentUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';
import 'main_graphs.dart';

class MainPersonalChartPageView extends StatelessWidget {
  final PageController pageController;
  //_currentPersonal

  bool isPersonal = false;
  int currentPersonal;
  int indexPersonal;

  //bool isLoading = false;
  bool isRefresh = false;

  String courtTitle;
  String courtRoadAddress;

  MainPersonalChartPageView({
    required this.pageController,
    required this.currentPersonal,
    required this.indexPersonal,
    required this.courtTitle,
    required this.courtRoadAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          //color: Colors.red,
          child: PageView.builder(
            onPageChanged: (int newPage) async {


              if (newPage != currentPersonal) {
                currentPersonal = newPage;
                print('_currentPersonal: $currentPersonal');

                // 요일 버튼 눌린 것이 초기화 되어야 함
                Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                    .resetSelectedList();


                if (currentPersonal != 0) {
                  indexPersonal = currentPersonal - 1;
                  isPersonal = false;

                } else {
                  indexPersonal = currentPersonal;
                  isPersonal = true;
                }

                courtTitle = Provider.of<ProfileUpdate>(context, listen: false)
                    .userProfile
                    .pingpongCourt?[indexPersonal]
                    .title ??
                    '';
                courtRoadAddress = Provider.of<ProfileUpdate>(context, listen: false)
                    .userProfile
                    .pingpongCourt?[indexPersonal]
                    .roadAddress ??
                    '';

                await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                    .personalDaywiseDurationsCalculate(
                    false, isPersonal, courtTitle, courtRoadAddress);
                await Provider.of<PersonalAppointmentUpdate>(context, listen: false)
                    .personalCountHours(
                    false, isPersonal, courtTitle, courtRoadAddress);

                // Provider.of<AppointmentUpdate>(context, listen: false)
                //     .updateRecentDays(0);

                //setState(() {});
              }
            },

            controller: pageController,
            itemCount: (Provider.of<ProfileUpdate>(context, listen: false)
                        .userProfile
                        .pingpongCourt
                        ?.length != 0)
                ? Provider.of<ProfileUpdate>(context, listen: false)
                        .userProfile
                        .pingpongCourt!
                        .length +
                    1
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
                    titleText: '나의 훈련 시간',
                    backgroundColor:
                        kMainColor,
                      isCourt: false, isMine: true, // isCourt: false 이면 개인화된 차트 제공, isMine: false이면 다른 유저의 내용 보여줌
                  ),
                );
              } else if (index + 1 ==
                  Provider.of<ProfileUpdate>(context, listen: false)
                      .userProfile
                      .pingpongCourt
                      ?.length) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: kRoundedRectangleBorder,
                    //color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    //index: index,
                    titleText:
                        Provider.of<ProfileUpdate>(context, listen: false)
                            .userProfile
                            .pingpongCourt![index - 1]
                            .title,
                    //ChartBasicList[index].text,
                    backgroundColor:
                        Colors.lightBlue,
                      isCourt: false, isMine: true, // isCourt: false 이면 개인화된 차트 제공, isMine: false이면 다른 유저의 내용 보여줌
                  ),
                );
              } else {
                return Container(
                  //color: Colors.grey,
                  child: GraphsWidget(
                    //index: index,
                    titleText:
                        Provider.of<ProfileUpdate>(context, listen: false)
                            .userProfile
                            .pingpongCourt![index - 1]
                            .title,
                    //ChartBasicList[index].text,
                    backgroundColor:
                        Colors.lightBlue,
                    isCourt: false, isMine: true, // isCourt: false 이면 개인화된 차트 제공, isMine: false이면 다른 유저의 내용 보여줌
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
