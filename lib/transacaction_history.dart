import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentxpert_flutter_web/service/payment_service.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = TransactionService().getAllTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _transactionsFuture = TransactionService().getAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactions,
          ),
        ],
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          final transactions = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshTransactions,
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    transaction.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: transaction.statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Date: ${transaction.formattedDate}'),
            const SizedBox(height: 4),
            Text('Base Amount: ₱${transaction.baseAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text('Interest: ₱${transaction.interestAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text('Reference: ${transaction.id}'),
          ],
        ),
      ),
    );
  }
}