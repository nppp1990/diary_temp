import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundController {
  final ValueNotifier<BackgroundInfo?> backgroundInfo;

  BackgroundController({
    BackgroundInfo? info,
  }) : backgroundInfo = ValueNotifier(info);

  void changeBackground(BackgroundInfo? info) {
    if (info == null) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
        ),
      );
    } else if (info.isColor) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: info.backgroundColor,
          systemNavigationBarColor: Colors.white,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    }
    backgroundInfo.value = info;
  }
}

class BackgroundInfo {
  final AssetImage? assetImage;
  final Color? backgroundColor;
  final Color? systemNavigationBarColor;

  const BackgroundInfo({this.assetImage, this.backgroundColor, this.systemNavigationBarColor});

  bool get isColor => backgroundColor != null;
}

class PageBackground extends StatefulWidget {
  final Widget child;
  final BackgroundController controller;

  const PageBackground({super.key, required this.controller, required this.child});

  @override
  State<StatefulWidget> createState() => _PageBackgroundState();
}

class _PageBackgroundState extends State<PageBackground> {
  @override
  void initState() {
    super.initState();
    final BackgroundInfo? info = widget.controller.backgroundInfo.value;
    if (info == null || info.isColor) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: info?.backgroundColor ?? Colors.white,
          systemNavigationBarColor: info?.systemNavigationBarColor ?? Colors.white,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller.backgroundInfo,
        builder: (context, info, child) {
          final bool isColorBackground = info == null || info.isColor;
          return Container(
            decoration: BoxDecoration(
              color: isColorBackground ? info?.backgroundColor ?? Colors.white : null,
              image: isColorBackground ? null : DecorationImage(
                image: info.assetImage!,
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: child,
            ),
          );
        },
        child: widget.child);
  }
}
