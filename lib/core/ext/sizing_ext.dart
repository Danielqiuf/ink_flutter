import 'dart:math';

import 'package:flutter/material.dart';

class Sizing {
  /// 画板/设计稿宽度（pt）
  static late final double _designW;

  /// 为了不在大屏/高密度下无脑放大，限制最大逻辑宽度（pt）
  static late final double _maxLogicalW;

  /// 计算得到的全局横向缩放因子
  static late double _scaleW;

  /// 文字缩放（可与 _scaleW 不同，避免字过大或过小）
  static late double _fontScale;

  static void init(
    BuildContext context, {
    double designWidth = 390, // 例如 iPhone 画板 390pt
    double maxLogicalWidth = 430, // iPhone 14/15/16 主流宽
    double fontMin = 0.95, // 字体缩放夹逼，保证可读性
    double fontMax = 1.15,
  }) {
    final mq = MediaQuery.of(context);
    final logicalW = mq.size.width;
    _designW = designWidth;
    _maxLogicalW = maxLogicalWidth;

    final clampedW = min(logicalW, _maxLogicalW);
    _scaleW = clampedW / _designW;

    // 字体缩放可以比布局缩放“更保守”一些（可选：开方或插值）
    final raw = _scaleW; // 也可用 sqrt(_scaleW)
    _fontScale = raw.clamp(fontMin, fontMax);
  }

  static double get scaleW => _scaleW;
  static double get fontScale => _fontScale;
}

extension Px on num {
  /// 尺寸按“屏宽/设计宽”线性缩放
  double get dp => this * Sizing.scaleW;

  /// 字体缩放可与 dp 不同（一般更保守）
  double get sp => this * Sizing.fontScale;
}
