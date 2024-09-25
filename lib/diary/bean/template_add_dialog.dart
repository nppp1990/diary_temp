import 'dart:math';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/dash.dart';
import 'package:flutter/material.dart';

class TemplateAddDialog extends StatelessWidget {
  static const _dialogHeight = 700.0;

  final String? title;
  final String? desc;
  final Color color;
  final String content;

  static show(
    BuildContext context, {
    String? title,
    String? desc,
    required Color color,
    required String content,
  }) {
    return showDialog(
      context: context,
      builder: (context) => TemplateAddDialog(title: title, desc: desc, color: color, content: content),
    );
  }

  const TemplateAddDialog({
    super.key,
    this.title,
    this.desc,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth - TestConfiguration.pagePadding * 4;
    return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding * 2),
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: SizedBox(
          width: dialogWidth,
          height: _dialogHeight,
          child: Stack(
            children: [
              Positioned.fill(
                top: 25,
                child: RotateCard(
                    cardHeight: _dialogHeight - 25,
                    angle: -3 / 180 * pi,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: _TemplateAddContent(color: color, content: content, title: title, desc: desc),
                    )),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: TestColors.third,
                      shape: BoxShape.circle,
                      border: Border.all(color: TestColors.black1, width: 2),
                    ),
                    child: Center(
                        child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: TestColors.second,
                        shape: BoxShape.circle,
                        border: Border.all(color: TestColors.black1, width: 2),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: TestColors.black1,
                        size: 15,
                      ),
                    )),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _TemplateAddContent extends StatefulWidget {
  final String? title;
  final String? desc;
  final Color color;
  final String content;

  const _TemplateAddContent({
    this.title,
    this.desc,
    required this.color,
    required this.content,
  });

  @override
  State<StatefulWidget> createState() => _TemplateAddContentState();
}

class _TemplateAddContentState extends State<_TemplateAddContent> {
  late String? _desc;
  late ValueNotifier<String?> _titleNotifier;

  @override
  void initState() {
    super.initState();
    _titleNotifier = ValueNotifier(widget.title);
    _desc = widget.desc;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 36),
          const Text(
            'add template',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
            child: TextFormField(
              onChanged: (value) {
                _titleNotifier.value = value;
              },
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
              initialValue: widget.title,
              decoration: InputDecoration(
                hintText: 'template name',
                labelText: 'name',
                hintStyle: const TextStyle(color: TestColors.grey1),
                errorStyle: const TextStyle(color: TestColors.red1),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: TestColors.red1),
                    borderRadius: BorderRadius.circular(10)),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: TestColors.red1),
                    borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: TestColors.black1, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: TestColors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
            child: TextFormField(
              onChanged: (value) {
                _desc = value;
              },
              initialValue: widget.desc,
              maxLines: 2,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: 'description',
                labelText: 'template description',
                hintStyle: const TextStyle(color: TestColors.grey1),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: TestColors.black1, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: TestColors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
            child: DashedBorder(
                color: TestColors.black1,
                strokeWidth: 1,
                dashWidth: 5,
                dashSpace: 3,
                borderRadius: 6,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.content,
                      style: const TextStyle(fontSize: 12),
                      // overflow: TextOverflow.s,
                    ),
                  ),
                )),
          )),
          ValueListenableBuilder(
            valueListenable: _titleNotifier,
            builder: (context, title, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: title == null || title.isEmpty ? TestColors.grey1 : TestColors.primary,
                    ),
                    onPressed: () {
                      if (title == null || title.isEmpty) {
                        return;
                      }
                      Navigator.pop(context, {'title': title, 'desc': _desc});
                    },
                    child: child,
                  ),
                ),
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
