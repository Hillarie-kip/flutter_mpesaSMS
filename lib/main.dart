import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_mpesa_sms/DatabaseHelper.dart';
import 'package:flutter_mpesa_sms/MpesaSMSModel.dart';
import 'package:telephony/telephony.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();
  runApp(const MyHomePage());
}

String _message = "";
final telephony = Telephony.instance;
Future<void> initializeService() async {
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
  //QB39KD8L9X Confirmed.on 3/2/22 at 11:57 AMKsh18,382.00
  // received from 254768011712 ELIJAH KIMANI GITUIYA.
  // New Account balance is Ksh88,033.38. Transaction cost, Ksh45.95
  const transStart = "";
  const transEnd = "Confirmed";
  final startIndex = message.body.toString().indexOf(transStart);
  final endIndex = message.body.toString().indexOf(transEnd, startIndex+ transStart.length);
  debugPrint("FG TransID"+message.body.toString().substring(startIndex + transStart.length, endIndex));


  saveMpesaMessage(
      MpesaSMSModel(
          _message.substring(startIndex + transStart.length, endIndex),
          "1",
          "1",
          "1",
          "1",
          1,
          1,
          DateTime.now().toString()));

}

onSendStatus(SendStatus status) {

  _message = status == SendStatus.SENT ? "sent" : "delivered";

}

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called"+message.body.toString());

  const transStart = "";
  const transEnd = "Confirmed";
  final startIndex = message.body.toString().indexOf(transStart);
  final endIndex = message.body.toString().indexOf(transEnd, startIndex+ transStart.length);
  debugPrint("BG TransID"+message.body.toString().substring(startIndex + transStart.length, endIndex));
  saveMpesaMessage(
      MpesaSMSModel(
          message.body.toString().substring(startIndex + transStart.length, endIndex),
          "1",
          "1",
          "1",
          "1",
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
    super.initState();


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
