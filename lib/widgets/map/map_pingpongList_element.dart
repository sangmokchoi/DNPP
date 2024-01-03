import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PPListElement extends StatelessWidget {
  PPListElement({
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

  void doubleToString() {
    String mapxString = mapx.toStringAsFixed(7); // 7자리로 고정된 소수점 형식
    String mapyString = mapy.toStringAsFixed(7);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        //print(title);
        final encodedTitle = Uri.encodeComponent(title);
        final url =
            'nmap://search?query=$encodedTitle&appname=com.simonwork.dnpp.dnpp';

        final Uri _url = Uri.parse(url);

        if (await launchUrl(_url)) {
          print('Could launch $url');
        } else {
          print('Could not launch $url');
        }
      },
      title: Padding(
        padding:
            EdgeInsets.only(top: 0.0, bottom: 0.0, left: 10.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45),
                        ),
                        Text(address,
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.black45),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Text(roadAddress,
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.black45),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        textStyle: TextStyle(fontSize: 15),
                      ),
                      onPressed: () {
                        print('팔로우 완료');
                      },
                      child: Text(
                        '팔로우',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
            Text(
              description,
              style: TextStyle(fontSize: 15.0, color: Colors.black45),
            ),
            Text(
              telephone,
              style: TextStyle(fontSize: 15.0, color: Colors.black45),
            ),
            Text(
              link,
              style: TextStyle(fontSize: 14.0, color: Colors.black45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Text(
            //   mapx.toString(),
            //   style: TextStyle(
            //       fontSize: 16.0,
            //       color: Colors.black45
            //   ),
            // ),
            // Text(
            //   mapy.toString(),
            //   style: TextStyle(
            //       fontSize: 16.0,
            //       color: Colors.black45
            //   ),
            // ),
            Divider(thickness: 2.0),
          ],
        ),
      ),
    );
  }
}
