import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import 'category_products_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_constants.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _searchQuery = '';
  List<dynamic> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    // Fetch categories when the page loads
    _loadCategories();
  }
  Future<void> _loadCategories() async {
    try {
      await Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      // Reset search when refreshing
      if (_searchQuery.isNotEmpty) {
        _filterCategories(_searchQuery);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCategories(String query) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCategories = [];
      } else {
        _filteredCategories = categoryProvider.categories.where((category) {
          return category['name'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'Refresh categories',
          ),
        ],
      ),
      body: RefreshIndicator(        onRefresh: _loadCategories,
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categoryProvider.categories.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No categories found',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            // Filtered categories based on search query
            final categoriesToShow = _searchQuery.isEmpty ? categoryProvider.categories : _filteredCategories;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: _filterCategories,
                    decoration: InputDecoration(
                      labelText: 'Search categories',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _filterCategories('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                if (categoryProvider.isLoading)
                  const LinearProgressIndicator(),
                if (_searchQuery.isNotEmpty && _filteredCategories.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No categories matching "$_searchQuery"',
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: categoriesToShow.length,                      itemBuilder: (context, index) {
                        final category = categoriesToShow[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryProductsPage(
                                    categoryId: category['id'],
                                    categoryName: category['name'],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Hero(
                                      tag: 'category_${category['id']}',
                                      child: category['image'] != null && category['image'].isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: '${ApiConstants.mediaBaseUrl}${category['image']}',
                                              placeholder: (context, url) => const Center(
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(Icons.category, size: 48),
                                              fit: BoxFit.contain,
                                            )
                                          : const Icon(Icons.category, size: 48),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    category['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
