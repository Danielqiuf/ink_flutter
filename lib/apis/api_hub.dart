import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:ink_self_projects/apis/user/user_api.dart';

///
/// 各种api汇聚管理
///
@immutable
class ApiHub {
  ApiHub({required this.dio, required this.host})
    : user = UserApi(dio, baseUrl: '$host/user');

  final Dio dio;
  final String host;

  final UserApi user;
}
