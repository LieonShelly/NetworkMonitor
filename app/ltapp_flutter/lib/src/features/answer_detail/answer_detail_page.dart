import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/core.dart';
import 'package:ltapp_flutter/src/core/theme/theme.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
import 'package:ltapp_flutter/src/service/dto/dto_model.dart';

class AnswerDetailPage extends ConsumerStatefulWidget with ImageCacheKeyType {
  final AnswerModel answer;
  const AnswerDetailPage({super.key, required this.answer});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AnswerDetailPageState();
  }
}

class _AnswerDetailPageState extends ConsumerState<AnswerDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleYAnimation;
  bool _hasTiggeredAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleYAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildQuestionView(),
            _buildContentView(),
            _buildBottomView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView() {
    return Expanded(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [_buildIconView(context), _buildAnswerContentView()],
          ),
          _buildCoverView(),
        ],
      ),
    );
  }

  Widget _buildCoverView() {
    return AnimatedBuilder(
      animation: _scaleYAnimation,
      builder: (context, child) {
        if (_scaleYAnimation.value == 0) {
          return const SizedBox.shrink();
        }
        return Transform(
          transform: Matrix4.diagonal3Values(1.0, _scaleYAnimation.value, 1.0),
          alignment: Alignment.bottomCenter,
          child: Container(color: Colors.red.withAlpha(100)),
        );
      },
    );
  }

  Widget _buildHeader() {
    final date = DateTime.parse(widget.answer.createdYmd);
    final fromat = DateFormat.MMMd('en_US');
    final dateStr = fromat.format(date);
    return SizedBox(
      height: 75,
      child: Center(
        child: Text(
          dateStr,
          style: AppTextStyle.poppins(color: Color(0xff423d3d), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildIconView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 50),
      child: CachedNetworkImage(
        imageUrl: widget.answer.icon?.url ?? "",
        cacheKey: widget.answer.icon?.url,
        imageBuilder: (context, imageProvider) {
          if (!_hasTiggeredAnimation) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                _controller.forward();
                _hasTiggeredAnimation = true;
              }
            });
          }
          return Image(image: imageProvider);
        },
        placeholder: (context, url) => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.answer.question.title,
        style: AppTextStyle.vividlyRegular(
          fontSize: 32,
          color: Color(0xff000000),
          height: 0.9,
        ),
      ),
    );
  }

  Widget _buildAnswerContentView() {
    final text = Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        widget.answer.content,
        style: AppTextStyle.poppins(fontSize: 14, color: Color(0xff323232)),
      ),
    );
    final container = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: Color(0xffebebeb)),
      ),
      child: text,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: container,
    );
  }

  Widget _buildBottomView(BuildContext context) {
    final container = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xEBEBEBEB),
      ),
      child: SvgAsset(IconName.close, width: 16, height: 16),
    );
    final padding = Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: container,
    );
    return GestureDetector(
      onTap: () {
        context.pop();
      },
      child: padding,
    );
  }
}
