import 'package:flutter/foundation.dart';

/// Navigasi antar tab dan permintaan membuka kategori dari beranda.
class AppNav {
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);
  static final ValueNotifier<String?> categoryRequest =
      ValueNotifier<String?>(null);
}
