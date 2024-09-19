import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundController {
  final ValueNotifier<BackgroundInfo> backgroundInfo;

  BackgroundController({
    AssetImage? assetImage,
    Color? backgroundColor,
  }) : backgroundInfo = ValueNotifier(BackgroundInfo(
          assetImage: assetImage,
          backgroundColor: backgroundColor,
        ));

  void changeBackground({AssetImage? assetImage, Color? backgroundColor}) {
    if (assetImage != null) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
          systemNavigationBarColor: Colors.white,
        ),
      );
    }
    backgroundInfo.value = BackgroundInfo(
      assetImage: assetImage,
      backgroundColor: backgroundColor,
    );
  }
}

class BackgroundInfo {
  final AssetImage? assetImage;
  final Color? backgroundColor;
  final Color? systemNavigationBarColor;

  const BackgroundInfo({this.assetImage, this.backgroundColor, this.systemNavigationBarColor});
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
    final BackgroundInfo info = widget.controller.backgroundInfo.value;
    if (info.assetImage != null) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: info.backgroundColor,
          systemNavigationBarColor: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.controller.backgroundInfo,
        builder: (context, info, child) {
          if (info.assetImage != null) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: info.assetImage!,
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: child,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: info.backgroundColor,
              body: child,
            );
          }
        },
        child: widget.child);
  }
}
