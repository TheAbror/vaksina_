import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaksina/data/stock_data_provider.dart';

class StockView extends ConsumerStatefulWidget {
  const StockView({Key? key}) : super(key: key);

  @override
  ConsumerState<StockView> createState() => _StockViewState();
}

class _StockViewState extends ConsumerState<StockView> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _scrollToSelectedIndex();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      //if reaches max, will generate more data
      ref.read(stockProvider.notifier).loadMore();
    }
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final currentIndex = ref.read(selectedIndexProvider);
      final maxIndex = ref.read(stockProvider).length - 1;

      if (event.logicalKey == LogicalKeyboardKey.arrowDown && currentIndex < maxIndex) {
        ref.read(selectedIndexProvider.notifier).state = currentIndex + 1;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && currentIndex > 0) {
        ref.read(selectedIndexProvider.notifier).state = currentIndex - 1;
      }
      _scrollToSelectedIndex();
    }
  }

  var itemHeight = 72.0;

  void _scrollToSelectedIndex() {
    final selectedIndex = ref.read(selectedIndexProvider);
    final listViewHeight = _scrollController.position.viewportDimension;

    final itemOffset = selectedIndex * itemHeight;
    final currentScrollOffset = _scrollController.offset;
    final topVisibleOffset = currentScrollOffset;
    final bottomVisibleOffset = currentScrollOffset + listViewHeight;

    final padding = listViewHeight * 0.1;

    if (itemOffset < topVisibleOffset + padding ||
        itemOffset + itemHeight > bottomVisibleOffset - padding) {
      final targetScrollOffset =
          (selectedIndex * itemHeight) - (listViewHeight / 2) + (itemHeight / 2);

      _scrollController.animateTo(
        targetScrollOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockItems = ref.watch(stockProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock View')),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _onKey,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(stockProvider.notifier).loadMore();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: stockItems.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = stockItems[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = index;
                },
                child: Container(
                  color: selectedIndex == index ? Colors.blueAccent : Colors.transparent,
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('Product: ', style: _styleBold()),
                        Expanded(child: Text(item.name, style: _styleOrdinary())),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text('Producer: ', style: _styleBold()),
                        Expanded(child: Text(item.producer, style: _styleOrdinary())),
                      ],
                    ),
                    trailing: Text('Quantity: ${item.qty}', style: _styleOrdinary()),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  TextStyle _styleOrdinary() => const TextStyle(
        color: Colors.white,
        overflow: TextOverflow.ellipsis,
      );
  TextStyle _styleBold() => const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );
}
