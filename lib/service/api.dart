import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentxpert_flutter_web/config/config.dart'; // Contains your baseUrl

class ApiService {
  static const bool debug = true; // Toggle this to false to stop debug logs

  /// Generic method to fetch count from any endpoint
  static Future<int?> fetchCount({
    required String endpoint, // e.g. "admin/count/All"
    String? label,            // Optional: for logging ("All", "Landlord", etc.)
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    if (debug) {
      print('\n🟡 Fetching count from: $url');
    }

    try {
      final response = await http.get(
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('count')) {
          if (debug) print('🟢 $label Count: ${data['count']}');
          return data['count'];
        } else {
          if (debug) print('🔴 "count" key not found in response');
          return null;
        }
      } else {
        if (debug) {
          print('🔴 Error fetching ${label ?? endpoint}: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (debug) print('🔴 Exception fetching ${label ?? endpoint}: $e');
      return null;
    }
  }

  /// Fetch user count by type ("All", "Landlord", "Tenant")
  static Future<int?> fetchUserCount(String userType) {
    return fetchCount(endpoint: 'admin/count/$userType', label: userType);
  }

  /// Fetch approved apartment count
  static Future<int?> fetchApprovedApartmentCount() {
    return fetchCount(endpoint: 'admin/count_apartment/Approved', label: 'Approved Apartments');
  }
}
