import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;

  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  static const TextStyle textStyle = TextStyle(fontFamily: 'Space Grotesk', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF252525));

  @override
  Widget build(BuildContext context) {
    final bool shouldShowButton = _shouldShowButton(widget.text, textStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AbsorbPointer(
          absorbing: (!isExpanded && shouldShowButton) || !shouldShowButton,
          child: InkWell(
            onTap: () => setState(() => isExpanded = false),
            child: Text(widget.text, style: textStyle, maxLines: isExpanded ? null : 3, overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(height: 4),
        if (shouldShowButton && !isExpanded)
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              color: const Color(0xFFF3F3F3),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Container(width: 2, color: const Color(0xFF000000), margin: const EdgeInsets.only(right: 8)), Text('view more...', style: textStyle)],
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _shouldShowButton(String text, TextStyle style) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(text: span, maxLines: 3, textDirection: TextDirection.ltr)..layout(maxWidth: MediaQuery.of(context).size.width);
    return tp.didExceedMaxLines;
  }
}
