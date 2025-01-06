import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PreloadPageControllerListIn extends ScrollController {
  PreloadPageControllerListIn({
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 0.95,
  }) : assert(viewportFraction > 0.0);

  final int initialPage;
  final bool keepPage;
  final double viewportFraction;
  double? get page {
    assert(
      positions.isNotEmpty,
      'PageController.page cannot be accessed before a PageView is built with it.',
    );
    assert(
      positions.length == 1,
      'The page property cannot be read when multiple PageViews are attached to '
      'the same PageController.',
    );
    final _PagePosition position = this.position as _PagePosition;
    return position.page;
  }

  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    final _PagePosition position = this.position as _PagePosition;
    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  void jumpToPage(int page) {
    final _PagePosition position = this.position as _PagePosition;
    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }

  Future<void> nextPage({required Duration duration, required Curve curve}) {
    return animateToPage(page!.round() + 1, duration: duration, curve: curve);
  }

  Future<void> previousPage(
      {required Duration duration, required Curve curve}) {
    return animateToPage(page!.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _PagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final _PagePosition pagePosition = position as _PagePosition;
    pagePosition.viewportFraction = viewportFraction;
  }
}

class PageMetrics extends FixedScrollMetrics {
  PageMetrics({
    required super.minScrollExtent,
    required super.maxScrollExtent,
    required super.pixels,
    required super.viewportDimension,
    required super.axisDirection,
    required super.devicePixelRatio,
    required this.viewportFraction,
  });

  @override
  PageMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    double? viewportFraction,
    double? devicePixelRatio,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }

  double? get page {
    return math.max(0.0, pixels.clamp(minScrollExtent, maxScrollExtent)) /
        math.max(1.0, viewportDimension * viewportFraction);
  }

  final double viewportFraction;
}

