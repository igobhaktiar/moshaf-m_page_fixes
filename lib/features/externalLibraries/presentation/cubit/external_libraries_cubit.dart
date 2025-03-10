import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:open_file/open_file.dart';
// import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/core/api/dio_consumer.dart';
import 'package:qeraat_moshaf_kwait/core/api/end_points.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/moshaf_snackbar.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/data/models/external_library_model.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/external_libraries_state.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/external_library_data_list.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/pdf_viewer_screen.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart' as di;
import 'package:http/http.dart' as http;
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class ExternalLibrariesCubit extends Cubit<ExternalLibrariesState> {
  ExternalLibrariesCubit({required this.dioConsumer, required this.internetConnectionChecker}) : super(ExternalLibrariesInitial());
  static ExternalLibrariesCubit get(context) => BlocProvider.of(context);

  DioConsumer dioConsumer;
  Map<String, bool> isDownloadingPdfMap = Map.fromIterables([], []);
  Map<String, String> downloadingPdfProgressMap = Map.fromIterables([], []);
  Map<String, bool> isPaused = Map.fromIterables([], []);

  dynamic externalLibrary;

  Map<String, CancelToken> cancelTokens = {};

  final InternetConnectionChecker internetConnectionChecker;
  Future<Directory> get getExternalLibrariesDirectory async => Directory("${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/External_Library")..createSync(recursive: true);

  Future<InternetConnectionStatus> checkConnection() async => await internetConnectionChecker.connectionStatus;

  Future<void> initExternalLibrariesCubit() async {
    externalLibrary = ExternalLibrary(
      count: 1,
      results: [
        Results(
          name: "Local Resources",
          resources: externalLibraryResourcesList,
        )
      ],
    );
    //  fetchAndPrintFileSizes(externalLibraryResourcesList);
    // Initialize maps for all resources
    for (var resource in externalLibraryResourcesList) {
      if (resource.title != null) {
        // Check if there's a progress file for this resource
        final progressFile = File("${(await getExternalLibrariesDirectory).path}/progress/${resource.title}---${resource.modified}.json");
        isPaused[resource.title!] = await progressFile.exists();
      }
    }
    emit(ExternalLibraryInitialized());
  }

  Future<bool> pdfFileIsDownloaded(String title, int expectedFileSize) async {
    bool fileIsFound = false;
    Directory("${(await getExternalLibrariesDirectory).path}/rewayat/").listSync().forEach((file) {
      if (file is File) {
        if (file.path.contains("$title---")) {
          // Check if the file size matches the expected size
          if (file.lengthSync() == expectedFileSize) {
            fileIsFound = true;
          } else {
            // print(
            //     "File: $title, Found but size mismatch (Expected: $expectedFileSize bytes, Actual: ${file.lengthSync()} bytes)");
          }
        }
      }
    });
    return fileIsFound;
  }

  Future<List<String>> fetchWhenOffline() async {
    final path = "${(await getExternalLibrariesDirectory).path}/rewayat/";
    final localPaths = <String>[];
    if (Directory(path).existsSync()) {
      for (var element in Directory(path).listSync(followLinks: false)) {
        String resourceTitle = basename(element.path).split("---").toList().first;
        localPaths.add(resourceTitle);
      }
      return localPaths.getRange(0, localPaths.length).toList();
    } else {
      return localPaths.toList();
    }
  }

  // Future openFileExternal(String title) async {
  //   print("title");
  //   final File? pdfFile = await _getRecourceFileByTitle(title);

  //   if (pdfFile != null && pdfFile.existsSync()) {
  //     await OpenFile.open(pdfFile.path);
  //   }
  // }

  Future<void> openFileExternal(BuildContext context, String title) async {
    final File? pdfFile = await _getRecourceFileByTitle(title);

    if (pdfFile != null && pdfFile.existsSync()) {
      print("PDF Path: ${pdfFile.path}"); // Debug: Print the file path
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(title: title, pdfPath: pdfFile.path),
        ),
      );
    } else {
      print("File: $title, Not found");
    }
  }

  Future deletePdf(String title) async {
    final file = await _getRecourceFileByTitle(title);
    if (file != null && file.existsSync()) {
      await file.delete();
    }
    await initExternalLibrariesCubit();
    emit(ExternalLibraryItemDeleted());
  }

  Future<void> requestStoragePermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permissions granted, proceed with download
    } else {
      // Handle denied permissions
      print("Storage permissions denied");
    }
  }

  Future downloadExternalLibrary(Resource resource, BuildContext context) async {
    try {
      await deleteIfFileExistsAndNotComplete(resource);
    } on Exception catch (e) {
      print(" Download Error while deleting: $e");
    }
    try {
      final title = resource.title!;
      final modified = resource.modified!;

      // Clear any paused state
      isPaused[title] = false;
      isDownloadingPdfMap[title] = true;
      downloadingPdfProgressMap[title] = "0.0";
      emit(ExternalLibraryDownloadingAssets(title));

      // Create a cancel token for this download
      CancelToken cancelToken = CancelToken();
      cancelTokens[title] = cancelToken;

      // Start a regular download with your DioConsumer
      // We'll monitor it and catch cancelation
      final dio = Dio();
      await dio.downloadUri(
        Uri.parse(resource.url!),
        "${(await getExternalLibrariesDirectory).path}/rewayat/${title}---${modified}.pdf",
        cancelToken: cancelToken,
        onReceiveProgress: (int received, int total) async {
          if (total != -1) {
            String percentage = ((received / total) * 100).toStringAsFixed(2);
            emit(ExternalLibraryDownloadingFile(percentage));
            downloadingPdfProgressMap[title] = percentage;

            // Save progress periodically every percentage
            if (received % 1048576 == 0) {
              await saveDownloadProgress(title, modified, received);
            }

            if ((received / total) == 1) {
              isDownloadingPdfMap[title] = false;
              isPaused[title] = false;

              // Clean up progress file if download completes
              final progressFile = File("${(await getExternalLibrariesDirectory).path}/progress/${title}---${modified}.json");
              if (progressFile.existsSync()) {
                progressFile.deleteSync();
              }

              emit(ExternalLibraryFinishDownload(title));
            }
          }
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        print("Download was paused: ${e.message}");
        // Don't reset download status as it's just paused
        // The pause function will handle updating the status
      } else {
        print("Download Error: $e");
        isDownloadingPdfMap[resource.title!] = false;
      }
    } on Exception catch (e) {
      print("Download Error while downloading: $e");
      isDownloadingPdfMap[resource.title!] = false;
    }
  }

  Future<File?> _getRecourceFileByTitle(String title) async {
    var matchFiles = <FileSystemEntity>[];
    matchFiles = Directory("${(await getExternalLibrariesDirectory).path}/rewayat/").listSync().where((element) => element.path.contains("$title---")).toList();
    if (matchFiles.isNotEmpty) {
      return matchFiles.first as File;
    }
    return null;
  }

  Future<bool> isFileNeedsUpdatte(Resource resource) async {
    File? resourceFile = await _getRecourceFileByTitle(resource.title!);
    if (resourceFile != null && resourceFile.existsSync()) {
      String storedModifiedDateString = resourceFile.path.split("---").toList().last.replaceAll(".pdf", "");
      return storedModifiedDateString != resource.modified;
    } else {
      return false;
    }
  }

  Future<String> getFileSizeInMB(String title) async {
    File? resourceFile = await _getRecourceFileByTitle(title);
    if (resourceFile != null && resourceFile.existsSync()) {
      String byteLength = '${(resourceFile.lengthSync() / 1000000).toStringAsFixed(2)} MB ';
      return byteLength;
    } else {
      return '';
    }
  }

  Future<void> fetchAndPrintFileSizes(List<Resource> resources) async {
    for (var resource in resources) {
      try {
        final response = await http.head(Uri.parse(resource.url ?? ''));
        if (response.statusCode == 200) {
          final contentLength = response.headers['content-length'];
          if (contentLength != null) {
            resource.fileSize = int.parse(contentLength);
            print("File: ${resource.title}, Size: ${resource.fileSize} bytes");
          } else {
            print("File: ${resource.title}, Size: Unknown (content-length header missing)");
          }
        } else {
          print("File: ${resource.title}, Failed to fetch size: HTTP ${response.statusCode}");
        }
      } catch (e) {
        print("File: ${resource.title}, Error fetching size: $e");
      }
    }
  }

  void deleteAndDownloadUpdatedFile(Resource libraryResource, BuildContext context) async {
    await deletePdf(libraryResource.title!);
    await Future.delayed(const Duration(milliseconds: 500));
    await downloadExternalLibrary(libraryResource, context);
  }

  deleteIfFileExistsAndNotComplete(Resource libraryResource) async {
    try {
      File? resourceFile = await _getRecourceFileByTitle(libraryResource.title!);
      if (resourceFile != null && resourceFile.existsSync()) {
        if (resourceFile.lengthSync() != libraryResource.fileSize) {
          await deletePdf(libraryResource.title!);
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> saveDownloadProgress(String title, String modified, int downloadBytes) async {
    final progressDir = Directory("${(await getExternalLibrariesDirectory).path}/progress");
    await progressDir.create(recursive: true);

    final progressFile = File("${progressDir.path}/$title---$modified.json");
    await progressFile.writeAsString(jsonEncode({
      "downloadedBytes": downloadBytes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  Future<int> getDownloadProgress(String title, String modified) async {
    try {
      final progressDir = Directory("${(await getExternalLibrariesDirectory).path}/progress");
      final progressFile = File("${progressDir.path}/${title}---${modified}.json");

      if (await progressFile.exists()) {
        final content = await progressFile.readAsString();
        final data = jsonDecode(content);
        return data['downloadedBytes'] ?? 0;
      }
    } catch (e) {
      print("Error reading progress: $e");
    }
    return 0;
  }

  Future<void> pauseDownload(String title) async {
    if (cancelTokens.containsKey(title) && !cancelTokens[title]!.isCancelled) {
      // get the file currently being downloaded
      final resource = externalLibraryResourcesList.firstWhere((element) => element.title == title);
      final partialFile = File("${(await getExternalLibrariesDirectory).path}/rewayat/${resource.title}---${resource.modified}.pdf");

      // save current download progress
      if (partialFile.existsSync()) {
        final downloadBytes = partialFile.lengthSync();
        await saveDownloadProgress(title, resource.modified!, downloadBytes);
      }

      // cancel the download
      cancelTokens[title]!.cancel('Download paused by user');
      isPaused[title] = true;
      isDownloadingPdfMap[title] = false;
    }
  }

  Future<void> resumeDownload(Resource resource, BuildContext context) async {
    if (isPaused[resource.title!] == true) {
      final title = resource.title!;
      final modified = resource.modified!;

      // get the partial file
      final partifialFilePath = "${(await getExternalLibrariesDirectory).path}/rewayat/$title---$modified.pdf";
      final partialFile = File(partifialFilePath);

      // get the saved progress
      final downloadedBytes = await getDownloadProgress(title, modified);

      if (downloadedBytes > 0 && partialFile.existsSync()) {
        // create a temporary file to download remaining content
        final tempFilePath = "${(await getExternalLibrariesDirectory).path}/temp/$title---$modified.pdf";
        final tempDir = Directory(dirname(tempFilePath));
        await tempDir.create(recursive: true);

        // set download status
        isDownloadingPdfMap[title] = true;
        isPaused[title] = false;

        print('ispause on resume: ${isPaused[title]}');

        try {
          // download remaining part using a custom URL with range
          final client = Dio();
          client.options.headers['Range'] = 'bytes=$downloadedBytes-';

          CancelToken cancelToken = CancelToken();
          cancelTokens[title] = cancelToken;

          await client.download(
            resource.url!,
            tempFilePath,
            cancelToken: cancelToken,
            onReceiveProgress: (received, total) async {
              if (total != -1) {
                // calculate progress
                int actualTotal = downloadedBytes + total;
                int actualReceived = downloadedBytes + received;
                String percentage = ((actualReceived / actualTotal) * 100).toStringAsFixed(2);

                emit(ExternalLibraryDownloadingFile(percentage));
                downloadingPdfProgressMap[title] = percentage;

                // save progres periodically
                if (received % 1048576 == 0) {
                  saveDownloadProgress(title, modified, actualReceived);
                }

                // check if download is complete
                if (received == total) {}
              }
            },
          );

          // delete the temp file if download is cancelled
          // Combine the partial file and the temp file
          final tempFile = File(tempFilePath);
          if (tempFile.existsSync()) {
            final tempBytes = await tempFile.readAsBytes();
            final raf = await partialFile.open(mode: FileMode.append);
            await raf.writeFrom(tempBytes);
            await raf.close();

            // Delete the temp file
            await tempFile.delete();

            // Delete progress file
            final progressFile = File("${(await getExternalLibrariesDirectory).path}/progress/${title}---${modified}.json");
            if (await progressFile.exists()) {
              await progressFile.delete();
            }

            // Update status
            isDownloadingPdfMap[title] = false;
            isPaused[title] = false;
            emit(ExternalLibraryFinishDownload(title));
          }
        } catch (e) {
          print("Error resuming download: $e");
          if (e is DioException && CancelToken.isCancel(e)) {
            // The download was paused again
            final tempFile = File(tempFilePath);
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          } else {
            isDownloadingPdfMap[title] = false;
          }
        }
      } else {
        await downloadExternalLibrary(resource, context);
      }
    }
  }
}
