import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirestoreService {
  final CollectionReference _transactionsCollection =
      FirebaseFirestore.instance.collection('transactions');

  FirestoreService() {
    // Enable offline persistence
    if (kIsWeb) {
      FirebaseFirestore.instance
          .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
    }
  }

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      print('Adding transaction to Firestore: ${transaction.description}');
      final docRef = await _transactionsCollection.add({
        'amount': transaction.amount,
        'description': transaction.description,
        'date': transaction.date.toIso8601String(),
      });
      print('Transaction added successfully with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Get all transactions
  Stream<List<TransactionModel>> getTransactions() {
    try {
      print('Setting up Firestore listener for transactions');
      return _transactionsCollection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        print('Received ${snapshot.docs.length} transactions from Firestore');
        final transactions = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print('Document ID: ${doc.id}, Data: $data');
          return TransactionModel(
            id: doc.id,
            amount: (data['amount'] as num).toDouble(),
            description: data['description'] as String,
            date: DateTime.parse(data['date'] as String),
          );
        }).toList();
        print('Mapped ${transactions.length} transactions');
        return transactions;
      });
    } catch (e) {
      print('Error getting transactions: $e');
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      print('Deleting transaction with ID: $id');
      await _transactionsCollection.doc(id).delete();
      print('Transaction deleted successfully');
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
}
