import 'package:flutter/material.dart';
import 'dart:io';

class FolderExplorerPage extends StatefulWidget {
  final String folderPath; //selectedDirectory from main menu

  const FolderExplorerPage({super.key, required this.folderPath});

  @override
  State<FolderExplorerPage> createState() => _FolderExplorerPageState();
}

class _FolderExplorerPageState extends State<FolderExplorerPage> {
  late int selectedProjectIndx;
  late List<Directory> projectDirectories;

  Map<String, bool> selectedFiles = {};

  @override
  void initState() {
    super.initState();
    projectDirectories = [Directory(widget.folderPath)];
    selectedProjectIndx = 0;
  }

  String getDirectoryName(Directory dir){
    return dir.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);
  }
  List<Widget> getProjectsWidgets(){
    return projectDirectories.map((item) => ListTile(
              leading: const Icon(Icons.folder),
              title: Text(getDirectoryName(item)),
              onTap: () {
                // Handle project tap
                Navigator.of(context).pop(); // Close the drawer
              },
            )
          ).toList();
  }
  Directory getSelectedDir(){
    return projectDirectories[selectedProjectIndx];
  }

  @override
  Widget build(BuildContext context) {
    final projectsWidgets = getProjectsWidgets();

    return Scaffold(
      appBar: AppBar(
        title: Text(getSelectedDir().path.split(Platform.pathSeparator).last),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'My Projects',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...projectsWidgets,
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'File Explorer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ..._buildDirList(getSelectedDir()),
          ],
        ),
      ),
      body: const Center(
        child: Text('Select a folder or file from the drawer.'),
      ),
    );
  }

List<Widget> _buildDirList(Directory dir) {
  List<FileSystemEntity> dirContents;
  List<Widget> tiles = [];

  try {
    dirContents = dir.listSync();
  } on FileSystemException {
    // Skip this directory if we don't have permission to access it
    return [];
  }

  for (var entity in dirContents) {
    bool isDir = FileSystemEntity.isDirectorySync(entity.path);
    String name = entity.path.split(Platform.pathSeparator).last;

    if (isDir) {
      try {
        tiles.add(
          ExpansionTile(
            key: PageStorageKey<String>(entity.path),
            title: Text(name),
            leading: const Icon(Icons.folder),
            children: _buildDirList(Directory(entity.path)),
          ),
        );
      } on FileSystemException {
        // If we don't have permission to access the directory, don't add it to the list
        continue;
      }
    } else {
      tiles.add(
        ListTile(
          title: Text(name),
          leading: Icon(
            selectedFiles[entity.path] == true
                ? Icons.check_circle
                : Icons.check_circle_outline,
          ),
          onTap: () {
            setState(() {
              // Toggle file selection
              selectedFiles[entity.path] = !(selectedFiles[entity.path] ?? false);
            });
          },
        ),
      );
    }
  }
  return tiles;
}

}
