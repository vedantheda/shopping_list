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
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadItem();
  }

  void loadItem() async {
    final url = Uri.https('shopping-list-2fa37-default-rtdb.firebaseio.com',
        'shopping-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        error = 'Failed to load items';
      }

      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }

      List<GroceryItem> loadedItems = [];

      final Map<String, dynamic> listData = json.decode(response.body);

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.name == item.value['category'])
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
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load items';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      groceryItems.add(newItem);
    });
  }

  _removeItem(GroceryItem item) async {
    final index = groceryItems.indexOf(item);
    setState(() {
      groceryItems.remove(item);
    });

    final url = Uri.https(
      'shopping-list-2fa37-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items found. Add some!'),
    );

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      content = Center(
        child: Text(error!),
      );
    }

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
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
      );
    }

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
      body: content,
    );
  }
}
