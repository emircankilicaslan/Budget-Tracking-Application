import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/transaction_model.dart';

class ApiService {
  static const String baseUrl =
      'https://your-api-endpoint.com'; // Replace with your API endpoint

  // GET request to fetch transactions
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }

  // POST request to add a transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add transaction');
      }
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // DELETE request to remove a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transaction');
      }
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
}
