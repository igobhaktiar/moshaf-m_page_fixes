import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/moshaf_snackbar.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/data/models/external_library_model.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/external_libraries_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/external_libraries_state.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/cubit/external_library_data_list.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class NewExternalLibrariesScreen extends StatefulWidget {
  const NewExternalLibrariesScreen({super.key});

  @override
  State<NewExternalLibrariesScreen> createState() => _NewExternalLibrariesScreenState();
}

// In external_libraries_cubit.dart

class _NewExternalLibrariesScreenState extends State<NewExternalLibrariesScreen> {
  late ExternalLibrariesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<ExternalLibrariesCubit>(context);
    _cubit.initExternalLibrariesCubit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(context.translate.external_library_title),
          ],
        ),
        leading: AppConstants.customBackButton(context),
      ),
      body: BlocBuilder<ExternalLibrariesCubit, ExternalLibrariesState>(
        builder: (context, state) {
          final externalLibrary = _cubit.externalLibrary;

          if (externalLibrary == null) {
            return Center(
              child: Text(context.translate.noBookAvailable),
            );
          }

          if (externalLibrary is! ExternalLibrary) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: externalLibraryResourcesList.map<Widget>((libraryResource) {
                return GestureDetector(
                  onTap: () async {
                    bool isDownloaded = await _cubit.pdfFileIsDownloaded(libraryResource.title!, libraryResource.fileSize!);
                    print("isDownloaded: $isDownloaded");
                    if (isDownloaded) {
                      await _cubit.openFileExternal(context, libraryResource.title!);
                    }
                  },
                  child: Slidable(
                    key: Key(libraryResource.title!),
                    closeOnScroll: true,
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        Expanded(
                          child: Container(
                            color: context.theme.brightness == Brightness.dark ? context.theme.scaffoldBackgroundColor : const Color(0xFFFEF2F2),
                            child: Container(
                              alignment: Alignment.center,
                              child: Builder(
                                builder: (ctx) {
                                  return InkWell(
                                    onTap: () {
                                      _cubit.deletePdf(libraryResource.title!);
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SvgPicture.asset(AppAssets.delete, color: Colors.red),
                                          const SizedBox(width: 10),
                                          Text(
                                            context.translate.delete,
                                            style: const TextStyle(fontSize: 16, height: 1.4, color: AppColors.red, fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 50,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          ClipOval(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.theme.brightness == Brightness.dark ? AppColors.dialogBgDark : AppColors.lightGrey,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.tenReadingsIcon,
                                color: context.theme.brightness == Brightness.dark ? AppColors.white : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(libraryResource.title!, style: context.textTheme.bodyMedium!.copyWith(fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          StreamBuilder(
                            stream: _cubit.pdfFileIsDownloaded(libraryResource.title!, libraryResource.fileSize!).asStream(),
                            builder: (BuildContext ctx, AsyncSnapshot f) {
                              final isDownloading = _cubit.isDownloadingPdfMap[libraryResource.title!] == true;
                              String percentage = _cubit.downloadingPdfProgressMap[libraryResource.title!] ?? '0.0';
                              bool? isPaused = _cubit.isPaused[libraryResource.title!];
                              if (isDownloading || isPaused == true) {
                                return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isPaused == true) {
                                          print('resume download');
                                          _cubit.resumeDownload(libraryResource, context);
                                        } else {
                                          print('pause download');
                                          _cubit.pauseDownload(libraryResource.title!);
                                        }

                                        setState(() {
                                          isPaused = _cubit.isPaused[libraryResource.title!]!;
                                          print('paused: $isPaused');
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: Center(
                                                  child: isPaused == true ? SvgPicture.asset(AppAssets.play) : const CircularProgressIndicator(),
                                                ),
                                              ),
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                top: 0,
                                                bottom: 0,
                                                child: Center(
                                                  child: isPaused == false ? SvgPicture.asset(AppAssets.pause) : const SizedBox(),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(width: 15),
                                          SizedBox(
                                            height: 20,
                                            child: Center(
                                              child: Text(
                                                "$percentage %",
                                                textDirection: TextDirection.ltr,
                                                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12.0),
                                              ),
                                            ),
                                          ),
                                        ].reversed.toList(),
                                      ),
                                    ));
                              } else {
                                return StreamBuilder(
                                    stream: _cubit.isFileNeedsUpdatte(libraryResource).asStream(),
                                    builder: (BuildContext ctx2, AsyncSnapshot ff) {
                                      if (ff.data == true) {
                                        return InkWell(
                                          onTap: () => _onUpdateResourcePressed(context, libraryResource),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(color: context.theme.appBarTheme.backgroundColor, borderRadius: BorderRadius.circular(5)),
                                            child: Text(
                                              context.translate.update,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        );
                                      } else {
                                        if (f.data != true) {
                                          return InkWell(
                                              child: SvgPicture.asset(
                                                AppAssets.downloadDisabled,
                                                color: context.isDarkMode ? Colors.white : null,
                                              ),
                                              onTap: () async {
                                                print("Downloading function called");
                                                try {
                                                  await ctx.read<ExternalLibrariesCubit>().downloadExternalLibrary(libraryResource, context);
                                                } on Exception catch (e) {
                                                  print(e);
                                                }
                                              });
                                        } else {
                                          return InkWell(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(AppAssets.checkBlack),
                                                  StreamBuilder(
                                                      stream: _cubit.getFileSizeInMB(libraryResource.title!).asStream(),
                                                      builder: (BuildContext ctx, AsyncSnapshot fff) {
                                                        final String fileSize = fff.data ?? '';

                                                        if (fileSize != '') {
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                                            child: Text(
                                                              fileSize,
                                                              textDirection: TextDirection.ltr,
                                                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12.0),
                                                            ),
                                                          );
                                                        } else {
                                                          return const SizedBox();
                                                        }
                                                      })
                                                ].reversed.toList(),
                                              ),
                                              onTap: () async {
                                                bool isDownloaded = await _cubit.pdfFileIsDownloaded(libraryResource.title!, libraryResource.fileSize!);
                                                print("isDownloaded: $isDownloaded");
                                                if (isDownloaded) {
                                                  await ctx.read<ExternalLibrariesCubit>().openFileExternal(context, libraryResource.title!);
                                                }
                                              });
                                        }
                                      }
                                    });
                              }
                            },
                          ),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  _onUpdateResourcePressed(BuildContext context, Resource libraryResource) {
    _cubit.deleteAndDownloadUpdatedFile(libraryResource, context);
  }
}
