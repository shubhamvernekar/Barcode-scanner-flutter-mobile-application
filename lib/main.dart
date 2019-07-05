import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:validators/validators.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String result = "Press the scan button to scan";
  TextEditingController _textFieldController = TextEditingController();

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Error:Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Error:Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "Error:You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Error:Unknown Error $ex";
      });
    }
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 3,
        color: Colors.blue[100],
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) //         <--- border radius here
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scanQR();
  }

  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    const IconData content_copy = IconData(0xe14d, fontFamily: 'MaterialIcons');
    const IconData email = IconData(0xe0be, fontFamily: 'MaterialIcons');
    const IconData link = IconData(0xe250, fontFamily: 'MaterialIcons');
    const IconData call = IconData(0xe0e8, fontFamily: 'MaterialIcons');
    _textFieldController.text = result;

    return MaterialApp(
        title: 'QR Scanner',
        home: Scaffold(
          key: key,
          appBar: AppBar(
            title: Text("Barcode & QR Scanner"),
          ),
          body: Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      margin: EdgeInsets.all(5),
                      alignment: Alignment(-1.0, 0.0),
                      width: 100,
                      height: 50,
                      decoration: myBoxDecoration(),
                      child: Center(
                        child: FlatButton.icon(
                          color: Colors.blue[300],
                          icon: Icon(content_copy),
                          label: Text('Copy'),
                          onPressed: () {
                            Clipboard.setData(new ClipboardData(text: result));
                            key.currentState.showSnackBar(new SnackBar(
                              content: new Text("Copied to Clipboard"),
                            ));
                            Scaffold.of(context).showSnackBar(new SnackBar(
                              content: new Text("Sending Message"),
                            ));
                          },
                        ),
                      ),
                    ),
                    new Container(
                      margin: EdgeInsets.all(5),
                      alignment: Alignment(1.0, 0.0),
                      width: 100,
                      height: 50,
                      decoration: myBoxDecoration(),
                      child: Center(
                        child: FlatButton.icon(
                          color: Colors.blue[200],
                          icon: Icon(email),
                          label: Text('Mail'),
                          onPressed: () {
                            result = result.replaceAll('mailto:', "");
                            result = result.split('?')[0];
                            if (isEmail(result)) {
                              var url = 'mailto:$result?subject=&body=';
                              launch(url);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      margin: EdgeInsets.all(5),
                      alignment: Alignment(-1.0, 0.0),
                      width: 100,
                      height: 50,
                      decoration: myBoxDecoration(),
                      child: Center(
                        child: FlatButton.icon(
                          color: Colors.blue[200],
                          label: Text('Link'),
                          icon: Icon(link),
                          onPressed: () {
                            if (isURL(result)) {
                              launch(result);
                            }
                          },
                        ),
                      ),
                    ),
                    new Container(
                      margin: EdgeInsets.all(5),
                      alignment: Alignment(1.0, 0.0),
                      width: 100,
                      height: 50,
                      decoration: myBoxDecoration(),
                      child: Center(
                        child: FlatButton.icon(
                          color: Colors.blue[300],
                          label: Text('Call'),
                          icon: Icon(call),
                          onPressed: () {
                            result = result.replaceAll('tel://', "");
                            result = result.replaceAll('//', "");
                            result = result.replaceAll('tel:', "");
                            result = result.replaceAll('-', "");
                            if (isNumeric(result)) {
                              var num = "tel://" + result;
                              launch(num);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Flexible(
                      child: new Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(5),
                        width: 300,
                        child: GestureDetector(
                          child: TextField(
                            controller: _textFieldController,
                            cursorColor: Colors.red,
                            cursorWidth: 3.0,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: "Result",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              ),
                              //fillColor: Colors.green
                            ),
                            onChanged: (text) {
                              result = _textFieldController.text;
                            },
                          ),
                          // child: new Text(
                          //   result,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: new TextStyle(
                          //     fontSize: 25.0,
                          //     fontFamily: 'Roboto',
                          //     color: Colors.red,
                          //   ),
                          // ),
                          onTap: () {
                            Clipboard.setData(new ClipboardData(text: result));
                            key.currentState.showSnackBar(new SnackBar(
                              content: new Text("Copied to Clipboard"),
                            ));
                            Scaffold.of(context).showSnackBar(new SnackBar(
                              content: new Text("Sending Message"),
                            ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.camera_alt),
            label: Text("Scan"),
            onPressed: _scanQR,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ));
  }

  void dispose() {
    // other dispose methods
    _textFieldController.dispose();
    super.dispose();
  }
}
