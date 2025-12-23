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

lib/
├── apis/
│   └── user/
├── app/
│   ├── router/
│   │   ├── di/
│   │   └── parts/
│   ├── screens/
│   │   ├── home/
│   │   │   └── presentation/
│   │   ├── login/
│   │   └── profile/
│   ├── session/
│   └── shell/
├── core/
│   ├── bootstrap/
│   ├── di/
│   ├── ext/
│   ├── network/
│   │   ├── contains/
│   │   ├── errors/
│   │   ├── middleware/
│   │   └── shared/
│   └── storage/
└── shared/
├── tools/
└── ui/
├── system/
└── toast/

### 产物目录
以下为代码生成的目录，不计入git中，需要自己手动执行命令生成
lib/
├── __assets__/  
└── __locale__/

-------------------------------------