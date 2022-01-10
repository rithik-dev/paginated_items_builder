import 'package:flutter/material.dart';
import 'package:paginated_items_builder/paginated_items_builder.dart';

import 'product.dart';
import 'products_controller.dart';

//******************************************************************
// WITH CONTROLLER
//******************************************************************

// ignore: must_be_immutable
class ProductsListWithController extends StatelessWidget {
  ProductsListWithController({
    Key? key,
  }) : super(key: key);

  ProductsController? _productsController;

  @override
  Widget build(BuildContext context) {
    _productsController = ProductsController.of(context);

    return SafeArea(
      child: Scaffold(
        body: PaginatedItemsBuilder<Product>(
          fetchPageData: (reset) => _productsController!.updateProducts(
            reset: reset,
            showLoaderOnReset: reset,
          ),
          response: _productsController!.productsResponse,
          itemBuilder: (ctx, idx, product) => Text(product.id),
        ),
      ),
    );
  }
}

//******************************************************************
// WITHOUT CONTROLLER
//******************************************************************

// ignore: must_be_immutable
class ProductsListWithoutController extends StatelessWidget {
  const ProductsListWithoutController({
    Key? key,
  }) : super(key: key);

  Future<PaginatedItemsResponse<Product>?> updateProducts() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PaginationItemsStateHandler<Product>(
          pageFetchData: (reset) => updateProducts(
              // reset: reset,
              // showLoaderOnReset: reset,
              ),
          itemsBuilder: (response, fetchPageData) {
            return PaginatedItemsBuilder<Product>(
              fetchPageData: fetchPageData,
              response: response,
              itemBuilder: (ctx, idx, product) => Text(product.id),
            );
          },
        ),
      ),
    );
  }
}
