# 핑퐁플러스
<img
  src="https://firebasestorage.googleapis.com/v0/b/dnpp-402403.appspot.com/o/matchingScreen_images%2FPingpong%20Plus%20Banner%20(500%20x%20100).png?alt=media&token=b47e52ff-e306-4159-a286-0f063d37ce44"
  width="100%"
/>
</br>

## 00. 개요

- **개발 기간:** 2023.12 - 2024.06

- **Github:** [https://github.com/sangmokchoi/DNPP](https://github.com/sangmokchoi/DNPP)

- **App Store:** [<핑퐁플러스> 다운로드 바로가기](https://apps.apple.com/app/%ED%95%91%ED%90%81%ED%94%8C%EB%9F%AC%EC%8A%A4/id6478840964)

- **Play Store:** [<핑퐁플러스> 다운로드 바로가기](https://play.google.com/store/apps/details?id=com.simonwork.dnpp.dnpp)


- 기술 구조 요약
  - **UI:** `Figma`
  - **Communication:** `Confluence`
  - **Architecture**: `MVVM`
  - **Data Storage**: (Firebase) `Firestore Database`, `Realtime Database`, `Storage`
  - **Library/Framework:**
      - **Firebase**
      `Authentication`, `App Check`, `Cloud Functions`, `Crashlyitics`, `Messaging`, `Remote Config`
      - **Google**
      `AdMob`. `Analytics`
      - **Naver**
      `Naver Map`
      - **Flutter**
      `Provider`

</br>

## 01. 핑퐁플러스 소개 및 기능


<aside>

핑퐁플러스는 탁구를 사랑하는 마음 하나로 제작된 탁구 전용 일정관리 및 유저 매칭 플랫폼이에요.

탁구장에서 이미 레슨을 받고 계신가요?
레슨 내용을 기록하고, 까먹지 않게끔 핑퐁플러스에서 관리해보세요!

아니면, 아직 레슨은 받고 있지 않지만, 함께 탁구를 칠 상대를 찾고 있으신가요? 동네 주변에서 핑퐁플러스를 이용하는 유저를 찾아보세요. 탁구를 즐기고 싶은 진짜 탁구 Lover들을 만날 수 있을거에요!
</aside>

탁구장에서 레슨을 받거나, 탁구장에서 개최되는 대회에 참가할 일 등이 있다면, 핑퐁플러스에 기록해보세요.

- 핑퐁플러스에 프로필을 작성하고, 탁구장에 방문하는 일정을 등록해보세요. 같은 탁구장을 다니는 다른 유저, 같은 동네에서 사는 핑퐁플러스 회원을 쉽게 발견할 수 있습니다.
- 다른 유저들의 일정에 맞춰 함께 탁구를 쳐보자고 먼저 이야기도 건네보고, 등록해둔 탁구장에 언제 사람이 많은 지도 확인해서 탁구장에 나가보세요.
- 근처의 동네 탁구 친구들을 찾아보세요 프로필에 설정한 지역과 동일한 지역에서 활동하는 다른 핑퐁플러스 유저들을 만날 수 있습니다.


</br>


## 02. 구현 사항

<table>
  <tr>
    <td align="center"><b>2.1. Apple, Google, Kakao 로그인</b><br /><br /><img src="https://github.com/sangmokchoi/DNPP/assets/63656142/59bfe102-047d-434f-984f-15491a656f98" width="200"/></td>
    <td>
    <p>
        `google_sign_in`, `sign_in_with_apple`, `kakao_flutter_sdk`를 이용해 각 소셜 로그인 기능을 구현했습니다.
      </p>
   </td>
  </tr>
  <tr>
    <td align="center"><b>2.2. 프로필 설정 화면</b><br /><br /><img src="https://github.com/sangmokchoi/DNPP/assets/63656142/3f5528e5-af67-41ca-92a8-21df7b2e9df2" width="200"/></td>
    <td>
      <p>
        경력, 플레이스타일, 라켓 종류, 러버 종류 등을 설정할 수 있습니다.
      </p>
    </td>
  </tr>
  <tr>
    <td align="center"><b>2.3. 탁구장 방문 일정 등록 화면</b><br /><br /><img src="https://github.com/sangmokchoi/DNPP/assets/63656142/68498895-becb-4ba2-b64e-796d32423e35" width="200"/></td>
    <td>
    <p>
        레슨 받는 날, 대회 나가는 날, 개인 연습 하는 날 등
        탁구장에 나서는 날이 있다면 캘린더에 일정을 등록하고 관리해보세요.
      </p>
    </td>

  </tr>
  <tr>
    <td align="center"><b>2.4. 홈 화면 중 일부</b><br /><br /><img src="https://github.com/sangmokchoi/DNPP/assets/63656142/94d26f12-272c-4efb-bcb9-e992b33d3eb1" width="200"/></td>
    <td>
<p>
        - 일정을 등록하면 홈 화면에서 등록한 일정들을 요일별, 시간대, 탁구장별로 정리해서 차트로 보여줍니다.<br />
        (차트에서 요일을 클릭하면, 해당 요일에 등록된 일정들의 시간대를 보여줍니다)<br />
        - 탁구장에 방문하는 일정을 홈 화면에서 한 눈에 살펴볼 수 있습니다.<br />
        캘린더 화면에서 '일' 클릭 시, 일 단위 캘린더에 시간대별로 일정들이 나타납니다.
      </p>
</td>
  </tr>
  <tr>
    <td colspan="2" align="left"><b>2.5. 캘린더 화면</b><br /><br />
    <p>
        캘린더 화면에서 '전체' 클릭 시, 등록된 일정들만 시간순으로 표현됩니다.<br />
        캘린더 화면에서 '월' 클릭 시, 월 단위 캘린더에 일정들이 나타납니다.<br />
        캘린더 화면에서 '주' 클릭 시, 주 단위 캘린더에 시간대별로 일정들이 나타납니다.<br />
        캘린더 화면에서 '일' 클릭 시, 일 단위 캘린더에 시간대별로 일정들이 나타납니다.
      </p>
      <div style="display: flex; flex-direction: row; justify-content: space-around;">
        <img src="https://github.com/sangmokchoi/DNPP/assets/63656142/8ed2bb78-de17-4eaa-8189-9e192feeab7f" width="200"/>
        <img src="https://github.com/sangmokchoi/DNPP/assets/63656142/5ea86045-5328-4109-abfb-c4b3eb37708d" width="200"/>
        <img src="https://github.com/sangmokchoi/DNPP/assets/63656142/b4ee2caa-3ef0-471d-9c60-9c817e8b5f97" width="200"/>
        <img src="https://github.com/sangmokchoi/DNPP/assets/63656142/0c9c5282-fd28-4c92-83c4-e7e155810c05" width="200"/>
      </div>
    </td>
  </tr>
</table>



</br>

## 03. **기술적 의사결정**


### 3.1. **Flutter**
탁구 이용자의 연령층을 고려했을 떄, 비교적 높은 연령층이 안드로이드 디바이스를 사용하는 점을 염두에 두어 안드로이드 앱 출시를 필수로 고려했습니다.

이에 따라, 하이브리드 앱 개발을 결정하게 되었으며, Fltter와 Reace Native 중 학습 속도 및 Firebase과의 연동 경험에 있어 더욱 장점을 가지고 있다고 판단한 Flutter를 이용해 개발을 진행했습니다.

### 3.2. `syncfusion_flutter_calendar` 라이브러리
앱의 핵심 기능은 크게 2가지로, '캘린더를 이용한 일정 관리'와 '유저 매칭'입니다.

그래서 첫 번째로 캘린더 구현을 위해 여러 라이브러리 중 일, 주, 월 단위의 일정 관리가 수월한 `syncfusion_flutter_calendar` 라이브러리를 이용했습니다.
각 시간 단위별로 유저가 원하는 캘린더 뷰를 선택하여 볼 수 있으며, 일정 추가 및 관리 시에 직관적인 UI를 제공할 수 있었습니다.

### 3.3. `flutter_chat_ui` 라이브러리
두번째로 유저 매칭 기능을 위해서는 `flutter_chat_ui` 라이브러리를 이용해 채팅 화면을 구현했습니다. 
해당 라이브러리는 깔끔한 디자인과 더불어서, Firebase Realtime Database와의 가벼운 설정만으로 연동을 지원했기 때문에 채팅 기능 구현을 위한 개발 기간이 예상보다 적게 소요될 수 있었습니다.


## 04. **Trouble Shooting**


### 4.1. Loading 화면
#### 문제점
맨 처음 앱을 열 떄 로딩 시간이 15초 가량 소요되는 문제가 있었습니다.
원인은 Firebase Storage에서 화면을 구성하는데 사용되는 이미지 및 공지사항 등을 불러오는데 너무 오래 소요되는 것이었습니다.
주변인들에게 피드백을 받을 때도 로딩 시간이 너무 길다는 이야기를 들었기 때문에 필수적으로 문제를 해결해야 했습니다.

#### 해결방안
그래서 Firebase Storage에서 데이터를 불러오는 함수를 조정하고, 유저가 기다리는 화면을 바꿔서 덜 기다리는 것처럼 느끼게끔 만들고자 했습니다.

먼저, Storage에서 불러온 이미지 및 텍스트 데이터를 처리하는데 있어서 순차적으로 await 함수가 실행되는 것이 로딩 시간을 늘리는 주요 원인이었습니다. 그래서 await Future.wait([ ])로 여러 개의 await 함수들을 병렬 처리하여 로딩 시간을 단축시켰습니다.

또한, 별도의 loading view를 사용하는 것 대신에 home view를 Stack widget으로 구성하여 backgroundColor를 transParent로 설정했습니다. Stack  widget의 최상단에는 '데이터를 불러오는 중입니다'라는 안내 문구와 함께, CircularProgressIndicator를 배치해서 화면이 구성되고 있음을 시각적으로 볼 수 있게끔 했습니다.

결과적으로, 로딩 시간이 절반 정도인 6~7초로 줄어들었고, 추가적으로 주변인들에게 피드백을 요청했을 때도 로딩 시간에 대한 불편함을 이야기하는 경우는 없었습니다.

### 4.2. Chat
#### 문제점
채팅 기능 구현 중 상대방이 같은 채팅방에 있는 경우에도 상대가 보낸 채팅이 notification으로 나타났습니다.
평소, 카카오톡 등의 메신저를 이용하면서 경험했던 채팅 기능을 최대한 구현하려고 했기 때문에 해당 이슈는 큰 불편함으로 다가왔습니다.

#### 해결방안
이를 해결하기 위해서는 상대방이 채팅방에 들어와 있는 지 여부를 확인할 필요가 있었고, RealTime Database에 유저가 채팅방에 들어올 때마다 그 채팅방에 있는지 여부를 isUserRoom이라는 bool 변수로 기록했습니다. 특정 채팅방 마다 isUserRoom이라는 변수를 두어 진입 시에는 true로, 채팅방을 빠져나가게 되면, false로 기록했습니다.

채팅 발송 시, notification을 보내게 되는 경우는 isUserRoom이 false인 경우에만 발송하게끔 수정하여 같은 채팅방에 있는 경우라면, 채팅 notification이 나타나지 않게끔 설정해 문제를 해결했습니다.

### 4.3. FCM(Firebase Cloud Messasing)
#### 문제점
4.2의 연장선에 해당하는 부분으로, FCM을 구현하는 과정에서 Badge 관리에 어려움을 겪었습니다.
notification이 도착하게 되면 디바이스 자체적으로 이를 관리할 것으로 에상했기 때문에 발송 기능 구현에만 집중했던 점이 화근이었습니다.

특히, 채팅방 진입과 동시에 채팅을 읽었음을 표현하기 위해 그만큼 Badge 개수를 일일이 조정해줬어야 했는데, 디바이스의 badge 개수가 제대로 변경되지 않는 문제가 발생했습니다.

#### 해결방안
그래서 채팅방 리스트 화면에 진입하게 되면, 채팅방 별로 읽지 못한 메시지를 모두 더하여 디바이스의 Badge 개수로 업데이트하게끔 설정하였고, 추가적으로 모두 읽음 처리 기능을 구현하여 유저가 Badge 개수를 0으로 만들 수 있게끔 했습니다.

</br>
