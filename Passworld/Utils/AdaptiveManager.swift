import SwiftUI

// MARK: - 设备信息

struct DeviceInfo {
    static let shared = DeviceInfo()

    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    var deviceName: DeviceModel {
        switch modelIdentifier {
        case "iPhone12,1": return .iPhone11
        case "iPhone12,3": return .iPhone11Pro
        case "iPhone12,5": return .iPhone11ProMax
        case "iPhone13,1": return .iPhone12mini
        case "iPhone13,2": return .iPhone12
        case "iPhone13,3": return .iPhone12Pro
        case "iPhone13,4": return .iPhone12ProMax
        case "iPhone14,4": return .iPhone13mini
        case "iPhone14,5": return .iPhone13
        case "iPhone14,2": return .iPhone13Pro
        case "iPhone14,3": return .iPhone13ProMax
        case "iPhone14,7": return .iPhone14
        case "iPhone14,8": return .iPhone14Plus
        case "iPhone15,2": return .iPhone14Pro
        case "iPhone15,3": return .iPhone14ProMax
        case "iPhone15,4": return .iPhone15
        case "iPhone15,5": return .iPhone15Plus
        case "iPhone16,1": return .iPhone15Pro
        case "iPhone16,2": return .iPhone15ProMax
        // 16 系列
        case "iPhone17,3": return .iPhone16
        case "iPhone17,4": return .iPhone16Plus
        case "iPhone17,1": return .iPhone16Pro
        case "iPhone17,2": return .iPhone16ProMax
        case "iPhone17,5": return .iPhone16e
        // 17 系列与 iPhone Air
        case "iPhone18,1": return .iPhone17Pro
        case "iPhone18,2": return .iPhone17ProMax
        case "iPhone18,3": return .iPhone17
        case "iPhone18,4": return .iPhoneAir
        // SE 系列
        case "iPhone8,4": return .iPhoneSE1st
        case "iPhone12,8": return .iPhoneSE2nd
        case "iPhone14,6": return .iPhoneSE3rd
        default: return .unknown
        }
    }
}

enum DeviceModel: String, CaseIterable {
    case iPhoneSE1st = "iPhone SE (1st gen)"
    case iPhoneSE2nd = "iPhone SE (2nd gen)"
    case iPhoneSE3rd = "iPhone SE (3rd gen)"
    case iPhone11 = "iPhone 11"
    case iPhone11Pro = "iPhone 11 Pro"
    case iPhone11ProMax = "iPhone 11 Pro Max"
    case iPhone12mini = "iPhone 12 mini"
    case iPhone12 = "iPhone 12"
    case iPhone12Pro = "iPhone 12 Pro"
    case iPhone12ProMax = "iPhone 12 Pro Max"
    case iPhone13mini = "iPhone 13 mini"
    case iPhone13 = "iPhone 13"
    case iPhone13Pro = "iPhone 13 Pro"
    case iPhone13ProMax = "iPhone 13 Pro Max"
    case iPhone14 = "iPhone 14"
    case iPhone14Plus = "iPhone 14 Plus"
    case iPhone14Pro = "iPhone 14 Pro"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case iPhone15 = "iPhone 15"
    case iPhone15Plus = "iPhone 15 Plus"
    case iPhone15Pro = "iPhone 15 Pro"
    case iPhone15ProMax = "iPhone 15 Pro Max"
    case iPhone16 = "iPhone 16"
    case iPhone16Plus = "iPhone 16 Plus"
    case iPhone16Pro = "iPhone 16 Pro"
    case iPhone16ProMax = "iPhone 16 Pro Max"
    case iPhone16e = "iPhone 16e"
    case iPhone17 = "iPhone 17"
    case iPhone17Pro = "iPhone 17 Pro"
    case iPhone17ProMax = "iPhone 17 Pro Max"
    case iPhoneAir = "iPhone Air"
    case unknown = "Unknown Device"

    // 修正了设备屏幕信息
    var screenInfo: ScreenInfo {
        switch self {
        case .iPhoneSE1st, .iPhoneSE2nd, .iPhoneSE3rd:
            return ScreenInfo(width: 375, height: 667, category: .compact)
        case .iPhone12mini, .iPhone13mini:
            return ScreenInfo(width: 375, height: 812, category: .compact)
        case .iPhone11, .iPhone12, .iPhone13, .iPhone14, .iPhone15, .iPhone16e:
            return ScreenInfo(width: 390, height: 844, category: .regular)
        case .iPhone11Pro, .iPhone12Pro, .iPhone13Pro:
            return ScreenInfo(width: 390, height: 844, category: .regular)
        case .iPhone14Plus, .iPhone15Plus:
            return ScreenInfo(width: 428, height: 926, category: .large)
        case .iPhone11ProMax, .iPhone12ProMax, .iPhone13ProMax:
            return ScreenInfo(width: 428, height: 926, category: .large)
        case .iPhone16Plus:
            return ScreenInfo(width: 430, height: 932, category: .large)
        case .iPhone14Pro, .iPhone15Pro, .iPhone16:
            return ScreenInfo(width: 393, height: 852, category: .large)
        case .iPhone16Pro, .iPhone17, .iPhone17Pro:
            return ScreenInfo(width: 402, height: 874, category: .large)
        case .iPhoneAir:
            return ScreenInfo(width: 420, height: 912, category: .large)
        case .iPhone14ProMax, .iPhone15ProMax, .iPhone16ProMax, .iPhone17ProMax:
            return ScreenInfo(width: 430, height: 932, category: .extraLarge)
        case .unknown:
            return ScreenInfo(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, category: .regular)
        }
    }
}

