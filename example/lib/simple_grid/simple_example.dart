import 'package:flutter/material.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class SimpleGridExample extends StatefulWidget {
  const SimpleGridExample({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) {
        return const SimpleGridExample();
      },
    );
  }

  @override
  SimpleGridExampleState createState() => SimpleGridExampleState();
}

class SimpleGridExampleState extends State<SimpleGridExample> {
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
      appBar: AppBar(
        title: const Text('Simple Example'),
      ),
      body: InfiniteGridList(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: _items.length,
        isLoading: _isLoading,
        onFetchData: _fetchData,
        itemBuilder: (context, index) {
          return ColoredBox(
            color: index.isOdd ? Colors.red : Colors.blue,
            child: Center(child: Text(_items[index])),
          );
        },
      ),
    );
  }
}
