//
//  AccountRowView.swift
//  Passworld
//
//  Created by luckly on 2025/12/3.
//

import SwiftData
import SwiftUI

struct AccountRowView: View {
    @EnvironmentObject var adaptiveManager: AdaptiveLayoutManager
    // 接收单个账户数据
    @Bindable var account: Account

    var body: some View {
        HStack(spacing: adaptiveManager.spacing(15)) {
            // 1. 图标视图 (使用 Service Name 的首字母)
            iconView

            // 2. 服务名称和用户名/密码
            VStack(alignment: .leading) {
                // 服务名称 (主标题)
                Text(account.serviceName)
                    .font(.headline)
                    .foregroundColor(.primary)

                // 用户名/邮箱 (副标题)
                // 仅作为示例，实际应显示用户名或邮箱
                Text(account.userName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 3. 箭头
//            Image(systemName: "chevron.right")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
        }
        // 使整个行区域可点击
        .contentShape(Rectangle())
    }

    // 模拟应用图标或首字母图标
    var iconView: some View {
        // 获取服务名称的首字母
        let initial = String(account.serviceName.prefix(1)).uppercased()

        return ZStack {
            // 背景 (使用系统灰色模拟截图中的占位符背景)
            RoundedRectangle(cornerRadius: adaptiveManager.cornerRadius(8), style: .continuous)
                .fill(Color(UIColor.systemGray))
                .frame(width: adaptiveManager.width(40), height: adaptiveManager.height(40))

            // 首字母
            Text(initial)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AccountRowView(account: Account(serviceName: "Facebook", userName: "chenlin",passwordHash: "hashed_pw_2",isFavorite: true))
}
