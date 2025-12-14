# Passworld

一个基于 SwiftUI 和 SwiftData 构建的本地密码管理应用，用于安全地保存你的各类账号信息，并通过分组、搜索和收藏等方式快速查找。

> This is a local password manager for iOS built with SwiftUI & SwiftData.

## 功能特性

- **本地账户管理**：为每个账号保存服务名称、用户名、密码和备注
- **安全存储设计**：
  - 使用 `CryptoKit` 对密码哈希（`SHA256`）
  - 明文密码通过 Keychain 安全存储
- **分组管理**：
  - 预置「全部、收藏、教育、社交媒体、工作、娱乐、购物、其他」等群组
  - 新建账号时可选择所属群组
- **收藏与统计**：
  - 支持将常用账号标记为收藏
  - 首页展示全部账号数量、收藏数量等
- **智能搜索与建议**：
  - 顶部搜索栏支持按服务名称 / 用户名模糊搜索
  - 根据最近使用时间或创建时间自动推荐账号
- **自适配布局**：
  - 内置 `AdaptiveLayoutManager`，根据不同 iPhone 设备尺寸自动调整字号、间距和布局

## 截图


![Home](https://raw.githubusercontent.com/chenlin1037/Password/refs/heads/main/Passworld/Screens/01.png)
![Detail](https://raw.githubusercontent.com/chenlin1037/Password/refs/heads/main/Passworld/Screens/02.png)
![Detail2](https://raw.githubusercontent.com/chenlin1037/Password/refs/heads/main/Passworld/Screens/03.png)
![Detail3](https://raw.githubusercontent.com/chenlin1037/Password/refs/heads/main/Passworld/Screens/04.png)


## 技术栈

- **语言**：Swift
- **UI 框架**：SwiftUI
- **数据存储**：SwiftData
- **安全存储**：Keychain（Security.framework）
- **密码哈希**：CryptoKit (SHA256)

## 项目结构（简要）

- **Passworld/**
  - `Model/Account.swift`：账号模型及 Keychain 辅助方法
  - `Model/Category.swift`：分组模型及默认群组初始化
  - `View/HomeView.swift`：应用首页，展示群组卡片、搜索和导航
  - `View/AddAccountView.swift`：新建账号页面
  - `View/AccountDetailView.swift`：账号详情页面（查看/使用密码）
  - `View/AccountListView.swift`：某个群组下的账号列表
  - `Utils/AdaptiveManager.swift`：设备与布局自适配工具
- **Passworld.xcodeproj/**：Xcode 工程文件
- **PassworldTests/**、**PassworldUITests/**：单元测试与 UI 测试（可按需扩展）

> 实际结构可能与上述略有不同，可按需要自行调整本节描述。

## 运行环境

- Xcode 16+（建议）
- iOS 17+（根据你在工程中设置的 `iOS Deployment Target` 为准）

## 如何运行

1. **克隆仓库**

   ```bash
   git clone https://github.com/your-username/Passworld.git
   cd Passworld
   ```

2. **使用 Xcode 打开项目**

   双击 `Passworld.xcodeproj`，或在 Xcode 中选择 `File > Open...` 打开项目根目录。

3. **选择运行目标设备**

   在 Xcode 顶部工具栏选择一个模拟器或真机（iPhone）。

4. **运行**

   点击 Xcode 左上角的「Run ▶️」按钮，编译并运行项目。

## 隐私与安全说明

- 本应用只在本地设备上保存账号数据，不涉及任何服务器端同步。
- 密码采用哈希 + Keychain 方式存储，尽量降低明文泄露风险。
- 如果你准备将 App 发布到 App Store，请根据苹果的隐私政策完善隐私说明。

## 许可证（License）

你可以根据自己的需要选择合适的开源协议（如 MIT、Apache 2.0 等）。下面是一个 MIT 协议的示例占位：

```text
MIT License

Copyright (c) 2025 chenlin1037

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
