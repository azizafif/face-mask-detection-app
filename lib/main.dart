import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = true;
  File? file;
  var output;
  var label;
  var fine;
  ImagePicker image = ImagePicker();
  var gfg = {
    'with_mask': 'no_fine',
    'without_mask': 'Fine_100_dollar',
  };

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  detectimage(File l) async {
    var prediction = await Tflite.runModelOnImage(
      path: l.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      output = prediction;
      label = (output![0]['label']).toString().substring(2);
      fine = gfg[label];
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getImageFromCamera() async {
    var img = await image.pickImage(source: ImageSource.camera);

    setState(() {
      file = File(img!.path);
    });
    detectimage(file!);
  }

  getImageFromGallery() async {
    var img = await image.pickImage(source: ImageSource.gallery);

    setState(() {
      file = File(img!.path);
    });
    detectimage(file!);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'mask or without_mask',
        ),
      ),
      body: SizedBox(
        height: h,
        width: w,
        child: Column(
          children: [
            loading == true
                ? Container()
                : Container(
                    color: Colors.red,
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          padding: const EdgeInsets.all(15),
                          child: Image.file(file!),
                        ),
                        Text(
                          (output![0]['label']).toString().substring(2),
                        ),
                        Text(
                          'Confidence: ${output![0]['confidence']}',
                        ),
                        Text(fine),
                      ],
                    ),
                  ),
            const SizedBox(
              height: 100,
            ),
            Stack(
              children: [
                Align(
                  alignment: const Alignment(-0.5, 0.8),
                  child: FloatingActionButton(
                    elevation: 0.0,
                    backgroundColor: Colors.indigo[900],
                    onPressed: getImageFromGallery,
                    child: const Icon(
                      Icons.image,
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0.5, 0.8),
                  child: FloatingActionButton(
                    elevation: 0.0,
                    backgroundColor: Colors.indigo[900],
                    onPressed: getImageFromCamera,
                    child: const Icon(
                      Icons.camera,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
