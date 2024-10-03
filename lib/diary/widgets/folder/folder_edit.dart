import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/folder.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/background/background_selector.dart';
import 'package:flutter/material.dart';

class FolderEditContent extends StatefulWidget {
  static show(BuildContext context, {Folder? folder}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth - TestConfiguration.pagePadding * 4;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding * 2),
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: OffsetCard(
          offset: const Offset(6, 6),
          decoration: BoxDecoration(
            color: TestColors.third,
            border: Border.all(color: TestColors.black1, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: TestColors.black1, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FolderEditContent(folder: folder),
          ),
        ),
      ),
    );
  }

  final Folder? folder;

  const FolderEditContent({super.key, this.folder});

  @override
  State<StatefulWidget> createState() => _FolderEditContentState();
}

class _FolderEditContentState extends State<FolderEditContent> {
  late ValueNotifier<String?> _folderName;
  BackgroundInfo? _selectedBackground;

  @override
  void initState() {
    super.initState();
    final folder = widget.folder;
    _folderName = ValueNotifier(folder?.name);
    if (folder?.backgroundImage != null || folder?.backgroundImage != null) {
      _selectedBackground = BackgroundInfo(
        assetImage: folder!.backgroundImage == null ? null : AssetImage(folder.backgroundImage!),
        backgroundColor: folder.backgroundColor,
      );
    }
  }

  void _save() {
    final folder = Folder(
      id: widget.folder?.id,
      name: _folderName.value!,
      backgroundImage: _selectedBackground?.assetImage?.assetName,
      backgroundColor: _selectedBackground?.backgroundColor,
      diaryCount: widget.folder?.diaryCount ?? 0,
    );
    Navigator.of(context).pop(folder);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(TestConfiguration.dialogPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.folder == null ? 'Create folder' : 'Edit folder',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.folder?.name,
                decoration: InputDecoration(
                  hintText: 'Enter Folder name',
                  hintStyle: const TextStyle(color: TestColors.grey1),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: TestColors.black1, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: TestColors.primary, width: 2),
                  ),
                ),
                maxLines: 1,
                onChanged: (value) {
                  _folderName.value = value;
                },
              ),
              const SizedBox(height: 16),
              BackgroundSelector(
                padding: EdgeInsets.zero,
                height: 300,
                onBackgroundChanged: (backgroundInfo) {
                  _selectedBackground = backgroundInfo;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop(-1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TestColors.grey1, width: 1),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: TestColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder(
                    valueListenable: _folderName,
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: value == null || value.isEmpty ? null : _save,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: TestColors.second,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TestColors.black1, width: 1),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
