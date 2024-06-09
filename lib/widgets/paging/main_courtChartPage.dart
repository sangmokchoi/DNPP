import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../statusUpdate/courtAppointmentUpdate.dart';
import '../../statusUpdate/profileUpdate.dart';
import 'graphWidget.dart';

class MainCourtChartPageView extends StatelessWidget {

  MainCourtChartPageView({
    required this.pageController,
    required this.currentCourt,
    required this.indexCourt,
    required this.courtTitle,
    required this.courtRoadAddress,
  });

  final PageController pageController;

  bool isPersonal = false;
  int currentCourt;
  int indexCourt;

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

              if (newPage != currentCourt) {
                currentCourt = newPage;

                // 요일 버튼 눌린 것이 초기화 되어야 함
                Provider.of<CourtAppointmentUpdate>(context, listen: false).resetSelectedList();

                indexCourt = currentCourt;

                courtTitle = Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?[indexCourt].title ??
                    '';
                courtRoadAddress = Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?[indexCourt].roadAddress ??
                        '';

                await Provider.of<CourtAppointmentUpdate>(context, listen: false).daywiseDurationsCalculate(
                        false, false, courtTitle, courtRoadAddress);
                debugPrint("3");
                await Provider.of<CourtAppointmentUpdate>(context, listen: false).courtCountHours(
                        false, false, courtTitle, courtRoadAddress);
              }
            },
            controller: pageController,
            itemCount: (Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?.length != 0)
                ? Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?.length
                : 1,
            itemBuilder: (context, index) {
              if (Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt?.length != 0) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: kRoundedRectangleBorder,
                  ),
                  child: GraphsWidget(
                    //index: index, // index == 0
                    titleText: Provider.of<ProfileUpdate>(context, listen: false).userProfile.pingpongCourt![index]
                            .title,
                    backgroundColor: Colors.lightBlue,
                    number: 1 // 0은 currentuser, 1은 탁구장별 데이터, 2은 다른 유저의 데이터
                  ),
                );
              } else {
                return Center(
                  child: Text('등록한 탁구장이 없습니다'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
