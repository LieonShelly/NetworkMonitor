import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:lt_reflection_service/reflection_service.dart';
import 'package:feature_core/feature_core.dart';

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
  bool _isImageReady = false;
  bool _isTansitionCompleted = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.animation != null) {
      if (route.animation!.status == AnimationStatus.completed) {
        _isTansitionCompleted = true;
      } else {
        route.animation!.addStatusListener(_handleRouteAnimationStatus);
      }
    }
  }

  void _handleRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isTansitionCompleted = true;
      _checkAndStartAnimation();
    }
  }

  void _checkAndStartAnimation() {
    if (_isImageReady && _isTansitionCompleted && !_hasTiggeredAnimation) {
      if (context.mounted) {
        _controller.forward();
        _hasTiggeredAnimation = true;
      }
    }
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
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFDF8), Color(0xFFFFFDF8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
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
    final icon = ProcessedIconView(
      imageUrl: widget.answer.icon?.url ?? "",
      width: double.infinity,
      height: 300,
      placeholder: const SizedBox(height: 100),
      herTag: 'answer_icon_${widget.answer.id}',
      onImageLoaded: () {
        if (!_hasTiggeredAnimation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _isImageReady = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                _checkAndStartAnimation();
              });
            }
          });
        }
      },
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 50),
      child: icon,
    );
  }

  Widget _buildQuestionView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.answer.question?.title ?? "",
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
