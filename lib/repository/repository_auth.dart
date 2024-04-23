import 'dart:convert';

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dnpp/dataSource/firebase_auth_remote_data_source.dart';
import 'package:dnpp/repository/chatBackgroundListen.dart';
import 'package:dnpp/repository/launchUrl.dart';
import 'package:dnpp/repository/repository_userData.dart';
import 'package:dnpp/repository/repsitory_appointments.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../statusUpdate/profileUpdate.dart';

class RepositoryAuth {
  final _fireAuth = FirebaseAuth.instance;

  FirebaseFirestore db = FirebaseFirestore.instance;

  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();

  kakao.User? user;

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("signOut Success");
    } catch (e) {
      print('e.toString(): ${e.toString()}');
    }
  }

  Future<void> deleteUserAccount() async {
    print('deleteUserAccount start!');

    try {

      await RepositoryUserData().deleteUser(_fireAuth.currentUser!.uid.toString());
      await RepositoryAppointments().deleteUserAppointment(_fireAuth.currentUser!.uid.toString());
      await ChatBackgroundListen().deleteUsersData(_fireAuth.currentUser!.uid.toString());
      await ChatBackgroundListen().deleteChatData(_fireAuth.currentUser!.uid.toString());
      await ChatBackgroundListen().adjustOpponentBadgeCount(_fireAuth.currentUser!.uid.toString());
      await FirebaseAuth.instance.currentUser!.delete();

      print('deleteUserAccount 완료');
      print('여기서 유저 데이터 삭제 및 해당 유저의 Appointment 문서 모두 삭제 필요');
    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.code == "requires-recent-login") {
        print('e.code: ${e.code}');
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions

      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> linkWithCredential(AuthCredential credential) async {

    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
    }
  }

  Future<void> unlink(String providerId) async {
    try {
      await FirebaseAuth.instance.currentUser?.unlink(providerId);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "no-such-provider":
          print("The user isn't linked to the provider or the provider "
              "doesn't exist.");
          break;
        default:
          print("Unkown error.");
      }
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    print('_reauthenticateAndDelete start!');

    try {
      final providerData = FirebaseAuth.instance.currentUser?.providerData;
      print('providerData: $providerData');
      print('providerData?.isEmpty: ${providerData?.isEmpty}');

      if (providerData!.isEmpty) {
        print('카카오로 로그인함');

        if (await AuthApi.instance.hasToken()) {
          try {
            AccessTokenInfo tokenInfo =
                await UserApi.instance.accessTokenInfo();
            print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');

            try {
              // 카카오계정으로 로그인
              OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
              print('로그인 성공 ${token.accessToken}');

              try {
                await UserApi.instance.unlink();
                print('연결 끊기 성공, SDK에서 토큰 삭제');
              } catch (error) {
                print('연결 끊기 실패 $error');
              }
            } catch (error) {
              print('로그인 실패 $error');
            }
          } catch (error) {
            if (error is KakaoException && error.isInvalidTokenError()) {
              print('토큰 만료 $error');
            } else {
              print('토큰 정보 조회 실패 $error');
            }
          }
        } else {
          print('발급된 토큰 없음');
          try {
            OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
            print('로그인 성공 ${token.accessToken}');
          } catch (error) {
            print('로그인 실패 $error');
          }
        }
      }

      if (AppleAuthProvider().providerId == providerData?.first.providerId) {
        print('AppleAuthProvider');
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId ==
          providerData?.first.providerId) {
        print('GoogleAuthProvider');
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      } else {
        print('else else else else');
      }
      print('delete 직전');

      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
      print('_reauthenticateAndDelete $e');
    }
  }

  Future kakaoLoginFirebaseRegister(BuildContext context) async {
    print('socialLogin 진입');
    user = await kakao.UserApi.instance.me();

    //print('user: ${user}');
    print('id: ${user!.id}');
    print('name: ${user!.kakaoAccount!.profile!.nickname!}'); //
    print('email: ${user!.kakaoAccount!.email!}');
    print('profile: ${user!.kakaoAccount!.profile}');
    print('profileImageUrl: ${user!.kakaoAccount!.profile?.profileImageUrl}');

    final token = await _firebaseAuthDataSource.createCustomToken({
      'uid': user!.id.toString(),
      'displayName': user!.kakaoAccount!.profile!.nickname,
      'email': user!.kakaoAccount!.email!,
      'photoURL': user!.kakaoAccount!.profile!.profileImageUrl!,
    });
    print('token: ${token}');
    print('새로 만든 로그인 함수 거의 완료');
    final credential = await FirebaseAuth.instance.signInWithCustomToken(token);
    //await linkWithCredential(credential);
    print('UserCredential credential: ${credential}');

    print('socialLogin 완료');

    await Provider.of<ProfileUpdate>(context, listen: false)
        .updateName(user!.kakaoAccount!.profile!.nickname!);
    await Provider.of<ProfileUpdate>(context, listen: false)
        .updateId(user!.id.toString());
    await Provider.of<ProfileUpdate>(context, listen: false)
        .updateEmail(user!.kakaoAccount!.email!);
    await Provider.of<ProfileUpdate>(context, listen: false)
        .updateImageUrl(user!.kakaoAccount!.profile!.profileImageUrl!);

    print('유저에게 사진 및 프로필 정보를 가져올지 말지 이때 문의 필요');
  }

  Future<bool> signInWithGoogle(BuildContext context) async {

    try {

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        String errorMessage = 'error is PlatformException && error.code == "CANCELED"';
        throw Exception(errorMessage);
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      print('OAuthCredential credential: ${credential}');
      //await linkWithCredential(credential);

      UserCredential _credential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('UserCredential _credential: ${_credential}');

      if (_credential.user != null) {
        //User? user = _credential.user;
        var user = _credential.user;

        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateName(user?.displayName ?? '');
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateId(user?.uid ?? '');
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateEmail(user?.email ?? '');
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateImageUrl(user?.photoURL ?? '');

        // print('id: ${Provider.of<ProfileUpdate>(context, listen: false).id}');
        // print(
        //     'email: ${Provider.of<ProfileUpdate>(context, listen: false).email}');
        // print(
        //     'imageUrl: ${Provider.of<ProfileUpdate>(context, listen: false).imageUrl}');

        //logger.e(user);
        print('signInWithGoogle user: $user');
        print('유저에게 사진 및 프로필 정보를 가져올지 말지 이때 문의 필요');

      }
      return true;

    } catch (error) {
      print('signInGoogle error: ${error}');
      if (error is PlatformException && error.code == 'CANCELED') { // 유저가 취소함
        print('error is PlatformException && error.code == "CANCELED"');

      }
      return false;
    }
  }

  Future<bool> signInWithApple(BuildContext context) async {
    print('signInWithApple 시작');
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      print('AuthorizationCredentialAppleID appleCredential: $appleCredential');
      //appleCredential: AuthorizationAppleID(000715.26ba164a2958469190db193831ed1504.0425, null, null, null, null)
      print('appleCredential.givenName: ${appleCredential.givenName}');
      print('appleCredential.familyName: ${appleCredential.familyName}');
      print('appleCredential.email: ${appleCredential.email}');
      print(
          'appleCredential.authorizationCode: ${appleCredential.authorizationCode}');
      print('appleCredential.identityToken: ${appleCredential.identityToken}');
      print(
          'appleCredential.userIdentifier: ${appleCredential.userIdentifier}');

      final credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      print('OAuthCredential credential: ${credential}');
      //await linkWithCredential(credential);

      final authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('UserCredential authResult: $authResult');
      print('signInWithApple user: ${authResult.user}');
      print(
          'signInWithApple additionalUserInfo: ${authResult.additionalUserInfo}');
      print('signInWithApple credential: ${authResult.credential}');

      if (authResult.user != null) {
        print('user != null');
        var user = authResult.user;
        print('user: $user');
        String nickName = '';

        if (user!.displayName == null) {

          if (appleCredential.givenName == null) {
            nickName = '';
            print('"" nickName: $nickName');
          } else {
            nickName = appleCredential.givenName!;
            print('appleCredential.givenName! nickName: $nickName');
          }

        } else {
          nickName = user!.displayName!;
          print('user!.displayName! nickName: $nickName');

        }

        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateName(nickName);
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateId(user!.uid);
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateEmail(user!.email ?? '');
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateImageUrl(user!.photoURL ?? '');

        // print('id: ${Provider.of<ProfileUpdate>(context, listen: false).id}');
        // print(
        //     'email: ${Provider.of<ProfileUpdate>(context, listen: false).email}');
        // print(
        //     'imageUrl: ${Provider.of<ProfileUpdate>(context, listen: false).imageUrl}');
      } else {
        print('user == null');
      }

      print('유저에게 사진 및 프로필 정보를 가져올지 말지 이때 문의 필요');

      //setUser(authResult.user);
      //return Future<void>.value();
      return true;
    } catch (error) {
      print('signinWithApple error: ${error}');
      //setUser(null);
      if (error.toString().contains('canceled')) {
        print('Apple 로그인이 사용자에 의해 취소되었습니다.');
      }
      return false;
    }

  }

  Future<bool> kakaoLogin(BuildContext context) async {
    try {

      if (await kakao.isKakaoTalkInstalled()) {
        print('isKakaoTalkInstalled yes');

        try {
          await kakao.UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공1');
          await kakaoLoginFirebaseRegister(context);
          return true;

        } catch (error) {
          print('카카오톡으로 로그인 실패1 $error');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            print('error is PlatformException && error.code == "CANCELED"');
            throw Exception(error);
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await kakao.UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공2');
            await kakaoLoginFirebaseRegister(context);
            return true;

          } catch (error) {
            print('카카오계정으로 로그인 실패2 $error');
            if (error is PlatformException && error.code == 'CANCELED') {
              print('error is PlatformException && error.code == "CANCELED"');
            }
            throw Exception(error);
          }
        }
      } else {
        print('isKakaoTalkInstalled NO');

        try {
          await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공3');
          await kakaoLoginFirebaseRegister(context);

          return true;

        } catch (error) {
          print('카카오계정으로 로그인 실패3 $error');
          if (error is PlatformException && error.code == 'CANCELED') {
            print('error is PlatformException && error.code == "CANCELED"');
          }
          throw Exception(error);
        }
      }

    } catch (error) {
      print('카카오 로그인 $error');
      if (error is PlatformException && error.code == 'CANCELED') {
        print('error is PlatformException && error.code == "CANCELED"');
        return false;
      }
      return false;
    }
  }

  Future<void> kakaoProfile() async {
    // 현재 접속한 유저의 프로필을 가져오는 함수
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
      SelectedUsers users = await PickerApi.instance
          .selectFriends(params: params, context: context);
      print('users: $users');
      print('친구 선택 성공: ${users.users!.length}');
    } catch (e) {
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

  Future<void> permissionPersonalInfo(bool isOkayToGet) async {}
}
