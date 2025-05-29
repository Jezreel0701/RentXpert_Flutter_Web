import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';

class TransactionService {
  static const String _baseUrl = 'http://127.0.0.1:8080';

  Future<List<Transaction>> getAllTransactions() async {
    debugPrint('[TransactionService] Fetching transactions from API...');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/get-all/transaction'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      debugPrint('[TransactionService] Response received in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('[TransactionService] Status code: ${response.statusCode}');
      debugPrint('[TransactionService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('[TransactionService] Successfully parsed ${data.length} transactions');
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        debugPrint('[TransactionService] Server error: ${response.statusCode}');
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('[TransactionService] Request timed out');
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('[TransactionService] Error: $e');
      throw Exception('Failed to fetch transactions: $e');
    } finally {
      stopwatch.stop();
    }
  }
}

class Transaction {
  final String id;
  final String userId;
  final double baseAmount;
  final double interestAmount;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.baseAmount,
    required this.interestAmount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      return Transaction(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        baseAmount: _parseDouble(json['base_amount']),
        interestAmount: _parseDouble(json['interest_amount']),
        totalAmount: _parseDouble(json['total_amount']),
        status: json['status']?.toString() ?? 'pending',
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e) {
      debugPrint('[Transaction] Error parsing transaction: $e');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      debugPrint('[Transaction] Error parsing date: $value');
      return DateTime.now();
    }
  }

  String get formattedDate =>
      '${createdAt.day.toString().padLeft(2, '0')}/'
          '${createdAt.month.toString().padLeft(2, '0')}/'
          '${createdAt.year} '
          '${createdAt.hour.toString().padLeft(2, '0')}:'
          '${createdAt.minute.toString().padLeft(2, '0')}';

  String get formattedAmount => '₱${totalAmount.toStringAsFixed(2)}';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'pending':
        return Icons.pending;
      case 'refunded':
        return Icons.assignment_return;
      default:
        return Icons.help_outline;
    }
  }

  @override
  String toString() {
    return 'Transaction(id: $id, user: $userId, amount: $totalAmount, status: $status)';
  }
}