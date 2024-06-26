import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/pingpongList.dart';

class UserProfile {
  UserProfile(
      {required this.uid,
        required this.email,
      required this.nickName,
        required this.selfIntroduction,
      required this.photoUrl,
      required this.gender,
      required this.ageRange,
      required this.playedYears,
      required this.address,
      required this.pingpongCourt,
      required this.playStyle,
      required this.rubber,
      required this.racket,
      });

  String uid;
  String email;
  String nickName;
  String selfIntroduction;
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
      selfIntroduction: data?['selfIntroduction'],
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
      if (selfIntroduction != null) "selfIntroduction": selfIntroduction,
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

  static UserProfile emptyUserProfile = UserProfile(
    uid: 'uid',
    email: '로그인이 필요합니다',
    nickName: '반갑습니다!',
    selfIntroduction: '',
    photoUrl: 'https://firebasestorage.googleapis.com/v0/b/dnpp-402403.appspot.com/o/profile_photos%2Fempty_profile_6.png?alt=media&token=545efdd6-5b89-4cd6-953a-4c1a66f96f96',
    gender: '밝히지 않음',
    ageRange: '20대',
    playedYears: '미정',
    address: ['동네를 추가해주세요'],
    pingpongCourt: [],
    playStyle: '공격',
    rubber: '미정',
    racket: '미정',
  );

  // 깊은 복사를 위한 복사 생성자
  UserProfile.copy(UserProfile original)
      : uid = original.uid,
        email = original.email,
        nickName = original.nickName,
        selfIntroduction = original.selfIntroduction,
        photoUrl = original.photoUrl,
        gender = original.gender,
        ageRange = original.ageRange,
        playedYears = original.playedYears,
        address = List<String>.from(original.address),
        pingpongCourt = original.pingpongCourt?.map((item) => PingpongList.copy(item)).toList(),
        playStyle = original.playStyle,
        rubber = original.rubber,
        racket = original.racket;

}
