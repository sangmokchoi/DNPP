import 'package:flutter/material.dart';

const kNaverMapApiKey = '7evubnn4j6';

const kCustomCircularProgressIndicator = CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(kMainColor),
);

const kAppbarTextStyle =
    TextStyle(
        //color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.bold);

const kMainColor = Color(0xFF46ABF6);

const kAppointmentTextStyle = TextStyle(
    // 시간시간, 종료시간
    //color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.bold);

const kAppointmentDateTextStyle = TextStyle(
    // 2023. 10. 10. (화) 14:30
    //color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.normal);

const kAppointmentTextButtonStyle = TextStyle(
  //
  //color: Colors.black,
  color: kMainColor,
  fontSize: 18.0,
);

const kAppointmentCourtTextButtonStyle = TextStyle(
  //
  //color: Colors.black,
  fontSize: 18.0,
);

const kElevationButtonStyle = TextStyle(
  // 취소, 저장
  color: kMainColor,
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
);

const kElevationButtonDeletionStyle = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(Colors.red),
);

const kProfileTextStyle = TextStyle(
    //color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.normal);

const kProfileSubTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 15.0,
    fontWeight: FontWeight.normal);

const kSettingMenuHeaderTextStyle =
    TextStyle(
        //color: Colors.black,
        fontSize: 18.0,
        fontWeight: FontWeight.bold);

const kSettingMenuTextStyle = TextStyle(
    //color: Colors.black,
    fontSize: 18.0,
    fontWeight: FontWeight.normal);

const kTextButtonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 18.0,
    fontWeight: FontWeight.normal);

final kCancelButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.grey),
);

final kConfirmButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(kMainColor),
);

const kAlertDialogTextButtonWidth = 120.0;

const kAlertDialogTitleTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.normal
);

const kAlertDialogContentTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal
);

const kRoundedRectangleBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(15),
  ),
);

const kMapPingponglistElementTitleTextStyle = TextStyle(
  //color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.bold);

const kMapPingponglistElementAddressTextStyle = TextStyle(
  //color: Colors.white,
    fontSize: 12.0,
    fontWeight: FontWeight.normal);

const kMapPingponglistElementEtcTextStyle = TextStyle(
    //color: Colors.white,
    fontSize: 14.0,
    fontWeight: FontWeight.normal);

const kMatchingScreenNicknameTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold
);

const kMatchingScreenUserInfoTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal
);

const kMatchingScreenAddressTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal
);

const kProfileScreenTogglebuttonsTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal
);

