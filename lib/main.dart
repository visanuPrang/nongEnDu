import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:nongendu/screens/home.dart';

void main() {
  runApp(
    MaterialApp(
      home: EasySplashScreen(
        logo: Image.asset(
          'assets/images/Owl.png',
          width: 250,
          height: 250,
        ),
        logoWidth: 250,
        title: const Text(
          'Nong EnDu Application',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 102, 82, 82)),
        ),
        showLoader: true,
        loaderColor: const Color.fromARGB(255, 191, 156, 168),
        loadingText: const Text(
          'Version 1.0.11',
          style: TextStyle(color: Color.fromARGB(255, 102, 82, 82)),
        ),
        durationInSeconds: 5,
        navigator: const HomeScreen(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Page')),
    );
  }
}


// Create APK command: 27/09/23 22:30
//   flutter build apk --build-name x.x.x --build-number xx

// upload to Amazon
// App Submission API Keys
// Use these values when programmatically managing this app with the App Submission API. Learn More.
// App ID
// This value identifies this app resource for the Developer Publishing API. For Application Key, see the Key column on the Mobile Ads page.
// amzn1.devportal.mobileapp.02867008e63b4f72b618e9aa8ad0d497

// Copy
// Copied to clipboard
// Release ID
// amzn1.devportal.apprelease.183c85b17e534a989029cdcc398c2977

// create/upload new project to git/github
// Step-1 Create a Flutter Project
// Step-2 Open Terminal
// Step-3 Step by step all commands to upload project remotely.// → 1. git init
// → 2. git add .
// → 3. git commit -m "description"
// → 4. git branch -M branchName
// → 5. git remote add origin https://github.com/visanuPrang/nongEnDu.git
// → 6. git push -u origin branchName

// Add modified files to that remote project;
// Step-1 Step by step 3 commands to upload modified files/folders.
// → 1. git add .
// → 2. git commit -m "description of this commit"
// → 3. git push -u origin branchName