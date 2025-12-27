import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'UserSession.dart';
import 'package:provider/provider.dart';

class Device {
  bool powerOn;
  final String title;
  final IconData icon;

  Device({required this.powerOn, required this.title, required this.icon});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // URL: Ensure this is your laptop IP and the server is running!
  final String _devicesApiUrl = 'http://192.168.0.65:3000/getDevices';

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserSession>().userId;
    final wifiName = context.read<UserSession>().wifiName;
    // Still try to fetch once on load
    fetchDevices(userId ?? "", wifiName ?? "" );
  }

  Future<void> fetchDevices(String userId, String wifiName) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("Calling API: $_devicesApiUrl");
      
      final response = await http.post(
        Uri.parse(_devicesApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': userId,
          'wifi': wifiName
          }),
      ).timeout(const Duration(seconds: 10));

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        
        setState(() {
          devices = decoded.map((item) => Device(
            powerOn: (item['powered'] ?? item['powerOn'] ?? false) == true,
            title: item['title']?.toString() ?? item['name']?.toString() ?? 'Unknown Device',
            icon: Icons.power_settings_new,
          )).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Server Error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _errorMessage = "Connection Failed. Is the server running?";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : devices.isEmpty && _errorMessage == null
                ? const Center(child: Text("No devices found. Click 'Fetch' below."))
                : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: devices.length,
                      itemBuilder: (context, index) => _buildClickableDeviceCard(devices[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableDeviceCard(Device d) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 1. Update the UI immediately
          setState(() {
            d.powerOn = !d.powerOn;
          });
          
          // 2. Send the update to the server
          // Note: Ensure your postDeviceStatus function is accessible here
          //_updateDeviceOnServer(d.title, d.powerOn);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // The color now updates dynamically because of setState
              Icon(
                d.icon, 
                color: d.powerOn ? const Color(0xFF92CF9D) : Colors.grey, 
                size: 30
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(d.powerOn ? "Status: ON" : "Status: OFF", 
                         style: TextStyle(color: d.powerOn ? const Color(0xFF92CF9D) : Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to sync with your backend
  Future<void> _updateDeviceOnServer(String title, bool isPowered) async {
    try {
      await http.post(
        Uri.parse('http://192.168.100.117:3000/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'powered': isPowered,
        }),
      );
    } catch (e) {
      print("Failed to sync toggle: $e");
    }
  }
}