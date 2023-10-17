import 'package:flutter/widgets.dart';
import 'package:very_good_infinite_list/src/callback_debouncer.dart';
import 'package:very_good_infinite_list/src/defaults.dart';
import 'package:very_good_infinite_list/src/infinite_list.dart';

/// The sliver version of [InfiniteGridList].
///
/// {@macro infinite_list}
///
/// As a infinite list, it is supposed to be the last sliver in the current
/// [ScrollView]. Otherwise, re-fetching data will have an unintuitive behavior.
class SliverInfiniteGridList extends StatefulWidget {
  /// Constructs a [SliverInfiniteGridList].
  const SliverInfiniteGridList({
    super.key,
    required this.itemCount,
    required this.onFetchData,
    required this.itemBuilder,
    this.debounceDuration = defaultDebounceDuration,
    this.isLoading = false,
    this.hasError = false,
    this.hasReachedMax = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    required this.gridDelegate,
  });

  /// {@macro debounce_duration}
  final Duration debounceDuration;

  /// {@macro item_count}
  final int itemCount;

  /// {@macro is_loading}
  final bool isLoading;

  /// {@macro has_error}
  final bool hasError;

  /// {@macro has_reached_max}
  final bool hasReachedMax;

  /// {@macro on_fetch_data}
  final VoidCallback onFetchData;

  /// {@macro empty_builder}
  final WidgetBuilder? emptyBuilder;

  /// {@macro loading_builder}
  final WidgetBuilder? loadingBuilder;

  /// {@macro error_builder}
  final WidgetBuilder? errorBuilder;

  /// {@macro item_builder}
  final ItemBuilder itemBuilder;

  /// {@macro grid_delegate}
  final SliverGridDelegate gridDelegate;

  @override
  State<SliverInfiniteGridList> createState() => _SliverInfiniteGridListState();
}

class _SliverInfiniteGridListState extends State<SliverInfiniteGridList> {
  late final CallbackDebouncer debounce;

  int? _lastFetchedIndex;

  @override
  void initState() {
    super.initState();
    debounce = CallbackDebouncer(widget.debounceDuration);
    attemptFetch();
  }

  @override
  void didUpdateWidget(SliverInfiniteGridList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.hasReachedMax && oldWidget.hasReachedMax) {
      attemptFetch();
    }
  }

  @override
  void dispose() {
    super.dispose();
    debounce.dispose();
  }

  void attemptFetch() {
    if (!widget.hasReachedMax && !widget.isLoading && !widget.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debounce(widget.onFetchData);
      });
    }
  }

  void onBuiltLast(int lastItemIndex) {
    if (_lastFetchedIndex != lastItemIndex) {
      _lastFetchedIndex = lastItemIndex;
      attemptFetch();
    }
  }

  WidgetBuilder get loadingBuilder =>
      widget.loadingBuilder ?? defaultInfiniteListLoadingBuilder;

  WidgetBuilder get errorBuilder =>
      widget.errorBuilder ?? defaultInfiniteListErrorBuilder;

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.itemCount != 0;

    final showEmpty = !widget.isLoading &&
        widget.itemCount == 0 &&
        widget.emptyBuilder != null;
    final showBottomWidget = showEmpty || widget.hasError;
    final effectiveItemCount =
        (!hasItems ? 0 : widget.itemCount) + (showBottomWidget ? 1 : 0);
    final lastItemIndex = effectiveItemCount - 1;

    return widget.itemCount == 0
        ? SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                if (widget.hasError) {
                  return errorBuilder(context);
                } else {
                  return widget.emptyBuilder != null
                      ? widget.emptyBuilder!(context)
                      : const SizedBox();
                }
              },
            ),
          )
        : SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == lastItemIndex) {
                  onBuiltLast(lastItemIndex);
                }
                if (index == lastItemIndex && showBottomWidget) {
                  if (widget.hasError) {
                    return errorBuilder(context);
                  } else {
                    return widget.emptyBuilder!(context);
                  }
                }
                return widget.itemBuilder(context, index);
              },
              childCount: effectiveItemCount,
            ),
          );
  }
}
