import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart'; // For Date formatting
import 'package:permission_handler/permission_handler.dart';

class PdfDownloadDocument {
  bool _isLoading = false;
  Function(bool)? onLoadingStateChange;

  bool get isLoading => _isLoading;

  // Method to download the PDF
  void downloadPDF(BuildContext context, String pdfUrl) async {
    _setLoading(true); // Show loader

    // Check and request storage permission
    if (await _requestStoragePermission()) {
      try {
        final now = DateTime.now();
        final formatter = DateFormat('dd-MM-yyyy_HHmmss');
        final formattedDate = formatter.format(now);

        // Start downloading the file
        FileDownloader.downloadFile(
          url: pdfUrl,
          name: "salaryslip_$formattedDate.pdf",
          onProgress: (String? fileName, double progress) {
            print('FILE $fileName HAS PROGRESS $progress');
          },
          onDownloadCompleted: (String? path) {
            _showSnackBar(context, "Download Successful! Saved at");
            _setLoading(false); // Hide loader
            print('Download completed: $path');
          },
          onDownloadError: (String? error) {
            _setLoading(false); // Hide loader
            _showSnackBar(context, "Download Failed! $error");
            print('Download failed: $error');
          },
        );
      } catch (e) {
        _setLoading(false); // Hide loader
        _showSnackBar(context, "Download Failed! $e");
        print('Download failed: $e');
      }
    } else {
      _setLoading(false); // Hide loader
      _showSnackBar(context, "Permission Denied!");
      print('Permission denied');
    }
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    return false;
  }

  // Show Snackbar for status messages
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Set loading state and notify UI
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (onLoadingStateChange != null) {
      onLoadingStateChange!(loading);
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PdfDownloadDocument pdfDownloader = PdfDownloadDocument();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pdfDownloader.onLoadingStateChange = (isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Downloader")),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Downloading..."),
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  pdfDownloader.downloadPDF(
                      context, 'https://www.fluttercampus.com/sample.pdf');
                },
                child: Text("Download PDF"),
              ),
      ),
    );
  }
}
