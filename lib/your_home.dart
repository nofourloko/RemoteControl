import 'package:flutter/material.dart';
import 'package:homml/home_page.dart';
import 'package:homml/login_page.dart';
import 'package:homml/wifi_connect_page.dart';

class YourHome extends StatefulWidget {
  const YourHome({super.key});

  @override
  State<YourHome> createState() => _YourHomeState();
}

class _YourHomeState extends State<YourHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

          const Spacer(),  

          // FIRST BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              label: const Text("Add devices", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WifiPickerPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // LOGOUT BUTTON
          SizedBox(
            width: double.infinity,
            
            child: ElevatedButton.icon(
              label: const Text("Logout", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 92, 7, 7),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ),

        ],
      ),
    ),

    );
  }
}
