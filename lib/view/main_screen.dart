import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnpp/models/main_chartBasic.dart';
import 'package:dnpp/models/pingpongList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:dnpp/widgets/map/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/userProfile.dart';
import '../viewModel/loginStatusUpdate.dart';
import '../viewModel/profileUpdate.dart';
import '../widgets/chart/main_barChart.dart';

import '../viewModel/appointmentUpdate.dart';
import '../widgets/chart/main_lineChart.dart';
import '../widgets/paging/main_graphs.dart';

class MainScreen extends StatefulWidget {
  static String id = '/MainScreenID';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _imagePageController = PageController(initialPage: 0);
  final PageController _barChartPageController = PageController();
  int _currentPage = 0;

  Map<String?, Uint8List?> imageMap = {};
  Map<String?, String?> urlMap = {};
  Map<String, String> refStringList = {};

  int count = 0;

  late Future<void> myFuture;

  FirebaseFirestore db = FirebaseFirestore.instance;

  bool isLoading = false;

  double _buttonwidth(BuildContext context, int buttoncount) {
    final width = (MediaQuery.of(context).size.width - 80) / buttoncount;
    return width;
  }

  Future<void> downloadAllImages() async {
    setState(() {
      isLoading = true;
    });

    final gsReference =
        FirebaseStorage.instance.refFromURL("gs://dnpp-402403.appspot.com");

    Reference imageReference = gsReference.child("main_images");
    Reference urlReference = gsReference.child("main_urls");

    // ListResult의 items를 통해 해당 폴더에 있는 파일들을 가져옵니다.
    ListResult imageListResult = await imageReference.list();
    ListResult urlListResult = await urlReference.list();

    try {
      for (Reference imageRef in imageListResult.items) {
        try {
          print('imageRef.fullPath: ${imageRef.fullPath}');
          List<String> parts = imageRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');
          const oneMegabyte = 1024 * 1024;
          final Uint8List? imageData = await imageRef.getData(oneMegabyte);

          imageMap['$result'] = imageData;

          refStringList['$count'] = result;
          count++;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }

      for (Reference urlRef in urlListResult.items) {
        try {
          print('urlRef.fullPath: ${urlRef.fullPath}');
          List<String> parts = urlRef.fullPath.split('/');
          String result = parts.last.substring(0, parts.last.length - 4);
          print('Result: $result');

          final Uint8List? urlData = await urlRef.getData();
          // Assuming the content of the text file is UTF-8 encoded
          String? urlContent = utf8.decode(urlData!); // Convert bytes to string

          urlMap['$result'] = urlContent;
        } catch (e) {
          // Handle any errors.
          print("Error downloading image: $e");
        }
      }
    } catch (e) {
      print("Error in downloadAllImages: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    print('downloadAllImages 완료');
    await loadDoc();
    print('loadDoc 완료');
  }

  Future<void> loadDoc() async {
    final User currentUser =
        Provider.of<LoginStatusUpdate>(context, listen: false).currentUser;

    final docRef = db.collection("UserData").doc(currentUser.uid);

    try {
      docRef.get().then(
        (DocumentSnapshot<Map<String, dynamic>> doc) async {
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;

            final _userProfile = UserProfile(
              uid: data['uid'] ?? '',
              nickName: data['nickName'] ?? '',
              photoUrl: data['photoUrl'],
              gender: data['gender'] ?? '',
              ageRange: data['ageRange'] ?? '',
              playedYears: data['playedYears'] ?? '',
              address: (data['address'] as List<dynamic>?)
                  ?.map<String>((dynamic item) => item.toString())
                  .toList() ?? [],
              pingpongCourt: (data['pingpongCourt'] as List<dynamic>?)
                  ?.map<PingpongList>((dynamic item) {
                return PingpongList(
                  title: item['title'],
                  link: item['link'],
                  description: item['description'],
                  telephone: item['telephone'],
                  address: item['address'],
                  roadAddress: item['roadAddress'],
                  mapx: item['mapx'] ?? 0.0,
                  mapy: item['mapy'] ?? 0.0,
                );
              }).toList(),
              playStyle: data['playStyle'] ?? '',
              rubber: data['rubber'] ?? '',
              racket: data['racket'] ?? '',
            );

            print('photourl: ${_userProfile.photoUrl}');

            await Provider.of<ProfileUpdate>(
                    context,
                    listen: false)
                .updateUserProfile(_userProfile);

          } else {
            print('Document does not exist');
          }
        },
        onError: (e) => print("Error getting document: $e"),
      );
    } catch (e) {
      print(e);
    } finally {
      print('함수 완료');
    }
  }

  @override
  void initState() {
    // try {
    //   Provider.of<AppointmentUpdate>(context, listen: false).daywiseDurationsCalculate();
    // } catch (e){
    //   print(e);
    // }
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // user == null
        print('SignupScreen user isNotLoggedIn');
        print('SignupScreen user: $user');
        print('신규유저 이므로 프로필 생성 필요');
      } else {
        // user != null
        print('SignupScreen user isLoggedIn');
        print('SignupScreen user: $user');

        //Provider.of<LoginStatusUpdate>(context, listen: false).currentUser = user;
        Provider.of<LoginStatusUpdate>(context, listen: false)
            .updateCurrentUser(user);

        if (user.providerData.isNotEmpty) {
          print('user.providerData.isNotEmpty');
          print(
              'SignupScreen user.providerData: ${user.providerData.first.providerId.toString()}');

          String providerId = user.providerData.first.providerId.toString();
          switch (providerId) {
            case 'google.com':
              return print('구글로 로그인');
            case 'apple.com':
              return print('애플로 로그인');
          }
          //Provider.of<LoginStatusUpdate>(context, listen: false).updateProviderId(user.providerData.first.providerId.toString());
        } else if (user.providerData.isEmpty) {
          print('카카오로 로그인한 상태');
          print('user.providerData.isEmpty');
        }
      }
    });

