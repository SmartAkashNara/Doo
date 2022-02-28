//
//  DeeplinkNavigator.swift
//  Deeplinks
//
//  Created by Stanislav Ostrovskiy on 5/25/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation
import UIKit

class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    private init() { }
    
    var alertController = UIAlertController()
    // for genericShare
    var deeplinkTypeAboutToHandle: DeeplinkType? = nil
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        self.deeplinkTypeAboutToHandle = type // assign type
        
        switch type {
        case .messages(.root):
            displayAlert(title: "Messages Root")
        case .messages(.details(id: let id)):
            displayAlert(title: "Messages Details \(id)")
        case .authSignin(code: let code):
            handleSignIn(code: code)
        }
    }
    
    private func displayAlert(title: String) {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        alertController.title = title
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            if vc.presentedViewController != nil {
                alertController.dismiss(animated: false, completion: {
                    vc.present(self.alertController, animated: true, completion: nil)
                })
            } else {
                vc.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: batchInvitationSignup
extension DeeplinkNavigator {
    func handleSignIn(code: String) {
        debugPrint(code)
        let rootVC = ((UIApplication.shared.topMostViewController() as?  DooTabbarViewController)?.selectedViewController as? UINavigationController)
        
        func callApiAndRedirectBackScreen(){
            API_LOADER.show(animated: true)
            API_SERVICES.callAPI(["alexaAuthCode":code], path: .enableAlexaSkill, method: .post) { response in
                API_LOADER.dismiss(animated: true)
                MQTTSwift.shared.isAvoidToStopLoader = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "alexaCalBack"), object: false)
                guard let skilEnableStatus  = response?["payload"]?["status"].stringValue else {
                    return
                }
                debugPrint(skilEnableStatus)
                CustomAlertView.init(title: "Sucessfully linked alexa.", forPurpose: .success).showForWhile(animated: true)
                rootVC?.popViewController(animated: true)
            }
        }
        
        
        if let _ = rootVC?.visibleViewController as? SignInWithAlexaAmazonViewController{
            MQTTSwift.shared.isAvoidToStopLoader = true
            callApiAndRedirectBackScreen()
        }else if let _ =  rootVC?.visibleViewController as? LinkWithAlexaViewController{
            MQTTSwift.shared.isAvoidToStopLoader = true
            callApiAndRedirectBackScreen()
        }
    }
}
