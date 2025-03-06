import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/utils/slide_pagee_transition.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/screens/playlist.dart';
import 'package:qeraat_moshaf_kwait/features/surah/data/models/reciter_model.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/cubit/reciters_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/surah/presentation/screens/surah_list_screen.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../playlist/presentation/widgets/playlist_tile.dart';
import '../cubit/surah_listen_cubit.dart';

class SoorahRecitersListScreen extends StatefulWidget {
  const SoorahRecitersListScreen({Key? key}) : super(key: key);

  @override
  State<SoorahRecitersListScreen> createState() =>
      _SoorahRecitersListScreenState();
}

class _SoorahRecitersListScreenState extends State<SoorahRecitersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(context.translate.reciters),
        leading: AppConstants.customBackButton(context),
        actions: [
          IconButton(
            onPressed: () {
              pushSlide(context, screen: const Playlist());
            },
            icon: const Icon(Icons.playlist_add_check),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: double.maxFinite,
            child: SvgPicture.asset(
              AppAssets.surahBannerSvg,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 10),
          const PlaylistTile(shrinkSize: true),
          Expanded(
            child: ListView.separated(
              itemCount: 1,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildSheikhOptions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheikhOptions() {
    return BlocConsumer<RecitersCubit, RecitersState>(
      listener: (context, state) {
        if (state is RecitersAvailability) {
          RecitersCubit.get(context).resetState();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.translate.reciterAvailableSoon)),
          );
        }
        if (state is ChangeCurrentReciterState) {
          RecitersCubit.get(context).resetState();

          pushSlide(context,
              screen: SurahListScreen(
                name: context.translate.localeName == AppStrings.arabicCode
                    ? state.currentReciter.nameArabic!
                    : state.currentReciter.nameEnglish!,
                currentReciter: state.currentReciter.allowedReciters ?? "",
                reciterArabicName: state.currentReciter.nameArabic!,
                reciterEnglishName: state.currentReciter.nameEnglish!,
                image: state.currentReciter.photo!,
              ));
        }
      },
      builder: (context, state) {
        var cubit = RecitersCubit.get(context);
        var surahCubit = context.watch<SurahListenCubit>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (ReciterModel reciter in cubit.recitersList)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      onTap: () {
                        cubit.selectReciter(reciter);
                      },
                      dense: true,
                      title: Text(
                        context.translate.localeName == AppStrings.englishCode
                            ? reciter.nameEnglish.toString()
                            : reciter.nameArabic.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(reciter.photo.toString()),
                      ),
                      trailing: surahCubit.isReciterCurrentlyPlaying(
                        reciter.allowedReciters!,
                      )
                          ? Text(
                              context.translate.nowPlaying,
                              style: context.textTheme.bodySmall!.copyWith(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              )
          ],
        );
      },
    );
  }
}
