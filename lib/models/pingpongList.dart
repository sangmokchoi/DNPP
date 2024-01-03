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
}