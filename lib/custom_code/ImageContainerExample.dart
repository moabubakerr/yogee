import 'package:flutter/material.dart';

class ImageContainerExample extends StatelessWidget {
  const ImageContainerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image in Container")),
      body: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/sample.jpg'),
              fit: BoxFit.cover, // Adjust how the image fits
            ),
          ),
        ),
      ),
    );
  }
}
