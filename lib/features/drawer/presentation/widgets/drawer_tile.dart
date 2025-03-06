part of 'moshaf_drawer.dart';

class _DrawerVerticalSpacer extends StatelessWidget {
  const _DrawerVerticalSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: DrawerConstants.hh,
      height: DrawerConstants.hh,
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    super.key,
    required this.text,
    required this.iconAsset,
    this.onTap,
    this.removeDarkModeFromIcon = false,
    this.svgIconLink = false,
  });
  final String text, iconAsset;
  final VoidCallback? onTap;
  final bool removeDarkModeFromIcon;
  final bool svgIconLink;

  Color? _getDrawerIconColor(BuildContext context) {
    if (!removeDarkModeFromIcon) {
      if (context.theme.brightness == Brightness.dark) {
        return Colors.white;
      } else {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              style: DrawerConstants.drawerTextStyle(),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          svgIconLink
              ? SvgPicture.asset(
                  iconAsset,
                  height: 32,
                  color: _getDrawerIconColor(context),
                )
              : Image.asset(
                  iconAsset,
                  height: 32,
                  color: _getDrawerIconColor(context),
                ),
        ],
      ),
    );
  }
}
