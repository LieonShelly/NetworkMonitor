import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';

class AppTabbar extends StatelessWidget {
  const AppTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabbarItem(
          context,
          Icons.calendar_today_outlined,
          '/calendar',
          location,
          IconName.calendar,
          IconName.deselectedCalendar,
        ),
        _buildTabbarItem(
          context,
          Icons.all_inclusive,
          '/thread',
          location,
          IconName.threads,
          IconName.deselectedThread,
        ),
        _buildTabbarItem(
          context,
          Icons.lightbulb_outline,
          '/insights',
          location,
          IconName.insights,
          IconName.deselectedInsights,
        ),
        _buildTabbarItem(
          context,
          Icons.person_outline,
          '/user',
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
        context.go(targetPath);
      },
      icon: isActive
          ? SvgAsset(activeIcon, width: 40, height: 40)
          : SvgAsset(inActiveIcon, width: 40, height: 40),
    );
  }
}
