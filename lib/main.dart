//import 'dart:js';

import 'package:dnpp/constants.dart';
import 'package:dnpp/view/calendar_screen.dart';
import 'package:dnpp/view/loading_screen.dart';
import 'package:dnpp/view/main_screen.dart';
import 'package:dnpp/view/map_screen.dart';
import 'package:dnpp/view/profile_screen.dart';
import 'package:dnpp/view/map_screen.dart';
import 'package:dnpp/view/setting_screen.dart';
import 'package:dnpp/view/signup_screen.dart';
import 'package:dnpp/viewModel/courtAppointmentUpdate.dart';
import 'package:dnpp/viewModel/loadingUpdate.dart';
import 'package:dnpp/viewModel/othersPersonalAppointmentUpdate.dart';
import 'package:dnpp/viewModel/personalAppointmentUpdate.dart';
import 'package:dnpp/viewModel/loginStatusUpdate.dart';
import 'package:dnpp/viewModel/mapWidgetUpdate.dart';
import 'package:dnpp/viewModel/profileUpdate.dart';
import 'package:dnpp/viewModel/sharedPreference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:provider/provider.dart';
import 'view/home_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NaverMapSdk.instance.initialize(
      clientId: '7evubnn4j6',
      onAuthFailed: (error) {
        print('Auth failed: $error');
      });

  try {
    kakao.KakaoSdk.init(nativeAppKey: '93a20d717a6ee1439f15045a460ac4cd');
  } catch (error) {
    print('KakaoSdk: $error');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(HomePage());
}

class HomePage extends StatelessWidget {

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(final BuildContext context) {

    // 라이트 모드와 다크 모드에 따라 테마 설정
    ThemeData theme = ThemeData(
      primaryColor: kMainColor, // 라이트 모드의 primaryColor 설정
      secondaryHeaderColor: Colors.grey,
    );

    ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: kMainColor, // 다크 모드의 primaryColor 설정
      secondaryHeaderColor: Colors.grey,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MapWidgetUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => PersonalAppointmentUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => OthersPersonalAppointmentUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => CourtAppointmentUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginStatusUpdate(),
        ),
        ChangeNotifierProvider(
          create: (context) => SharedPreference(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoadingUpdate(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          home: AnimatedSplashScreen(
            backgroundColor: kMainColor, //Theme.of(context).primaryColor,
            splash: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/핑퐁플러스 로고.png'),
                  //fit: BoxFit.cover,
                ),
              ),
            ),
            nextScreen: LoadingScreen(),//LoadingScreen(),//HomeScreen(),
            splashTransition: SplashTransition.fadeTransition,
          ),
          // theme: ThemeData(
          //   primaryColor: kMainColor,//Colors.blueAccent,
          //   //primarySwatch: Colors.blue,
          //   secondaryHeaderColor: Colors.grey,
          // ),
          theme: theme,
          darkTheme: darkTheme,
          // initialRoute: LoadingScreen.id,
          // routes: {
          //   // When navigating to the "/" route, build the FirstScreen widget.
          //   LoadingScreen.id: (context) => LoadingScreen(),
          //   HomeScreen.id: (context) => HomeScreen(), // '/'
          //   SignupScreen.id: (context) => SignupScreen(), // '/SignupScreenID'
          //   ProfileScreen.id: (context) => ProfileScreen(),// '/ProfileScreenID'
          //   MainScreen.id: (context) => MainScreen(), //MainScreenID
          //   MapScreen.id: (context) => MapScreen(), //MapScreenID
          //   CalendarScreen.id: (context) => CalendarScreen(),
          //   SettingScreen.id: (context) => SettingScreen(),//StatisticsScreenID
          // },
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('ko', 'KR'),
            // Locale('es', ''), // Spanish, no country code
          ],
        ),
      ),
    );
  }
}
