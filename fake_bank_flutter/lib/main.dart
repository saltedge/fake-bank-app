import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StartScreen();
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final appTitle = 'Fake Bank';
  String _appLink;

  @override
  void initState() {
    super.initState();
    initUniLinks(this.updateAppLink);
  }

  void updateAppLink(String appLink) {
    setState(() {
      this._appLink = appLink;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 16.0),
                      child: SvgPicture.asset("assets/saltedge.svg")
                  ),
                  Text(
                    appTitle,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),

              Container(
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Grant or Deny access to Fake Bank data',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 16.0),
                        child: RaisedButton(
                          onPressed: () {
                            if (!_redirectToGrantURL(_appLink)) {
                              _showToast();
                            }
                          },
                          textColor: Colors.white,
                          color: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: const Text('GRANT ACCESS',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      OutlineButton(
                        onPressed: () {
                          if (!_redirectToDenyURL(_appLink)) {
                            _showToast();
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0
                        ),
                        child: const Text('DENY ACCESS',
                            style: TextStyle(fontSize: 20, color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast() {
    Fluttertoast.showToast(
        msg: "Can not perform action. Not enough data.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}


// class _MyAppState extends State<MyApp> {
//
// }

StreamSubscription _sub;

Future<Null> initUniLinks(Function updateAppLink) async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    var link = await getInitialLink();
    updateAppLink(link);

    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) {
      print('getLinksStream: link:$link');
      updateAppLink(link);
    }, onError: (err) {
      print('onError');
    });
  } on PlatformException {
    print("PlatformException");
  } on Exception {
    print('Exception thrown');
  }
}

String _createReturnTo(String link) {
  if (link == null || link.isEmpty) return null;
  try {
    var uri = Uri.parse(link);
    var params = uri.queryParameters;
    var returnTo = params["return_to"];
    var state = params["state"];
    if (returnTo != null && state != null) {
      return "$returnTo?state=$state";
    }
  } on Exception {
    print('_createReturnTo: Exception thrown');
  }
  return null;
}

bool _redirectToGrantURL(String link) {
  print('Grant click');
  var returnTo = _createReturnTo(link);
  if (returnTo != null && returnTo.isNotEmpty) {
    _launchURL("$returnTo&access_token=123");
    return true;
  } else {
    return false;
  }
}

bool _redirectToDenyURL(String link) {
  print('Deny click');
  var returnTo = _createReturnTo(link);
  if (returnTo != null && returnTo.isNotEmpty) {
    _launchURL(returnTo);
    return true;
  } else {
    return false;
  }
}

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
