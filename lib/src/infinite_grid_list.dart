import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:very_good_infinite_list/src/defaults.dart';
import 'package:very_good_infinite_list/src/sliver_infinite_grid_list.dart';
import 'package:very_good_infinite_list/src/sliver_infinite_list.dart';

/// {@macro infinite_list}
/// A widget that makes it easy to declaratively load and display paginated data
/// as a list.
///
/// When the list is scrolled to the end, the [onFetchData] callback will be
/// called.
///
/// When there are too few items to fill the widget's allocated space,
/// [onFetchData] will be called automatically.
///
/// The [itemCount], [hasReachedMax], [onFetchData] and [itemBuilder] must be
/// provided and cannot be `null`.
/// {@endtemplate}
///
/// See also:
/// - [SliverInfiniteGridList]. The sliver version of this widget.
class InfiniteGridList extends StatelessWidget {
  /// {@macro infinite_list}
  const InfiniteGridList({
    super.key,
    required this.itemCount,
    required this.onFetchData,
    required this.itemBuilder,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.cacheExtent,
    this.debounceDuration = defaultDebounceDuration,
    this.reverse = false,
    this.isLoading = false,
    this.hasError = false,
    this.hasReachedMax = false,
    this.padding,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    required this.gridDelegate,
  });

  /// {@template scroll_controller}
  /// An optional [ScrollController] to be used by the internal [ScrollView].
  /// {@endtemplate}
  final ScrollController? scrollController;

  /// {@template scroll_direction}
  /// An optional [Axis] to be used by the internal [ScrollView] that defines
  /// the axis of scroll.
  /// {@endtemplate}
  final Axis scrollDirection;

  /// {@template physics}
  /// An optional [ScrollPhysics] to be used by the internal [ScrollView].
  /// {@endtemplate}
  final ScrollPhysics? physics;

  /// {@template debounce_duration}
  /// The duration with which calls to [onFetchData] will be debounced.
  ///
  /// Is set to [defaultDebounceDuration] by default and cannot be `null`.
  /// {@endtemplate}
  final Duration debounceDuration;

  /// {@template reverse}
  /// Indicates if the list should be reversed.
  ///
  /// If set to `true`, the list of items, [loadingBuilder] and [errorBuilder]
  /// will be rendered from bottom to top.
  /// {@endtemplate}
  final bool reverse;

  /// {@template item_count}
  /// The amount of items that need to be rendered by the [itemBuilder].
  ///
  /// Is required and cannot be `null`.
  /// {@endtemplate}
  final int itemCount;

  /// {@template is_loading}
  /// Indicates if new items are currently being loaded.
  ///
  /// While set to `true`, the [onFetchData] callback will not be triggered
  /// and the [loadingBuilder] will be rendered.
  ///
  /// Is set to `false` by default and cannot be `null`.
  /// {@endtemplate}
  final bool isLoading;

  /// {@template has_error}
  /// Indicates if an error has occurred.
  ///
  /// While set to `true`, the [onFetchData] callback will not be triggered
  /// and the [errorBuilder] will be rendered.
  ///
  /// Is set to `false` by default and cannot be `null`.
  /// {@endtemplate}
  final bool hasError;

  /// {@template has_reached_max}
  /// Indicates if the end of the data source has been reached and no more
  /// data can be fetched.
  ///
  /// While set to `true`, the [onFetchData] callback will not be triggered.
  ///
  /// Is set to `false` by default and cannot be `null`.
  /// {@endtemplate}
  final bool hasReachedMax;

  /// {@template on_fetch_data}
  /// The callback method that's called whenever the list is scrolled to the end
  /// (meaning the top when [reverse] is `true`, or the bottom otherwise).
  ///
  /// In normal operation, this method should trigger new data to be fetched and
  /// [isLoading] to be set to `true`.
  ///
  /// Exactly when this is called depends on the [cacheExtent].
  /// Additionally, every call to this will be debounced by the provided
  /// [debounceDuration].
  ///
  /// Is required and cannot be `null`.
  /// {@endtemplate}
  final VoidCallback onFetchData;

