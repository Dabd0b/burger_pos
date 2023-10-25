import 'package:flutter/material.dart';
import 'menu_edit.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'dart:io';
class POSPage extends StatefulWidget {
  final List<Category> categories;

  const POSPage({super.key, required this.categories});

  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  double total = 0.0;
  List<Item> cart = [];
  Category? selectedCategory;
  int orderNumber=1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hindoze'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MenuEditPage(widget.categories),
                ),
              );
            },
          ),
        ],
      ),
      body:  Column(
        children: <Widget>[
             const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.categories.map((category) {
              return ElevatedButton(
                onPressed: () {
                  openSideList(category);
                },
                child: Column(
                  children: <Widget>[
                    Icon(category.icon, size: 64.0),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 1,
    childAspectRatio: 15
  ),
  itemCount: cart.length,
  itemBuilder: (context, index) {
    final item = cart[index];
    return ListTile(
      title: Text('${item.name} x${item.quantity}'),
      subtitle: Text('${item.price.toStringAsFixed(2)} L.E'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              increaseQuantity(item);
            },
          ),
          Text('${item.quantity}'),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              decreaseQuantity(item);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              removeItem(item);
            },
          ),
        ],
      ),
    );
  },
),
          ),
          Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Total: ${total.toStringAsFixed(2)} L.E',
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    ),
    Visibility(
      visible: cart.isNotEmpty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
         
          //const SizedBox(height: 16.0), // Add vertical space between the buttons
          ElevatedButton(//icon: const Icon(Icons.recycling),
            onPressed: () {
              clearCart();
            },child: const Column(
                  children: <Widget>[
                    Icon(Icons.recycling, size: 32.0),
                    Text('Clear'),
                  ],
                ),
          ),
          
           ElevatedButton(//icon: const Icon(Icons.receipt_long),
            onPressed: () async {
              const String title = 'Hindoze';
              await Printing.directPrintPdf(printer: const Printer(url: 'XP-80C'),
                 onLayout: (format) async {
                   final pdf = await _generatePdf(format, title, cart, orderNumber, total);
                    await Printing.directPrintPdf( printer: const Printer(url: 'XP-80C'),
                       onLayout: (format) => pdf);
                       return pdf;
                }
             );
              orderNumber++;
              clearCart();
            },child: const Column(
                  children: <Widget>[
                    Icon(Icons.receipt_sharp, size: 32.0),
                    Text('Print'),
                  ],
                ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16.0),
  ],
)

        ],
      ),
    );
  }

  void addToCart(Item item) {
    setState(() {
      cart.add(item);
      total += item.price;
      item.quantity=1;
    });
  }

  void increaseQuantity(Item item) {
  setState(() {
    item.quantity++; // Increase the quantity
    total += item.price;
  });
}

void decreaseQuantity(Item item) {
  setState(() {
    if (item.quantity > 1) {
      item.quantity--; // Decrease the quantity (if it's greater than 1)
      total -= item.price;
    }
  });
}

void removeItem(Item item) {
  setState(() {
    total -= (item.price * item.quantity); // Deduct the item's total price
    cart.remove(item); // Remove the item from the cart
  });
}


 

  void clearCart() {
    setState(() {
      cart.clear();
      total = 0.0;
    });
  }

  void openSideList(Category category) {
    setState(() {
      selectedCategory = category;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: category.items.length,
          itemBuilder: (context, index) {
            final item = category.items[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text('${item.price.toStringAsFixed(2)} L.E'),
              onTap: () {
                if (!cart.contains(item)) {
                      addToCart(item);
                    }else{
                      increaseQuantity(item);
                    }
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

IconData getIcon(String iconName) {
  switch (iconName) {
    case "fastfood":
      return Icons.fastfood;
    case "local_drink":
      return Icons.local_drink;
    case "local_dining":
      return Icons.local_dining;
    // Add more cases for other icons if needed
    default:
      return Icons.error; // Default to an error icon if the name is not recognized
  }
}

Future<Uint8List> _generatePdf(PdfPageFormat format, String title, List<Item> cart, int orderNumber, double total) async {
  final pdf = pw.Document(
    version: PdfVersion.pdf_1_5,
    compress: true,
  );

  

  final font = await PdfGoogleFonts.nunitoExtraLight();

  pdf.addPage(
    pw.Page(
      pageFormat: format,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title
            pw.SizedBox(
              width: double.infinity,
              child: pw.FittedBox(
                child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 24)),
              ),
            ),
            // Order Number and Date & Time
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Order Number: $orderNumber', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Date & Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.Divider(), // Add a divider

            // List of cart items
            for (final item in cart) ...[
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.name, style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('${item.price.toStringAsFixed(2)} L.E', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Text('   Qty: ${item.quantity.toString()}', style: const pw.TextStyle(fontSize: 10)), // Update with actual quantity
                  pw.Text('   ${(item.price * item.quantity).toStringAsFixed(2)} L.E', style: const pw.TextStyle(fontSize: 10)), // Update with the total price
                ],
              ),
              pw.Divider(),
            ],

            // Total
            pw.Divider(), // Add a divider before the total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:', style: const pw.TextStyle(fontSize: 18)),
                pw.Text(
                  '${total.toStringAsFixed(2)} L.E',
                  style: const pw.TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
  final output = Directory("receipts");
   final pdfName = '${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}_Order_$orderNumber.pdf';
   final file = File('${output.path}/$pdfName');
    await file.writeAsBytes(await pdf.save());

  return pdf.save();
}




 



class Item {
  final String name;
  final double price;
  int quantity = 1;


  Item({
    required this.name,
    required this.price,

  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,

    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      price: json['price'].toDouble(),

    );
  }
}

class Category {
  final String name;
  List<Item> items;
  final IconData icon;

  Category({
    required this.name,
    this.items = const [],
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'icon': icon.codePoint,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      items: List<Item>.from(json['items'].map((item) => Item.fromJson(item))),
      icon: getIcon(json['icon']),
    );
  }
}
