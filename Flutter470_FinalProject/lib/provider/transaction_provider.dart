import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  bool isLoading = false;
  String? error;

  List<TransactionModel> get transactions => _transactions;

  Future<void> initializeTransactions() async {
    isLoading = true;
    notifyListeners();

    try {
      final loadedTransactions =
          await DatabaseHelper.instance.getTransactions();
      _transactions.clear();
      _transactions.addAll(loadedTransactions);
      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await DatabaseHelper.instance.insertTransaction(transaction);
      _transactions.add(transaction); // ✅ CRITICAL
      notifyListeners(); // ✅ CRITICAL
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((txn) => txn.id == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
