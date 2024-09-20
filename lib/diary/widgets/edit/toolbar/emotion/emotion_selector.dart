import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:flutter/material.dart';

const List<String> _emotionList = [
  'assets/images/ic_emotion1.png',
  'assets/images/ic_emotion2.png',
  'assets/images/ic_emotion3.png',
  'assets/images/ic_emotion4.png',
];

class EmotionSelector extends StatelessWidget {
  final Function(String) onEmotionSelected;

  const EmotionSelector({super.key, required this.onEmotionSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 400,
        child: Padding(
            padding: const EdgeInsets.all(TestConfiguration.dialogPadding),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 0, // 水平间距
                mainAxisSpacing: 0, // 垂直间距
                childAspectRatio: 1, // 宽高比
              ),
              shrinkWrap: true,
              itemCount: _emojiList.length,
              itemBuilder: (context, index) {
                final String emoji = _emojiList[index];
                return GestureDetector(
                  onTap: () => onEmotionSelected(emoji),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }
}

const List<String> _emojiList = [
  '😀',
  '😃',
  '😄',
  '😁',
  '😆',
  '😅',
  '😂',
  '🤣',
  '😊',
  '😇',
  '🙂',
  '🙃',
  '😉',
  '😌',
  '😍',
  '🥰',
  '😘',
  '😗',
  '😙',
  '😚',
  '😋',
  '😛',
  '😜',
  '🤪',
  '😝',
  '🤑',
  '🤗',
  '🤭',
  '🤫',
  '🤔',
  '🤐',
  '🤨',
  '😐',
  '😑',
  '😶',
  '😏',
  '😒',
  '🙄',
  '😬',
  '🤥',
  '😌',
  '😔',
  '😪',
  '🤤',
  '😴',
  '😷',
  '🤒',
  '🤕',
  '🤢',
  '🤮',
  '🤧',
  '😵',
  '🤯',
  '🤠',
  '🥳',
  '😎',
  '🤓',
  '🧐',
  '😕',
  '😟',
  '🙁',
  '☹️',
  '😮',
  '😯',
  '😲',
  '😳',
  '🥺',
  '😦',
  '😧',
  '😨',
  '😰',
  '😥',
  '😢',
  '😭',
  '😱',
  '😖',
  '😣',
  '😞',
  '😓',
  '😩',
  '😫',
  '🥱',
  '😤',
  '😡',
  '😠',
  '🤬',
  '😈',
  '👿',
  '💀',
  '☠️',
  '💩',
  '🤡',
  '👹',
  '👺',
  '👻',
  '👽',
  '👾',
  '🤖',
  '😺',
  '😸',
  '😹',
  '😻',
  '😼',
  '😽',
  '🙀',
  '😿',
  '😾'
];
