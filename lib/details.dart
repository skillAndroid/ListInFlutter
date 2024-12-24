// Create a ProductDetailsScreen
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/list.dart';
import 'package:list_in/main.dart';


class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final List<Product> recommendedProducts;
  
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.recommendedProducts,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Find the current product from sampleProducts
    final product = sampleProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => throw Exception('Product not found'),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(product.name),
      ),
      body: CustomScrollView(
        slivers: [
          // Product details
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product images carousel
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: product.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                // Product details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product.location} • \$${product.price}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (product.isNew)
                        Chip(
                          label: const Text('New'),
                          backgroundColor: Colors.green.shade100,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Recommended products grid
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recommendedProduct = widget.recommendedProducts[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to new product details while keeping current in stack
                      context.push(
                        AppPath.productDetails.replaceAll(':id', recommendedProduct.id),
                        extra: getRecommendedProducts(recommendedProduct.id),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: recommendedProduct.images.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendedProduct.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${recommendedProduct.price}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: widget.recommendedProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


List<Product> getRecommendedProducts(String currentProductId) {
  return sampleProducts
    .where((p) => p.id != currentProductId)
    .take(6)
    .toList();
}
