// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkifyText extends StatefulWidget {
  const LinkifyText({
    Key? key,
    this.width,
    this.height,
    required this.text,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String text;

  @override
  _LinkifyTextState createState() => _LinkifyTextState();
}

class _LinkifyTextState extends State<LinkifyText> {
  @override
  Widget build(BuildContext context) {
    // We ignore widget.height here entirely to allow dynamic expansion
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink-wraps the height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableLinkify(
            onOpen: (link) async {
              if (!await launchUrl(Uri.parse(link.url))) {
                throw Exception('Could not launch ${link.url}');
              }
            },
            text: widget.text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).info,
                  useGoogleFonts: false,
                ),
            linkStyle: TextStyle(
              color: FlutterFlowTheme.of(context).primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
