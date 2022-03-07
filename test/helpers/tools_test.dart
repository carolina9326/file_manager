import 'dart:io';
import 'dart:math';

import 'package:file_manager/helpers/tools.dart';
import 'package:test/test.dart';

void main() {
  test('rm file', () async {
    var rng = Random();
    int random = rng.nextInt(100);
    var resultCmd = await Process.run('touch', ['file$random.txt']);

    assert(resultCmd.exitCode == 0);

    var tools = Tools();

    var result = await tools.crud(OPERATION.rm, 'file$random.txt');

    assert(result);

    random++;
    result = await tools.crud(OPERATION.rm, 'file$random.txt');

    assert(!result);
  });

  test('rm folder', () async {
    var rng = Random();
    int random = rng.nextInt(100);
    var resultCmd = await Process.run('mkdir', ['f$random']);

    assert(resultCmd.exitCode == 0);

    var tools = Tools();

    var result = await tools.crud(OPERATION.rm, 'f$random', isFile: false);

    assert(result);
  });
}
