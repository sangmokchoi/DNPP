import 'package:dnpp/LocalDataSource/DS_Local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../RemoteDataSource/firebase_auth_remote_datasource.dart';
import '../statusUpdate/profileUpdate.dart';

class RepositoryFirebaseAuth {

  final _firebaseAuthRemoteDataSource = FirebaseAuthRemoteDataSource();
  final _localDSAuth = LocalDSAuth();

  final currentUser = FirebaseAuth.instance.currentUser;
  kakao.User? user;

  Future<void> deleteUserAccount() async {
    print('deleteUserAccount start!');

    try {

      final providerData = currentUser?.providerData;
      print('providerData: $providerData');
      print('providerData?.isEmpty: ${providerData?.isEmpty}');

      //await ChatBackgroundListen().adjustOpponentBadgeCount(_fireAuth.currentUser!.uid.toString());
      await currentUser!.delete();

      if (providerData!.isEmpty) {
        try {
          await UserApi.instance.unlink();
          print('연결 끊기 성공, SDK에서 토큰 삭제');
        } catch (error) {
          print('연결 끊기 실패 $error');
        }
      }

      print('deleteUserAccount 완료');
    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.code == "requires-recent-login") {
        print('e.code: ${e.code}');
        await _reAuthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> _reAuthenticateAndDelete() async {
    print('_reauthenticateAndDelete start!');

    try {
      final providerData = currentUser?.providerData;
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
        await currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId ==
          providerData?.first.providerId) {
        print('GoogleAuthProvider');
        await currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      } else {
        print('else else else else');
      }
      print('delete 직전');

      await currentUser?.delete();
    } catch (e) {
      // Handle exceptions
      print('_reauthenticateAndDelete $e');
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
  Future kakaoLoginFirebaseRegister(BuildContext context) async {
    print('socialLogin 진입');
    user = await kakao.UserApi.instance.me();

    //print('user: ${user}');
    print('id: ${user!.id}');
    print('name: ${user!.kakaoAccount!.profile!.nickname!}'); //
    print('email: ${user!.kakaoAccount!.email!}');
    print('profile: ${user!.kakaoAccount!.profile}');
    print('profileImageUrl: ${user!.kakaoAccount!.profile?.profileImageUrl}');

    final token = await _firebaseAuthRemoteDataSource.createCustomToken({
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

  Future<void> getSignOut() async {
    return await _localDSAuth.signOut();
  }
  Future<void> getLinkWithCredential(AuthCredential credential) async {
    return await _localDSAuth.linkWithCredential(credential);
  }
  Future<void> getUnlink(String providerId) async {
    return await _localDSAuth.unlink(providerId);
  }
  Future<bool> getSignInWithGoogle(BuildContext context) async {
    return await _localDSAuth.signInWithGoogle(context);
  }
  Future<void> getKakaoProfile() async {
    return await _localDSAuth.kakaoProfile();
  }
  Future<void> getKakaoLoadFriendsList() async {
    return await _localDSAuth.kakaoLoadFriendsList();
  }
  Future<void> getKakaoSelectFriends(BuildContext context) async {
    return await _localDSAuth.kakaoSelectFriends(context);
  }
  Future<bool> getSignInWithApple(BuildContext context) async {
    return await _localDSAuth.signInWithApple(context);
  }


}