import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../home/homepage.dart';
import '../guide/guide_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  bool _isLoading = false;

  Future<void> _requestLocationAndStart() async {
  setState(() => _isLoading = true);

  String region = '위치 미확인';

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();

        // 백엔드 /region 호출
        final response = await http.get(
          Uri.parse('https://team6-project.onrender.com/region?lat=${position.latitude}&lon=${position.longitude}'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          region = data['full_name'] ?? '위치 미확인';
        }
      }
    }
  } catch (e) {
    debugPrint('위치 오류: $e');
  }

  if (!mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => region == '위치 미확인'
          ? GuideScreen(region: region)
          : HomePage(region: region),
    ),
  );
}

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.recycling, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  '분리배출 도우미',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '사진 한 장으로 올바른 분리배출 방법을\n바로 확인하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 80),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '시작하기 버튼을 누르면 지역별 분리배출 기준\n적용을 위해 위치 정보 제공에 동의하게 됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        onPressed: _requestLocationAndStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '위치 동의 후 시작하기',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}