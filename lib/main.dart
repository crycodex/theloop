import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/loop_theme.dart';

void main() {
  runApp(const ProviderScope(child: LoopApp()));
}

class LoopApp extends ConsumerWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Loop',
      debugShowCheckedModeBanner: false,
      theme: LoopTheme.light,
      routerConfig: router,
    );
  }
}
