import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final hiveReadyProvider = FutureProvider<void>((ref) async {
  await DatabaseService.initialize();
});
