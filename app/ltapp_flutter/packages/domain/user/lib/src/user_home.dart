import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feature_core/feature_core.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() {
    return _UserHomePageState();
  }
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildListView()),
      appBar: _buildHeaderView(),
    );
  }

  PreferredSizeWidget _buildHeaderView() {
    return AppBar(
      title: Text(
        "User",
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 32,
          color: const Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return _buildItem("Chat", () {
          context.push(AppRoutePath.chat);
        });
      },
    );
  }

  Widget _buildItem(String title, VoidCallback action) {
    final containter = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.black87, fontSize: 16.0),
      ),
    );
    return GestureDetector(onTap: action, child: containter);
  }
}
