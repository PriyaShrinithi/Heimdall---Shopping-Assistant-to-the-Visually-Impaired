import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show basename, join;
import 'package:path_provider/path_provider.dart';
import 'upload/upload.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`can be called before `runApp()`
  //why? if there's no camera, there's no use in running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  //controllers generally give control to parent widget over child
  CameraController _controller; //gives control of Camera to the variable _controller
  //Future <void> is the future result of an execution that returns no value
  //Future would be the result of executing run()
  //Future represents the result of an asynchronous operation
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera, //TakePictureScreenState widget's camera description
      //description --> CameraDescription(0, CameraLensDirection.back, 90)
      // String name (0), CameraLensDirection lensDirection (back), int sensorOrientation (90)
      // Define the resolution to use.
      ResolutionPreset.medium,
      //why not max? cuz max resolution is compensated by cutting the screen availability by let's say 10%
    );
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    //The framework calls this method when this State object will never build again
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
        //loading spinner --> shows a spinning circle while controller loads
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
          //child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
          child: GestureDetector(
          onTap: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              //Path to the temporary directory on the device that is not backed up and is suitable for storing caches of downloaded files.
              //Files in this directory may be cleared at any time. This does not return a new temporary directory.
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      )
      )
    );
  }
}// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final imagePath;
  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image has been Captured')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      // constructor with the given path to display the image.
      floatingActionButton: FloatingActionButton(
          child: GestureDetector(
              onDoubleTap: () =>
                  Upload(File(imagePath)) //send image path to api,
          )
      ),
      //Creates a widget that displays an ImageStream obtained from a File.
    );
  }
}

