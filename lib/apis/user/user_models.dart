import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

///
/// 用户信息
/// [FieldRename.snake] 自动把下环线映射成驼峰，不用再写JsonKey
///
@freezed
abstract class UserinfoModel with _$UserinfoModel {
  const UserinfoModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserinfoModel({
    required int userId,
    required String token,
    required int sex,
    required int age,
    required int birth,
    required String avatarUrl,
    @Default(false) bool isGuestBind,
    @Default(0.0) double inviteBalance,
    @Default(0.0) double gold,
  }) = _UserinfoModel;

  factory UserinfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserinfoModelFromJson(json);
}
