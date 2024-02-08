import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/screens/chat_home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyImageViewer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.green),
        primarySwatch: Colors.blue,
      ),
      home: const ImageViewer(),
    );
  }
}

class ImageViewer extends StatefulWidget {
  const ImageViewer({
    Key? key,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final _pageController = PageController();
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  final List<ImageProvider> _imageProviders = [
    const NetworkImage(
        "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2F014z9Pq898.webp?alt=media&token=b6b18bdc-68e1-462b-9f10-3e758cb19a04"),
    const NetworkImage(
        "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2Fe17z902082.jpg?alt=media&token=ed76e206-645d-4cbe-bedc-d339801b4bb1"),
    const NetworkImage(
        "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2F2332666898.png?alt=media&token=d75bbc7f-dd93-45bc-ab2d-b4493d893657"),
    const NetworkImage(
        "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2FUNHZHSrGYY.png?alt=media&token=10ee1b59-f876-4f98-9791-0e804a26d746")
  ];

  late final _easyEmbeddedImageProvider = MultiImageProvider(_imageProviders);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const ChatHomePage())),
          ),
          ElevatedButton(
              child: const Text("Custom Progress Indicator"),
              onPressed: () {
                CustomImageWidgetProvider customImageProvider =
                    CustomImageWidgetProvider(
                  imageUrls: [
                    "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2F014z9Pq898.webp?alt=media&token=b6b18bdc-68e1-462b-9f10-3e758cb19a04",
                    "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2Fe17z902082.jpg?alt=media&token=ed76e206-645d-4cbe-bedc-d339801b4bb1",
                    "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2F2332666898.png?alt=media&token=d75bbc7f-dd93-45bc-ab2d-b4493d893657",
                    "https://firebasestorage.googleapis.com/v0/b/messagingapp-ac1d6.appspot.com/o/images%2FP01%20EnDu%20School_P02%20EnDu%20School%2FUNHZHSrGYY.png?alt=media&token=10ee1b59-f876-4f98-9791-0e804a26d746"
                  ].toList(),
                );
                showImageViewerPager(context, customImageProvider);
              }),
        ],
      )),
    );
  }
}

class CustomImageProvider extends EasyImageProvider {
  @override
  final int initialIndex;
  final List<String> imageUrls;

  CustomImageProvider({required this.imageUrls, this.initialIndex = 0})
      : super();

  @override
  ImageProvider<Object> imageBuilder(BuildContext context, int index) {
    return NetworkImage(imageUrls[index]);
  }

  @override
  int get imageCount => imageUrls.length;
}

class CustomImageWidgetProvider extends EasyImageProvider {
  @override
  final int initialIndex;
  final List<String> imageUrls;

  CustomImageWidgetProvider({required this.imageUrls, this.initialIndex = 0})
      : super();

  @override
  ImageProvider<Object> imageBuilder(BuildContext context, int index) {
    return NetworkImage(imageUrls[index]);
  }

  @override
  Widget progressIndicatorWidgetBuilder(BuildContext context, int index,
      {double? value}) {
    // Create a custom linear progress indicator
    // with a label showing the progress value
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: value,
        ),
        Text(
          "${(value ?? 0) * 100}%",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        )
      ],
    );
  }

  @override
  int get imageCount => imageUrls.length;
}
