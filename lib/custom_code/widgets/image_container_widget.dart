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
// import 'package:flutter/material.dart';

class ImageContainerWidget extends StatelessWidget {
  const ImageContainerWidget({
    super.key,
    this.borderRadius = 16.0,
    this.width = 200,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  //String imageUrl="https://firebasestorage.googleapis.com/v0/b/novelhub-imai.firebasestorage.app/o/001c840f-6f66-454d-892d-0727262ed1d5.jpg?alt=media&token=62543f16-f665-4d7b-9ca6-48b1da0349ce"; // URL or asset path
  final double borderRadius;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(
            image:
                // imageUrl != null
                //     ? (imageUrl!.startsWith('http')
                NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/yoogeeapp.firebasestorage.app/o/Square%20(1).png?alt=media&token=5932f151-5360-49cd-be97-d44d0390d9cb"),
            //  : AssetImage(imageUrl!) as ImageProvider)
            //: const AssetImage('assets/images/play.png'),
            fit: fit,
          )),
    );
  }
}
