import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'thread_page_controller.dart';

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
    final questions =
        ref.watch(
          threadPageControllerProvider.select((e) => e.questions.value),
        ) ??
        [];
    List<Widget> sections = [];
    for (final question in questions) {
      final text = Text(
        question.title,
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 24,
          color: Color(0xFF000000),
        ),
      );
      sections.add(text);
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(children: sections),
    );
  }
}
