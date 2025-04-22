import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentxpert_flutter_web/config/config.dart'; // Your baseUrl config

// Existing ApiService class
class ApiService {
  static const bool debug = true; // Toggle debug mode

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

// New PropertyTypeApiService class
class PropertyTypeApiService {
  static const bool debug = true; // Toggle debug mode

  /// Generic method to fetch property type count
  static Future<int?> fetchPropertyTypeCount({
    required String propertyType, // e.g. "Apartment", "Condo", etc.
  }) async {
    final url = Uri.parse('$baseUrl/admin/count-property-type/$propertyType');

    if (debug) {
      print('\n🟡 Fetching property count for: $propertyType');
      print('📡 Endpoint: $url');
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
          if (debug) print('🟢 $propertyType Count: ${data['count']}');
          return data['count'];
        } else {
          if (debug) print('🔴 "count" key not found in response');
          return null;
        }
      } else {
        if (debug) {
          print('🔴 Error fetching $propertyType count: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (debug) print('🔴 Exception fetching $propertyType count: $e');
      return null;
    }
  }

  /// Specific methods for each property type
  static Future<int?> fetchApartmentCount() {
    return fetchPropertyTypeCount(propertyType: 'Apartment');
  }

  static Future<int?> fetchCondoCount() {
    return fetchPropertyTypeCount(propertyType: 'Condo');
  }

  static Future<int?> fetchTransientCount() {
    return fetchPropertyTypeCount(propertyType: 'Transient');
  }

  static Future<int?> fetchBoardingHouseCount() {
    return fetchPropertyTypeCount(propertyType: 'BoardingHouse');
  }
}

// ✅ Model Class for Year Count
class YearCount {
  final int year;
  final int count;

  YearCount({required this.year, required this.count});

  factory YearCount.fromJson(Map<String, dynamic> json) {
    return YearCount(
      year: json['year'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'count': count,
    };
  }

  @override
  String toString() {
    return 'Year: $year, Count: $count';
  }
}

//
class YearCountService {
  // Singleton instance
  static final YearCountService _instance = YearCountService._internal();

  // Private constructor for singleton pattern
  YearCountService._internal();

  // Factory constructor to return the single instance
  factory YearCountService() {
    return _instance;
  }

  static const bool debug = true;

  // Store the year count data
  List<YearCount> _yearCounts = [];

  // Getter for year counts
  List<YearCount> get yearCounts => _yearCounts;

  // Fetch Year Counts from API
  Future<void> fetchYearCounts() async {
    final url = Uri.parse('$baseUrl/api/stats/users-by-year?years=');

    if (debug) print('\n🟡 Fetching Year Counts from: $url');

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
        final List<dynamic> data = jsonDecode(response.body);
        _yearCounts = data.map((json) => YearCount.fromJson(json)).toList();

        if (debug) {
          print('🟢 Year Counts fetched successfully!');
          for (var yearCount in _yearCounts) {
            print('➡️ ${yearCount.toString()}');
          }
        }
      } else {
        if (debug) {
          print('🔴 Failed to fetch year counts: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (debug) print('🔴 Exception occurred while fetching year counts: $e');
    }
  }
}

class AdminApiService {
  static const String _updateEndpoint = '/admin/update-profile';

  static Future<bool> updateAdminCredentials({
    required String newEmail,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$_updateEndpoint');
      final response = await http.put( // Changed from post to put
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          // Add authorization if needed
          // 'Authorization': 'Bearer ${yourToken}',
        },
        body: jsonEncode(<String, String>{
          'email': newEmail,
          'password': newPassword,
        }),
      );

      if (ApiService.debug) {
        print('🔵 Update Admin Response: ${response.statusCode}');
        print('🔵 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('Failed to update: $error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }
}