  /// See [RenderViewportBase.cacheExtent]
  final double? cacheExtent;

  /// {@template padding}
  /// The amount of space by which to inset the list of items.
  ///
  /// Is optional and can be `null`.
  /// {@endtemplate}
  final EdgeInsets? padding;

  /// {@template empty_builder}
  /// An optional builder that's shown when the list of items is empty.
  ///
  /// If `null`, nothing is shown.
  /// {@endtemplate}
  final WidgetBuilder? emptyBuilder;

  /// {@template loading_builder}
  /// An optional builder that's shown at the end of the list when [isLoading]
  /// is `true`.
  ///
  /// Defaults to [defaultInfiniteGridListLoadingBuilder].
  /// {@endtemplate}
  final WidgetBuilder? loadingBuilder;

  /// {@template error_builder}
  /// An optional builder that's shown when [hasError] is not `null`.
  ///
  /// Defaults to [defaultInfiniteGridListErrorBuilder].
  final WidgetBuilder? errorBuilder;

  /// {@template item_builder}
  /// The builder used to build a widget for every index of the `itemCount`.
  ///
  /// Is required and cannot be `null`.
  /// {@endtemplate}
  final ItemBuilder itemBuilder;

  /// {@template grid_delegate}
  /// Creates a sliver that places multiple box children in a two dimensional arrangement.
  ///
  /// Is required and cannot be `null`.
  /// {@endtemplate}
  final SliverGridDelegate gridDelegate;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: scrollController,
      physics: physics,
      cacheExtent: cacheExtent,
      slivers: [
        _ContextualSliverPadding(
          padding: padding,
          scrollDirection: scrollDirection,
          sliver: SliverInfiniteGridList(
            itemCount: itemCount,
            onFetchData: onFetchData,
            itemBuilder: itemBuilder,
            debounceDuration: debounceDuration,
            isLoading: isLoading,
            hasError: hasError,
            hasReachedMax: hasReachedMax,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            emptyBuilder: emptyBuilder,
            gridDelegate: gridDelegate,
          ),
        ),
        if (isLoading)
          SliverToBoxAdapter(
            child: loadingBuilder != null
                ? loadingBuilder!(context)
                : defaultInfiniteListLoadingBuilder(context),
          ),
      ],
    );
  }
}

/// To work just as a plain ListView, It should automatically apply a
/// media query padding if the passing options is omitted or null.
class _ContextualSliverPadding extends StatelessWidget {
  const _ContextualSliverPadding({
    required this.scrollDirection,
    required this.sliver,
    this.padding,
  });

  final EdgeInsets? padding;
  final Axis scrollDirection;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry? effectivePadding = padding;
    final mediaQuery = MediaQuery.maybeOf(context);

    var sliver = this.sliver;
    if (padding == null) {
      if (mediaQuery != null) {
        // Automatically pad sliver with padding from MediaQuery.
        late final mediaQueryHorizontalPadding =
            mediaQuery.padding.copyWith(top: 0, bottom: 0);
        late final mediaQueryVerticalPadding =
            mediaQuery.padding.copyWith(left: 0, right: 0);
        // Consume the main axis padding with SliverPadding.
        effectivePadding = scrollDirection == Axis.vertical
            ? mediaQueryVerticalPadding
            : mediaQueryHorizontalPadding;
        // Leave behind the cross axis padding.
        sliver = MediaQuery(
          data: mediaQuery.copyWith(
            padding: scrollDirection == Axis.vertical
                ? mediaQueryHorizontalPadding
                : mediaQueryVerticalPadding,
          ),
          child: sliver,
        );
      }
    }

    if (effectivePadding != null) {
      sliver = SliverPadding(padding: effectivePadding, sliver: sliver);
    }
    return sliver;
  }
}
