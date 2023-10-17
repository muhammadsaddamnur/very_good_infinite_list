import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class SliverGridExample extends StatefulWidget {
  const SliverGridExample({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) {
        return const SliverGridExample();
      },
    );
  }

  @override
  SliverGridExampleState createState() => SliverGridExampleState();
}

class SliverGridExampleState extends State<SliverGridExample> {
  var _items = <String>[];
  var _isLoading = false;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _items = List.generate(_items.length + 10, (i) => 'Item $i');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Sliver Example'),
            ),
          ),
          SliverInfiniteGridList(
            itemCount: _items.length,
            isLoading: _isLoading,
            onFetchData: _fetchData,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return ColoredBox(
                color: index.isOdd ? Colors.red : Colors.blue,
                child: Center(child: Text(_items[index])),
              );
            },
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
