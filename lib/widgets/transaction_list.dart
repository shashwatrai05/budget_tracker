import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import '../providers/transaction.dart';
import './transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Expense> transactions;
  final Function deleteTx;

  TransactionList(this.transactions, this.deleteTx);

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
          ? LayoutBuilder(builder: (ctx, constraints){
            return Column(
              children: <Widget>[
                Text(
                  'No transactions added yet!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    height: constraints.maxHeight*0.7,
                    child: Image.asset(
                      'assets/images/NoTransaction.webp',
                      fit: BoxFit.cover,
                    )),
              ],
            );
          }) 
          : ListView(children: 
            transactions.map((tx) => TransactionItem(
              key:ValueKey(tx.id),
              transaction: tx, 
              deleteTx: deleteTx
              )).toList() 
               
              );
              
                
              }
    
  }


