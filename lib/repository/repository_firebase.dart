import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dnpp/dataSource/firebase_auth_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseRepository {
  final _fireAuthInstance = FirebaseAuth.instance;

  //final _firestoreInstance = FirebaseFirestore.instance;

  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();

  //final SocialLogin _socialLogin;

  kakao.User? user;

  //MainViewModel(this._socialLogin);

  Future kakaoLoginFirebaseRegister() async {

    print('socialLogin 진입');
    user = await kakao.UserApi.instance.me();
    print('id: ${user!.id}');
    print('email: ${user!.kakaoAccount!.email!}');
    print('profile: ${user!.kakaoAccount!.profile}');

    final token = await _firebaseAuthDataSource.createCustomToken({
      'uid': user!.id.toString(),
      // 'displayName': user!.kakaoAccount!.profile!.nickname,
      'email': user!.kakaoAccount!.email!,
      //'photoURL': user!.kakaoAccount!.profile!.profileImageUrl!,
    });
    print('token: ${token}');
    print('새로 만든 로그인 함수 거의 완료');
    await FirebaseAuth.instance.signInWithCustomToken(token);
    print('socialLogin 완료');

  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential _credential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    if (_credential.user != null) {
      //User? user = _credential.user;
      var user = _credential.user;

      //logger.e(user);
      print('signInWithGoogle user: $user');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print('appleCredential.givenName: ${appleCredential.givenName}');
      print('appleCredential.familyName: ${appleCredential.familyName}');

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      print('signInWithApple: $authResult');
      //setUser(authResult.user);
      //return Future<void>.value();
    } catch (error) {
      print('error: $error');
      //setUser(null);
      //return Future<void>.value();
    }
  }

  // 서비스 설정에 오류가 있어 네이버 아이디로 로그인할 수 없습니다
  Future<void> signInWithNaver() async {
    // NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
    // final NaverLoginResult result = await FlutterNaverLogin.logIn();
    // print('res: $res');
    // print('result: $result');
    //
    // if (result.status == NaverLoginStatus.loggedIn) {
    //   print('accessToken = ${result.accessToken}');
    //   print('id = ${result.account.id}');
    //   print('email = ${result.account.email}');
    //   print('name = ${result.account.name}');
    //
    // }
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      print(res.toString());
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> kakaoLogin() async {
    if (await kakao.isKakaoTalkInstalled()) {
      print('isKakaoTalkInstalled yes');
      try {
        await kakao.UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공1');
        await kakaoLoginFirebaseRegister();
      } catch (error) {
        print('카카오톡으로 로그인 실패1 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공2');
          await kakaoLoginFirebaseRegister();
        } catch (error) {
          print('카카오계정으로 로그인 실패2 $error');
        }
      }
    } else {
      print('isKakaoTalkInstalled NO');
      try {
        await kakao.UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공3');
        await kakaoLoginFirebaseRegister();
      } catch (error) {
        print('카카오계정으로 로그인 실패3 $error');
      }
    }
  }

  Future<void> kakaoProfile() async{ // 현재 접속한 유저의 프로필을 가져오는 함수
    try {
      TalkProfile profile = await TalkApi.instance.profile();
      print('카카오톡 프로필 받기 성공'
          '\n닉네임: ${profile.nickname}'
          '\n프로필사진: ${profile.thumbnailUrl}');
    } catch (error) {
      print('카카오톡 프로필 받기 실패 $error');
    }
  }

  Future<void> kakaoLoadFriendsList() async {
    try {
      Friends friends = await TalkApi.instance.friends();
      print('카카오톡 친구 목록 가져오기 성공'
          '\n${friends.elements?.map((friend) => friend.profileNickname).join('\n')}');
    } catch (error) {
      print('카카오톡 친구 목록 가져오기 실패 $error');
    }
  }



  Future<void> kakaoSelectFriends(BuildContext context) async {

    kakao.User user;

    try {
      user = await UserApi.instance.me();
      print('사용자 정보 요청 성공');
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return;
    }

    // 사용자의 추가 동의가 필요한 사용자 정보 동의항목 확인
    List<String> scopes = [];

    if (user.kakaoAccount?.emailNeedsAgreement == true) {
      print('scopes.add(account_email)');
      scopes.add('account_email');
    }
    if (user.kakaoAccount?.birthdayNeedsAgreement == true) {
      print('scopes.add(birthday)');
      scopes.add("birthday");
    }
    if (user.kakaoAccount?.birthyearNeedsAgreement == true) {
      print('scopes.add(birthyear)');
      scopes.add("birthyear");
    }
    if (user.kakaoAccount?.ciNeedsAgreement == true) {
      print('scopes.add(account_ci)');
      scopes.add("account_ci");
    }
    if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) {
      print('scopes.add(phone_number)');
      scopes.add("phone_number");
    }
    if (user.kakaoAccount?.profileNeedsAgreement == true) {
      print('scopes.add(profile)');
      scopes.add("profile");
    }
    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) {
      print('scopes.add(age_range)');
      scopes.add("age_range");
    }

    scopes.add("friends"); // 친구 설정 시 해당 내용 add 하게끔 설정 필요

    if (scopes.length > 0) {
      print('사용자에게 추가 동의 받아야 하는 항목이 있습니다');

      // OpenID Connect 사용 시
      // scope 목록에 "openid" 문자열을 추가하고 요청해야 함
      // 해당 문자열을 포함하지 않은 경우, ID 토큰이 재발급되지 않음
      // scopes.add("openid")

      // scope 목록을 전달하여 추가 항목 동의 받기 요청
      // 지정된 동의항목에 대한 동의 화면을 거쳐 다시 카카오 로그인 수행
      OAuthToken token;
      try {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        print('현재 사용자가 동의한 동의항목: ${token.scopes}');
      } catch (error) {
        print('추가 동의 요청 실패 $error');
        return;
      }

      // 사용자 정보 재요청
      try {
        kakao.User user = await UserApi.instance.me();
        print('사용자 정보 필요청 성공'
            '\n회원번호: ${user.id}'
            '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
            '\n이메일: ${user.kakaoAccount?.email}');
      } catch (error) {
        print('사용자 정보 요청 실패 $error');
      }
    }

    // 파라미터 설정
    var params = PickerFriendRequestParams(
      title: '멀티 친구 피커',
      enableSearch: true,
      showMyProfile: true,
      showFavorite: true,
      showPickedFriend: true,
      maxPickableCount: null,
      minPickableCount: null,
      enableBackButton: true,
    );

