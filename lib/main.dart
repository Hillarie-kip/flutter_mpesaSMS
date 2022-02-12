import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_mpesa_sms/DatabaseHelper.dart';
import 'package:flutter_mpesa_sms/MpesaSMSModel.dart';
import 'package:telephony/telephony.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeBackgroundService();
  runApp(const MyHomePage());
}

String _message = "";
final telephony = Telephony.instance;
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();


  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,
      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,
      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}
// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
void onIosBackground() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('FLUTTER BACKGROUND FETCH');
}
void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {

    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);

      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "Mpesa Service",
      content: "Pulled At ${DateTime.now()}",
    );

    initListenIncomingSmsState();
    service.sendData({"current_date": DateTime.now().toIso8601String()},
    );
  });

}

Future<dynamic> initListenIncomingSmsState() async {
  final bool? result = await telephony.requestPhoneAndSmsPermissions;

  if (result != null && result) {
    telephony.listenIncomingSms(onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);

  }


}
onMessage(SmsMessage message) async {

  _message = message.body ?? "Error reading message body.";
  debugPrint("onMessage called");


}
onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called "+message.subscriptionId.toString());

  // QB39KD8L9X Confirmed.on 3/2/22 at 11:57 AMKsh18,382.00
  // received from 254720968729 Hillary Kalya.
  // New Account balance is Ksh88,033.38. Transaction cost, Ksh45.95

  const transStart = "";
  const transEnd = "Confirmed";
  final transStartIndex = message.body.toString().indexOf(transStart);
  final transEndIndex = message.body.toString().indexOf(transEnd, transStartIndex+ transStart.length);
  debugPrint("BG TransID "+message.body.toString().substring(transStartIndex + transStart.length, transEndIndex));
  String transID=message.body.toString().substring(transStartIndex + transStart.length, transEndIndex);

  const transDateStart = "Confirmed.on";
  const transDateEnd = "Ksh";
  final transDateStartIndex = message.body.toString().indexOf(transDateStart);
  final transDateEndIndex = message.body.toString().indexOf(transDateEnd, transDateStartIndex+ transDateStart.length);
  debugPrint("BG TransDate "+message.body.toString().substring(transDateStartIndex + transDateStart.length, transDateEndIndex));
  String transDate=message.body.toString().substring(transDateStartIndex + transDateStart.length, transDateEndIndex);

  const transAmountStart = "Ksh";
  const transAmountEnd = "received";
  final transAmountStartIndex = message.body.toString().indexOf(transAmountStart);
  final transAmountEndIndex = message.body.toString().indexOf(transAmountEnd, transAmountStartIndex+ transAmountStart.length);
  debugPrint("BG TransAmount "+message.body.toString().substring(transAmountStartIndex + transAmountStart.length, transAmountEndIndex));
  String transAmount=message.body.toString().substring(transAmountStartIndex + transAmountStart.length, transAmountEndIndex);

  const phoneStart = "from ";
  const phoneEnd = " ";
  final phoneStartIndex = message.body.toString().indexOf(phoneStart);
  final phoneEndIndex = message.body.toString().indexOf(phoneEnd, phoneStartIndex+ phoneStart.length);
  debugPrint("BG PhoneNumber "+message.body.toString().substring(phoneStartIndex + phoneStart.length, phoneEndIndex));
  String phoneNumber=message.body.toString().substring(phoneStartIndex + phoneStart.length, phoneEndIndex).toString();

  String nameStart = phoneNumber;
  const nameEnd = ".";
  final nameStartIndex = message.body.toString().indexOf(nameStart);
  final nameEndIndex = message.body.toString().indexOf(nameEnd, nameStartIndex+ nameStart.length);
  debugPrint("BG UserName "+message.body.toString().substring(nameStartIndex +nameStart.length, nameEndIndex));
  String userName=message.body.toString().substring(nameStartIndex + nameStart.length, nameEndIndex).toString();



  saveMpesaMessage(
      MpesaSMSModel(
          transID,
          transAmount,
          phoneNumber,
          userName,
          transDate,
          1,
          1,
          DateTime.now().toString()));
}
void saveMpesaMessage( MpesaSMSModel smsModel) async {
  DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.insertMpesaMessage(smsModel);
}















