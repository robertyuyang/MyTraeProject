//
//  AppDelegate.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let debugIndicatorKey = "com.mytraeproject.debug.indicator"
    static let launchCountKey = "com.mytraeproject.launch.count"
    static let lastLaunchDateKey = "com.mytraeproject.last.launch.date"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 记录启动信息
        recordLaunchInfo()
        
        // 显示调试指示器
        showDebugIndicator()
        
        return true
    }
    
    private func recordLaunchInfo() {
        let defaults = UserDefaults.standard
        
        // 更新启动次数
        let launchCount = defaults.integer(forKey: Self.launchCountKey) + 1
        defaults.set(launchCount, forKey: Self.launchCountKey)
        
        // 保存上一次启动时间
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss"
        defaults.set(formatter.string(from: now), forKey: Self.lastLaunchDateKey)
        
        defaults.synchronize()
    }
    
    private func showDebugIndicator() {
        let defaults = UserDefaults.standard
        let launchCount = defaults.integer(forKey: Self.launchCountKey)
        let lastLaunchDate = defaults.string(forKey: Self.lastLaunchDateKey) ?? "Unknown"
        
        // 创建调试指示器按钮
        let indicator = UIButton(type: .system)
        indicator.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        indicator.tintColor = .white
        indicator.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        indicator.setTitle("debug版 第\(launchCount)次\n\(lastLaunchDate)", for: .normal)
        indicator.titleLabel?.textAlignment = .center
        indicator.titleLabel?.numberOfLines = 0
        indicator.layer.cornerRadius = 8
        indicator.clipsToBounds = true
        indicator.tag = 9999
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加点击手势
        indicator.addTarget(self, action: #selector(dismissDebugIndicator), for: .touchUpInside)
        
        // 延迟添加到窗口，确保窗口已准备好
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                // 先移除旧的指示器
                window.viewWithTag(9999)?.removeFromSuperview()
                
                window.addSubview(indicator)
                
                NSLayoutConstraint.activate([
                    indicator.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
                    indicator.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -8),
                    indicator.widthAnchor.constraint(equalToConstant: 100),
                    indicator.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
        }
    }
    
    @objc private func dismissDebugIndicator() {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            UIView.animate(withDuration: 0.3, animations: {
                window.viewWithTag(9999)?.alpha = 0
            }) { _ in
                window.viewWithTag(9999)?.removeFromSuperview()
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

