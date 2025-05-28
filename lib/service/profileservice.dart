import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/config.dart';

class ProfileService {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> getJwtToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<String?> getFullnameByUid(String uid) async {
    try {
      final token = await getJwtToken();
      if (token == null) {
        print("JWT token not found.");
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/fullname/$uid'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('User fullname response: $response.body');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['fullname'];
      } else {
        print("Failed to fetch fullname: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching fullname: $e");
      return null;
    }
  }

  Future<String?> getUserProfilePhotoByUid(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/photo/$uid'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['photo_url'];
      } else {
        print("Failed to fetch photo_url: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching photo_url: $e");
      return null;
    }
  }
}