class _PagePosition extends ScrollPositionWithSingleContext
    implements PageMetrics {
  _PagePosition({
    required super.physics,
    required super.context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    super.oldPosition,
  })  : assert(viewportFraction > 0.0),
        _viewportFraction = viewportFraction,
        _pageToUseOnStartup = initialPage.toDouble(),
        super(
          initialPixels: null,
          keepScrollOffset: keepPage,
        );

  final int initialPage;
  double _pageToUseOnStartup;

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    final double? oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
  }

  double? getPageFromPixels(double? pixels, double? viewportDimension) {
    if (pixels == null || viewportDimension == null) {
      return null;
    }
    return math.max(0.0, pixels) /
        math.max(1.0, viewportDimension * viewportFraction);
  }

  double getPixelsFromPage(double page) {
    return page *
        (hasViewportDimension ? viewportDimension : 0) *
        viewportFraction;
  }

  @override
  double? get page => hasPixels
      ? getPageFromPixels(
          hasContentDimensions
              ? pixels.clamp(minScrollExtent, maxScrollExtent)
              : null,
          hasViewportDimension ? viewportDimension : null,
        )
      : null;

  @override
  void saveScrollOffset() {
    PageStorage.of(context.storageContext).writeState(
        context.storageContext,
        getPageFromPixels(hasPixels ? pixels : null,
            hasViewportDimension ? viewportDimension : null));
  }

  @override
  void restoreScrollOffset() {
    if (hasPixels == true) {
      final double? value = PageStorage.of(context.storageContext)
          .readState(context.storageContext);
      if (value != null) _pageToUseOnStartup = value;
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final double? oldViewportDimensions =
        (hasViewportDimension) ? this.viewportDimension : null;
    final bool result = super.applyViewportDimension(viewportDimension);
    final double? oldPixels = (hasPixels) ? pixels : null;
    final double? page = (oldPixels == null || oldViewportDimensions == 0.0)
        ? _pageToUseOnStartup
        : getPageFromPixels(oldPixels, oldViewportDimensions!);
    final double? newPixels = page != null ? getPixelsFromPage(page) : null;
    if (newPixels != null && newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  @override
  PageMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    double? viewportFraction,
    double? devicePixelRatio,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ??
          ((hasContentDimensions) ? this.minScrollExtent : null),
      maxScrollExtent: maxScrollExtent ??
          ((hasContentDimensions) ? this.maxScrollExtent : null),
      pixels: pixels ?? ((hasPixels) ? this.pixels : null),
      viewportDimension: viewportDimension ??
          ((hasViewportDimension) ? this.viewportDimension : null),
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }
}

class PageScrollPhysics extends ScrollPhysics {
  const PageScrollPhysics({super.parent});

  @override
  PageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PageScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    if (position is _PagePosition && position.page != null) {
      return position.page!;
    }
    return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    if (position is _PagePosition) return position.getPixelsFromPage(page);
    return page * position.viewportDimension;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double? page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
      // ignore: curly_braces_in_flow_control_structures
    } else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(FixedScrollMetrics(
      minScrollExtent: null,
      maxScrollExtent: null,
      pixels: null,
      viewportDimension: null,
      axisDirection: AxisDirection.down,
      // ignore: deprecated_member_use
      devicePixelRatio: WidgetsBinding.instance.window.devicePixelRatio,
    ));

    final double target =
        _getTargetPixels(position as ScrollPosition, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

final PreloadPageControllerListIn _defaultPageController =
    PreloadPageControllerListIn();
const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

class PreloadPageViewListIn extends StatefulWidget {
  PreloadPageViewListIn({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PreloadPageControllerListIn? controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
    this.preloadPagesCount = 1,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = SliverChildListDelegate(children);

  PreloadPageViewListIn.builder({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PreloadPageControllerListIn? controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.preloadPagesCount = 1,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount);
  PreloadPageViewListIn.custom({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PreloadPageControllerListIn? controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    required this.childrenDelegate,
    this.preloadPagesCount = 1,
  }) : controller = controller ?? _defaultPageController;

  final Axis scrollDirection;
  final bool reverse;
  final PreloadPageControllerListIn controller;
  final ScrollPhysics? physics;
  final bool pageSnapping;

  final ValueChanged<int>? onPageChanged;
  final SliverChildDelegate childrenDelegate;
  final int preloadPagesCount;

  @override
  _PreloadPageViewState createState() =>
      // ignore: no_logic_in_create_state
      _PreloadPageViewState(preloadPagesCount);
}

class _PreloadPageViewState extends State<PreloadPageViewListIn> {
  int _lastReportedPage = 0;
  int _preloadPagesCount = 1;

  _PreloadPageViewState(int preloadPagesCount) {
    _validatePreloadPagesCount(preloadPagesCount);
    _preloadPagesCount = preloadPagesCount;
  }

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  void _validatePreloadPagesCount(int preloadPagesCount) {
    if (preloadPagesCount < 0) {
      throw 'preloadPagesCount cannot be less than 0. Actual value: $preloadPagesCount';
    }
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return widget.reverse
            ? flipAxisDirection(axisDirection)
            : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics? physics = widget.pageSnapping
        ? _kPagePhysics.applyTo(widget.physics)
        : widget.physics;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            widget.onPageChanged != null &&
            notification is ScrollUpdateNotification) {
          final PageMetrics metrics = notification.metrics as PageMetrics;
          final int currentPage = metrics.page!.round();
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged!(currentPage);
          }
        }
        return false;
      },
      child: Scrollable(
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: _preloadPagesCount < 1
                ? 0
                : (_preloadPagesCount == 1
                    ? 1
                    : widget.scrollDirection == Axis.horizontal
                        ? MediaQuery.of(context).size.width *
                                _preloadPagesCount -
                            1
                        : MediaQuery.of(context).size.height *
                                _preloadPagesCount -
                            1),
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              SliverFillViewport(
                  viewportFraction: widget.controller.viewportFraction,
                  delegate: widget.childrenDelegate),
            ],
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(
        FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(DiagnosticsProperty<PreloadPageControllerListIn>(
        'controller', widget.controller,
        showName: false));
    description.add(DiagnosticsProperty<ScrollPhysics>(
        'physics', widget.physics,
        showName: false));
    description.add(FlagProperty('pageSnapping',
        value: widget.pageSnapping, ifFalse: 'snapping disabled'));
  }
}
