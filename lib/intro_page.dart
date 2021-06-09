import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'main.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

class IntroPage extends StatefulWidget {
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  String? _petType;
  String? _petBreeds;
  //var myPetType, myPetBreeds;

  List<String> _default = [];
  List<String> _dogBreeds = ['柯基', '臘腸', '吉娃娃', '馬爾濟斯', '拉不拉多'];
  List<String> _catBreeds = ['虎斑', '金吉拉', '波斯貓', '橘貓', '玳瑁'];
  List<String> _rabbitBreeds = ['道奇兔', '獅子兔', '家兔', '銀狐'];
  List<String> _turtleBreeds = ['巴西龜', '象龜', '蛇龜'];

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (context) => new MyHomePage(title: '寵物日記')));
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: HexColor("#718792"),

      /* All pages in IntroScreen */
      rawPages: [
        /* Page 1: Welcome Page */
        Card(
          color: HexColor("#455A64"),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '歡迎使用寵物日記\n\n讓我們先來做些初始設定吧!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HexColor('#D7CCC8'),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          margin: EdgeInsets.all(35.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        /* Page 2: Select Pet Type And Breeds */
        Card(
          color: HexColor("#455A64"),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '請選擇您的寵物類型',
                style: TextStyle(
                  color: HexColor('#D7CCC8'),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 40),
              Container(
                color: HexColor('#C4C4C4'),
                width: 250,
                height: 40,
                alignment: Alignment.center,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _petType,
                  onChanged: (value) {
                    setState(() {
                      _petType = value;
                    });
                    _default.clear();
                    switch (_petType) {
                      case "狗狗":
                        _default.addAll(_dogBreeds);
                        break;
                      case "貓咪":
                        _default.addAll(_catBreeds);
                        break;
                      case "兔子":
                        _default.addAll(_rabbitBreeds);
                        break;
                      case "烏龜":
                        _default.addAll(_turtleBreeds);
                        break;
                      case "其他":
                        print("自行輸入");
                        break;
                      default:
                        _default.clear();
                    }
                  },
                  items: <String>['狗狗', '貓咪', '兔子', '烏龜', '其他']
                      .map<DropdownMenuItem<String>>((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: new Text(type),
                    );
                  }).toList(),
                  hint: Text(
                    "選擇寵物類型",
                    style: TextStyle(
                      color: HexColor('#000000'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Text(
                '請選擇您的寵物品種(花色)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HexColor('#D7CCC8'),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 40),
              Container(
                color: HexColor('#C4C4C4'),
                width: 250,
                height: 40,
                alignment: Alignment.center,
                child: DropdownButton(
                  hint: Text(
                    "選擇寵物品種",
                    style: TextStyle(
                      color: HexColor('#000000'),
                    ),
                  ),
                  value: _petBreeds,
                  isExpanded: true,
                  dropdownColor: HexColor('#C4C4C4'),
                  onChanged: (String? value) {
                    setState(() {
                      _petBreeds = value;
                    });
                  },
                  items: _default.map<DropdownMenuItem<String>>((breeds) {
                    return DropdownMenuItem<String>(
                      value: breeds,
                      child: new Text(breeds),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          margin: EdgeInsets.all(35.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
        /* Page 3: Set Pet Information */
        Card(
          color: HexColor("#455A64"),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '來輸入寵物的基本資料吧!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HexColor('#D7CCC8'),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/paw.jpg',
                      fit: BoxFit.fill, width: 75, height: 75),
                  SizedBox(width: 20),
                  Icon(Icons.add_a_photo),
                ],
              ),
              SizedBox(height: 30),
              Container(
                color: HexColor('#C4C4C4'),
                width: 250,
                height: 40,
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.pets),
                    hintText: '請輸入寵物的名字',
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                color: HexColor('#C4C4C4'),
                width: 250,
                height: 40,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.calendar_today, color: HexColor('#5d6670')),
                    Tooltip(
                      message: '選擇日期',
                      child: TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(2.0),
                            primary: HexColor('#5d6670'),
                            textStyle: const TextStyle(fontSize: 17),
                            minimumSize: Size(225, 35)),
                        onPressed: () async {
                          var result = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1971),
                              lastDate: DateTime(2030));
                          print('$result');
                        },
                        child: Text('請點擊選擇寵物生日'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                color: HexColor('#C4C4C4'),
                width: 250,
                height: 40,
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    hintText: '請選擇性別',
                  ),
                ),
              ),
            ],
          ),
          margin: EdgeInsets.all(35.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ],
      isTopSafeArea: true,
      isBottomSafeArea: true,
      color: HexColor('#D7CCC8'),

      /* Skip Button */
      skip: const Text('跳過'),
      showSkipButton: true,
      skipFlex: 0,

      /* Next Button */
      next: const Text('下一頁'),
      showNextButton: true,
      nextFlex: 0,

      /* Done Button */
      done: const Text('完成'),
      onDone: () => _onIntroEnd(context),

      /* controls/dots */
      controlsMargin: EdgeInsets.all(40.0),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: HexColor("#A69B97"),
        activeColor: HexColor("#725b53"),
      ),
    );
  }
}
