import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: 0, // TODO: Replace with actual categories count
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {
                // TODO: Navigate to category products
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 48),
                  SizedBox(height: 8),
                  Text('Category Name'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
