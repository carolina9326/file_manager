import 'dart:io';
import 'package:path/path.dart';

enum OPERATION { cp, mv, rm }

class PathFile {
  final String path;
  final String absolutePath;
  final bool isFile;
  final String name;
  final String parent;
  PathFile(
      {required this.path,
      required this.name,
      required this.absolutePath,
      this.isFile = true,
      required this.parent});
}

class PathFolder {
  final List<PathFile> pathFiles;
  final String parent;
  PathFolder({required this.pathFiles, required this.parent});
}

class Tools {
  Future<bool> crud(OPERATION op, String path,
      {bool isFile = true, String? path2}) async {
    List<String> parameters = [];
    String cmd = 'cp';

    if (!isFile && op != OPERATION.mv) {
      parameters.add('-r');
    }

    parameters.add(path);

    if (op == OPERATION.cp || op == OPERATION.mv) {
      cmd = (op == OPERATION.cp) ? 'cp' : 'mv';

      parameters.add(path2!);
    }

    if (op == OPERATION.rm) {
      cmd = 'rm';
    }

    var result = await Process.run(cmd, parameters);

    if (result.exitCode != 0) {
      return false;
    }

    return true;
  }

  PathFolder readFilesFolders(String? path) {
    final dir = Directory(path ?? '');

    List<PathFile> paths = [];

    String parent = dir.absolute.path;

    for (FileSystemEntity f in dir.listSync()) {
      PathFile path;

      String filename = basename(f.path);

      if (f is File) {
        path = PathFile(
            path: f.path,
            absolutePath: f.absolute.path,
            name: filename,
            parent: parent);
      }

      if (f is Directory) {
        path = PathFile(
            path: f.path,
            isFile: false,
            absolutePath: f.absolute.path,
            name: filename,
            parent: parent);
      } else {
        path = PathFile(
            path: f.path,
            absolutePath: f.absolute.path,
            name: filename,
            parent: parent);
      }

      paths.add(path);
    }

    return PathFolder(pathFiles: paths, parent: parent);
  }
}
