import 'services/db_helper.dart';
import 'models/transaction_model.dart';

void main() async {
  // create an instance of the database helper
  final db = DBHelper();

  // insert a sample transaction into the database
  await db.insertTransaction(TransactionModel(
    amount: 25.5,
    category: 'Food',
    date: '2025-11-04',
    note: 'Lunch',
  ));

  // fetch all transactions from the database
  var list = await db.getTransactions();
  print('Transactions: ${list.map((t) => t.toMap())}');

  // if there are any transactions, update the first one
  if (list.isNotEmpty) {
    var first = list.first;
    await db.updateTransaction(TransactionModel(
      id: first.id,
      amount: 30.0, // new amount after update
      category: first.category,
      date: first.date,
      note: 'Updated Lunch',
    ));
  }

  // if there are still transactions, delete the first one
  if (list.isNotEmpty) await db.deleteTransaction(list.first.id!);
}
