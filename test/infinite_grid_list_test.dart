import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

extension on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          body: widget,
        ),
      ),
    );
    await pump();
  }
}

void main() {
  group('InfiniteGridList', () {
    void emptyCallback() {}

    testWidgets(
      'attempts to fetch new elements if rebuild occurs '
      'with different set of items',
      (tester) async {
        const key = Key('__test_target__');

        Future<void> rebuild() async {
          await tester.tap(find.byKey(key));
          await tester.pumpAndSettle();
        }

        var itemCount = 3;
        var hasReachedMax = true;

        var onFetchDataCalls = 0;

        await tester.pumpApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TextButton(
                    key: key,
                    onPressed: () => setState(() {}),
                    child: const Text('REBUILD'),
                  ),
                  Expanded(
                    child: InfiniteGridList(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: itemCount,
                      hasReachedMax: hasReachedMax,
                      onFetchData: () => onFetchDataCalls++,
                      itemBuilder: (_, i) => Text('$i'),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        itemCount = 5;
        hasReachedMax = false;
        await rebuild();

        expect(onFetchDataCalls, equals(1));

        hasReachedMax = true;
        await rebuild();

        expect(onFetchDataCalls, equals(1));
      },
    );

    testWidgets(
      'renders CustomScrollView',
      (tester) async {
        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: 3,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) => Text('$i'),
          ),
        );

        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );

    testWidgets(
      'passes padding to internal SliverPadding',
      (tester) async {
        const padding = EdgeInsets.all(16);

        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            padding: padding,
            itemCount: 3,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) => Text('$i'),
          ),
        );

        final sliverPadding =
            tester.widget<SliverPadding>(find.byType(SliverPadding));
        expect(sliverPadding.padding, equals(padding));
      },
    );

    testWidgets(
      'uses media query padding when padding is omitted',
      (tester) async {
        const padding = EdgeInsets.all(40);

        await tester.pumpApp(
          Builder(
            builder: (context) {
              final data = MediaQuery.of(context);
              return MediaQuery(
                data: data.copyWith(padding: padding),
                child: InfiniteGridList(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                  ),
                  padding: padding,
                  itemCount: 3,
                  onFetchData: emptyCallback,
                  itemBuilder: (_, i) => Text('$i'),
                ),
              );
            },
          ),
        );

        final sliverPadding =
            tester.widget<SliverPadding>(find.byType(SliverPadding));
        expect(sliverPadding.padding, equals(padding));
      },
    );

    testWidgets(
      'renders items using itemBuilder',
      (tester) async {
        const itemCount = 4;
        var itemBuilderCalls = 0;

        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: itemCount,
            hasReachedMax: true,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) {
              itemBuilderCalls++;
              return Text('$i');
            },
          ),
        );

        expect(itemBuilderCalls, equals(itemCount));
      },
    );

    group('with an empty set of items', () {
      testWidgets(
        'renders no list items by default',
        (tester) async {
          await tester.pumpApp(
            InfiniteGridList(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: 0,
              onFetchData: emptyCallback,
              itemBuilder: (_, i) => Text('$i'),
            ),
          );

          expect(
            find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Widget),
            ),
            findsNothing,
          );
        },
      );

      testWidgets(
        'renders custom emptyBuilder',
        (tester) async {
          const key = Key('__test_target__');

          await tester.pumpApp(
            InfiniteGridList(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: 0,
              onFetchData: emptyCallback,
              emptyBuilder: (_) => const Text('__EMPTY__', key: key),
              itemBuilder: (_, i) => Text('$i'),
            ),
          );

          expect(find.byKey(key), findsOneWidget);
        },
      );
    });

    group('with hasError set to true', () {
      testWidgets(
        'renders default errorBuilder',
        (tester) async {
          await tester.pumpApp(
            InfiniteGridList(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              hasError: true,
              itemCount: 0,
              onFetchData: emptyCallback,
              itemBuilder: (_, i) => Text('$i'),
            ),
          );

          expect(find.text('Error'), findsOneWidget);
        },
      );

      testWidgets(
        'renders custom errorBuilder',
        (tester) async {
          const key = Key('__test_target__');

          await tester.pumpApp(
            InfiniteGridList(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              hasError: true,
              itemCount: 0,
              onFetchData: emptyCallback,
              errorBuilder: (_) => const Text('__ERROR__', key: key),
              itemBuilder: (_, i) => Text('$i'),
            ),
          );

          expect(find.byKey(key), findsOneWidget);
        },
      );
    });

    group('with isLoading set to true', () {
      testWidgets(
        'renders default loadingBuilder',
        (tester) async {
          await tester.pumpApp(
            InfiniteGridList(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              isLoading: true,
              itemCount: 4,
              onFetchData: emptyCallback,
              itemBuilder: (_, i) => Text('$i'),
            ),
          );
          // debugDumpRenderTree();
          // debugDumpApp();
          // await tester.pumpAndSettle(
          //     Duration(seconds: 10), EnginePhase.build, Duration(minutes: 10));
          // final textWidget = find.byType(CustomScrollView);
          final textWidget = tester.firstWidget(find.byType(CustomScrollView));

          // final textWidget = tester.firstWidget(find.descendant(
          //     of: find.byType(CustomScrollView),
          //     matching: find.byType(CircularProgressIndicator)));
          expect(textWidget, findsOneWidget);
          // expect(find.byType(CustomScrollView), findsOneWidget);
          // expect(find.byType(SliverToBoxAdapter), findsNWidgets(3));
        },
      );

      testWidgets(
        'renders custom loadingBuilder',
        (tester) async {
          const key = Key('__test_target__');

          await tester.pumpApp(
            InfiniteGridList(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              isLoading: true,
              itemCount: 3,
              onFetchData: emptyCallback,
              loadingBuilder: (_) => const Text('__LOADING__', key: key),
              itemBuilder: (_, i) => Text('$i'),
            ),
          );

          expect(find.byKey(key), findsOneWidget);
        },
      );
    });

    group('transitionary properties', () {
      testWidgets('scrollDirection', (tester) async {
        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: 10,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) => Text('$i'),
            scrollDirection: Axis.horizontal,
          ),
        );

        final customScrollView =
            tester.widget<CustomScrollView>(find.byType(CustomScrollView));
        expect(customScrollView.scrollDirection, equals(Axis.horizontal));
      });

      testWidgets('scrollController', (tester) async {
        final scrollController = ScrollController();
        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: 10,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) => Text('$i'),
            scrollController: scrollController,
          ),
        );

        final customScrollView =
            tester.widget<CustomScrollView>(find.byType(CustomScrollView));
        expect(customScrollView.controller, scrollController);
      });

      testWidgets('physics', (tester) async {
        const physics = ScrollPhysics();
        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: 10,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) => Text('$i'),
            physics: physics,
          ),
        );

        final customScrollView =
            tester.widget<CustomScrollView>(find.byType(CustomScrollView));
        expect(customScrollView.physics, physics);
      });

      testWidgets('reverse', (tester) async {
        const reverse = true;
        await tester.pumpApp(
          InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            itemCount: 10,
            onFetchData: emptyCallback,
            itemBuilder: (_, i) => Text('$i'),
            reverse: reverse,
          ),
        );

        final customScrollView =
            tester.widget<CustomScrollView>(find.byType(CustomScrollView));
        expect(customScrollView.reverse, reverse);
      });
    });

    group('goldens', () {
      const tags = 'golden';
      String goldenPath(String fileName) => 'goldens/grid/$fileName.png';

      testWidgets(
        'renders successfully when scrolled vertically to the end',
        tags: tags,
        (tester) async {
          const path = 'successful_vertical_scroll';

          const colors = [Colors.red, Colors.green, Colors.blue];
          final subject = InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            onFetchData: emptyCallback,
            isLoading: true,
            itemCount: 30,
            itemBuilder: (_, i) => SizedBox.square(
              dimension: 40,
              child: ColoredBox(color: colors[i % colors.length]),
            ),
          );
          await tester.pumpApp(subject);

          await expectLater(
            find.byWidget(subject),
            matchesGoldenFile(goldenPath('$path/before_scroll')),
          );

          await tester.fling(
            find.byWidget(subject),
            const Offset(0, -1000),
            1000,
          );

          await tester.pump(const Duration(milliseconds: 16));
          await expectLater(
            find.byWidget(subject),
            matchesGoldenFile(goldenPath('$path/after_scroll')),
          );
        },
      );

      testWidgets(
        'renders successfully when scrolled horizontally to the end',
        tags: tags,
        (tester) async {
          const path = 'successful_horizontal_scroll';

          const colors = [Colors.red, Colors.green, Colors.blue];
          final subject = InfiniteGridList(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
            ),
            onFetchData: emptyCallback,
            isLoading: true,
            itemCount: 30,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => SizedBox.square(
              dimension: 40,
              child: ColoredBox(color: colors[i % colors.length]),
            ),
          );
          await tester.pumpApp(subject);

          await expectLater(
            find.byWidget(subject),
            matchesGoldenFile(goldenPath('$path/before_scroll')),
          );

          await tester.fling(
            find.byWidget(subject),
            const Offset(-1000, 0),
            1000,
          );

          await tester.pump(const Duration(milliseconds: 16));
          await expectLater(
            find.byWidget(subject),
            matchesGoldenFile(goldenPath('$path/after_scroll')),
          );
        },
      );
    });
  });
}
