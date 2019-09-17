import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

//import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'La Smorfia, letteralmente'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*
   int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Questa app è offerta da:',
            ),
            Expanded(
              flex: 6,
              child: Image.asset(
                'assets/images/copertina.jpg',
//              fit: BoxFit.fitHeight,
//              scale: 0.5,
              ),
            ),
            new RichText(
              text: new TextSpan(
                children: [
//              new TextSpan(
//                text: 'This is no Link, ',
//                style: new TextStyle(color: Colors.black),
//              ),
                  new TextSpan(
                    text: 'maggiori informazioni',
                    style: new TextStyle(
                      color: Colors.blue,
                      fontSize: 24.0,
                    ),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            'https://www.amazon.it/dp/B07TC4Z2F2?fbclid=IwAR12OMmdzoW38upOVERhhg3j_byrih1R3qK8wxO3PDoZHlvRv_dYDvhhev8');
                      },
                  ),
                ],
              ),
            ),
//            Text(
//              'disponibile su Amazon',
//              style: Theme.of(context).textTheme.display1,
//            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
        onPressed: detectFaceParameters,
        tooltip: 'Foto',
        child: Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> detectFaceParameters() async {
// Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
    final _camera = selezionaCamera(cameras);

    final imagePath = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
//    final imagePath = await ImagePicker.pickImage(source: _camera,);
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imagePath);
//    final LabelDetector labelDetector = FirebaseVision.instance.labelDetector();
//    final List<Label> labels = await labelDetector.detectInImage(visionImage);
//
//    List<String> labelTexts = new List();
//    for (Label label in labels) {
//      final String text = label.label;
//
//      labelTexts.add(text);
//      print("***** $text");
//    }

    FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
        FaceDetectorOptions(enableLandmarks: true, enableClassification: true));
    List<Face> faces;
    faces = await faceDetector.processImage(visionImage);
    int f = 1;
    for (Face face in faces) {
      print("**** faccia n.$f");
      final boundingBox = face.boundingBox;

      final double rotY =
          face.headEulerAngleY; // Head is rotated to the right rotY degrees
      final double rotZ =
          face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
      if (leftEar != null) {
        final leftEarPos = leftEar.position;
        print('*** leftEarPos=$leftEarPos');
      }
// If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        final double smileProb = face.smilingProbability;
        print('*** smileProb=$smileProb');
      }

      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int id = face.trackingId;
        print('*** id=$id');
      }
    }

//    final String uuid = Uuid().v1();
//    final String downloadURL = await _uploadFile(uuid);
//
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => ItemsListScreen()),
//    );
//
//    await _addItem(downloadURL, labelTexts);
  }

  CameraDescription selezionaCamera(List<CameraDescription> cameras) {
    //return cameras.first;
    CameraDescription retVal;
    retVal = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);
    return retVal;
  }
}
