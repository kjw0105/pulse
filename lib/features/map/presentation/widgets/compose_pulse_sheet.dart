import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/pulse_post.dart';

class ComposePulseSheet extends StatefulWidget {
  const ComposePulseSheet({required this.onSubmit, super.key});

  final Future<bool> Function(String message) onSubmit;

  @override
  State<ComposePulseSheet> createState() => _ComposePulseSheetState();
}

class _ComposePulseSheetState extends State<ComposePulseSheet> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _textController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final submitted = await widget.onSubmit(_textController.text);
    if (!mounted) return;
    if (submitted) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '지금의 마음은 어떤가요?',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          const Text(
            '이 근처의 누군가에게 익명으로 한 문장을 남겨요.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            autofocus: true,
            maxLength: PulsePost.maxMessageLength,
            maxLines: 2,
            minLines: 1,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              LengthLimitingTextInputFormatter(PulsePost.maxMessageLength),
            ],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '오늘도 잘 버텼어',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.055),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0x66B6FF69)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _textController.text.trim().isEmpty || _isSubmitting
                  ? null
                  : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB6FF69),
                foregroundColor: const Color(0xFF11150D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '남기기',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
