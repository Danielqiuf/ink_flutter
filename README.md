# ink_self_projects

Flutter + RiverPod + Dio + Retrofit + Annotation Gen + Spider + Slang + Hive + Drift + Go Router

## 运行

- `flutter pub get`
- `dart run slang`
- `dart run build_runner build -d`
- `flutter run --dart-define-from-file=env/dev.env`

### 安装Spider
资源通过**Spider CLI**独立生成，它不需要单独添加到项目依赖中：

- 安装 `dart pub global activate spider`
- 检查是否安装成功 `dart pub global run spider --help`
- 生成资产常量文件 **\_\_assets.g\_\_** `dart pub global run spider build`

---------------------------------------------------


## 项目结构

|  # | 模块       | 目录（相对 `lib/`）                    | 层级 |                  作用 |
| -: | -------- | -------------------------------- | -: |--------------------:|
|  1 | `apis`   | `apis/`                          |  1 |             API接口定义 |
|  2 | `apis`   | `apis/user/`                     |  2 |                     |
|  3 | `app`    | `app/`                           |  1 |              应用主要内容 |
|  4 | `app`    | `app/router/`                    |  2 |                  路由 |
|  5 | `app`    | `app/router/di/`                 |  3 |             路由的DI模块 |
|  6 | `app`    | `app/router/parts/`              |  3 |               子路由定义 |
|  7 | `app`    | `app/screens/`                   |  2 |                  页面 |
|  8 | `app`    | `app/screens/home/`              |  3 |
|  9 | `app`    | `app/screens/home/presentation/` |  4 |
| 10 | `app`    | `app/screens/login/`             |  3 |
| 11 | `app`    | `app/screens/profile/`           |  3 |
| 12 | `app`    | `app/session/`                   |  2 |          全局会话处理(请求) |
| 13 | `app`    | `app/shell/`                     |  2 | Router Shell相关(Tab) |
| 14 | `core`   | `core/`                          |  1 |                核心功能 |
| 15 | `core`   | `core/bootstrap/`                |  2 |               初始化容器 |
| 16 | `core`   | `core/di/`                       |  2 |            全局核心DI模块 |
| 17 | `core`   | `core/ext/`                      |  2 |              全局扩展模块 |
| 18 | `core`   | `core/network/`                  |  2 |              核心网络实现 |
| 19 | `core`   | `core/network/contains/`         |  3 |                网络常量 |
| 20 | `core`   | `core/network/errors/`           |  3 |              网络错误相关 |
| 21 | `core`   | `core/network/middleware/`       |  3 |        网络请求中间件(拦截器) |
| 22 | `core`   | `core/network/shared/`           |  3 |         网络请求共享函数与工具 |
| 23 | `core`   | `core/storage/`                  |  2 |              核心存储实现 |
| 24 | `shared` | `shared/`                        |  1 |              全局共享模块 |
| 25 | `shared` | `shared/tools/`                  |  2 |             全局工具类实现 |
| 26 | `shared` | `shared/ui/`                     |  2 |         全局UI Widget |

### 产物目录
以下为代码生成的目录，不计入git中，需要自己手动执行命令生成

| # | 模块             | 目录（相对 `lib/`）   | 层级 |                  作用 |
|--:|----------------|-----------------| -: | -: |
| 1 | `__assets.g__` | `__assets.g__/` |  1 | 应用资产常量，通过`Spider`生成 |
| 2 | `__locale.g__` | `__locale.g__/` |  1 | 多语言常量，通过`slang`生成 |

-------------------------------------

## 存储
- 存储有用到Hive和Drift， Hive只管简单的Key-Value存储， Drift则需要在数据复杂且有关系的情况下使用，自动根据表字段生成对应的实体模型类({name}RowModel)
- [Drift](https://pub.dev/packages/drift)替代Sqflite，通过文件`.drift`来维护sql表，与`.sql`一致。最终通过`build_runner`生成产物
### Key-Value Hive
在`core/storage/hiv`目录下， 通过后缀`_repo`来区分这是一个Hive的存储类。

#### 创建存储类
创建一个{name}Repo，通过`_k`前缀来指定KEY的常量， 最后通过`_box`来写入和读取.
```dart 
class AuthLocalRepo {
  AuthLocalRepo(this._box);

  final Box _box;

  static const String _kToken = "_k_token";
  static const String _kUserId = "_k_uid";

  String? get token => _box.get(_kToken) as String?;
  String? get userId => _box.get(_kUserId) as String?;

  Future<void> setToken(String? token) async {
    if (token != null) {
      await _box.put(_kToken, token);
    }
  }

  Future<void> setUid(String? uid) async {
    if (uid != null) {
      await _box.put(_kUserId, uid);
    }
  }
}
```
最后通过`RiverPod`特性，创建一个全局的Provider
```dart
final authLocalRepoProvider = Provider<AuthLocalRepo>((ref) {
  final box = ref.watch(authBoxProvider);
  return AuthLocalRepo(box);
});
```

在Widget中使用。 **`StatelessWidget记得要缓存ConsumerWidget， StatefulWidget记得要换成ConsumerStatefulWidget`**：
```dart

class Widget extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      body: GestureDetector(
        onTap:() async {
         await ref.read(authLocalRepoProvider).setToken("token value");
        },
        child: Text("设置Token数据")
      )
    );
  }
}
```
-----------------------------
### Sqflite DB数据库存储