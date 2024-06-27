import 'dart:math';

class StockItem {
  final String name;
  final String producer;
  final int qty;

  StockItem({
    required this.name,
    required this.producer,
    required this.qty,
  });

  static String _randomString(int minLength, int maxLength) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
    final rnd = Random();
    final length = minLength + rnd.nextInt(maxLength - minLength);
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
  }

  static StockItem generate() {
    return StockItem(
      name: _randomString(50, 100),
      producer: _randomString(20, 50),
      qty: Random().nextInt(100),
    );
  }
}
