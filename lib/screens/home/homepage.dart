import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> recyclingData = {};
  String selectedCategory = '';
  Map<String, dynamic>? resultItem;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _locationMessage = '';

   

  final List<Map<String, dynamic>> categories = [
    {'key': 'plastic_bottle', 'label': '플라스틱', 'icon': '♻️'},
    {'key': 'paper', 'label': '종이', 'icon': '📄'},
    {'key': 'can', 'label': '캔/금속', 'icon': '🥫'},
    {'key': 'glass', 'label': '유리', 'icon': '🍶'},
    {'key': 'vinyl', 'label': '비닐', 'icon': '🛍️'},
    {'key': 'trash', 'label': '일반쓰레기', 'icon': '🗑️'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecyclingData();
  }

  Future<void> _loadRecyclingData() async {
    final String jsonString =
        await rootBundle.loadString('assets/recycling_data.json');
    setState(() {
      recyclingData = json.decode(jsonString);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _checkLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    setState(() => _locationMessage = '위치 서비스가 비활성화되어 있습니다');
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() => _locationMessage = '위치 권한이 거부되었습니다');
      return;
    }
  }

  Position position = await Geolocator.getCurrentPosition();
  
  // 광주광역시 좌표 범위 체크
  // 위도 35.05 ~ 35.25, 경도 126.75 ~ 127.00
  bool isGwangju = position.latitude >= 35.05 &&
      position.latitude <= 35.25 &&
      position.longitude >= 126.75 &&
      position.longitude <= 127.00;

  setState(() {
    _locationMessage = isGwangju ? '📍 광주광역시' : '📍 광주광역시 외 지역';
  });
}

  void _onCategoryTap(String key) {
    setState(() {
      selectedCategory = key;
      resultItem = recyclingData[key];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분리배출 도우미'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _locationMessage.isEmpty ? '위치 미확인' : _locationMessage,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                TextButton.icon(
                  onPressed: _checkLocation,
                  icon: const Icon(Icons.location_on, color: Colors.green),
                  label: const Text('위치 확인', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: InkWell(
                  onTap: () => _pickImage(),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _selectedImage!.path,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 60, color: Colors.green),
                            SizedBox(height: 10),
                            Text('사진 촬영하기',
                                style: TextStyle(fontSize: 18, color: Colors.green)),
                            Text('탭하여 쓰레기를 촬영하세요',
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('직접 선택하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat['key'];
                  return InkWell(
                    onTap: () => _onCategoryTap(cat['key']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat['icon'], style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(
                            cat['label'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (resultItem != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resultItem!['name'],
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      const SizedBox(height: 8),
                      const Text('📌 배출 방법',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(resultItem!['method']),
                      const SizedBox(height: 8),
                      const Text('⚠️ 주의사항',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(resultItem!['caution']),
                      const SizedBox(height: 8),
                      Text('📍 ${resultItem!['region']}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}