struct ScreenInfo {
    let width: CGFloat
    let height: CGFloat
    let category: ScreenCategory

    enum ScreenCategory {
        case compact // SE 系列, mini 系列
        case regular // 标准尺寸
        case large // Plus 系列, Pro 系列
        case extraLarge // Pro Max 系列
    }
}

// MARK: - 改进的适配管理器

class AdaptiveLayoutManager: ObservableObject {
    static let shared = AdaptiveLayoutManager()

    let baselineDevice: DeviceModel

    private init(baselineDevice: DeviceModel = .iPhone13) {
        self.baselineDevice = baselineDevice
    }

    // 基础缩放因子
    private var scaleFactor: CGFloat {
        let currentDevice = DeviceInfo.shared.deviceName
        let currentScreen = currentDevice.screenInfo
        let baselineScreen = baselineDevice.screenInfo

        let widthRatio = currentScreen.width / baselineScreen.width
        let heightRatio = currentScreen.height / baselineScreen.height

        return min(widthRatio, heightRatio)
    }

    // 宽度缩放因子
    var widthScale: CGFloat {
        let currentDevice = DeviceInfo.shared.deviceName
        let currentScreen = currentDevice.screenInfo
        let baselineScreen = baselineDevice.screenInfo

        return currentScreen.width / baselineScreen.width
    }

    // 高度缩放因子
    var heightScale: CGFloat {
        let currentDevice = DeviceInfo.shared.deviceName
        let currentScreen = currentDevice.screenInfo
        let baselineScreen = baselineDevice.screenInfo

        return currentScreen.height / baselineScreen.height
    }

    // 字体大小适配
    func fontSize(_ baseSize: CGFloat) -> CGFloat {
        return baseSize * scaleFactor
    }

    // 间距适配
    func spacing(_ baseSpacing: CGFloat) -> CGFloat {
        return baseSpacing * scaleFactor
    }

    // 宽度适配
    func width(_ baseWidth: CGFloat) -> CGFloat {
        return baseWidth * widthScale
    }

    // 高度适配
    func height(_ baseHeight: CGFloat) -> CGFloat {
        return baseHeight * heightScale
    }

    // 圆角半径适配
    func cornerRadius(_ baseRadius: CGFloat) -> CGFloat {
        return baseRadius * scaleFactor
    }

    // 图标尺寸适配
    func iconSize(_ baseSize: CGFloat) -> CGFloat {
        return baseSize * scaleFactor
    }
}

// MARK: - View 扩展

extension View {
    // 字体适配
    func adaptiveFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        let manager = AdaptiveLayoutManager.shared
        return font(.system(size: manager.fontSize(size), weight: weight, design: design))
    }

    // 内边距适配
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        let manager = AdaptiveLayoutManager.shared
        return padding(edges, manager.spacing(length))
    }

    // 宽度适配
    func adaptiveWidth(_ width: CGFloat) -> some View {
        let manager = AdaptiveLayoutManager.shared
        return frame(width: manager.width(width))
    }

    // 高度适配
    func adaptiveHeight(_ height: CGFloat) -> some View {
        let manager = AdaptiveLayoutManager.shared
        return frame(height: manager.height(height))
    }

    // 尺寸适配
    func adaptiveSize(width: CGFloat, height: CGFloat) -> some View {
        let manager = AdaptiveLayoutManager.shared
        return frame(width: manager.width(width), height: manager.height(height))
    }

    // 圆角适配
    func adaptiveCornerRadius(_ radius: CGFloat) -> some View {
        let manager = AdaptiveLayoutManager.shared
        return cornerRadius(manager.cornerRadius(radius))
    }

    // 间距适配
    func adaptiveSpacing(_: CGFloat) -> some View {
        // 用于 VStack, HStack 等
        return self
    }
}

// 在环境中访问适配管理器，可以添加这个扩展
struct AdaptiveManagerKey: EnvironmentKey {
    static let defaultValue: AdaptiveLayoutManager = .shared
}

extension EnvironmentValues {
    var adaptiveManager: AdaptiveLayoutManager {
        get { self[AdaptiveManagerKey.self] }
        set { self[AdaptiveManagerKey.self] = newValue }
    }
}
