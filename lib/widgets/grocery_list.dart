import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(
      () {
        groceryItems.add(newItem);
      },
    );
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
