///
/// 公用的request返回类型接受容器
/// ApiResult<UserInfoModel>? apiResult;
///
/// apiResult = Ok(userinfo);
///
sealed class ApiResult<T> {
  const ApiResult();
}

class Ok<T> extends ApiResult<T> {
  final T data;
  const Ok(this.data);
}

class Err<T> extends ApiResult<T> {
  final ApiError error;
  const Err(this.error);
}

class ApiError {
  final String message;
  final int? code;
  ApiError(this.message, {this.code});
}
