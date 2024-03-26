//
//  CHYScreenTool.swift
//  CHYTool
//
//  Created by TAL on 2024/3/21.
//

import Foundation


public let SCREEN_WIDTH:CGFloat = UIScreen().bounds.size.width
public let SCREEN_HEIGHT:CGFloat = UIScreen().bounds.size.height

public func delegateWindow() -> UIWindow?{
    if let delegate = UIApplication.shared.delegate {
        return delegate.window ?? UIApplication.shared.keyWindow
    }
    return UIApplication.shared.keyWindow
}

public func keyWindow() -> UIWindow?{
    var originalKeyWindow:UIWindow?
    if #available(iOS 13.0, *) {
        let connectedScenes = UIApplication.shared.connectedScenes
        for scene in connectedScenes {
            if scene.activationState == .foregroundActive,
               scene.isKind(of: UIWindowScene.self),
               let windowScene:UIWindowScene = scene as? UIWindowScene{
                for window in windowScene.windows {
                    if window.isKeyWindow {
                        originalKeyWindow = window
                        break
                    }
                }
            }
        }
        if originalKeyWindow == nil {
            originalKeyWindow = UIApplication.shared.keyWindow
        }
    } else {
        originalKeyWindow = UIApplication.shared.keyWindow
    }
    return originalKeyWindow
}

public func getCurrentWindowRootController() -> UIViewController?{
    return delegateWindow()?.rootViewController
}


public func getTopVisibleController(vc:UIViewController?) ->UIViewController?{
    guard vc != nil else {
        return getCurrentWindowRootController()
    }
    if vc?.presentedViewController != nil,
       !(vc?.presentedViewController?.isKind(of: UIAlertController.self) ?? true){
        return getTopVisibleController(vc: vc?.presentedViewController)
    }else if (vc?.isKind(of: UITabBarController.self)) ?? false{
        let tabbarController:UITabBarController = vc as? UITabBarController ?? UITabBarController()
        return getTopVisibleController(vc: tabbarController.selectedViewController)
    }else if vc?.isKind(of: UINavigationController.self) ?? false {
        let navigationController:UINavigationController = vc as? UINavigationController ?? UINavigationController()
        return getTopVisibleController(vc: navigationController.visibleViewController)
    }else{
        var returnVC = vc;
        _ = vc?.childViewControllers.count ?? 0
        for childVC in vc?.childViewControllers ?? [] {
            if childVC.view.window != nil {
                returnVC = getTopVisibleController(vc: childVC)
            }
            break
        }
        return returnVC
    }
}

public func getTopVisibleController() -> UIViewController?{
    return getTopVisibleController(vc: getCurrentWindowRootController())
}

/// 判断是否为刘海屏
/// - Returns: bool
public func hasNotch() -> Bool{
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.windows.first
        if #available(iOS 13.0, *) {
            if let windowScene = window?.windowScene {
                let insets = windowScene.windows.first?.safeAreaInsets
                return insets?.top ?? 0 > 0
            }
        } else {
            let insets = window?.safeAreaInsets
            return insets?.top ?? 0 > 0
        }
    }
    return false
}
