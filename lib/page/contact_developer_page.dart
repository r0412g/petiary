import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/background_painter.dart';
import 'package:pet_diary/common/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDeveloperPage extends StatefulWidget {
  ContactDeveloperPage({Key? key}) : super(key: key);

  @override
  _ContactDeveloperPageState createState() => _ContactDeveloperPageState();
}

class _ContactDeveloperPageState extends State<ContactDeveloperPage> {

  String subjectOfSendEmail = '寵物日記 petiary 聯絡';
  String bodyOfSendEmail = '';

  TextEditingController contactLauraController = TextEditingController();
  TextEditingController contactGraceController = TextEditingController();
  TextEditingController contactm147Controller = TextEditingController();

  @override
  void initState() {
    contactLauraController.text = ' UI 設計 Laura';
    contactGraceController.text = ' 程式設計 Grace';
    contactm147Controller.text = ' 圖像設計 m147';
    super.initState();
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  /* Clean up the controller when the widget is disposed */
  @override
  void dispose() {
    contactLauraController.dispose();
    contactGraceController.dispose();
    contactm147Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 50.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '設定',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: ColorSet.colorsBlackOfOpacity80,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 600.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin: const EdgeInsets.only(
                                right: 22.0, top: 55.0, bottom: 17.0),
                            shape: MyCardTheme.cardsForLeftShapeBorder,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300.0,
                        height: 600.0,
                        child: Stack(
                          children: <Widget>[
                            Card(
                              color: ColorSet.primaryColorsGreenOfOpacity80,
                              margin: const EdgeInsets.only(
                                  top: 55.0, bottom: 17.0),
                              child: Padding(
                                // padding: const EdgeInsets.fromLTRB(
                                //     25.0, 25.0, 25.0, 65.0),
                                padding: const EdgeInsets.only(
                                    top: 25.0, bottom: 50.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Text(
                                      '開發人員',
                                      style: const TextStyle(
                                        letterSpacing: 1.0,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                        color: ColorSet.colorsBlackOfOpacity80,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 55.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            IntrinsicWidth(
                                              child: TextField(
                                                readOnly: true,
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                ),
                                                controller:
                                                    contactGraceController,
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(
                                                    Icons
                                                        .person_outline_outlined,
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                  ),
                                                  prefixIconConstraints:
                                                      const BoxConstraints(
                                                          minWidth: 0,
                                                          minHeight: 0),
                                                ),
                                              ),
                                            ),
                                            TextButton.icon(
                                              label: Text(
                                                'r0412g@gmail.com',
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                alignment: Alignment.centerLeft,
                                              ),
                                              onPressed: () {
                                                _launchInBrowser('mailto:r0412g@gmail.com?subject=$subjectOfSendEmail&body=$bodyOfSendEmail');
                                              },
                                              icon: Icon(
                                                Icons.inbox_outlined,
                                                color: ColorSet
                                                    .colorsBlackOfOpacity80,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30.0,
                                            ),
                                            IntrinsicWidth(
                                              child: TextField(
                                                readOnly: true,
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                ),
                                                controller:
                                                    contactLauraController,
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(
                                                    Icons
                                                        .person_outline_outlined,
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                  ),
                                                  prefixIconConstraints:
                                                      const BoxConstraints(
                                                          minWidth: 0,
                                                          minHeight: 0),
                                                ),
                                              ),
                                            ),
                                            TextButton.icon(
                                              label: Text(
                                                'laurachwu0@gmail.com',
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                alignment: Alignment.centerLeft,
                                              ),
                                              onPressed: () {
                                                _launchInBrowser(
                                                    'mailto:laurachwu0@gmail.com?subject=$subjectOfSendEmail&body=$bodyOfSendEmail');
                                              },
                                              icon: Icon(
                                                Icons.inbox_outlined,
                                                color: ColorSet
                                                    .colorsBlackOfOpacity80,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30.0,
                                            ),
                                            IntrinsicWidth(
                                              child: TextField(
                                                readOnly: true,
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.0,
                                                ),
                                                controller:
                                                    contactm147Controller,
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  prefixIcon: Icon(
                                                    Icons
                                                        .person_outline_outlined,
                                                    color: ColorSet
                                                        .colorsBlackOfOpacity80,
                                                  ),
                                                  prefixIconConstraints:
                                                      const BoxConstraints(
                                                          minWidth: 0,
                                                          minHeight: 0),
                                                ),
                                              ),
                                            ),
                                            TextButton.icon(
                                              label: Text(
                                                'instagram: m147___',
                                                style: const TextStyle(
                                                  color: ColorSet
                                                      .colorsBlackOfOpacity80,
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                alignment: Alignment.centerLeft,
                                              ),
                                              onPressed: () {
                                                _launchInBrowser(
                                                    'https://instagram.com/m147___?utm_medium=copy_link');
                                              },
                                              icon: Icon(
                                                Icons.inbox_outlined,
                                                color: ColorSet
                                                    .colorsBlackOfOpacity80,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            CustomPaint(
                              //size: Size.fromHeight(10.0),
                              painter: DrawContactDevPainter(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 600.0,
                          child: Card(
                            color: ColorSet.primaryColorsGreenOfOpacity80,
                            margin: const EdgeInsets.only(
                                left: 22.0, top: 55.0, bottom: 17.0),
                            shape: MyCardTheme.cardsForRightShapeBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
