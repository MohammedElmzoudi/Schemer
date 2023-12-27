import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'chatbox.dart';
import 'dart:io';

class ProjectDashboard extends StatefulWidget {
  final String folderPath; //selectedDirectory from main menu

  const ProjectDashboard({super.key, required this.folderPath});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  late int selectedProjectIndx;
  late List<Directory> projectDirectories;
  late List<String> projectNames;
  int? editingProjectIndex;
  late FocusNode renameFocusNode; // To ensure that the textfield for renaming automatically appears
  late Offset _tapPosition;
  Map<String, Set<String>> selectedFiles = {};
  Map<String, List<Map<String, dynamic>>> projectMessages = {};

  @override
  void initState() {
    super.initState();
    Directory initialDirectory = Directory(widget.folderPath);
    projectDirectories = [initialDirectory];
    projectNames = [getDirectoryName(initialDirectory)];
    selectedProjectIndx = 0;
    _tapPosition = Offset.zero;
    renameFocusNode = FocusNode();
  }
  @override
  void dispose() {
    renameFocusNode.dispose();
    super.dispose();
  }

  String getDirectoryName(Directory dir){
    return dir.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);
  }

  List<Widget> getProjectsWidgets() {
    return List<Widget>.generate(projectDirectories.length, (index) {
      bool isSelected = selectedProjectIndx == index;
      bool isEditing = editingProjectIndex == index;

      return GestureDetector(
        onSecondaryTapDown: (details) => _tapPosition = details.globalPosition,
        onSecondaryTap: () => isEditing ? null : _showContextMenu(context, index),
        onLongPress: () => isEditing ? null : _showContextMenu(context, index),
        child: Container(
          color: isSelected ? const Color.fromARGB(40, 1, 33, 105) : null,
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.chat : Icons.chat_bubble_outline,
            ),
            title: isEditing ? _buildEditProjectNameField(index) : Text(projectNames[index]),
            onTap: () {
              if (!isEditing) {
                setState(() {
                  selectedProjectIndx = index;
                });
                // Add/Retrieve messages for the selected project
                projectMessages.putIfAbsent(projectNames[index], () => <Map<String, dynamic>>[]);
                //Navigator.of(context).pop();
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildEditProjectNameField(int index) {
    TextEditingController controller = TextEditingController(text: projectNames[index]);

    return TextField(
      controller: controller,
      focusNode: renameFocusNode,
      autofocus: true,
      onSubmitted: (newName) {
        _renameProject(index, newName);
        setState(() {
          editingProjectIndex = null; // Stop editing mode
        });
      },
    );
  }


  void _renameProject(int projectIndex, String newName) {
    setState(() {
      projectNames[projectIndex] = newName;
    });
  }


  void _showContextMenu(BuildContext context, int projectIndex) {
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (overlay != null) {
      showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size // Bigger rect, the entire screen
        ),
        items: <PopupMenuEntry>[
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ).then((value) {
        if (value == 'rename') {
          setState(() {
            editingProjectIndex = projectIndex;
          });
          renameFocusNode.requestFocus();
        } else if (value == 'delete') {
          _deleteProject(projectIndex);
        }
      });
    }
  }


  void _deleteProject(int projectIndex) {
    setState(() {
      projectDirectories.removeAt(projectIndex);
      projectNames.removeAt(projectIndex);
      if (selectedProjectIndx >= projectIndex) {
        selectedProjectIndx = projectDirectories.isNotEmpty ? 0 : -1;
      }
    });
  }

  Future<void> addNewProject() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      Directory newDirectory = Directory(selectedDirectory);
      setState(() {
        projectDirectories.add(newDirectory);
        projectNames.add(getDirectoryName(newDirectory));
        selectedProjectIndx = projectDirectories.length - 1;
      });
    }
  }
  void updateProjectMessages(List<Map<String, dynamic>> newMessages) {
    setState(() {
      projectMessages[projectNames[selectedProjectIndx]] = newMessages;
    });
  }

  Directory getSelectedDir(){
    return projectDirectories[selectedProjectIndx];
  }

  @override
  Widget build(BuildContext context) {
    final projectsWidgets = getProjectsWidgets();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 50,
        backgroundColor: const Color.fromRGBO(0, 63, 155, 1),
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 5), // Adjust the padding to move title down
              title: Text(
                projectDirectories.isNotEmpty 
                    ? projectNames[selectedProjectIndx] 
                    : 'Unititled Very Wicked and Sick App',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 48, 135, 1),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Projects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: addNewProject,
                    ),
                  ],
                ),
              ),
            ),
            if (projectDirectories.isNotEmpty) ...[
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
            ]
          ],
        ),
      ),
      body: Center(
        child: projectDirectories.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0), // Add some padding around the chatbox
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 63, 155, 1), // Chat background color
              ),
              child: ChatBox(
                messages: projectMessages[projectNames[selectedProjectIndx]] ?? [],
                updateProjectMessages: (newMessages) {
                  updateProjectMessages(newMessages);
                },
              ),
            )
          : const Text('Select a codebase to work with from the drawer'),
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

    try{
    String currentProjectName = getDirectoryName(getSelectedDir()); 
    
    for (var entity in dirContents) {
      bool isDir = FileSystemEntity.isDirectorySync(entity.path);
      String name = entity.path.split(Platform.pathSeparator).last;

      if (isDir) { // Is Folder
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
      } else { // Is File
        bool isSelected = selectedFiles[currentProjectName]?.contains(entity.path) ?? false;
        tiles.add(
          ListTile(
            title: Text(name),
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.adjust_outlined,
              color: isSelected ? Colors.green : null,
            ),
            onTap: () {
              _toggleFileSelection(entity.path, currentProjectName);
            },
          ),
        );
      }
    }
    } catch (e){
      // If there's an error accessing the directory (e.g., permission issue), skip it.
    }
    return tiles;
  }
  void _toggleFileSelection(String filePath, String projectName) {
    setState(() {
      if (selectedFiles[projectName]?.contains(filePath) ?? false) {
        selectedFiles[projectName]?.remove(filePath);
      } else {
        selectedFiles.putIfAbsent(projectName, () => <String>{}).add(filePath);
      }
    });
  }

}


