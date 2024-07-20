

import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;

  ExpandableText({required this.text});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: isExpanded ? null : 2,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? 'See less' : 'See more',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}