import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final mainWalletProvider = StateNotifierProvider<MainWalletNotifier, String?>(
  (ref) => MainWalletNotifier(),
);

class MainWalletNotifier extends StateNotifier<String?> {
  static const _boxKey = 'main_wallet';
  static const _boxName = 'settings';

  MainWalletNotifier() : super(null) {
    _loadMainWallet();
  }

  void _loadMainWallet() {
    try {
      final box = Hive.box(_boxName);
      state = box.get(_boxKey) as String?;
    } catch (e) {
      state = null;
    }
  }

  Future<void> setMainWallet(String walletId) async {
    final box = Hive.box(_boxName);
    await box.put(_boxKey, walletId);
    state = walletId;
  }
}
