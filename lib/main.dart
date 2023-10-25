import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ipad_pos/POSPage.dart';
import 'dart:convert';


void main() async {
 
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load menu data from a JSON file
  final String jsonData = await File('categories.json').readAsString();

final List<Category> categories = (json.decode(jsonData) as List<dynamic>)
    .map((data) => Category.fromJson(data as Map<String, dynamic>))
    .toList();



  runApp(MyApp(categories: categories));
}

class MyApp extends StatelessWidget {
  final List<Category> categories; // Nullable List<Category>

  const MyApp({super.key, required this.categories}); // Nullable parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hindoze',
      home: POSPage(categories: categories),
    );
  }
}
