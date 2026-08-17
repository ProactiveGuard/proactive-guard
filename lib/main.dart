 import 'package:flutter/material.dart'; 
 import 'services/api.dart';
 
    // This is the starting point of your app 
    void main() { 
      runApp(const MyApp()); 
    } 
 
    class MyApp extends StatelessWidget { 
      const MyApp({super.key}); 
 
      @override 
      Widget build(BuildContext context) { 
        return MaterialApp( 
          debugShowCheckedModeBanner: false, 
          title: 'Proactive Guard', 
          home: const SOSScreen(), 
        ); 
      } 
    } 
 
    // This is your actual screen 
    class SOSScreen extends StatelessWidget { 
      const SOSScreen({super.key}); 
 
      @override 
      Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,// Dark mode looks cool and serious 
          appBar: AppBar( 
            title: const Text("Proactive Guard"), 
            backgroundColor: Colors.grey[900], 
          ), 
          body: Center( 
            child: ElevatedButton( 
              // What happens when the button is pressed: 
             onPressed: () {
  print("SOS BUTTON PRESSED! Sending to Backend...");

  ApiService.sendSOSAlert();
},
              // How the button looks: 
              style: ElevatedButton.styleFrom( 
                backgroundColor: Colors.red, 
                shape: const CircleBorder(), 
                padding: const EdgeInsets.all(80), // Makes the button huge 
              ), 
              child: const Text( 
                "SOS", 
                style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold), 
              ), 
            ), 
          ), 
        ); 
      } 
    }