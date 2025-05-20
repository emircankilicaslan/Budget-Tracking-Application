import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ADD
  Future<void> insertTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getTransactions();
      list.add(transaction);
      final jsonList = list.map((t) => t.toJson()).toList();
      await prefs.setString('transactions', jsonEncode(jsonList));
    } else {
      final db = await database;
      await db.insert(
        'transactions',
        transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // READ
  Future<List<TransactionModel>> getTransactions() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('transactions');
      if (raw == null) return [];
      final decoded = jsonDecode(raw) as List;
      return decoded.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('transactions');
      return maps.map((map) => TransactionModel.fromJson(map)).toList();
    }
  }

  // DELETE
  Future<void> deleteTransaction(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getTransactions();
      list.removeWhere((txn) => txn.id == id);
      final jsonList = list.map((t) => t.toJson()).toList();
      await prefs.setString('transactions', jsonEncode(jsonList));
    } else {
      final db = await database;
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // CLEAR ALL (optional)
  Future<void> clearTransactions() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('transactions');
    } else {
      final db = await database;
      await db.delete('transactions');
    }
  }
}
