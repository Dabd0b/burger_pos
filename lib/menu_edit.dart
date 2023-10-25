import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'POSPage.dart';

class MenuEditPage extends StatefulWidget {
  final List<Category> categories;
  const MenuEditPage(this.categories, {super.key});

  @override
  _MenuEditPageState createState() => _MenuEditPageState();
}

class _MenuEditPageState extends State<MenuEditPage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();
  Category? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<Category>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              onChanged: (Category? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: widget.categories.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Add Item to Selected Category:'),
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: itemPriceController,
              decoration: const InputDecoration(labelText: 'Item Price'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null &&
                    itemNameController.text.isNotEmpty &&
                    itemPriceController.text.isNotEmpty) {
                  final double price = double.tryParse(itemPriceController.text) ?? 0.0;
                  final Item newItem = Item(name: itemNameController.text, price: price);
                  setState(() {
                    selectedCategory!.items.add(newItem);
                  });
                  saveMenuToJson();
                  itemNameController.clear();
                  itemPriceController.clear();
                }
              },
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 20),
            const Text('Remove Item from Selected Category:'),
            if (selectedCategory != null)
            
              Column(
                children: selectedCategory!.items.map((Item item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.price.toStringAsFixed(2)} L.E'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          selectedCategory!.items.remove(item);
                        });
                        saveMenuToJson();
                      },
                    ),
                  );
                }).toList(),
              ),
              
          ],
        ),
      ),
    ),
    );
  }
  
  String getIconName(IconData icon) {
  switch (icon) {
    case Icons.fastfood:
      return 'fastfood';
    case Icons.local_drink:
      return 'local_drink';
    case Icons.local_dining:
      return 'local_dining';
    // Add more cases for other icons if needed
    default:
      return 'error'; // Default to an error icon if the icon is not recognized
  }
}


  void saveMenuToJson() {
    final List<Map<String, dynamic>> jsonData = widget.categories.map((Category category) {
      return {
        'name': category.name,
        'items': category.items.map((item) {
          return {
            'name': item.name,
            'price': item.price,
          };
        }).toList(),
        'icon': getIconName(category.icon),
      };
    }).toList();
    
    final jsonContent = json.encode(jsonData);
    final file = File('categories.json'); // Provide the actual file path
    file.writeAsStringSync(jsonContent);
    
  }
}
