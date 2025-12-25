import 'package:flutter/material.dart'; 
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WifiInfo {
  final String name;

  WifiInfo({required this.name});
}

class WifiPickerPage extends StatefulWidget {
  const WifiPickerPage({super.key});

  @override
  State<WifiPickerPage> createState() => _WifiPickerPageState();
}

class _WifiPickerPageState extends State<WifiPickerPage> with WidgetsBindingObserver {
  String wifi = "Checking...";
  bool loading = true;
  List<WifiInfo> wifiList = [];
  


  @override
  void initState() async {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    init();

    
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> init() async {
    await requestPermissions();
    await callForUserWifi();
  }

  Future<void> requestPermissions() async {
    await Permission.locationWhenInUse.request();
    await Permission.location.request();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      callForUserWifi();
    }
  }

  Future<void> callForUserWifi() async {
  final url = Uri.parse('http://192.168.0.206:3000/getWifiInfo'); // Your API URL
  print("sending request for wifi info");
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mail': "jakub.mista@icloud.com"
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("User Wi-Fi info retrieved: ${response.body}");

      final decodedBody = jsonDecode(response.body) as List;
      setState(() {
        print("Decoded body: $decodedBody");
        wifiList = decodedBody.map((item) => WifiInfo(name: item['name'] as String)).toList();
        loading = false;
      });

    } else {
      print("Failed to update status. Status code: ${response.statusCode}");
      setState(() {
        loading = false;
      });
    }
  } catch (e) {
    print("Exception during POST request: $e");
    setState(() {
      loading = false;
    });
  }
}
  Future<void> openWifiPage() async {
    AppSettings.openAppSettings(type: AppSettingsType.wifi);
    //add picked wifi name to server
    await callForUserWifi();
  }

  @override
  Widget build(BuildContext context) {
    final cardMargin = const EdgeInsets.symmetric(horizontal: 16, vertical: 20);

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Wi-Fi Networks List
                  Expanded(
                    child: ListView.builder(
                      itemCount: wifiList.length,
                      itemBuilder: (context, index) {
                        final wifiItem = wifiList[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Color(0xFF2F2F2F),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            title: Text(
                              "Wi-Fi Network",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              wifiItem.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HomePage()),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom button (smaller width, same as card)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: openWifiPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.greenAccent,
                      ),
                      child: const Text(
                        "📡 Pick Wi-Fi Network",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32), // bottom margin
                ],
              ),
            ),
    );
  }
}