    myFuture = downloadAllImages();
    super.initState(); // downloadAllImages()가 완료된 후에 initState()를 호출
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width * 3 / 4;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ListView(
              children: [
                //MainScreenPageView(pageController: _pageController, imageUrls: imageUrls ),
                FutureBuilder<void>(
                  future: myFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: width,
                        height: height,
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      // Images are downloaded, use the data
                      // imageList = snapshot.data ?? [];
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Timer.periodic(Duration(seconds: 1), (timer) {
                          // if (_currentPage < imageList.length - 1) {
                          //   _currentPage++;
                          // } else {
                          //   _currentPage = 0;
                          // }

                          _imagePageController.animateToPage(
                            _currentPage,
                            duration: Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );
                        });
                      });
                      return MainBannerPageView(
                        pageController: _imagePageController,
                        width: width,
                        height: height,
                        imageMap: imageMap,
                        urlMap: urlMap,
                        refStringList: refStringList,
                      );
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                        borderRadius: BorderRadius.circular(4.0),
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('최근 7일'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('최근 28일'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('최근 3개월'),
                          ),
                        ],
                        isSelected: Provider.of<AppointmentUpdate>(context,
                                listen: false)
                            .isSelected,
                        constraints: BoxConstraints(
                          minHeight: 40.0, // 36.0,
                          minWidth: _buttonwidth(context, 3),
                        ),
                        onPressed: (index) async {
                          setState(() {
                            Provider.of<AppointmentUpdate>(context,
                                    listen: false)
                                .updateChart(index);
                          });
                        }),
                  ],
                ),
                MainChartPageView(pageController: _barChartPageController),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent black
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MainBannerPageView extends StatelessWidget {
  final PageController pageController;

  final Map<String?, Uint8List?> imageMap;
  final Map<String?, String?> urlMap;
  final Map<String, String> refStringList;

  final double width;
  final double height;

  MainBannerPageView({
    required this.pageController,
    required this.width,
    required this.height,
    required this.imageMap,
    required this.urlMap,
    required this.refStringList,
  });

  Future<void> _launchUrl(String _url) async {
    print('_launchURL 진입');
    final Uri _newUrl = Uri.parse(_url);
    if (!await launchUrl(_newUrl)) {
      throw Exception('Could not launch $_newUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
          child: Container(
            height: height, // or any desired height
            width: width, // 4:3 aspect ratio
            child: PageView.builder(
              controller: pageController,
              itemCount: refStringList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    print('refStringList: $refStringList');
                    await _launchUrl("${urlMap[refStringList['$index']]}");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        //refStringList['$index'] 가 파일의 fullpath 추출한 부분을 의미함
                        image: MemoryImage(
                            imageMap[refStringList['$index']] ?? Uint8List(0)),
                        //MemoryImage(imageMap['$index'] ?? Uint8List(0)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MainChartPageView extends StatelessWidget {
  final PageController pageController;

  MainChartPageView({required this.pageController});

  List<ChartBasic> ChartBasicList = [
    ChartBasic('나의 훈련 시간', Colors.black),
    ChartBasic('보라매탁구장 방문 데이터', Colors.blue),
    ChartBasic('신대방탁구장 방문 데이터', Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          child: PageView.builder(
            controller: pageController,
            itemCount: ChartBasicList.length,
            itemBuilder: (context, index) {
              print('ChartBasicList.length: ${ChartBasicList.length}');
              if (index == 0) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(20)),
                    ),
                    color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    index: index,
                    titleText: ChartBasicList[index].text,
                    backgroundColor: ChartBasicList[index].color,
                  ),
                );
              } else if (index == ChartBasicList.length - 1) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(20)),
                    ),
                    color: Colors.grey, // 배경색을 지정하세요.
                  ),
                  child: GraphsWidget(
                    index: index,
                    titleText: ChartBasicList[index].text,
                    backgroundColor: ChartBasicList[index].color,
                  ),
                );
              } else {
                return Container(
                  color: Colors.grey,
                  child: GraphsWidget(
                    index: index,
                    titleText: ChartBasicList[index].text,
                    backgroundColor: ChartBasicList[index].color,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
