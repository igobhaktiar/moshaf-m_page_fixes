import 'dart:convert';
import 'dart:io';
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
  ExternalLibrariesCubit(
      {required this.dioConsumer, required this.internetConnectionChecker})
      : super(ExternalLibrariesInitial());
  static ExternalLibrariesCubit get(context) => BlocProvider.of(context);

  DioConsumer dioConsumer;
  Map<String, bool> isDownloadingPdfMap = Map.fromIterables([], []);
  Map<String, String> downloadingPdfProgressMap = Map.fromIterables([], []);

  dynamic externalLibrary;

  final InternetConnectionChecker internetConnectionChecker;
  Future<Directory> get getExternalLibrariesDirectory async => Directory(
      "${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/External_Library")
    ..createSync(recursive: true);

  Future<InternetConnectionStatus> checkConnection() async =>
      await internetConnectionChecker.connectionStatus;

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
    emit(ExternalLibraryInitialized());
  }

  Future<bool> pdfFileIsDownloaded(String title, int expectedFileSize) async {
    bool fileIsFound = false;
    Directory("${(await getExternalLibrariesDirectory).path}/rewayat/")
        .listSync()
        .forEach((file) {
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
        String resourceTitle =
            basename(element.path).split("---").toList().first;
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
          builder: (context) =>
              PdfViewerScreen(title: title, pdfPath: pdfFile.path),
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

  Future downloadExternalLibrary(
      Resource resource, BuildContext context) async {
    try {
      await deleteIfFileExistsAndNotComplete(resource);
    } on Exception catch (e) {
      print(" Download Error while deleting: $e");
    }
    try {
      isDownloadingPdfMap[resource.title!] = true;
      downloadingPdfProgressMap[resource.title!] = "0.0";
      emit(ExternalLibraryDownloadingAssets(resource.title!));
      await dioConsumer.download(
        remoteUrl: resource.url!,
        storagePath:
            "${(await getExternalLibrariesDirectory).path}/rewayat/${resource.title}---${resource.modified}.pdf",
        onRecieveProgress: (int received, int total) {
          if (total != -1) {
            String percentage = ((received / total) * 100).toStringAsFixed(2);
            emit(ExternalLibraryDownloadingFile(percentage));
            downloadingPdfProgressMap[resource.title!] = percentage;
            if ((received / total) == 1) {
              isDownloadingPdfMap[resource.title!] = false;
              emit(ExternalLibraryFinishDownload(resource.title!));
            }
          }
        },
      );
    } on Exception catch (e) {
      print(" Download Error while downloading: $e");
    }
  }

  Future<File?> _getRecourceFileByTitle(String title) async {
    var matchFiles = <FileSystemEntity>[];
    matchFiles =
        Directory("${(await getExternalLibrariesDirectory).path}/rewayat/")
            .listSync()
            .where((element) => element.path.contains("$title---"))
            .toList();
    if (matchFiles.isNotEmpty) {
      return matchFiles.first as File;
    }
    return null;
  }

  Future<bool> isFileNeedsUpdatte(Resource resource) async {
    File? resourceFile = await _getRecourceFileByTitle(resource.title!);
    if (resourceFile != null && resourceFile.existsSync()) {
      String storedModifiedDateString =
          resourceFile.path.split("---").toList().last.replaceAll(".pdf", "");
      return storedModifiedDateString != resource.modified;
    } else {
      return false;
    }
  }

  Future<String> getFileSizeInMB(String title) async {
    File? resourceFile = await _getRecourceFileByTitle(title);
    if (resourceFile != null && resourceFile.existsSync()) {
      String byteLength =
          '${(resourceFile.lengthSync() / 1000000).toStringAsFixed(2)} MB ';
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
            print(
                "File: ${resource.title}, Size: Unknown (content-length header missing)");
          }
        } else {
          print(
              "File: ${resource.title}, Failed to fetch size: HTTP ${response.statusCode}");
        }
      } catch (e) {
        print("File: ${resource.title}, Error fetching size: $e");
      }
    }
  }

  void deleteAndDownloadUpdatedFile(
      Resource libraryResource, BuildContext context) async {
    await deletePdf(libraryResource.title!);
    await Future.delayed(const Duration(milliseconds: 500));
    await downloadExternalLibrary(libraryResource, context);
  }

  deleteIfFileExistsAndNotComplete(Resource libraryResource) async {
    try {
      File? resourceFile =
          await _getRecourceFileByTitle(libraryResource.title!);
      if (resourceFile != null && resourceFile.existsSync()) {
        if (resourceFile.lengthSync() != libraryResource.fileSize) {
          await deletePdf(libraryResource.title!);
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
