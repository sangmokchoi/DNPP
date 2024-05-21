import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dnpp/RemoteDataSource/firebase_auth_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../statusUpdate/profileUpdate.dart';
import 'firebase_realtime/users/DS_Local_isUserInApp.dart';

class LocalDSAuth {

  final currentUser = FirebaseAuth.instance.currentUser;
  kakao.User? user;

  Future<void> signOut() async {
    try {
      final providerData = currentUser?.providerData;
      debugPrint('providerData: $providerData');
      debugPrint('providerData?.isEmpty: ${providerData?.isEmpty}');

      if (providerData!.isEmpty) {
        debugPrint('카카오로 로그인함');

        try {
          await UserApi.instance.logout();
          debugPrint('로그아웃 성공, SDK에서 토큰 삭제');

          try {
            LocalDSIsUserInApp().disconnectIsCurrentUserInApp().then((value) async {
              await FirebaseAuth.instance.signOut();
            });

            debugPrint('FirebaseAuth.instance.signOut 성공');
          } catch (error) {
            debugPrint('FirebaseAuth.instance.signOut 실패: $error');
          }
        } catch (error) {
          debugPrint('로그아웃 실패, SDK에서 토큰 삭제 $error');

          try {
            LocalDSIsUserInApp().disconnectIsCurrentUserInApp().then((value) async {
              await FirebaseAuth.instance.signOut();
            });
            debugPrint('FirebaseAuth.instance.signOut 성공');
          } catch (error) {
            debugPrint('FirebaseAuth.instance.signOut 실패: $error');
          }
        }
      } else {
        try {
          LocalDSIsUserInApp().disconnectIsCurrentUserInApp().then((value) async {
            await FirebaseAuth.instance.signOut();
          });

          debugPrint('FirebaseAuth.instance.signOut 성공');
        } catch (error) {
          debugPrint('FirebaseAuth.instance.signOut 실패: $error');
        }
      }
    } catch (e) {
      debugPrint('signOut e.toString(): ${e.toString()}');
    }
  }

  Future<void> linkWithCredential(AuthCredential credential) async {

    try {

      await currentUser?.linkWithCredential(credential);

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          debugPrint("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          debugPrint("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          debugPrint("Unknown error.");
      }
    }
  }

  Future<void> unlink(String providerId) async {
    try {
      await currentUser?.unlink(providerId);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "no-such-provider":
          debugPrint("The user isn't linked to the provider or the provider "
              "doesn't exist.");
          break;
        default:
          debugPrint("Unkown error.");
      }
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        String errorMessage =
            'error is PlatformException && error.code == "CANCELED"';
        throw Exception(errorMessage);
      }

      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      debugPrint('OAuthCredential credential: ${credential}');
      //await linkWithCredential(credential);

      UserCredential _credential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('UserCredential _credential: ${_credential}');

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

