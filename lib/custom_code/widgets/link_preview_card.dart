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

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:any_link_preview/any_link_preview.dart';

class LinkPreviewCard extends StatefulWidget {
  const LinkPreviewCard({
    Key? key,
    this.width,
    this.height,
    required this.url,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String url;

  @override
  _LinkPreviewCardState createState() => _LinkPreviewCardState();
}

class _LinkPreviewCardState extends State<LinkPreviewCard> {
  @override
  Widget build(BuildContext context) {
    return AnyLinkPreview(
      link: widget.url,
      displayDirection: UIDirection.uiDirectionVertical,
      showMultimedia: true,
      bodyMaxLines: 3,
      bodyTextOverflow: TextOverflow.ellipsis,
      titleStyle: TextStyle(
        color: const Color.fromARGB(255, 255, 255, 255),
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      bodyStyle: TextStyle(color: Colors.grey, fontSize: 12),
      errorBody: 'Could not load preview',
      errorTitle: 'Error',
      errorWidget: SizedBox.shrink(), // Returns nothing if it fails
      cache: Duration(days: 7),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      borderRadius: 12,
      removeElevation: false,
      boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
    );
  }
}
