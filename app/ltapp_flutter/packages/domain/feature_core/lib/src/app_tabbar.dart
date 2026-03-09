import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'app_route_path.dart';

class AppTabbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppTabbar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabbarItem(
          0,
          context,
          Icons.calendar_today_outlined,
          AppRoutePath.calendar,
          location,
          IconName.calendar,
          IconName.deselectedCalendar,
        ),
        _buildTabbarItem(
          1,
          context,
          Icons.all_inclusive,
          AppRoutePath.thread,
          location,
          IconName.threads,
          IconName.deselectedThread,
        ),
        _buildTabbarItem(
          2,
          context,
          Icons.lightbulb_outline,
          AppRoutePath.insights,
          location,
          IconName.insights,
          IconName.deselectedInsights,
        ),
        _buildTabbarItem(
          3,
          context,
          Icons.person_outline,
          AppRoutePath.user,
          location,
          IconName.user,
          IconName.deselectedUser,
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(left: 40, right: 40),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: row,
      ),
    );
  }

  Widget _buildTabbarItem(
    int index,
    BuildContext context,
    IconData icon,
    String targetPath,
    String currentPath,
    IconName activeIcon,
    IconName inActiveIcon,
  ) {
    final bool isActive = targetPath == currentPath;
    return IconButton(
      onPressed: () {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      icon: isActive
          ? SvgAsset(activeIcon, width: 40, height: 40)
          : SvgAsset(inActiveIcon, width: 40, height: 40),
    );
  }
}
