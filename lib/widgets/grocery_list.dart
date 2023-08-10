import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Groceries'),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) {
          return ListTile(
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
          );
        },
      ),
    );
  }
}