//
//  AppTracking.swift
//  SmartMirro2
//
//  Created by Coloring C on 2021/4/21.
//  Copyright © 2021 Coloring C. All rights reserved.
//

import UIKit
import Foundation
import AdSupport
import AppTrackingTransparency

public class AppTrackingManager {
    
    public init() { }
    
    private let tapped = "ATTrackingTaapped"
    
    public let localizationTexts = [
        "en":
            (title: "“Tracking” permission not yet allowed",
             message: "In order to provide you with better quality and favorite services, we want to access your relevant permissions, and your consent is required.",
             cancel: "Cancel", setting: "Go Setting"),
        "zh-Hans":
            (title: "尚未允许“跟踪”权限",
            message: "为了向您提供更优质、喜欢的服务，我们想访问您的相关权限，需要您的同意。",
            cancel: "取消", setting: "去设置"),
        "zh-Hant":
            (title: "尚未允許“跟踪”權限",
             message: "為了向您提供更優質、喜歡的服務，我們想訪問您的相關權限，需要您的同意。",
             cancel: "取消", setting: "去設置"),
        "ja":
            (title: "まだ許可されていない「追跡」権限",
             message: "より良い品質とお気に入りのサービスを提供するために、私たちはあなたの関連する許可にアクセスしたいと思っており、あなたの同意が必要です。",
             cancel: "キャンセル", setting: "設定に移動"),
        "ko": (title: "“추적”권한이 아직 허용되지 않음",
            message: "더 나은 품질과 선호하는 서비스를 제공하기 위해 당사는 귀하의 관련 권한에 액세스하기를 원하며 귀하의 동의가 필요합니다.",
            cancel: "취소", setting: "세팅하기")
    ]
    
    private func alert(_ parent: UIViewController) {
        
        let preferredLang = Bundle.main.localizations.first ?? "en"
        let texts = localizationTexts[preferredLang] ?? localizationTexts["en"]!
        
        openSettings(parent: parent, title: texts.title, message: texts.message, cancel: texts.cancel, confirm: texts.setting)
    }
    
    public func setup(_ parent: UIViewController) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .restricted:
                    debugPrint("授权限制")//系统隐私开关关闭
                case .denied:
                    debugPrint("未授权")
                    if !UserDefaults.standard.bool(forKey: "OpenATTracking") {
                        self.sendPageEvent(self.tapped, label: "首次拒绝授权")
                        UserDefaults.standard.set(true, forKey: "firstATTracking")
                    } else {
                        self.requestAppTracking(parent)
                    }
                case .authorized:
                    debugPrint("已授权")
                    if !UserDefaults.standard.bool(forKey: "firstATTracking") {
                        self.sendPageEvent(self.tapped, label: "首次授权")
                        UserDefaults.standard.set(true, forKey: "OpenATTracking")
                    }
                    if !UserDefaults.standard.bool(forKey: "changedATTracking") {
                        self.sendPageEvent(self.tapped, label: "首次更改为授权")
                        UserDefaults.standard.set(true, forKey: "changedATTracking")
                    }
                default:
                    break
                }
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                debugPrint("允许授权")
            } else {
                debugPrint("拒绝授权")
            }
        }
    }
    
    private func requestAppTracking(_ parent: UIViewController) {
        let last = UserDefaults.standard.integer(forKey: "lastAppTrackingRete")
        let now = Int(Date().timeIntervalSince1970)
        let hour = 24
        if now - last > 60*60*hour {
            alert(parent)
            UserDefaults.standard.setValue(now, forKey: "lastAppTrackingRete")
        }
    }
    
    private func sendPageEvent(_ eventId: String, label: String? = nil) {
        LLog("[DEBUG] Event统计: ", eventId, ", label: ", label ?? "nil")
    }
}