// 피커 호출
    try {
      print('피커 호출');
      SelectedUsers users = await PickerApi.instance.selectFriends(params: params, context: context);
      print('users: $users');
      print('친구 선택 성공: ${users.users!.length}');
    } catch(e) {
      print('친구 선택 실패: $e');
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Future<UserCredential> signInWithApple() async {
  //   final rawNonce = generateNonce();
  //   final nonce = sha256ofString(rawNonce);
  //
  //   //앱에서 애플 로그인 창을 호출하고, apple계정의 credential을 가져온다.
  //   final appleCredential = await SignInWithApple.getAppleIDCredential(
  //     scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ],
  //     nonce: nonce,
  //   );
  //
  //   //그 credential을 넣어서 OAuth를 생성
  //   final oauthCredential = OAuthProvider("apple.com").credential(
  //     idToken: appleCredential.identityToken,
  //     rawNonce: rawNonce,
  //   );
  //
  //   //OAuth를 넣어서 firebase유저 생성
  //   return await _fireAuthInstance.signInWithCredential(oauthCredential);
  // }


// Stream<UserModel?> getUserStream() {
//   //userChanges()는 User타입의 객체를 Stream으로 갖고오는 Firebase제공 함수이다.
//   //Firebase와 연결된 User가 변경될 때 마다 transform()을 실행한다.
//   //userModel은 제공해주는 타입이 아니라, 직접 만들어야 한다.
//   //model클래스 생성에 대해서는 freezed에 대해서 설명할때 또 다루겠다.
//   return _fireAuthInstance.userChanges().transform(
//       StreamTransformer<User?, UserModel?>.fromHandlers(
//           handleData: (user, sink) async {
//
//             //user타입을 갖고오는데 실패했으면 stream에 아무것도 추가하지 않는다.
//             if (user == null) {
//               sink.add(null);
//               return;
//             }
//
//             var userCollection = _firestoreInstance.collection("user");
//             Map<String, dynamic> userDoc = {};
//
//             try {
//               //try catch로 유저 있어요?를 물어본다. 유저가 있다면 데이터를 긁어와주고 끝
//               var snapshot = await userCollection.doc(user.uid).get();
//               userDoc = snapshot.data() as Map<String, dynamic>;
//             } catch (e) {
//               //유저가 없으면 만들어주자
//               var addedUser = await userCollection.doc(user.uid).set({
//                 //나의 UserModel에 있는 param들을 넣는다.
//                 'uid': user.uid,
//                 'createdAt': DateTime.now(),
//                 'email': user.email,
//                 'nickName': '',
//                 'isTermChecked': false,
//                 'age': 0,
//               });
//               var snapshot = await userCollection.doc(user.uid).get();
//               userDoc = snapshot.data() as Map<String, dynamic>;
//             }
//             return sink.add(UserModel.fromJson(userDoc));
//           }));
// }
}
