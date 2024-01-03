import 'package:flutter/material.dart';

class AddressListElement extends StatelessWidget {

  AddressListElement({
    required this.roadAddress,
    required this.jibunAddress,
    required this.x,
    required this.y,
  });

  final String roadAddress;
  final String jibunAddress;
  final String x;
  final String y;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 0.0, left: 10.0, right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roadAddress,
            style: TextStyle(
              fontSize: 20.0,
              //color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 2.0,
          ),
          Text(
            jibunAddress,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.black45
            ),
          ),
          Divider(
              thickness: 2.0
          ),
        ],
      ),
    );
  }
}