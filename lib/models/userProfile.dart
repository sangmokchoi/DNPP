import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  UserProfile(
      {required this.nickName,
      required this.photoUrl,
      required this.gender,
      required this.ageRange,
      required this.playStyle,
      required this.rubber,
      required this.racket});

  String nickName;
  String photoUrl;
  String gender;
  String ageRange;
  String playStyle;
  String rubber;
  String racket;

  static List<String> genderList = ['남', '여', '밝히지 않음'];
  static List<String> ageRangeList = [
    '10대 이하',
    '20대',
    '30대',
    '40대',
    '50대',
    '60대',
    '70대 이상'
  ];
  static List<String> playStyleList = ['공격', '수비'];
  static List<String> rubberList = ['평면', '핌플', '기타', '미정'];
  static List<String> racketList = ['펜홀더', '쉐이크', '중펜', '미정'];

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserProfile(
      nickName: data?['nickName'],
      photoUrl: data?['photo'],
      gender: data?['gender'],
      ageRange: data?['ageRange'],
      playStyle: data?['playStyle'],
      rubber: data?['rubber'],
      racket: data?['racket'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nickName != null) "nickName": nickName,
      if (photoUrl != null) "photo": photoUrl,
      if (gender != null) "gender": gender,
      if (ageRange != null) "ageRange": ageRange,
      if (playStyle != null) "playStyle": playStyle,
      if (rubber != null) "rubber": rubber,
      if (racket != null) "regions": racket,
    };
  }
}
