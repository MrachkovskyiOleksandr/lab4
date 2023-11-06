import 'package:flutter/material.dart';
import 'package:lab4/models/expense.dart';
import 'package:lab4/widgets/expenses_list/expenses_list.dart';
import 'package:lab4/widgets/new_expense.dart';
import 'package:lab4/widgets/chart/chart.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  Map<String, List<Expense>> familyExpenses = {
    'Dad': [], // Витрати для Member 1
    'Mom': [], // Витрати для Member 2
    'Bro': [], // Витрати для Member 3
    'Sis': [], // Витрати для Member 4
  };

  List<String> familyMembers = [
    'Dad',
    'Mom',
    'Bro',
    'Sis',
  ]; // Список членів сім'ї

  List<Expense> allExpenses = []; // Усі витрати

  String _selectedFamilyMember = 'Dad'; // Початковий вибраний член сім'ї
  bool _showTotal = false; // Відображення загальних витрат по темах
  bool _showDropdown = true; // Відображати DropdownButton

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  void _addExpense(Expense expense) {
    final familyMember = expense.familyMember;
    if (familyExpenses.containsKey(familyMember)) {
      setState(() {
        familyExpenses[familyMember]!.add(expense);
        allExpenses.add(expense); // Додайте витрату до загальних витрат
      });
    }
  }

  void _removeExpense(Expense expense) {
    final familyMember = expense.familyMember;
    if (familyExpenses.containsKey(familyMember)) {
      final index = familyExpenses[familyMember]!.indexOf(expense);
      setState(() {
        familyExpenses[familyMember]!.removeAt(index);
        allExpenses.remove(expense); // Видаліть витрату з загальних витрат
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: const Text('Expense deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                familyExpenses[familyMember]!.insert(index, expense);
                allExpenses.add(expense); // Додайте витрату до загальних витрат
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFamilyMemberExpenses = familyExpenses[_selectedFamilyMember]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
          // Додайте можливість вибору режиму відображення.
          TextButton(
            onPressed: () {
              setState(() {
                _showTotal =
                    !_showTotal; // Перемикач для відображення загальних витрат по темах
                if (_showTotal) {
                  _showDropdown =
                      false; // Приховувати DropdownButton у режимі сумарних витрат
                } else {
                  _showDropdown =
                      true; // Відображати DropdownButton у режимі окремих витрат
                }
              });
            },
            child: Text(_showTotal ? 'Show Individual' : 'Show Total'),
          ),
          if (_showDropdown)
            DropdownButton(
              value: _selectedFamilyMember,
              items: familyMembers
                  .map(
                    (member) => DropdownMenuItem(
                      value: member,
                      child: Text(member),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFamilyMember = value;
                  });
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Chart(
            memberExpenses: _showTotal
                ? allExpenses
                : selectedFamilyMemberExpenses, // Передаємо відповідні дані в Chart
          ),
          Expanded(
            child: selectedFamilyMemberExpenses.isNotEmpty
                ? ExpensesList(
                    expenses: selectedFamilyMemberExpenses,
                    onRemoveExpense: _removeExpense,
                  )
                : const Center(
                    child: Text('No expenses found. Start adding some!'),
                  ),
          ),
        ],
      ),
    );
  }
}
