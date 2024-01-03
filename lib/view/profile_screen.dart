import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:dnpp/models/userProfile.dart';
import 'package:dnpp/viewModel/profileUpdate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class ProfileScreen extends StatefulWidget {
  static String id = '/ProfileScreenID';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _currentSliderValue = 0.0;
  final TextEditingController _textFormFieldController =
      TextEditingController();

  bool _isLoading = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  UserProfile newProfile = UserProfile(
      nickName: '',
      photoUrl: 'https://firebasestorage.googleapis.com/v0/b/dnpp-402403.appspot.com/o/main_images%2FSimonwork_profile.png?alt=media&token=0222c22b-8380-4398-955e-44a3d6da23a2',
      gender: '밝히지 않음',
      ageRange: '10대 이하',
      playStyle: '공격',
      rubber: '미정',
      racket: '미정');

  double _buttonwidth(BuildContext context, int buttoncount) {
    //final maxwidth = 80.0;
    final width = (MediaQuery.of(context).size.width - 80) / buttoncount;
    return width;

    // if (width < maxwidth) {
    //   return width;
    // } else {
    //   return maxwidth;
    // }
  }

  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화

  //이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
    }
  }

  Widget buildProfilePhoto() {
    return Stack(
      children: [
        Positioned(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _image != null
                ? Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(_image!.path)),
                  ) //가져온 이미지를 화면에 띄워주는 코드
              ),
            )
                : Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('images/empty_profile_160.png'),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 60,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              CupertinoIcons.pencil,
              size: 40,
            ),
            onPressed: () async {
              if (Platform.isAndroid) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("프로필 수정"),
                      content: Text("프로필 사진 변경을 위한 방법을 선택해주세요"),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelLarge,
                          ),
                          child: const Text("카메라 촬영"),
                          onPressed: () async {
                            getImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelLarge,
                          ),
                          child: const Text("사진첩 선택"),
                          onPressed: () async {
                            getImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              } else if (Platform.isIOS) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text("프로필 수정"),
                      content: Text("프로필 사진 변경을 위한 방법을 선택해주세요"),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: Text(
                            "카메라 촬영",
                            style: TextStyle(
                                fontWeight: FontWeight.normal),
                          ),
                          onPressed: () async {
                            getImage(ImageSource.camera);

                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: Text(
                            "사진첩 선택",
                            style: TextStyle(
                                fontWeight: FontWeight.normal),
                          ),
                          onPressed: () async {
                            getImage(ImageSource.gallery);

                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> toggleLoading(bool isLoading) async {
    setState(() {
      _isLoading = isLoading;

      if (isLoading) {
        // 로딩 바를 화면에 표시
        print('로딩 바를 화면에 표시');
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(), // 로딩 바 표시
            );
          },
        );
      } else {
        print('로딩 바 제거');
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '뒤로',
                        style: kElevationButtonStyle,
                      ),
                    ),
                    Text(
                      '프로필 설정',
                      style: kAppointmentTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () async {
                        await toggleLoading(true);

                        newProfile.nickName = _textFormFieldController.text;

                        if (_image == null) {

                        } else {
                          var imageName = DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString();
                          var storageRef = FirebaseStorage.instance.ref().child(
                              'profile_photos/$imageName.jpg');

                          String filePath = _image!.path;
                          print('filePath: $filePath');
                          File file = File(filePath);

                          var uploadTask = storageRef.putFile(file);
                          var downloadUrl = await (await uploadTask).ref
                              .getDownloadURL();
                          print('downloadUrl: $downloadUrl');
                          newProfile.photoUrl = downloadUrl.toString();
                        }

                        await Provider.of<ProfileUpdate>(context, listen: false)
                            .updatUserProfile(newProfile);

                        final docRef = db
                            .collection("UserData")
                            .withConverter(
                              fromFirestore: UserProfile.fromFirestore,
                              toFirestore: (UserProfile newProfile, options) =>
                                  newProfile.toFirestore(),
                            )
                            .doc();

                        await docRef.set(newProfile);

                        await toggleLoading(false);
                      },
                      child: Text(
                        '다음',
                        style: kElevationButtonStyle,
                      ),
                    ),
                  ],
                ),
              ), // 프로필 설정 Text
              buildProfilePhoto(), // 유저 프로필 사진
              Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, bottom: 5.0),
                    child: TextFormField(
                      controller: _textFormFieldController,
                      decoration: const InputDecoration(
                        labelText: '닉네임',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                        // enabledBorder: const OutlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.red, width: 1.0),
                        //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        // ),
                        // focusedBorder: const OutlineInputBorder(
                        //   //borderSide: BorderSide(color: Colors.black, width: 2.0),
                        //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        // ),
                      ),
                    ),
                  ), // 닉네임
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text('성별', style: kProfileTextStyle),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ToggleButtons(
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: Provider.of<ProfileUpdate>(context,
                                        listen: false)
                                    .genderIsSelected,
                                constraints: BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: _buttonwidth(
                                      context,
                                      Provider.of<ProfileUpdate>(context,
                                              listen: false)
                                          .genderIsSelected
                                          .length),
                                ),
                                onPressed: (index) async {
                                  setState(() {
                                    Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                        .updateGenderIsSelected(index);
                                    newProfile.gender =
                                        UserProfile.genderList[index];
                                  });
                                },
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(UserProfile.genderList[0]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(UserProfile.genderList[1]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(UserProfile.genderList[2]),
                                  ),
                                ]),
                          ],
                        ),
                      ],
                    ),
                  ), // 성별
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('연령대', style: kProfileTextStyle),
                            Text(
                                '${UserProfile.ageRangeList[_currentSliderValue.toInt()]}',
                                style: kProfileTextStyle),
                          ],
                        ),
                        Slider(
                          value: _currentSliderValue,
                          min: 0.0,
                          max: 6.0,
                          divisions: 6,
                          label:
                              '${UserProfile.ageRangeList[_currentSliderValue.toInt()]}',
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue = value;
                              newProfile.ageRange = UserProfile
                                  .ageRangeList[_currentSliderValue.toInt()];
                            });
                          },
                        ),
                      ],
                    ),
                  ), // 연령대
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text('플레이 스타일', style: kProfileTextStyle)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ToggleButtons(
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: Provider.of<ProfileUpdate>(context,
                                        listen: false)
                                    .playStyleIsSelected,
                                constraints: BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: _buttonwidth(
                                      context,
                                      Provider.of<ProfileUpdate>(context,
                                              listen: false)
                                          .playStyleIsSelected
                                          .length),
                                ),
                                onPressed: (index) async {
                                  setState(() {
                                    Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                        .updatePlayStyleIsSelected(index);
                                    newProfile.playStyle =
                                        UserProfile.playStyleList[index];
                                  });
                                },
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(UserProfile.playStyleList[0]),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(UserProfile.playStyleList[1]),
                                  ),
                                ]),
                          ],
                        ),
                      ],
                    ),
                  ), // 플레이 스타일
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text('러버', style: kProfileTextStyle),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ToggleButtons(
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: Provider.of<ProfileUpdate>(context,
                                        listen: false)
                                    .rubberIsSelected,
                                constraints: BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: _buttonwidth(
                                      context,
                                      Provider.of<ProfileUpdate>(context,
                                              listen: false)
                                          .rubberIsSelected
                                          .length),
                                ),
                                onPressed: (index) async {
                                  setState(() {
                                    Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                        .updateRubberIsSelected(index);
                                    newProfile.rubber =
                                        UserProfile.rubberList[index];
                                  });
                                },
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.rubberList[0]),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.rubberList[1]),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.rubberList[2]),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.rubberList[3]),
                                  ),
                                ]),
                          ],
                        ),
                      ],
                    ),
                  ), // 러버
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text('라켓', style: kProfileTextStyle),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ToggleButtons(
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: Provider.of<ProfileUpdate>(context,
                                        listen: false)
                                    .racketIsSelected,
                                constraints: BoxConstraints(
                                  minHeight: 40.0,
                                  minWidth: _buttonwidth(
                                      context,
                                      Provider.of<ProfileUpdate>(context,
                                              listen: false)
                                          .racketIsSelected
                                          .length),
                                ),
                                onPressed: (index) async {
                                  setState(() {
                                    Provider.of<ProfileUpdate>(context,
                                            listen: false)
                                        .updateRacketIsSelected(index);
                                    newProfile.racket =
                                        UserProfile.racketList[index];
                                  });
                                },
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.racketList[0]),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.racketList[1]),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.racketList[2]),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(UserProfile.racketList[3]),
                                  ),
                                ]),
                          ],
                        ),
                      ],
                    ),
                  ), // 라켓
                ],
              ), // 라켓
            ],
          ),
        ),
      ),
    );
  }
}
