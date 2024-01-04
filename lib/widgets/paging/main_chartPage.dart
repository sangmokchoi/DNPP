import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../viewModel/profileUpdate.dart';
import 'main_graphs.dart';

class MainPersonalChartPageView extends StatelessWidget {
  final PageController pageController;

  MainPersonalChartPageView({required this.pageController});

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
