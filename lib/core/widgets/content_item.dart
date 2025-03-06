import 'package:flutter/material.dart';

class ContentItem extends StatelessWidget {
  final String title;
  final String body;
  final bool isLeftAligned;
  const ContentItem({
    super.key,
    required this.title,
    required this.body,
    this.isLeftAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isLeftAligned ? TextDirection.ltr : TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 5,
          ),
          //content as text
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
