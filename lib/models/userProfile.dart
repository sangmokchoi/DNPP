import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/pingpongList.dart';

class UserProfile {
  UserProfile(
      {required this.uid,
        required this.email,
      required this.nickName,
      required this.photoUrl,
      required this.gender,
      required this.ageRange,
      required this.playedYears,
      required this.address,
      required this.pingpongCourt,
      required this.playStyle,
      required this.rubber,
      required this.racket});

  String uid;
  String email;
  String nickName;
  String photoUrl;
  String gender;
  String ageRange;
  String playedYears;
  List<String> address;
  List<PingpongList>? pingpongCourt;
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
  static List<String> playedYearsList = [
    '1개월 이하',
    '3개월',
    '6개월',
    '1년',
    '3년',
    '5년',
    '7년',
    '10년',
    '15년',
    '20년 이상'
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
      uid: data?['uid'],
      email: data?['email'],
      nickName: data?['nickName'],
      photoUrl: data?['photoUrl'],
      gender: data?['gender'],
      ageRange: data?['ageRange'],
      playedYears: data?['playedYears'],
      address: data?['address'],
      //pingpongCourt: data?['pingpongCourt'],
      pingpongCourt: (data?['pingpongCourt'] as List<dynamic>?)
          ?.map((pingpongData) => PingpongList(
                title: pingpongData['title'],
                link: pingpongData['link'],
                description: pingpongData['description'],
                telephone: pingpongData['telephone'],
                address: pingpongData['address'],
                roadAddress: pingpongData['roadAddress'],
                mapx: pingpongData['mapx'],
                mapy: pingpongData['mapy'],
              ))
          .toList(),
      playStyle: data?['playStyle'],
      rubber: data?['rubber'],
      racket: data?['racket'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (uid != null) "uid": uid,
      if (email != null) "email": email,
      if (nickName != null) "nickName": nickName,
      if (photoUrl != null) "photoUrl": photoUrl,
      if (gender != null) "gender": gender,
      if (ageRange != null) "ageRange": ageRange,
      if (playedYears != null) "playedYears": playedYears,
      if (address != null) "address": address,
      //if (pingpongCourt != null) "pingpongCourt": pingpongCourt,
      if (pingpongCourt != null)
        "pingpongCourt": pingpongCourt
            ?.map((pingpong) => {
                  'title': pingpong.title,
                  'link': pingpong.link,
                  'description': pingpong.description,
                  'telephone': pingpong.telephone,
                  'address': pingpong.address,
                  'roadAddress': pingpong.roadAddress,
                  'mapx': pingpong.mapx,
                  'mapy': pingpong.mapy,
                })
            .toList(),
      if (playStyle != null) "playStyle": playStyle,
      if (rubber != null) "rubber": rubber,
      if (racket != null) "racket": racket,
    };
  }

  CollectionReference<Map<String, dynamic>> pingpongCourtCollection() {
    // 유저의 pingpongCourt 서브컬렉션을 참조합니다.
    return FirebaseFirestore.instance.collection('UserData/$uid/pingpongCourt');
  }
}
