import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/features/playlist/presentation/widgets/playlist_tile.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/constants.dart';

class Playlist extends StatefulWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.playlist),
        leading: AppConstants.customBackButton(context),
      ),
      body: Column(
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
          const Expanded(child: PlaylistTile()),
        ],
      ),
    );
  }
}
