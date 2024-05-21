import 'package:cloud_firestore/cloud_firestore.dart';

class PingpongList {
  PingpongList({
    required this.title,
    required this.link,
    required this.description,
    required this.telephone,
    required this.address,
    required this.roadAddress,
    required this.mapx,
    required this.mapy,
  });

  final String title;
  final String link;
  final String description;
  final String telephone;
  final String address;
  final String roadAddress;
  final double mapx;
  final double mapy;

  static PingpongList emptyPingpongList = PingpongList(
     title: '',
    link: '',
    description: '',
    telephone: '',
    address: '',
    roadAddress: '',
    mapx: 0.0,
    mapy: 0.0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PingpongList &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              roadAddress == other.roadAddress &&
              address == other.address;

  @override
  int get hashCode => title.hashCode ^ roadAddress.hashCode ^ address.hashCode;


  factory PingpongList.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PingpongList(
      title: data?['title'],
      link: data?['link'],
      description: data?['description'],
      telephone: data?['telephone'],
      address: data?['address'],
      roadAddress: data?['roadAddress'],
      mapx: data?['mapx'],
      mapy: data?['mapy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (link != null) "link": link,
      if (description != null) "description": description,
      if (telephone != null) "telephone": telephone,
      if (address != null) "address": address,
      if (roadAddress != null) "roadAddress": roadAddress,
      if (mapx != null) "mapx": mapx,
      if (mapy != null) "mapy": mapy,
    };
  }

  // 복사 생성자
  PingpongList.copy(PingpongList original)
      : title = original.title,
        link = original.link,
        description = original.description,
        telephone = original.telephone,
        address = original.address,
        roadAddress = original.roadAddress,
        mapx = original.mapx,
        mapy = original.mapy;
}