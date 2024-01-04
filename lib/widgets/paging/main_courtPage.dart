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

  MainCourtChartPageView({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          //color: Colors.red,
          child: PageView.builder(
            controller: pageController,
            itemCount: (Provider.of<ProfileUpdate>(context, listen: false)
                .userProfile.pingpongCourt?.length != 0)
                ? Provider.of<ProfileUpdate>(context, listen: false)
                    .userProfile.pingpongCourt?.length
                : 1,
            itemBuilder: (context, index) {
              if (Provider.of<ProfileUpdate>(context, listen: false)
                  .userProfile.pingpongCourt?.length != 0) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: kRoundedRectangleBorder,
                    //color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    //index: index, // index == 0
                    titleText: Provider.of<ProfileUpdate>(context, listen: false)
                        .userProfile.pingpongCourt![index].title,
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
