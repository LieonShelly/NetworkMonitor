import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTabbar extends StatelessWidget {
  const AppTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    return Container(
      width: 280,
      height: 72,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabbarItem(
            context,
            Icons.calendar_today_outlined,
            '/calendar',
            location,
          ),
          _buildTabbarItem(context, Icons.all_inclusive, '/thread', location),
          _buildTabbarItem(
            context,
            Icons.lightbulb_outline,
            '/insights',
            location,
          ),
          _buildTabbarItem(context, Icons.person_outline, '/user', location),
        ],
      ),
    );
  }

  Widget _buildTabbarItem(
    BuildContext context,
    IconData icon,
    String targetPath,
    String currentPath,
  ) {
    final bool isActive = targetPath == currentPath;
    return IconButton(
      onPressed: () {
        context.go(targetPath);
      },
      icon: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        size: 28,
      ),
    );
  }
}
