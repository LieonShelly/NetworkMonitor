import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/core.dart';
import 'package:ltapp_flutter/src/service/dto/dto_model.dart';

class AnswerDetailPage extends ConsumerWidget with ImageCacheKeyType {
  final AnswerModel answer;
  const AnswerDetailPage({super.key, required this.answer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildHeader(), _buildIconView()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 75,
      child: Center(
        child: Text(
          "September 18 ",
          style: AppTextStyle.poppins(color: Color(0xff423d3d), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildIconView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 50),
      child: CachedNetworkImage(
        imageUrl: answer.icon?.url ?? "",
        cacheKey: answer.icon?.url,
      ),
    );
  }
}
