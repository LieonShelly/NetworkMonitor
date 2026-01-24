import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/theme/theme.dart';
import 'package:ltapp_flutter/src/core/ui_component/uicomponent.dart';

class AddAnswerPage extends ConsumerStatefulWidget {
  const AddAnswerPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddAnswerPageState();
  }
}

class _AddAnswerPageState extends ConsumerState<AddAnswerPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildCardHeaderSection(),
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
    return AppBar(
      backgroundColor: Color(0xFFFFFDF8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'September 18',
        style: AppTextStyle.poppins(color: Color(0xFF423d3d), fontSize: 12),
      ),
    );
  }

  Widget _buildCardHeaderSection() {
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
                '#Simple joys',
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
              "What small moment of peace did you experience today?",
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
    return IconButton(onPressed: () {}, icon: SvgAsset(IconName.refresh));
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
    return Container(
      width: double.infinity,
      height: 62,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ElevatedButton(
        onPressed: _isSubmitEnabled ? () {} : null,
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
            color: _isSubmitEnabled ? Colors.white : Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}
