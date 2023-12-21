import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider((ref) => Counter(0));

class Counter {
  int id = 0;

  Counter(this.id);
}

class TestRiverpod extends ConsumerWidget {
  const TestRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider).id;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).update((state) {
            return Counter(state.id + 1);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Center(
            child: Text("Counter: $counter"),
          )
        ],
      ),
    );
  }
}
