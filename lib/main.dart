import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info/device_info.dart';
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const  MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _deviceName;
  double textSize = 14;
  Timer? _timer;

  Future<void> initPlatformState() async {
    var deviceInfo = DeviceInfoPlugin();
    try{
      if(Platform.isAndroid) {
       AndroidDeviceInfo deviceData = await deviceInfo.androidInfo;
       setState(() {
         _deviceName = deviceData.brand + "-" + deviceData.device + "-" +deviceData.version.sdkInt.toString();
       });
      } else if(Platform.isIOS) {
        IosDeviceInfo deviceData = await deviceInfo.iosInfo;
        setState(() {
          _deviceName = deviceData.systemVersion + deviceData.systemName + deviceData.toString();
        });
      }
    }  on PlatformException{if (kDebugMode) {
      print("Error happened in platform");
    }}

  }
  void _incrementCounter() {
    setState(() {
      textSize++;
    });
  }

  // 方法1：使用Time.periodic 方式执行定时器操作
  void _incrementAuto() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        textSize++;
      });
    });
  }

  void cancelAutoIncrement() {
    _timer?.cancel();
  }
  // 方法2：监听事件变化，复杂的用法 Rxdart
  Stream stream = Stream.periodic(const Duration(milliseconds: 100)).asBroadcastStream();
  PublishSubject longPressGesBeganSignal = PublishSubject();
  PublishSubject longPressGesEndedSignal = PublishSubject();
  @override
  void initState() {
    super.initState();
    longPressGesBeganSignal.flatMap((_) {
      return stream.takeUntil(longPressGesEndedSignal);
    }).listen((event) {_incrementCounter();});
  }
 

  @override
  Widget build(BuildContext context) {
    initPlatformState();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'current device is $_deviceName',
            style: TextStyle(fontSize: textSize,color: Colors.deepOrangeAccent),),
            Text(
              '$textSize',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
          onTap: _incrementCounter,
          child: Container(
            child: const Icon(Icons.add),
            decoration: const BoxDecoration(color: Colors.blue,shape: BoxShape.circle),
          ),
          onTapDown: (detail) {
            //_incrementAuto();
            longPressGesBeganSignal.add("began");
            },
          onTapUp: (detail) {
            //cancelAutoIncrement();
            longPressGesEndedSignal.add("end");
            },
        )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
