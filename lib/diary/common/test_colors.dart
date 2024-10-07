import 'dart:ui';

abstract class TestColors {
  static const Color primary = Color(0xFF5735EB);
  static const Color second = Color(0xFF0BD77B);
  static const Color third = Color(0xFFFBDF3C);

  static const Color black1 = Color(0xFF2C2C2C);
  static const Color black2 = Color(0xFF4A4A4A);
  static const Color black3 = Color(0xFF999999);

  static const Color toolBarBackground = Color(0xFFF7F7F7);
  static const Color grey1 = Color(0xFFD5D5D5);
  static const Color grey2 = Color(0xFFEFEFEF);
  static const Color grey3 = Color(0xFFA9A9A9);

  static const Color greyDivider1 = Color(0xFFDBDBDB);
  static const Color greyDivider2 = Color(0xFFF4F4F4);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color red1 = Color(0xFFEF2D24);


// - 生气 9B101C
// - 沮丧 658EA5
// - 担忧 E1512B
// - 伤心 CBDCE3
// - 平静、放松  C1CF9C
// - 开心 FA9153
// - 兴奋  FABD63
// - 大笑  FCDB64

 static const List<Color> moodColors = [
    Color(0xFF9B101C), // 生气
    Color(0xFF658EA5), // 沮丧
    Color(0xFFE1512B), // 担忧
    Color(0xFFCBDCE3), // 伤心
    Color(0xFFC1CF9C), // 平静
    Color(0xFFFA9153), // 开心
    Color(0xFFFABD63), // 兴奋
    Color(0xFFFCDB64), // 大笑
  ];
}
