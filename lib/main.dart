import 'package:flutter/material.dart'; // Import the Flutter Material Design package.
import 'package:github/github.dart';
import 'package:file_picker/file_picker.dart';
 
import 'src/folder_explorer_page.dart';


void main() {
  runApp(const MyApp()); // Main entry point of the app, running the MyApp widget.
}

class MyApp extends StatelessWidget { // A stateless widget MyApp.
  const MyApp({super.key}); // Constructor for MyApp, with an optional 'key' parameter.

  @override
  Widget build(BuildContext context) { // Describes the part of the UI represented by MyApp.
    return MaterialApp( // MaterialApp is a convenience widget that wraps several widgets.
      title: 'Schemer', // Title of the app, mainly seen in a web-browser tab
      theme: ThemeData( // Defines the app's visual theme.
        primarySwatch: Colors.blue, // Primary color swatch of the app.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Visual density adapts to the platform.
        useMaterial3: true, // Opt-in to use Material 3 design.
      ),
      home: const MyHomePage(title: 'Schemer'), // The home page of the app.
    );
  }
} 

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to UntitledApp!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Choose your project source'),
            const SizedBox(height: 25), // Increased height for more space
            ElevatedButton(
              onPressed: () async {
                // Implement Local Folder selection
                String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                if (selectedDirectory != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FolderExplorerPage(folderPath: selectedDirectory),
                  ));
                }
              },
              child: const Text('Local Folder'),
            ),
          ],
        ),
      ),
    );
  }
}                                                           
