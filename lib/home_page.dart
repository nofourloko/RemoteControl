import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class Device {
  bool powerOn;
  final String title;
  final IconData icon;

  Device({required this.powerOn, required this.title, required this.icon});
}

Future<bool> postDeviceStatus(bool powered) async {
  final url = Uri.parse('http://192.168.0.206:3000/toggle'); // Your API URL

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'powered': powered}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Successfully updated device status: $powered");
      return true;
    } else {
      print("Failed to update status. Status code: ${response.statusCode}");
      
    }
  } catch (e) {
    print("Exception during POST request: $e");
  }
  return false;
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> devices = [
    Device(powerOn: true, title: "Living Room Light", icon: Icons.lightbulb),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryText = Theme.of(context).textTheme.bodyLarge;
    final secondaryText = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // List of devices
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final d = devices[index];
                  return Card(
                    elevation: 0,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color(0xFF2F2F2F), // grey border
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        d.icon,
                        color: d.powerOn ? Colors.greenAccent : Colors.grey,
                      ),
                      title: Text(d.title, style: primaryText),
                      subtitle: Text(
                        d.powerOn ? "Powered ON" : "Powered OFF",
                        style: secondaryText,
                      ),
                      trailing: Switch(
                        activeColor: Theme.of(context).primaryColor,
                        value: d.powerOn,
                         onChanged: (val) async {
                            // Update local state
                            setState(() => d.powerOn = val);
                            await postDeviceStatus(d.powerOn);
                          },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Logout Button (bottom)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 92, 7, 7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
