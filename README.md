# ink_self_projects

A new Flutter project.

## 运行

`flutter pub get`
`dart run slang`
`dart run build_runner build -d`
`flutter run --dart-define-from-file=env/dev.env`

### 安装Spider
资源通过通过**Spider CLI**独立完成，它不需要单独添加到项目依赖中：

安装
`dart pub global activate spider`
检查是否安装成功
`dart pub global run spider --help`
生成资产常量文件 **__assets__**
`dart pub global run spider build`

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

| # | 模块           | 目录（相对 `lib/`） | 层级 |                  作用 |
|--:|--------------|---------------| -: | -: |
| 1 | `__assets__` | `__assets__/` |  1 | 应用资产常量，通过`Spider`生成 |
| 2 | `__locale__` | `__locale__/` |  1 | 多语言常量，通过`slang`生成 |

-------------------------------------