import 'package:AccuChat/utils/backappbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlViewer extends StatelessWidget {
  final String htmlContent;
  const HtmlViewer({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backAppBar(),
      body: SingleChildScrollView(
        child: Html(
          data: htmlContent,
        ),
      ),
    );
  }
}
