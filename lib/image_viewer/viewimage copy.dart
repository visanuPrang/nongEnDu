import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/image_viewer/async_demo_page.dart';

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
      home: const ImageViewer(title: 'EasyImageViewer Demo'),
    );
  }
}

class ImageViewer extends StatefulWidget {
  final String title;

  const ImageViewer({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final _pageController = PageController();
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  final List<ImageProvider> _imageProviders = [
    const NetworkImage("https://picsum.photos/id/1001/4912/3264"),
    const NetworkImage("https://picsum.photos/id/1003/1181/1772"),
    const NetworkImage("https://picsum.photos/id/1004/4912/3264"),
    const NetworkImage("https://picsum.photos/id/1005/4912/3264")
  ];

  late final _easyEmbeddedImageProvider = MultiImageProvider(_imageProviders);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              child: const Text("Custom Progress Indicator"),
              onPressed: () {
                CustomImageWidgetProvider customImageProvider =
                    CustomImageWidgetProvider(
                  imageUrls: [
                    "https://picsum.photos/id/1001/4912/3264",
                    "https://picsum.photos/id/1003/1181/1772",
                    "https://picsum.photos/id/1004/4912/3264",
                    "https://picsum.photos/id/1005/4912/3264"
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
