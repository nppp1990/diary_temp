import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundController {
  final ValueNotifier<BackgroundInfo?> backgroundInfo;

  BackgroundController({
    BackgroundInfo? info,
  }) : backgroundInfo = ValueNotifier(info);

  void changeBackground(BackgroundInfo? info) {
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
  final PreferredSizeWidget? appBar;

  const PageBackground({
    super.key,
    required this.controller,
    this.appBar,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _PageBackgroundState();
}

class _PageBackgroundState extends State<PageBackground> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: widget.controller.backgroundInfo,
            builder: (context, info, child) {
              final bool isColorBackground = info == null || info.isColor;
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Container(
                  decoration: BoxDecoration(
                    color: isColorBackground ? info?.backgroundColor ?? Colors.white : null,
                    image: isColorBackground
                        ? null
                        : DecorationImage(
                            image: info.assetImage!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              );
            }),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              if (widget.appBar != null) widget.appBar!,
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        )
      ],
    );
  }
}
