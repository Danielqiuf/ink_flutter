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

|  # | 模块       | 目录（相对 `lib/`）                    | 层级 |
| -: | -------- | -------------------------------- | -: |
|  1 | `apis`   | `apis/`                          |  1 |
|  2 | `apis`   | `apis/user/`                     |  2 |
|  3 | `app`    | `app/`                           |  1 |
|  4 | `app`    | `app/router/`                    |  2 |
|  5 | `app`    | `app/router/di/`                 |  3 |
|  6 | `app`    | `app/router/parts/`              |  3 |
|  7 | `app`    | `app/screens/`                   |  2 |
|  8 | `app`    | `app/screens/home/`              |  3 |
|  9 | `app`    | `app/screens/home/presentation/` |  4 |
| 10 | `app`    | `app/screens/login/`             |  3 |
| 11 | `app`    | `app/screens/profile/`           |  3 |
| 12 | `app`    | `app/session/`                   |  2 |
| 13 | `app`    | `app/shell/`                     |  2 |
| 14 | `core`   | `core/`                          |  1 |
| 15 | `core`   | `core/bootstrap/`                |  2 |
| 16 | `core`   | `core/di/`                       |  2 |
| 17 | `core`   | `core/ext/`                      |  2 |
| 18 | `core`   | `core/network/`                  |  2 |
| 19 | `core`   | `core/network/contains/`         |  3 |
| 20 | `core`   | `core/network/errors/`           |  3 |
| 21 | `core`   | `core/network/middleware/`       |  3 |
| 22 | `core`   | `core/network/shared/`           |  3 |
| 23 | `core`   | `core/storage/`                  |  2 |
| 24 | `shared` | `shared/`                        |  1 |
| 25 | `shared` | `shared/tools/`                  |  2 |
| 26 | `shared` | `shared/ui/`                     |  2 |
| 27 | `shared` | `shared/ui/system/`              |  3 |
| 28 | `shared` | `shared/ui/toast/`               |  3 |

### 产物目录
以下为代码生成的目录，不计入git中，需要自己手动执行命令生成

| # | 模块           | 目录（相对 `lib/`） | 层级 |
|--:|--------------|---------------| -: |
| 1 | `__assets__` | `__assets__/` |  1 |
| 2 | `__locale__` | `__locale__/` |  1 |

-------------------------------------