        debugPrint('signInWithGoogle user: $user');
        debugPrint('유저에게 사진 및 프로필 정보를 가져올지 말지 이때 문의 필요');
      }
      return true;
    } catch (error) {
      debugPrint('signInGoogle error: ${error}');
      if (error is PlatformException && error.code == 'CANCELED') {
        // 유저가 취소함
        debugPrint('error is PlatformException && error.code == "CANCELED"');
      }
      return false;
    }
  }


  Future<void> kakaoProfile() async {
    // 현재 접속한 유저의 프로필을 가져오는 함수
    try {
      TalkProfile profile = await TalkApi.instance.profile();
      debugPrint('카카오톡 프로필 받기 성공'
          '\n닉네임: ${profile.nickname}'
          '\n프로필사진: ${profile.thumbnailUrl}');
    } catch (error) {
      debugPrint('카카오톡 프로필 받기 실패 $error');
    }
  }

  Future<void> kakaoLoadFriendsList() async {
    try {
      Friends friends = await TalkApi.instance.friends();
      debugPrint('카카오톡 친구 목록 가져오기 성공'
          '\n${friends.elements?.map((friend) => friend.profileNickname).join('\n')}');
    } catch (error) {
      debugPrint('카카오톡 친구 목록 가져오기 실패 $error');
    }
  }

  Future<void> kakaoSelectFriends(BuildContext context) async {
    kakao.User user;

    try {
      user = await UserApi.instance.me();
      debugPrint('사용자 정보 요청 성공');
    } catch (error) {
      debugPrint('사용자 정보 요청 실패 $error');
      return;
    }

    // 사용자의 추가 동의가 필요한 사용자 정보 동의항목 확인
    List<String> scopes = [];

    if (user.kakaoAccount?.emailNeedsAgreement == true) {
      debugPrint('scopes.add(account_email)');
      scopes.add('account_email');
    }
    if (user.kakaoAccount?.birthdayNeedsAgreement == true) {
      debugPrint('scopes.add(birthday)');
      scopes.add("birthday");
    }
    if (user.kakaoAccount?.birthyearNeedsAgreement == true) {
      debugPrint('scopes.add(birthyear)');
      scopes.add("birthyear");
    }
    if (user.kakaoAccount?.ciNeedsAgreement == true) {
      debugPrint('scopes.add(account_ci)');
      scopes.add("account_ci");
    }
    if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) {
      debugPrint('scopes.add(phone_number)');
      scopes.add("phone_number");
    }
    if (user.kakaoAccount?.profileNeedsAgreement == true) {
      debugPrint('scopes.add(profile)');
      scopes.add("profile");
    }
    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) {
      debugPrint('scopes.add(age_range)');
      scopes.add("age_range");
    }

    scopes.add("friends"); // 친구 설정 시 해당 내용 add 하게끔 설정 필요

    if (scopes.length > 0) {
      debugPrint('사용자에게 추가 동의 받아야 하는 항목이 있습니다');

      // OpenID Connect 사용 시
      // scope 목록에 "openid" 문자열을 추가하고 요청해야 함
      // 해당 문자열을 포함하지 않은 경우, ID 토큰이 재발급되지 않음
      // scopes.add("openid")

      // scope 목록을 전달하여 추가 항목 동의 받기 요청
      // 지정된 동의항목에 대한 동의 화면을 거쳐 다시 카카오 로그인 수행
      OAuthToken token;
      try {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        debugPrint('현재 사용자가 동의한 동의항목: ${token.scopes}');
      } catch (error) {
        debugPrint('추가 동의 요청 실패 $error');
        return;
      }

      // 사용자 정보 재요청
      try {
        kakao.User user = await UserApi.instance.me();
        debugPrint('사용자 정보 필요청 성공'
            '\n회원번호: ${user.id}'
            '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
            '\n이메일: ${user.kakaoAccount?.email}');
      } catch (error) {
        debugPrint('사용자 정보 요청 실패 $error');
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
      debugPrint('피커 호출');
      SelectedUsers users = await PickerApi.instance
          .selectFriends(params: params, context: context);
      debugPrint('users: $users');
      debugPrint('친구 선택 성공: ${users.users!.length}');
    } catch (e) {
      debugPrint('친구 선택 실패: $e');
    }
  }

  Future<bool> signInWithApple(BuildContext context) async {
    debugPrint('signInWithApple 시작');
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      debugPrint('AuthorizationCredentialAppleID appleCredential: $appleCredential');
      //appleCredential: AuthorizationAppleID(000715.26ba164a2958469190db193831ed1504.0425, null, null, null, null)
      debugPrint('appleCredential.givenName: ${appleCredential.givenName}');
      debugPrint('appleCredential.familyName: ${appleCredential.familyName}');
      debugPrint('appleCredential.email: ${appleCredential.email}');
      debugPrint(
          'appleCredential.authorizationCode: ${appleCredential.authorizationCode}');
      debugPrint('appleCredential.identityToken: ${appleCredential.identityToken}');
      debugPrint(
          'appleCredential.userIdentifier: ${appleCredential.userIdentifier}');

      final credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      debugPrint('OAuthCredential credential: ${credential}');
      //await linkWithCredential(credential);

      final authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint('UserCredential authResult: $authResult');
      debugPrint('signInWithApple user: ${authResult.user}');
      debugPrint(
          'signInWithApple additionalUserInfo: ${authResult.additionalUserInfo}');
      debugPrint('signInWithApple credential: ${authResult.credential}');

      if (authResult.user != null) {
        debugPrint('user != null');
        var user = authResult.user;
        debugPrint('user: $user');
        String nickName = '';

        if (user!.displayName == null) {
          if (appleCredential.givenName == null) {
            nickName = '';
            debugPrint('"" nickName: $nickName');
          } else {
            nickName = appleCredential.givenName!;
            debugPrint('appleCredential.givenName! nickName: $nickName');
          }
        } else {
          nickName = user!.displayName!;
          debugPrint('user!.displayName! nickName: $nickName');
        }

        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateName(nickName);
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateId(user!.uid);
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateEmail(user!.email ?? '');
        await Provider.of<ProfileUpdate>(context, listen: false)
            .updateImageUrl(user!.photoURL ?? '');

        // debugPrint('id: ${Provider.of<ProfileUpdate>(context, listen: false).id}');
        // debugPrint(
        //     'email: ${Provider.of<ProfileUpdate>(context, listen: false).email}');
        // debugPrint(
        //     'imageUrl: ${Provider.of<ProfileUpdate>(context, listen: false).imageUrl}');
      } else {
        debugPrint('user == null');
      }

      debugPrint('유저에게 사진 및 프로필 정보를 가져올지 말지 이때 문의 필요');

      //setUser(authResult.user);
      //return Future<void>.value();
      return true;
    } catch (error) {
      debugPrint('signinWithApple error: ${error}');
      //setUser(null);
      if (error.toString().contains('canceled')) {
        debugPrint('Apple 로그인이 사용자에 의해 취소되었습니다.');
      }
      return false;
    }
  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

}
