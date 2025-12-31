import 'package:flutter/material.dart';
import 'package:ltapp_flutter/src/core/ui_component/app_tabbar.dart';

class HomeView extends StatelessWidget {
  final Widget child;

  const HomeView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: AppTabbar(),
      ),
    );
  }
}
