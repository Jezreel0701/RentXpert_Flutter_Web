import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentxpert_flutter_web/config/config.dart'; // Your baseUrl config

class UserManagementUpdate {  // PascalCase for class name
  static const bool debug = true;  // Add debug constant matching original pattern

  static Future<Map<String, dynamic>?> updateUserDetails({
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse('$baseUrl/users/update');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);

      // Add detailed logging
      if (debug) {
        print('Response Status: ${response.statusCode}');
        print('Full Response Body: $responseData');
      }

      // Flexible status code check
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle different response formats
        final successCode = responseData['RetCode'] ?? responseData['retCode'];
        final userData = responseData['Data'] ?? responseData['data'];

        if (successCode.toString() == '200' && userData != null) {
          return userData.cast<String, dynamic>();
        }
      }
      return null;
    } catch (e) {
      if (debug) print('Update error: $e');
      return null;
    }
  }
}  // Removed extra closing brace

// Add to usermanagement.dart
class UserManagementDelete {
  static const bool debug = true;

  /// Delete user by UID
  static Future<bool> deleteUser(String uid) async {
    final url = Uri.parse('$baseUrl/admin/user/$uid');

    if (debug) {
      print('\n🟡 Deleting user at: $url');
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (debug) {
        print('🔵 Response Status Code: ${response.statusCode}');
        print('🔵 Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      // Handle different response formats
      final successCode = responseData['RetCode'] ?? responseData['retCode'];
      if (response.statusCode == 200 && successCode.toString() == '200') {
        if (debug) print('🟢 User deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      if (debug) print('🔴 Exception deleting user: $e');
      return false;
    }
  }
}