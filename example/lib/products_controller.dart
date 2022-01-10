import 'package:flutter/cupertino.dart' show BuildContext, ChangeNotifier;
import 'package:paginated_items_builder/paginated_items_builder.dart';
import 'product.dart';

class ProductsController extends ChangeNotifier {
  // not necessary, just something I use, which makes the code better.
  static ProductsController of(
    BuildContext context, {
    bool listen = true,
  }) => ProductsController();

  // add provider as dependency and replace the above return statement
  // }) => Provider.of<ProductsController>(context, listen: listen);

  PaginatedItemsResponse<Product>? _productsResponse;

  PaginatedItemsResponse<Product>? get productsResponse => _productsResponse;

  Future<void> updateProducts({
    bool reset = false,
    bool showLoaderOnReset = false,
  }) async {
    if (reset && showLoaderOnReset) {
      _productsResponse = null;
      notifyListeners();
    }

    final res = await apiFunction(
      // startKey is optional and only required when you have pagination support in api
      startKey: reset ? null : _productsResponse?.paginationKey,
    );
    if (reset || _productsResponse == null) {
      _productsResponse = res;
    } else {
      _productsResponse!.update(res);
    }
    notifyListeners();
  }

  void clear() {
    _productsResponse = null;
    notifyListeners();
  }
}

// actual repo function to fetch data from repository
Future<PaginatedItemsResponse<Product>?> apiFunction({
  // can be of any type, or null
  String? startKey,
}) async {
  // probably use dio or http to call api and get the response. and pass the contents
  // in the constructor for [PaginatedItemsResponse].

  // final res = await _api.getProducts(startKey: startKey);

  final res = await Future.delayed(const Duration(seconds: 1));

  return PaginatedItemsResponse<Product>(
    listItems: res.data?.products,
    paginationKey: res.data?.lastEvaluatedKey,
    idGetter: (product) => product.id,
  );
}
