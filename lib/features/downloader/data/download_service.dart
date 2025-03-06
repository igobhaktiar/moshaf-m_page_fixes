// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:archive/archive.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class DownloadService {
//   static void init() {
//     FlutterDownloader.initialize(debug: true);
//   }

//   static Future<void> requestPermissions() async {
//     await Permission.storage.request();
//   }

//   static Future<String?> downloadZipFile(String url, String fileName) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final savedDir = directory.path;

//     await requestPermissions();

//     final taskId = await FlutterDownloader.enqueue(
//       url: url,
//       savedDir: savedDir,
//       fileName: fileName,
//       showNotification: true,
//       openFileFromNotification: true,
//     );

//     return taskId;
//   }

//   static Future<void> extractZipFile(
//       String zipFilePath, String destinationDir) async {
//     final zipFile = File(zipFilePath);
//     if (!zipFile.existsSync()) return;

//     final bytes = await zipFile.readAsBytes();
//     final archive = ZipDecoder().decodeBytes(bytes);

//     for (final file in archive) {
//       final filePath = "$destinationDir/${file.name}";
//       if (file.isFile) {
//         await File(filePath).create(recursive: true);
//         await File(filePath).writeAsBytes(file.content as List<int>);
//       } else {
//         await Directory(filePath).create(recursive: true);
//       }
//     }
//     print("Unzip Completed!");
//   }

//   static void downloadCallback(String id, int status, int progress) {
//     final SendPort? send =
//         IsolateNameServer.lookupPortByName('downloader_send_port');
//     send?.send([id, status, progress]);
//   }

//   static void registerCallback() {
//     ReceivePort port = ReceivePort();

//     port.listen((dynamic data) {
//       String id = data[0];
//       int status = data[1];
//       int progress = data[2];
//       print("Download Status: $status, Progress: $progress%");
//     });

//     IsolateNameServer.registerPortWithName(
//         port.sendPort, 'downloader_send_port');
//     FlutterDownloader.registerCallback(downloadCallback);
//   }
// }
