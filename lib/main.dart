import 'dart:developer';

import 'package:file_manager/file_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'helpers/tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<PathFile> paths = [];
  var tools = Tools();
  List<BreadCrumbs> breadList = [];
  late PathFolder folder;
  late Map<String, PathFile> selections;
  String? _currentPath;
  OPERATION? _operation;

  @override
  void initState() {
    super.initState();

    folder = tools.readFilesFolders(_currentPath);
    paths = folder.pathFiles;
    selections = <String, PathFile>{};
  }

  void _incrementCounter() async {
    bool result = await tools
        .crud(OPERATION.rm, '/home/carolina/Templates/carpeta4', isFile: false);

    print(result);

    // List<String> parameters = [];

    // parameters.add('/home/carolina/Templates/archivo3.txt');

    // var model = await tools.runCommand('rm', parameters);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    breadList.clear();
    String bread = folder.parent;
    List<String> breadPath = [];

    // /home/carolina/desarrollo/file_manager/windows
    // /home
    var breads = bread.split('/');

    for (var b in breads.skip(1)) {
      if (b == '.') continue;

      breadPath.add('/');
      breadPath.add(b);
      var breadPathString = breadPath.join('');
      var breadElement = BreadCrumbs(
        text: b,
        path: breadPathString,
        openFolder: (path) {
          setState(() {
            _currentPath = breadPathString;
            folder = tools.readFilesFolders(_currentPath);
            paths = folder.pathFiles;
          });
        },
      );
      breadList.add(breadElement);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Row(
            children: breadList,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () async {
                    _operation = OPERATION.cp;
                  },
                  child: Icon(Icons.copy)),
              TextButton(
                  onPressed: () async {
                    if (_operation == null) return;

                    if (selections.entries.isEmpty) return;
                    String? parent;
                    for (var s in selections.values) {
                      parent = s.parent;
                      await tools.crud(_operation!, s.absolutePath,
                          isFile: s.isFile, path2: _currentPath);
                    }

                    selections.clear();

                    setState(() {
                      folder = tools.readFilesFolders(_currentPath);
                      paths = folder.pathFiles;
                    });

                    _operation = null;
                  },
                  child: Icon(Icons.paste)),
              TextButton(
                  onPressed: () async {
                    _operation = OPERATION.mv;
                    print(_currentPath);
                  },
                  child: Icon(Icons.cut)),
              TextButton(
                  onPressed: () async {
                    if (selections.entries.isEmpty) return;
                    String? parent;
                    for (var s in selections.values) {
                      parent = s.parent;
                      await tools.crud(OPERATION.rm, s.absolutePath,
                          isFile: s.isFile);
                    }

                    selections.clear();

                    setState(() {
                      folder = tools.readFilesFolders(_currentPath);
                      paths = folder.pathFiles;
                    });
                  },
                  child: Icon(Icons.delete)),
            ],
          ),
          Expanded(
            child: GridView.count(
                childAspectRatio: 5,
                crossAxisCount: 3,
                children: List.generate(paths.length, (index) {
                  var p = paths[index];

                  return Center(
                    child: FileWidget(
                      key: Key(const Uuid().v4().toString()),
                      pathFile: p,
                      openFolder: () {
                        _currentPath = p.absolutePath;
                        setState(() {
                          folder = tools.readFilesFolders(_currentPath);
                          paths = folder.pathFiles;
                        });
                      },
                      operation: (isSelected) {
                        if (isSelected) {
                          selections.putIfAbsent(p.absolutePath, () => p);
                        } else {
                          selections.remove(p.absolutePath);
                        }

                        print(selections.entries.toList());
                      },
                    ),
                  );
                })),
            flex: 9,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
