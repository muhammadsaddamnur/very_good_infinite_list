import 'package:example/advanced/people_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class AdvancedGridExample extends StatelessWidget {
  const AdvancedGridExample({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (_) => PeopleCubit(),
          child: const AdvancedGridExample(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PeopleCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Example'),
      ),
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: InfiniteGridList(
              itemCount: state.values.length,
              isLoading: state.isLoading,
              hasError: state.error != null,
              hasReachedMax: state.hasReachedMax,
              onFetchData: () => context.read<PeopleCubit>().loadData(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return ColoredBox(
                  color: index.isOdd ? Colors.red : Colors.blue,
                  child: Center(child: Text(state.values[index].name)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
            bottom: 8,
          ),
          child: Text(
            'A maximum of 24 items can be fetched.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
