import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class SettingViewModel extends ChangeNotifier {

  FirebaseFirestore db = FirebaseFirestore.instance;

  List<String> LoggedInsettingMenuList = [
    '프로필 수정',
    '오픈소스 라이센스',
    '이용약관',
    '개인정보 처리방침',
    '광고 문의',
    '로그아웃',
    '회원 탈퇴'
  ];

  List<String> LoggedOutsettingMenuList = [
    '로그인',
    '오픈소스 라이센스',
    '이용약관',
    '개인정보 처리방침',
    '광고 문의',
  ];

}