//
//  SSReachabilityManager.swift
//  XMPPChatDemo
//
//  Created by Kiran Jasvanee on 21/08/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit
import Reachability

let INTERNET_OFF = "Internet connection appears to be offline."

class SSReachabilityManager: NSObject {
    static  let shared = SSReachabilityManager()  // 2. Shared instance
    
    // 3. Boolean to track network reachability
    var isNetworkAvailable : Bool {
      return reachabilityStatus != .unavailable
    }
    
    // 4. Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.Connection = .unavailable
    // 5. Reachability instance for Network status monitoring
    let reachability = try! Reachability()
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
       NotificationCenter.default.addObserver(self,
                 selector: #selector(self.reachabilityChanged),
                 name: Notification.Name.reachabilityChanged,
                   object: reachability)
      do{
        try reachability.startNotifier()
      } catch {
        debugPrint("Could not start reachability notifier")
      }
    }
    
    /// Called whenever there is a change in NetworkReachibility Status
    ///
    /// — parameter notification: Notification with the Reachability instance
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .unavailable:
            debugPrint("Network became unreachable")
            SSReachabilityManager.shared.reachabilityStatus = .unavailable
        case .wifi:
            debugPrint("Network reachable through WiFi")
            SSReachabilityManager.shared.reachabilityStatus = .wifi
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
            SSReachabilityManager.shared.reachabilityStatus = .cellular
        case .none:
            break
        }
        self.internetStatusInformingMethod()
    }
    
    func internetStatusInformingMethod() {
        NotificationCenter.default.post(name: Notification.Name("SSInternetStatusChange"), object: nil)
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (SSReachabilityManager) -> Void) {
        if (SSReachabilityManager.shared.reachability).connection != .unavailable {
            completed(SSReachabilityManager.shared)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (SSReachabilityManager) -> Void) {
        if (SSReachabilityManager.shared.reachability).connection == .unavailable {
            completed(SSReachabilityManager.shared)
        }
    }

    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (SSReachabilityManager) -> Void) {
        if (SSReachabilityManager.shared.reachability).connection == .cellular {
            completed(SSReachabilityManager.shared)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (SSReachabilityManager) -> Void) {
        if (SSReachabilityManager.shared.reachability).connection == .wifi {
            completed(SSReachabilityManager.shared)
        }
    }
}




