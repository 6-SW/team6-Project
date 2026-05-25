import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class GuideScreen extends StatefulWidget {
  final String region;

  const GuideScreen({required this.region, super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  Map<String, dynamic> recyclingData = {};
  String selectedCategory = '';
  Map<String, dynamic>? resultItem;

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
        title: const Text('배출방법 조회'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 ${widget.region}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              '쓰레기 종류를 선택하세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat['key'];
                return InkWell(
                  onTap: () => _onCategoryTap(cat['key']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['icon'],
                            style: const TextStyle(fontSize: 28)),
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
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          resultItem!['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('📌 배출 방법',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(resultItem!['method']),
                    const SizedBox(height: 12),
                    const Text('⚠️ 주의사항',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
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
    );
  }
}