import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/allah_names.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class NinetyNineNames extends StatelessWidget {
  // Sample JSON data
  NinetyNineNames({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.namesOfAllah),
        leading: AppConstants.customBackButton(context),
      ),
      body: ListView.builder(
        itemCount: allahNames.length,
        itemBuilder: (context, index) {
          final item = allahNames[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Image.asset('assets/allah_names/${item["id"]}.png',
                        fit: BoxFit.contain),
                  ),
                ),

                const SizedBox(height: 8),
                // Text
                StyledText(description: item["description"] ?? ""),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StyledText extends StatelessWidget {
  final String description;

  const StyledText({required this.description, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split description into parts using <specialFont> tags
    final textSpans = <TextSpan>[];
    final regex = RegExp(r'<specialFont>(.*?)<\/specialFont>');
    description.splitMapJoin(
      regex,
      onMatch: (match) {
        textSpans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(
              fontFamily: AppStrings.uthmanyHafsV20fontFamily,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        );
        return '';
      },
      onNonMatch: (nonMatch) {
        textSpans.add(
          TextSpan(
            text: nonMatch,
            style: const TextStyle(
              fontFamily: AppStrings.scheherazadeNewRegular,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        );
        return '';
      },
    );

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}
