import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentxpert_flutter_web/config/config.dart';
import 'package:rentxpert_flutter_web/service/usermanagement.dart'; // Your baseUrl config



class ApartmentManagementFetch {
  static const bool debug = true;

  static Future<ApartmentFetchResult?> fetchApartments({
    // Add uid parameter
    String? uid,
    String? propertyName,
    String? propertyType,
    double? rentPrice,
    String? status,
    String? landlordName,
    String? amenities,
    String? houseRules,
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/admin/apartments/details');
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    // Add UID to parameters
    if (uid != null && uid.isNotEmpty) params['uid'] = uid;
    if (propertyName != null) params['property_name'] = propertyName;
    if (propertyType != null) params['property_type'] = propertyType;
    if (rentPrice != null) params['rent_price'] = rentPrice.toString();
    if (status != null) params['status'] = status;
    if (landlordName != null) params['landlord_name'] = landlordName;
    if (amenities != null) params['amenities'] = amenities;
    if (houseRules != null) params['house_rules'] = houseRules;
    if (debug) print('Filter Params: $params');

    if (debug) {
      print('\n🟡 Fetching apartments from: ${url.replace(queryParameters: params)}');
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

        // Handle different response formats
        final successCode = responseData['RetCode'] ?? responseData['retCode'];
        if (successCode.toString() != '200') return null;

        final data = responseData['Data'] ?? responseData['data'];
        return ApartmentFetchResult.fromJson(data);
      }
      return null;
    } catch (e) {
      if (debug) print('🔴 Exception fetching apartments: $e');
      return null;
    }
  }
}

class ApartmentFetchResult {
  final int limit;
  final int page;
  final int total;
  final int totalPages;
  final List<ApartmentData> apartments;

  ApartmentFetchResult({
    required this.limit,
    required this.page,
    required this.total,
    required this.totalPages,
    required this.apartments,
  });

  factory ApartmentFetchResult.fromJson(Map<String, dynamic> json) {
    return ApartmentFetchResult(
      limit: json['limit'] as int,
      page: json['page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      apartments: (json['apartments'] as List)
          .map((apt) => ApartmentData.fromJson(apt))
          .toList(),
    );
  }
}

class ApartmentData {
  final int id;
  final String uid;
  final String propertyName;
  final String address;
  final String propertyType;
  final double rentPrice;
  final String locationLink;
  final String landmarks;
  final String status;
  final double latitude;
  final double longitude;
  final String allowedGender;
  final String availability;
  final String userID;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime updatedAt;
  final String landlordName;

  ApartmentData({
    required this.id,
    required this.uid,
    required this.propertyName,
    required this.address,
    required this.propertyType,
    required this.rentPrice,
    required this.locationLink,
    required this.landmarks,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.allowedGender,
    required this.availability,
    required this.userID,
    required this.createdAt,
    this.expiresAt,
    required this.updatedAt,
    required this.landlordName,
  });

  factory ApartmentData.fromJson(Map<String, dynamic> json) {
    return ApartmentData(
      id: json['ID'] as int,
      uid: json['Uid'] as String,
      propertyName: json['PropertyName'] as String,
      address: json['Address'] as String,
      propertyType: json['PropertyType'] as String,
      rentPrice: (json['RentPrice'] as num).toDouble(),
      locationLink: json['LocationLink'] as String,
      landmarks: json['Landmarks'] as String,
      status: json['Status'] as String,
      latitude: (json['Latitude'] as num).toDouble(),
      longitude: (json['Longitude'] as num).toDouble(),
      allowedGender: json['Allowed_Gender'] as String,
      availability: json['Availability'] as String,
      userID: json['UserID'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['ExpiresAt'] != null
          ? DateTime.parse(json['ExpiresAt'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      landlordName: json['landlord_name'] as String,
    );
  }
}

class ApartmentManagementDelete {
  static const bool debug = true;

  /// Delete apartment by ID
  static Future<bool> deleteApartment(String id) async {
    final url = Uri.parse('$baseUrl/admin/apartment/delete/$id');

    if (debug) {
      print('\n🟡 Deleting apartment at: $url');
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
        if (debug) print('🟢 Apartment deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      if (debug) print('🔴 Exception deleting apartment: $e');
      return false;
    }
  }
}


class ApartmentManagementStatus {
  static const bool debug = true;

  /// Update apartment status
  static Future<bool> updateApartmentStatus(String ID, String status) async {
    final url = Uri.parse('$baseUrl/apartments/verify/$ID');

    if (debug) print('\n🟡 Updating apartment status at: $url');

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({'status': status}),
      );

      if (debug) {
        print('🔵 Response Status Code: ${response.statusCode}');
        print('🔵 Response Body: ${response.body}');
      }

      // Check only the HTTP status code for success
      return response.statusCode == 200;
    } catch (e) {
      if (debug) print('🔴 Exception updating apartment status: $e');
      return false;
    }
  }
}

class ApartmentManagementReject {
  static const bool debug = true;

  static Future<RejectionResult> rejectApartment(String id, String rejectionReason) async {
    final url = Uri.parse('$baseUrl/rejecting/landlordApartment/$id');

    if (debug) {
      print('\n🟡 Rejecting apartment at: $url');
      print('🔵 Rejection Reason: $rejectionReason');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({'rejection_reason': rejectionReason}),
      );

      if (debug) {
        print('🔵 Response Status Code: ${response.statusCode}');
        print('🔵 Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Successful response handling
        final message = responseData['message'] ?? 'Apartment status updated';
        final status = responseData['status']?.toString().toLowerCase();
        final apartmentId = responseData['apartment_id']?.toString();

        return RejectionResult(
          success: true,
          message: message,
          data: {
            'apartment_id': apartmentId,
            'status': status,
            if (status == 'approved') 'expires_at': responseData['expires_at']
          },
        );
      }

      // Error response handling
      return RejectionResult(
        success: false,
        message: responseData['error'] ?? 'Failed to update apartment status',
        data: {
          'status_code': response.statusCode,
          'raw_response': response.body
        },
      );
    } catch (e) {
      if (debug) print('🔴 Exception rejecting apartment: $e');
      return RejectionResult(
        success: false,
        message: 'Connection error: ${e.toString()}',
        data: {'exception': e},
      );
    }
  }
}