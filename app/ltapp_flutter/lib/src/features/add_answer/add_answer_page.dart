import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';

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
    if (!_isSubmitEnabled != isNotEmpty) {
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
            children: [
              _buildCardHeaderSection(),
              _buildRefreshButton(),
              _buildInputSection(),
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
    return SizedBox();
  }

  Widget _buildRefreshButton() {
    return SizedBox();
  }

  Widget _buildInputSection() {
    return SizedBox();
  }

  Widget _buildSubmitButton() {
    return SizedBox();
  }
}
