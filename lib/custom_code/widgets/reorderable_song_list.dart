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

class ReorderableSongList extends StatefulWidget {
  final List<String> songs;
  final double width;
  final double height;

  const ReorderableSongList(
      {Key? key,
      required this.songs,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  _ReorderableSongListState createState() => _ReorderableSongListState();
}

class _ReorderableSongListState extends State<ReorderableSongList> {
  late List<String> _songs;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.songs);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ReorderableListView(
          children: [
            for (final song in _songs)
              ListTile(
                key: ValueKey(song),
                title: Text(song),
                trailing: const Icon(Icons.drag_handle),
              )
          ],
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = _songs.removeAt(oldIndex);
              _songs.insert(newIndex, item);
            });
          },
        ));
  }
}
