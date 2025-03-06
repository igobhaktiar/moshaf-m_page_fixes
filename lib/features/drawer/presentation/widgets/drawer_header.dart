part of 'moshaf_drawer.dart';

class _MoshafDrawerHeader extends StatelessWidget {
  const _MoshafDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            DrawerConstants.drawerHeaderBackground,
          ),
          fit: BoxFit
              .cover, // This will cover the entire space of the _MoshafDrawerHeader
        ),
      ),
      child: Center(
        child: Image.asset(
          DrawerConstants.drawerLogo,
        ), // Correct way to use an image as a child
      ),
    );
  }
}
