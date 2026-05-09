import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(String employeeID, String password) async {
    final String apiBaseUrl = dotenv.env['API_BASE_URL']!;
    final String companyCode = dotenv.env['COMPANY_CODE']!;

    final Map<String, dynamic> requestBody = {
      "API_Body": [
        {"Unique_Id": employeeID, "Pw": password}
      ],
      "Api_Action": "GetUserData",
      "Company_Code": companyCode,
    };

    try {
      final response = await http.post(
        Uri.parse(apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
