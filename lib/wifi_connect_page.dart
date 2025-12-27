import 'package:flutter/material.dart';
import 'package:homml/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'UserSession.dart';
// Simple model for WiFi items
class WifiInfo {
  final String name;
  WifiInfo({required this.name});

  factory WifiInfo.fromJson(String n) => WifiInfo(
    name:  n ?? 'Unknown',
  );
} 

class WifiInfoPage extends StatefulWidget {
  const WifiInfoPage({
    super.key
    });

  @override
  State<WifiInfoPage> createState() => _WifiInfoPageState();
}

class _WifiInfoPageState extends State<WifiInfoPage> {
  bool _isLoading = false;
  String? _errorMessage;
  

  // List of WiFi items retrieved from server
  List<WifiInfo> wifiList = [];

  final String _apiUrl = 'http://192.168.0.65:3000/getWifiInfo';

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserSession>().userId;


    fetchWifiInfo(userId ?? "");
  }
  // ----------------------------

  // Fetches a single Wi-Fi record by user id with retry/backoff and longer timeout
  Future<void> fetchWifiInfo(String userId, {int maxAttempts = 3}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

     try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': userId}),
        ).timeout(const Duration(seconds: 15)); // extended timeout

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          print("Response Data: $data");

          if (mounted) {
            setState(() {
              wifiList = data.map((element) => WifiInfo(name: element.toString())).toList();
              
              _isLoading = false;
              _errorMessage = null;
            });
          }
          return;
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Server Status: ${response.statusCode}';
              _isLoading = false;
            });
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Connection Error: $e';
            _isLoading = false;
          });
        }
        return;
      }
  }


  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserSession>(context).userId;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                    child: Column(
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => fetchWifiInfo(userId ?? ""),
                          child: const Text('Retry'),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                      ],
                    ),
                  ),

                if (wifiList.isNotEmpty)
                  Column(
  children: wifiList.map((w) => Container(
    // 1. Add the slight grey border
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20), // Space between segments
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFF2F2F2F), width: 1), // Your slight grey color
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_find, size: 60, color: Color(0xFF92CF9D)),
                  const SizedBox(height: 20),
                  Text(
                    "Registered WiFi:", 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16, )
                  ),
                  const SizedBox(height: 10),
                  Text(
                    w.name ?? "Unknown",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF92CF9D)
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // 2. Your TextButton integration with Global State
                  TextButton.icon(
                    onPressed: () {
                      // Set the global state for the selected WiFi
                      Provider.of<UserSession>(context, listen: false).PickWifiName(w.name);
                      
                      // Navigate to Home
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    icon: const Icon(Icons.chevron_right, color: Color(0xFF92CF9D)),
                    label: const Text("Tap for details"), 
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF92CF9D), // Sets the text/icon color
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        )
              ],
              const SizedBox(height: 40),
              // Kept the button so the user can manual refresh the list if needed
              TextButton.icon(
                onPressed: () => fetchWifiInfo(userId ?? ""),
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Data"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(color: Color(0xFF92CF9D)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}