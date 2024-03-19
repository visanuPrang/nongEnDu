import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:focused_area_ocr_flutter/focused_area_ocr_view.dart';
import 'package:focused_area_ocr_flutter/focused_area_ocr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
// import 'package:focused_area_ocr_flutter/focused_area_ocr_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focused Area OCR Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OCRReader(),
    );
  }
}

class OCRReader extends StatefulWidget {
  const OCRReader({Key? key}) : super(key: key);

  @override
  State<OCRReader> createState() => _OCRReaderState();
}

class _OCRReaderState extends State<OCRReader> {
  final StreamController<String> controller = StreamController<String>();
  final double _textViewHeight = 120.0;
  String textOCR = '------';
  double numberOCR = 0;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final Offset focusedAreaCenter = Offset(
      0,
      (statusBarHeight + kToolbarHeight + _textViewHeight) / 2,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 57, 6, 119),
        title: const Text(
          'Focused Area OCR Flutter',
          style: TextStyle(color: Colors.white70),
        ),
      ),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          FocusedAreaOCRView(
            focusedAreaWidth: MediaQuery.of(context).size.width * 0.5,
            focusedAreaHeight: 50.0,
            onScanText: (text) {
              controller.add(text);
            },
            // focusedAreaCenter : Offset.zero,
            focusedAreaCenter: const Offset(0, -80), //focusedAreaCenter,
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                height: _textViewHeight,
                color: Colors.black,
                child: StreamBuilder<String>(
                  stream: controller.stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    // textOCR = '   DoDO56    ';
                    if (snapshot.data != null && snapshot.data!.length == 6) {
                      if (snapshot.data!.startsWith('D', 0) ||
                          snapshot.data!.startsWith('O', 0) ||
                          snapshot.data!.startsWith('o', 0) ||
                          snapshot.data!.startsWith(RegExp(r'[0-9]'))) {
                        textOCR = textOCR = snapshot.data!;
                        textOCR = textOCR.replaceAll('D', '0');
                        textOCR = textOCR.replaceAll('O', '0');
                        textOCR = textOCR.replaceAll('o', '0');
                        if (!textOCR.contains('.')) {
                          textOCR =
                              '${textOCR.substring(0, 5)}.${textOCR.substring(5)}';
                        }
                        Vibration.vibrate(duration: 200, repeat: 1);
                      }
                    } else {
                      textOCR = '';
                    }
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              textOCR,
                              textAlign: TextAlign.center,
                              style:
                                  //  GoogleFonts.ibmPlexSansThai(
                                  //     textStyle: const TextStyle(
                                  //         fontSize: 70, color: Colors.white70)),
                                  GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                    color: Colors.amber,
                                    letterSpacing: .5,
                                    fontSize: 70,
                                    fontWeight: FontWeight.w500),
                              ),
                              // const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(250, 40),
                ),
                child: const Text(
                  'เก็บค่า',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
