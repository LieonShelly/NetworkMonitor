import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/theme/theme.dart';

class ThreadPage extends ConsumerStatefulWidget {
  const ThreadPage({super.key});

  @override
  ConsumerState<ThreadPage> createState() {
    return _ThreadPageState();
  }
}

class _ThreadPageState extends ConsumerState<ThreadPage> {
  @override
  Widget build(BuildContext context) {
    final page = _buildScrollContentView();

    return Scaffold(body: page, appBar: _buildHeaderView());
  }

  PreferredSizeWidget _buildHeaderView() {
    return AppBar(
      backgroundColor: Color(0xFFFFF8F8),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        "Thread",
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 32,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildScrollContentView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(),
    );
  }
}
