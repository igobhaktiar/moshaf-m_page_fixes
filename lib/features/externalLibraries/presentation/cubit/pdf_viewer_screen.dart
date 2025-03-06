import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PdfViewerScreen({Key? key, required this.pdfPath, required this.title})
      : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width, // Fit to screen width
          height: MediaQuery.of(context).size.height, // Fit to screen height
          child: PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false, // Disable horizontal swipe
            autoSpacing: true,
            pageFling: false,
            fitPolicy: FitPolicy.HEIGHT, // Fit the PDF to the screen
            onRender: (pages) {
              print("PDF rendered with $pages pages");
            },
            onError: (error) {
              print("Error loading PDF: $error");
            },
            onPageError: (page, error) {
              print("Error on page $page: $error");
            },
            onViewCreated: (PDFViewController controller) {
              //  _pdfViewController = controller;
              print("PDF view created");

              // Debug: Check the number of pages
              controller.getPageCount().then((pageCount) {
                print("Total pages: $pageCount");
              });
            },
          ),
        ),
      ),
    );
  }
}
