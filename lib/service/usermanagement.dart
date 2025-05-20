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


class UserManagementFetch {
  static const bool debug = true;


  static Future<UserFetchResult?> fetchUsers({
    String? userType,
    String? accountStatus,
    String? name,
    String? searchField,
    String? searchTerm,
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/adminuserinfo/search');


    // Prepare query parameters
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };


    if (userType?.isNotEmpty ?? false) params['user_type'] = userType!;
    if (accountStatus?.isNotEmpty ?? false) params['account_status'] = accountStatus!;
    if (name?.isNotEmpty ?? false) params['name'] = name!;
    if (searchField?.isNotEmpty ?? false) params['field'] = searchField!;
    if (searchTerm?.isNotEmpty ?? false) params['search_term'] = searchTerm!;


    if (debug) {
      print('\n🟡 Fetching users from: $url');
      print('🔵 Query parameters: $params');
    }


    try {
      final response = await http.get(
        url.replace(queryParameters: params),
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
        final responseData = jsonDecode(response.body);
        final result = UserFetchResult.fromJson(responseData['Data'] ?? responseData['data']);
        return result;
      }
      return null;
    } catch (e) {
      if (debug) print('🔴 Exception fetching users: $e');
      return null;
    }
  }
}


class UserFetchResult {
  final int limit;
  final int page;
  final int total;
  final int totalPages;
  final List<UserData> users;


  UserFetchResult({
    required this.limit,
    required this.page,
    required this.total,
    required this.totalPages,
    required this.users,
  });


  factory UserFetchResult.fromJson(Map<String, dynamic> json) {
    return UserFetchResult(
      limit: json['limit'] as int,
      page: json['page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      users: (json['users'] as List)
          .map((user) => UserData.fromJson(user))
          .toList(),
    );
  }
}


class UserData {
  final int? ID;
  final String uid;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String address;
  final String validId;
  final String accountStatus;
  final String userType;


  UserData({
    required this.ID,
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.address,
    required this.validId,
    required this.accountStatus,
    required this.userType,
  });


  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      ID: json['id'] as int?, // Parse ID from JSON
      uid: json['uid'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      fullName: json['fullname'] as String,
      address: json['address'] as String,
      validId: json['valid_id'] as String,
      accountStatus: json['account_status'] as String,
      userType: json['user_type'] as String,
    );
  }
}

class UserManagementStatus {
  static const bool debug = true;

  /// Verify landlord using UID (admin endpoint)
  static Future<bool> verifyLandlordViaAdmin(String uid) async {
    final url = Uri.parse('$baseUrl/accept/landlordrequest/$uid');

    if (debug) print('\n🟡 Verifying landlord with UID: $uid at: $url');

    try {
      final response = await http.put(
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

      // Handle non-200 responses first
      if (response.statusCode != 200) {
        if (debug) {
          // Handle non-JSON responses gracefully
          final isJson = response.headers['content-type']?.contains('application/json') ?? false;
          if (isJson) {
            try {
              final errorData = json.decode(response.body);
              print('🔴 Server Error: ${errorData['message']}');
              if (errorData.containsKey('error')) {
                print('🔴 Error Details: ${errorData['error']}');
              }
            } catch (e) {
              print('🔴 Malformed JSON error response: $e');
            }
          } else {
            print('🔴 Non-JSON Error Response: ${response.body}');
          }
        }
        return false;
      }

      // Handle success case
      try {
        final responseData = json.decode(response.body);
        if (debug) {
          print('🟢 Verification Details:');
          print('- Profile ID: ${responseData['data']['profile_id']}');
          print('- Verified At: ${responseData['data']['verified_at']}');
        }
        return true;
      } catch (e) {
        if (debug) print('🔴 Failed to parse successful response: $e');
        return false;
      }
    } catch (e) {
      if (debug) print('🔴 Network Exception: ${e.runtimeType}');
      return false;
    }
  }
}

class UserManagementRejection {
  static const bool debug = true;
  static Future<RejectionResult> rejectLandlordRequest({
    required String uid,
    required String rejectionReason,
  }) async {
    final url = Uri.parse('$baseUrl/rejecting/landlordrequest/$uid');
    final Map<String, dynamic> requestBody = {
      'rejection_reason': rejectionReason,
    };

    if (debug) {
      print('\n🟡 Rejecting landlord request for UID: $uid');
      print('• Endpoint: $url');
      print('• Request Body: ${json.encode(requestBody)}');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (debug) {
        print('🔵 Response Status: ${response.statusCode}');
        print('🔵 Response Body: ${response.body}');
      }

      final isJson = response.headers['content-type']?.contains('application/json') ?? false;
      final responseData = isJson ? json.decode(response.body) : null;

      // Handle specific status codes
      switch (response.statusCode) {
        case 200:
          return _handleSuccess(responseData);
        case 400:
          return RejectionResult(
            success: false,
            message: responseData?['message'] ?? 'Invalid request format',
          );
        case 404:
          return RejectionResult(
            success: false,
            message: 'No landlord profile found for UID: $uid',
          );
        case 409:
          return RejectionResult(
            success: false,
            message: 'Profile already rejected',
          );
        case 500:
          return RejectionResult(
            success: false,
            message: responseData?['message'] ?? 'Server error occurred',
          );
        default:
          return RejectionResult(
            success: false,
            message: 'Unexpected response: ${response.statusCode}',
          );
      }
    } catch (e) {
      if (debug) print('🔴 Network Error: ${e.toString()}');
      return RejectionResult(
        success: false,
        message: 'Network error: ${e.runtimeType.toString().replaceAll('_', ' ')}',
      );
    }
  }

  static RejectionResult _handleSuccess(dynamic responseData) {
    try {
      if (debug) {
        print('🟢 Rejection Successful:');
        print('• Message: ${responseData['message']}');
        print('• Profile ID: ${responseData['data']['profile_id']}');
        print('• Account Status: ${responseData['data']['account_status']}');
        print('• Rejected At: ${responseData['data']['rejected_at']}');
      }

      return RejectionResult(
        success: true,
        message: responseData['message'],
        data: responseData['data'],
      );
    } catch (e) {
      if (debug) print('🔴 Success Response Parsing Error: $e');
      return RejectionResult(
        success: false,
        message: 'Failed to parse successful response',
      );
    }
  }
}

class RejectionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  RejectionResult({
    required this.success,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'RejectionResult: $message (Success: $success)';
}