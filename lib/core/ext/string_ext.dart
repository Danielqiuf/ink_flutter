///
/// 字母大小写控制
extension StringCasingExtension on String {
  ///
  /// 首字母大写
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);

  ///
  /// 将字符串中的每个单词首字母大写，其余字母小写。
  String toTitleCase() => split(' ').map((word) => word.capitalize()).join(' ');

  ///
  /// 将整个字符串转为大写
  String toAllCaps() => toUpperCase();

  ///
  /// 使用正则，将第一个字母字符大写，其余小写
  String capitalizeFirstLetterCharOnly() {
    if (isEmpty) return this;

    final lower = toLowerCase();
    final match = RegExp(r'[A-Za-z]').firstMatch(lower);
    if (match == null) return lower;

    final index = match.start;
    return lower.replaceRange(index, index + 1, lower[index].toUpperCase());
  }

  ///
  /// \n \r转义给Text显示
  String parseEscapedForText() {
    return replaceAll(
      r'\n',
      '\n',
    ).replaceAll(r'\r', '\r').replaceAll(r'\t', '\t');
  }
}
