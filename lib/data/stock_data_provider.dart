import 'stock_item.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod/riverpod.dart';

final stockProvider = StateNotifierProvider<StockNotifier, List<StockItem>>(
  (ref) => StockNotifier(),
);
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class StockNotifier extends StateNotifier<List<StockItem>> {
  StockNotifier() : super(List.generate(50, (index) => StockItem.generate()));

  void loadMore() {
    final moreItems = List.generate(50, (index) => StockItem.generate());
    state = [...state, ...moreItems];
  }
}
