// FILE: home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/add_transaction_page.dart';
import 'package:flutter_application_1/provider/transaction_provider.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    Provider.of<TransactionProvider>(context, listen: false)
        .initializeTransactions();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Transaction Tracker'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 1,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  Text("Error: ${provider.error}", textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.initializeTransactions,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final transactions = provider.transactions;
          final totalBalance = transactions.fold<double>(
            0.0,
            (sum, txn) => sum + txn.amount,
          );

          _controller.forward();

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Balance",
                        style: TextStyle(fontSize: 18)),
                    Text(
                      "\$${totalBalance.toStringAsFixed(2)}",
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: totalBalance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: txn.amount >= 0
                                ? Colors.green[100]
                                : Colors.red[100],
                            child: Icon(
                              txn.amount >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color:
                                  txn.amount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(txn.description,
                              style: theme.textTheme.titleMedium),
                          subtitle: Text(
                              "${txn.date.toLocal().toString().split(' ')[0]}",
                              style: theme.textTheme.bodySmall),
                          trailing: Text(
                              "${txn.amount >= 0 ? '+' : '-'}\$${txn.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color:
                                    txn.amount >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              )),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Transaction Details"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Description: ${txn.description}'),
                                  Text('Amount: \$${txn.amount}'),
                                  Text(
                                      'Date: ${txn.date.toLocal().toString().split(' ')[0]}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Provider.of<TransactionProvider>(context,
                                            listen: false)
                                        .deleteTransaction(txn.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionPage()),
        ),
        label: const Text("Add"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
