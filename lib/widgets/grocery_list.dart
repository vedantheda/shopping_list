import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItems = [];

  @override
  void initState() {
    super.initState();
    loadItem();
  }

  void loadItem() async {
    final url = Uri.https(
      'shopping-list-2fa37-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    final response = await http.get(url);

    List<GroceryItem> loadedItems = [];

    final Map<String, dynamic> listData = json.decode(response.body);

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((element) => element.value.name == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      groceryItems = loadedItems;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    loadItem();
  }

  _removeItem(GroceryItem item) {
    setState(() {
      groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: groceryItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No items yet!',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: groceryItems.length,
              itemBuilder: (ctx, index) {
                return Dismissible(
                  onDismissed: (direction) => _removeItem(groceryItems[index]),
                  key: ValueKey(groceryItems[index].id),
                  child: ListTile(
                    leading: Container(
                      height: 24,
                      width: 24,
                      color: groceryItems[index].category.color,
                    ),
                    title: Text(groceryItems[index].name),
                    subtitle: Text(
                      groceryItems[index].category.name,
                    ),
                    trailing: Text(groceryItems[index].quantity.toString()),
                  ),
                );
              },
            ),
    );
  }
}
