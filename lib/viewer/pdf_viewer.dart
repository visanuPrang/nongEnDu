import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  runApp(MaterialApp(
    title: 'Syncfusion PDF Viewer Demo',
    theme: ThemeData(
      useMaterial3: false,
    ),
    home: const PdfViewer(pdfFile: '', fileName: ''),
  ));
}

/// Represents PdfViewer for Navigation
class PdfViewer extends StatefulWidget {
  final String pdfFile, fileName;
  const PdfViewer({super.key, required this.pdfFile, required this.fileName});
  @override
  _PdfViewer createState() => _PdfViewer();
}

class _PdfViewer extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, style: const TextStyle(fontSize: 17)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.library_books,
              color: Colors.black87,
              semanticLabel: 'Page Index.',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(widget.pdfFile, key: _pdfViewerKey),
    );
  }
}
