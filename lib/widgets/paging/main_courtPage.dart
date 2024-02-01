import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../viewModel/courtAppointmentUpdate.dart';
import '../../viewModel/personalAppointmentUpdate.dart';
import '../../viewModel/profileUpdate.dart';
import 'main_graphs.dart';

class MainCourtChartPageView extends StatelessWidget {
  final PageController pageController;

  bool isPersonal = false;

  int currentCourt;

  int indexCourt;

  //bool isLoading = false;
  bool isRefresh = false;

  String courtTitle;
  String courtRoadAddress;

  MainCourtChartPageView({
    required this.pageController,
    required this.currentCourt,
    required this.indexCourt,
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
              if (newPage != currentCourt) {
                currentCourt = newPage;

                // 요일 버튼 눌린 것이 초기화 되어야 함
                Provider.of<CourtAppointmentUpdate>(context, listen: false)
                    .resetSelectedList();

                indexCourt = currentCourt;

                courtTitle = Provider.of<ProfileUpdate>(context, listen: false)
                        .userProfile
                        .pingpongCourt?[indexCourt]
                        .title ??
                    '';
                courtRoadAddress =
                    Provider.of<ProfileUpdate>(context, listen: false)
                            .userProfile
                            .pingpongCourt?[indexCourt]
                            .roadAddress ??
                        '';

                await Provider.of<CourtAppointmentUpdate>(context,
                        listen: false)
                    .courtDaywiseDurationsCalculate(
                        false, false, courtTitle, courtRoadAddress);
                await Provider.of<CourtAppointmentUpdate>(context,
                        listen: false)
                    .courtCountHours(
                        false, false, courtTitle, courtRoadAddress);
              }
            },
            controller: pageController,
            itemCount: (Provider.of<ProfileUpdate>(context, listen: false)
                        .userProfile
                        .pingpongCourt
                        ?.length !=
                    0)
                ? Provider.of<ProfileUpdate>(context, listen: false)
                    .userProfile
                    .pingpongCourt
                    ?.length
                : 1,
            itemBuilder: (context, index) {
              if (Provider.of<ProfileUpdate>(context, listen: false)
                      .userProfile
                      .pingpongCourt
                      ?.length !=
                  0) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: kRoundedRectangleBorder,
                    //color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    //index: index, // index == 0
                    titleText:
                        Provider.of<ProfileUpdate>(context, listen: false)
                            .userProfile
                            .pingpongCourt![index]
                            .title,
                    backgroundColor: Colors.lightBlue,
                    isCourt: true, isMine: false,
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
