import 'package:flutter/material.dart';

import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../screens/quran_fihris_screen.dart';
import 'fihris_list_body.dart';

class SwarList extends StatelessWidget {
  const SwarList({
    Key? key,
    this.onTapFihrisItem,
  }) : super(key: key);
  final Function(int)? onTapFihrisItem;

  @override
  Widget build(BuildContext context) {
    return FihrisListBody(
      onTapFihrisItem: onTapFihrisItem,
      fihrisItems: EssentialMoshafCubit.get(context).swarListForFihris,
      fihrisType: FihrisTypes.SWAR,
    );
  }
}

class AhzabList extends StatelessWidget {
  const AhzabList({
    Key? key,
    this.onTapFihrisItem,
  }) : super(key: key);
  final Function(int)? onTapFihrisItem;

  @override
  Widget build(BuildContext context) {
    return FihrisListBody(
      onTapFihrisItem: onTapFihrisItem,
      fihrisItems: EssentialMoshafCubit.get(context).ahzabListForFihris,
      fihrisType: FihrisTypes.AHZAB,
    );
  }
}

class AjzaaList extends StatelessWidget {
  const AjzaaList({
    Key? key,
    this.onTapFihrisItem,
  }) : super(key: key);
  final Function(int)? onTapFihrisItem;

  @override
  Widget build(BuildContext context) {
    return FihrisListBody(
      onTapFihrisItem: onTapFihrisItem,
      fihrisItems: EssentialMoshafCubit.get(context).ajzaaListForFihris,
      fihrisType: FihrisTypes.AJZAA,
    );
  }
}
