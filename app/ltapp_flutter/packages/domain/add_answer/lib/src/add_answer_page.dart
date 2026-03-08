import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:intl/intl.dart';
import 'add_answer_controller.dart';
import 'package:lt_reflection_service/reflection_service.dart';

class AddAnswerPage extends ConsumerStatefulWidget {
  final List<QuestionModel> questions;
  const AddAnswerPage({super.key, required this.questions});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddAnswerPageState();
  }
}

class _AddAnswerPageState extends ConsumerState<AddAnswerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSubmitEnabled = false;

  late List<QuestionModel> _displayQuestions;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_onTextChanged);
    _displayQuestions = List.from(widget.questions);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, -0.5)).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotateQuestions();
        _animationController.reset();
      }
    });
  }

  void _rotateQuestions() {
    setState(() {
      if (_displayQuestions.isNotEmpty) {
        final first = _displayQuestions.removeAt(0);
        _displayQuestions.add(first);
      }
    });
  }

  void _onSwithCard() {
    if (_animationController.isAnimating || _displayQuestions.isEmpty) return;
    _animationController.forward();
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isNotEmpty = _textEditingController.text.trim().isNotEmpty;
    if (_isSubmitEnabled != isNotEmpty) {
      setState(() {
        _isSubmitEnabled = isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addAnswerControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${next.error}')));
      } else if (next is AsyncData && !next.isLoading) {
        if (mounted) {
          context.pop();
        }
      }
    });
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildCardSection(),
              _buildRefreshButton(),
              Expanded(child: _buildInputSection()),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final now = DateTime.now();
    final format = DateFormat.MMMd('en_US');
    final dateStr = format.format(now);
    return AppBar(
      backgroundColor: Color(0xFFFFFDF8),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        dateStr,
        style: AppTextStyle.poppins(color: Color(0xFF423d3d), fontSize: 12),
      ),
    );
  }

  double _getCardAngle(int index) {
    switch (index) {
      case 0:
        return 0.0;
      case 1:
        return -0.06;
      case 2:
        return 0.06;
      default:
        return 0.0;
    }
  }

  Widget _buildCardSection() {
    final questions = _displayQuestions;
    if (questions.isEmpty) return const SizedBox();
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final int visibleCount = questions.length > 3 ? 3 : questions.length;
        List<Widget> stackChildren = [];
        for (int index = visibleCount - 1; index >= 0; index--) {
          final question = questions[index];
          double currentAngle;
          if (index == 0) {
            currentAngle = 0;
          } else {
            double startAngle = _getCardAngle(index);
            double targetAngle = _getCardAngle(index - 1);
            currentAngle =
                lerpDouble(
                  startAngle,
                  targetAngle,
                  _animationController.value,
                ) ??
                0.0;
          }
          Widget card = Transform.rotate(
            angle: currentAngle,
            key: ValueKey(question.id),
            child: _buildCardView(question),
          );
          if (index == 0) {
            card = GestureDetector(
              onTap: _onSwithCard,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(scale: _scaleAnimation, child: card),
                ),
              ),
            );
          }
          stackChildren.add(card);
        }
        return Stack(children: stackChildren);
      },
    );
  }

  Widget _buildCardView(QuestionModel question) {
    final categoryTitle = question.category.name;
    final contaienr = Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFAEE),
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: Color(0xFF717171), width: 1),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFFFFDF8),
                borderRadius: BorderRadius.circular(100),
                border: BoxBorder.all(width: 1, color: Color(0xFFEBEBEB)),
              ),
              child: Text(
                '#$categoryTitle',
                style: AppTextStyle.poppins(
                  fontSize: 10,
                  color: Color(0xff000000),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 20,
            ),
            child: Text(
              question.title,
              textAlign: TextAlign.center,
              style: AppTextStyle.vividlyRegular(
                fontSize: 36,
                color: Color(0xFF000000),
                height: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      child: contaienr,
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: _onSwithCard,
      icon: SvgAsset(IconName.refresh),
    );
  }

  Widget _buildInputSection() {
    final textField = TextField(
      controller: _textEditingController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: AppTextStyle.poppins(color: Color(0xff000000), fontSize: 12),
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        focusColor: Color(0xff000000),
        hint: Text(
          'Write anything....',
          style: AppTextStyle.poppins(fontSize: 12, color: Color(0xFF6F6F6F)),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(width: 1, color: Color(0xFFEBEBEB)),
        ),
        child: textField,
      ),
    );
  }

  Widget _buildSubmitButton() {
    final submitState = ref.watch(addAnswerControllerProvider);
    final isLoading = submitState.isLoading;
    return Container(
      width: double.infinity,
      height: 62,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ElevatedButton(
        onPressed: (_isSubmitEnabled && !isLoading) ? _onSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF000000),
          disabledBackgroundColor: const Color(0xFF9D9D9D),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'OK',
          style: AppTextStyle.feltTipSeniorRegular(
            fontSize: 32,
            color: (_isSubmitEnabled && !isLoading)
                ? Colors.white
                : Color(0xFF000000),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final content = _textEditingController.text.trim();
    if (content.isEmpty) return;
    if (_displayQuestions.isEmpty) return;
    ref
        .read(addAnswerControllerProvider.notifier)
        .submitAnswer(questionId: _displayQuestions[0].id, content: content);
  }
}