class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  void initState() {
    initializeBackgroundService();
    initForeGroundState();
    super.initState();


  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<dynamic> initForeGroundState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
      debugPrint(_message .toString());
    }

    if (!mounted) return;
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
      debugPrint("onForegroundMessage called ");

      // QB39KD8L9X Confirmed.on 3/2/22 at 11:57 AMKsh18,382.00
      // received from 254720968729 Hillary Kalya.
      // New Account balance is Ksh88,033.38. Transaction cost, Ksh45.95

      const transStart = "";
      const transEnd = "Confirmed";
      final transStartIndex = message.body.toString().indexOf(transStart);
      final transEndIndex = message.body.toString().indexOf(transEnd, transStartIndex+ transStart.length);
      debugPrint("BG TransID "+message.body.toString().substring(transStartIndex + transStart.length, transEndIndex));
      String transID=message.body.toString().substring(transStartIndex + transStart.length, transEndIndex);

      const transDateStart = "Confirmed.on";
      const transDateEnd = "Ksh";
      final transDateStartIndex = message.body.toString().indexOf(transDateStart);
      final transDateEndIndex = message.body.toString().indexOf(transDateEnd, transDateStartIndex+ transDateStart.length);
      debugPrint("BG TransDate "+message.body.toString().substring(transDateStartIndex + transDateStart.length, transDateEndIndex));
      String transDate=message.body.toString().substring(transDateStartIndex + transDateStart.length, transDateEndIndex);

      const transAmountStart = "Ksh";
      const transAmountEnd = "received";
      final transAmountStartIndex = message.body.toString().indexOf(transAmountStart);
      final transAmountEndIndex = message.body.toString().indexOf(transAmountEnd, transAmountStartIndex+ transAmountStart.length);
      debugPrint("BG TransAmount "+message.body.toString().substring(transAmountStartIndex + transAmountStart.length, transAmountEndIndex));
      String transAmount=message.body.toString().substring(transAmountStartIndex + transAmountStart.length, transAmountEndIndex);

      const phoneStart = "from ";
      const phoneEnd = " ";
      final phoneStartIndex = message.body.toString().indexOf(phoneStart);
      final phoneEndIndex = message.body.toString().indexOf(phoneEnd, phoneStartIndex+ phoneStart.length);
      debugPrint("BG PhoneNumber "+message.body.toString().substring(phoneStartIndex + phoneStart.length, phoneEndIndex));
      String phoneNumber=message.body.toString().substring(phoneStartIndex + phoneStart.length, phoneEndIndex).toString();

      String nameStart = phoneNumber;
      const nameEnd = ".";
      final nameStartIndex = message.body.toString().indexOf(nameStart);
      final nameEndIndex = message.body.toString().indexOf(nameEnd, nameStartIndex+ nameStart.length);
      debugPrint("BG UserName "+message.body.toString().substring(nameStartIndex +nameStart.length, nameEndIndex));
      String userName=message.body.toString().substring(nameStartIndex + nameStart.length, nameEndIndex).toString();



      saveMpesaMessage(
          MpesaSMSModel(
              message.body.toString().substring(transStartIndex + transStart.length, transEndIndex),
              transAmount,
              phoneNumber,
              userName,
              transDate,
              1,
              1,
              DateTime.now().toString()));

    });
  }


  @override
  Widget build(BuildContext context) {
    String text = "Stop Service";

    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  StreamBuilder<Map<String, dynamic>?>(
                    stream: FlutterBackgroundService().onDataReceived,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final data = snapshot.data!;
                      DateTime? date = DateTime.tryParse(data["current_date"]);
                      return Text(date.toString());
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Foreground Mode"),
                    onPressed: () {
                      FlutterBackgroundService()
                          .sendData({"action": "setAsForeground"});
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Background Mode"),
                    onPressed: () {
                      FlutterBackgroundService()
                          .sendData({"action": "setAsBackground"});
                    },
                  ),
                  ElevatedButton(
                    child: Text(text),
                    onPressed: () async {
                      final service = FlutterBackgroundService();
                      var isRunning = await service.isServiceRunning();
                      if (isRunning) {
                        service.sendData(
                          {"action": "stopService"},
                        );
                      } else {
                        service.start();
                      }

                      if (!isRunning) {
                        text = 'Stop Service';
                      } else {
                        text = 'Start Service';
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
              Center(child: Text("Latest received SMS: $_message")),
              TextButton(
                  onPressed: () async {
                 //   await telephony.getInboxSms("");

                    saveMpesaMessage(
                        MpesaSMSModel(
                            "1",
                            "1",
                            "1",
                            "1",
                            "1",
                            1,
                            1,
                            DateTime.now().toString()));
                  },
                  child: const Text('Open Dialer'))
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              FlutterBackgroundService().sendData({
                "hello": "world",
              });
            },
            child: const Icon(Icons.play_arrow),
          ),
        ));
  }
}
