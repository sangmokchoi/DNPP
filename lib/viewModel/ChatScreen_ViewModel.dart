import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/statusUpdate/reportUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../repository/firebase_realtime_blockedList.dart';
import '../repository/firebase_realtime_messages.dart';
import '../repository/firebase_realtime_users.dart';
import '../statusUpdate/loginStatusUpdate.dart';
import '../statusUpdate/profileUpdate.dart';

class ChatScreenViewModel extends ChangeNotifier {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool?> chatScreenReportFunc(
    BuildContext context,
    String currentUserProfileUid,
    dynamic element,
    String chatRoomId,
      String chatText,
    List<String> reportData,
  ) async {

    await RepositoryRealtimeBlockedList()
        .getAddToBlockList(currentUserProfileUid, element, true)
        .then((value) async {

          debugPrint('채팅 신고 element: $element');
      String otherReason = Provider.of<ReportUpdate>(context, listen: false)
              .reportTextEditingController
              .text ??
          '';
      debugPrint('otherReason: $otherReason');

      final currentUserProfile =
          Provider.of<ProfileUpdate>(context, listen: false).userProfile;

      String reportItems = reportData.map((item) {
        debugPrint('item: $item');

        if (item == '기타') {
          return '<li>$item 사유: $otherReason</li>';
        } else {
          return '<li>${item}</li>';
        }
      }).join();

      String id = '';
      String nickName = '';

      if (element['id'] != null) {
        id = element['id'];
        nickName = element['firstName'];
      } else if (element['uid'] != null) {
        id = element['uid'];
        nickName = element['nickName'];
      }
          debugPrint('chatScreenReportFunc reportItems: $reportItems');

      // 상대방의 report 수 추가
      await RepositoryRealtimeUsers().getFlagOpponentReportedCount(id, chatRoomId, reportItems).then((reportCount) async {
      //element['id'] 는 채팅방에서 들어온 경우,
      //element['uid'] 는 matchingScreen에서 다이렉트로 들어온 경우
        debugPrint('getFlagOpponentReportedCount reportCount: $reportCount');

        if (reportCount == null) {
          // 중복 신고에 해당되므로 별도의 메일 발송 없음
          return false;

        } else {
          // 한 유저가 다른 유저를 신고하는 첫 신고에 해당하며, 메일 발송 필요
          final data = {
            "to": "simonwork177@simonwork.net",
            "reporter": "${currentUserProfile.uid.toString()}",
            "antireporter": "${id}",
            "reportcount": "$reportCount",
            "chatRoomid": "$chatRoomId",
            "message": {
              "subject": "핑퐁플러스 유저 신고",
              "html": """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .header {
            text-align: center;
            padding: 10px 0;
            border-bottom: 1px solid #eeeeee;
        }
        .header h1 {
            margin: 0;
            color: #444444;
        }
        .content {
            padding: 20px;
            text-align: left;
        }
        .content h2 {
            color: #444444;
        }
        .content p {
            line-height: 1.6;
        }
        .footer {
            text-align: center;
            padding: 10px 0;
            border-top: 1px solid #eeeeee;
            margin-top: 20px;
        }
        .footer p {
            margin: 0;
            color: #888888;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>핑퐁플러스 유저 신고</h1>
        </div>
        <div class="content">
            <h2>유저 신고 접수</h2>
            <p><strong>핑퐁플러스</strong>에서 유저 신고가 접수되었으며, 신고 내용에 대한 확인이 필요합니다.
            아래 내용을 토대로 Realtime Database를 확인해주세요</p>
            
            <h3>신고 대상자 정보</h3>
            <ul>
                <li>신고 대상자 닉네임: ${nickName}</li>
                <li>신고 대상자 uid: ${id}</li>
                <li>누적 신고수: ${reportCount}</li>
            </ul>
            
            <h3>신고 채팅:</h3>
            <ul>
                ${chatText}
            </ul>
            
            <h3>사유:</h3>
            <ul>
                ${reportItems}
            </ul>
            
            <h3>신고자 정보</h3>
            <ul>
                <li>신고자 닉네임: ${currentUserProfile.nickName.toString()}</li>
                <li>신고자 uid: ${currentUserProfile.uid.toString()}</li>
            </ul>
            
            <p>아래 버튼을 클릭하여 더 자세한 정보를 확인하세요:</p>
            <p style="text-align: center;">
                <a href="https://console.firebase.google.com/project/dnpp-402403/overview?hl=ko" style="background-color: #007BFF; color: #ffffff; padding: 10px 20px; text-decoration: none; border-radius: 5px;">자세히 보기</a>
            </p>
        </div>
        <div class="footer">
            <p>&copy; 2024 Simonwork. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
    """,
            },
          };

          db.collection("Report").add(data);

          // nickName은 다이렉트 진입 시,
          // firstname은 채팅 리스트에서 진입시,

          if (reportCount > 4) {
            // 5회 이상 신고되었음을 피신고자에게 고지하는 privateMail 발송
            // 단, 이미 5회 이상 고지가 된 경우에는 10회, 15회, 20 회 등으로 그 수를 달성했을 시에만 고지가 되어야 함

            int limitedDays = 0;

            if (reportCount == 5) {
              debugPrint('채팅 기능 7일 이용 정지');
              await RepositoryRealtimeUsers().getFlagOpponentLimitDays(
                  id); // 시간만 설정
              limitedDays = 7;

              await RepositoryRealtimeMessages().getSendPrivateReportWarning(
                  id, nickName, reportCount, limitedDays);

            } else if (reportCount == 10) {
              debugPrint('채팅 기능 14일 이용 정지');
              await RepositoryRealtimeUsers().getFlagOpponentLimitDays(
                  id); // 시간만 설정
              limitedDays = 14;

              await RepositoryRealtimeMessages().getSendPrivateReportWarning(
                  id, nickName, reportCount, limitedDays);

            } else if (reportCount == 15) {
              debugPrint('채팅 이용 영구 정지');
              await RepositoryRealtimeUsers().getFlagOpponentLimitDays(
                  id); // 시간만 설정

              await RepositoryRealtimeMessages().getSendPrivateReportWarning(
                  id, nickName, reportCount, limitedDays);
            }

            return true;
          }
        }

      });


    });
  }

}
