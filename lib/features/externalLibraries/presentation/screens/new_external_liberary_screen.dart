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
  State<NewExternalLibrariesScreen> createState() =>
      _NewExternalLibrariesScreenState();
}

// In external_libraries_cubit.dart

class _NewExternalLibrariesScreenState
    extends State<NewExternalLibrariesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExternalLibrariesCubit>().initExternalLibrariesCubit();
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
          final externalLibrary =
              context.read<ExternalLibrariesCubit>().externalLibrary;

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
              children:
                  externalLibraryResourcesList.map<Widget>((libraryResource) {
                return GestureDetector(
                  onTap: () async {
                    bool isDownloaded = await context
                        .read<ExternalLibrariesCubit>()
                        .pdfFileIsDownloaded(
                            libraryResource.title!, libraryResource.fileSize!);
                    print("isDownloaded: $isDownloaded");
                    if (isDownloaded) {
                      await context
                          .read<ExternalLibrariesCubit>()
                          .openFileExternal(context, libraryResource.title!);
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
                            color: context.theme.brightness == Brightness.dark
                                ? context.theme.scaffoldBackgroundColor
                                : const Color(0xFFFEF2F2),
                            child: Container(
                              alignment: Alignment.center,
                              child: Builder(
                                builder: (ctx) {
                                  return InkWell(
                                    onTap: () {
                                      context
                                          .read<ExternalLibrariesCubit>()
                                          .deletePdf(libraryResource.title!);
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SvgPicture.asset(AppAssets.delete,
                                              color: Colors.red),
                                          const SizedBox(width: 10),
                                          Text(
                                            context.translate.delete,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.4,
                                                color: AppColors.red,
                                                fontWeight: FontWeight.w500),
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
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          ClipOval(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    context.theme.brightness == Brightness.dark
                                        ? AppColors.dialogBgDark
                                        : AppColors.lightGrey,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.tenReadingsIcon,
                                color:
                                    context.theme.brightness == Brightness.dark
                                        ? AppColors.white
                                        : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(libraryResource.title!,
                                style: context.textTheme.bodyMedium!
                                    .copyWith(fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          StreamBuilder(
                            stream: context
                                .read<ExternalLibrariesCubit>()
                                .pdfFileIsDownloaded(libraryResource.title!,
                                    libraryResource.fileSize!)
                                .asStream(),
                            builder: (BuildContext ctx, AsyncSnapshot f) {
                              final isDownloading = context
                                          .read<ExternalLibrariesCubit>()
                                          .isDownloadingPdfMap[
                                      libraryResource.title!] ==
                                  true;
                              String percentage = context
                                  .read<ExternalLibrariesCubit>()
                                  .downloadingPdfProgressMap[
                                      libraryResource.title!]
                                  .toString();

                              if (isDownloading) {
                                return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        SizedBox(
                                          height: 20,
                                          child: Center(
                                            child: Text(
                                              "$percentage %",
                                              textDirection: TextDirection.ltr,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        ),

                                        ///******************* */
                                      ].reversed.toList(),
                                    ));
                              } else {
                                return StreamBuilder(
                                    stream: context
                                        .read<ExternalLibrariesCubit>()
                                        .isFileNeedsUpdatte(libraryResource)
                                        .asStream(),
                                    builder:
                                        (BuildContext ctx2, AsyncSnapshot ff) {
                                      if (ff.data == true) {
                                        return InkWell(
                                          onTap: () => _onUpdateResourcePressed(
                                              context, libraryResource),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: context.theme.appBarTheme
                                                    .backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Text(
                                              context.translate.update,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        );
                                      } else {
                                        if (f.data != true) {
                                          return InkWell(
                                              child: SvgPicture.asset(
                                                AppAssets.downloadDisabled,
                                                color: context.isDarkMode
                                                    ? Colors.white
                                                    : null,
                                              ),
                                              onTap: () async {
                                                // MoshafSnackbar.triggerSnackbar(
                                                //   context,
                                                //   text:
                                                //       "${context.translate.downloading} ${libraryResource.title}",
                                                // );
                                                print(
                                                    "Downloading function called");
                                                try {
                                                  await ctx
                                                      .read<
                                                          ExternalLibrariesCubit>()
                                                      .downloadExternalLibrary(
                                                          libraryResource,
                                                          context);
                                                } on Exception catch (e) {
                                                  print(e);
                                                }
                                              });
                                        } else {
                                          return InkWell(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                      AppAssets.checkBlack),
                                                  StreamBuilder(
                                                      stream: context
                                                          .read<
                                                              ExternalLibrariesCubit>()
                                                          .getFileSizeInMB(
                                                              libraryResource
                                                                  .title!)
                                                          .asStream(),
                                                      builder: (BuildContext
                                                              ctx,
                                                          AsyncSnapshot fff) {
                                                        final String fileSize =
                                                            fff.data ?? '';

                                                        if (fileSize != '') {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12),
                                                            child: Text(
                                                              fileSize,
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      12.0),
                                                            ),
                                                          );
                                                        } else {
                                                          return const SizedBox();
                                                        }
                                                      })
                                                ].reversed.toList(),
                                              ),
                                              onTap: () async {
                                                bool isDownloaded = await context
                                                    .read<
                                                        ExternalLibrariesCubit>()
                                                    .pdfFileIsDownloaded(
                                                        libraryResource.title!,
                                                        libraryResource
                                                            .fileSize!);
                                                print(
                                                    "isDownloaded: $isDownloaded");
                                                if (isDownloaded) {
                                                  await ctx
                                                      .read<
                                                          ExternalLibrariesCubit>()
                                                      .openFileExternal(
                                                          context,
                                                          libraryResource
                                                              .title!);
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
    context
        .read<ExternalLibrariesCubit>()
        .deleteAndDownloadUpdatedFile(libraryResource, context);
  }
}
