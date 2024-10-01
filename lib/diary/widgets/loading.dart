import 'package:dribbble/diary/common/test_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ResultConvert<T, U> = U? Function(T?);
typedef ContentWidgetBuilder<T> = Widget Function(BuildContext, T t);
typedef PlaceParentBuilder = Widget Function(BuildContext context, Widget child);
typedef BoolConvert<U> = bool Function(U);

class FutureLoading<T, U> extends StatefulWidget {
  final AsyncValueGetter<T> futureBuilder;
  final ContentWidgetBuilder<U> contentBuilder;
  final String? errorText;
  final ResultConvert<T, U> convert;
  final PlaceParentBuilder? placeParentBuilder;
  final BoolConvert<U>? emptyCheck;

  const FutureLoading({
    super.key,
    required this.futureBuilder,
    required this.contentBuilder,
    this.errorText,
    required this.convert,
    this.placeParentBuilder,
    this.emptyCheck,
  });

  @override
  State<StatefulWidget> createState() => _FutureLoadingState<T, U>();
}

class _FutureLoadingState<T, U> extends State<FutureLoading<T, U>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.futureBuilder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const loadingView = Center(
                child: CircularProgressIndicator(
              color: TestColors.primary,
            ));
            return widget.placeParentBuilder?.call(context, loadingView) ?? loadingView;
          }
          U? res;
          if (snapshot.hasData) {
            res = widget.convert(snapshot.data);
          }
          if (res != null && (widget.emptyCheck?.call(res) ?? true)) {
            return widget.contentBuilder(context, res);
          } else {
            final emptyView = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image.asset(
                  //   'assets/images/empty.png',
                  //   width: 140,
                  //   height: 140,
                  // ),
                  const SizedBox(height: 10),
                  Text(
                    widget.errorText ?? 'Something went wrong',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // retry
                  TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry', style: TextStyle(color: TestColors.primary)),
                  ),
                ],
              ),
            );
            return widget.placeParentBuilder?.call(context, emptyView) ?? emptyView;
          }
        });
  }
}

enum LoadingType {
  loading,
  // error,
  empty,
  success,
}

typedef ContentChildBuilder = Widget Function();
