import 'package:flutter/material.dart';

import 'helpers/tools.dart';

class FileWidget extends StatefulWidget {
  final PathFile pathFile;
  final Function(bool) operation;
  final Function() openFolder;
  const FileWidget(
      {Key? key,
      required this.pathFile,
      required this.openFolder,
      required this.operation})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FileWidget();
  }
}

class _FileWidget extends State<FileWidget> {
  late Color _color;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _color = Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    Icon icon;

    if (widget.pathFile.isFile) {
      icon = const Icon(
        Icons.insert_drive_file,
        color: Colors.black,
        size: 25,
      );
    } else {
      icon = const Icon(Icons.folder, color: Colors.black, size: 25);
    }

    return GestureDetector(
      onTap: () {
        if (_isSelected) {
          widget.operation(false);
          _isSelected = false;
          setState(() {
            _color = Colors.transparent;
          });

          return;
        }

        widget.operation(true);
        _isSelected = true;
        setState(() {
          _color = Colors.black38;
        });
      },
      onDoubleTap: () {
        if (widget.pathFile.isFile) {
          return;
        }

        widget.openFolder();
      },
      child: Container(
        color: _color,
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          children: [icon, Text(widget.pathFile.name)],
        ),
      ),
    );
  }
}

class BreadCrumbs extends StatelessWidget {
  final String text;
  final String path;
  final Function(String path) openFolder;
  const BreadCrumbs(
      {Key? key,
      required this.text,
      required this.path,
      required this.openFolder})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          openFolder(path);
        },
        child: Text(text));
  }
}
