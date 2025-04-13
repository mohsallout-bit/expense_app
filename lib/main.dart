import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'services/database_service.dart';
import 'core/app_theme.dart';
import 'views/home.dart';
import 'providers/hive_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveInit = ref.watch(hiveReadyProvider);

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: hiveInit.when(
        data: (_) => const HomeScreen(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, stack) =>
                Scaffold(body: Center(child: Text('حدث خطأ: $error'))),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final scale = mediaQuery.textScaleFactor.clamp(0.8, 1.2);

        return MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(top: mediaQuery.padding.top),
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
    );
  }
}
