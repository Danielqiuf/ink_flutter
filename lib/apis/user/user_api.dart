import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/network/shared/net_extra.dart';
import 'user_models.dart';

part 'user_api.g.dart';

@immutable
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  @Extra({NetExtra.log: true})
  @POST('/get_user_info')
  Future<UserinfoModel> getUserInfo({@CancelRequest() CancelToken? ct});
}
