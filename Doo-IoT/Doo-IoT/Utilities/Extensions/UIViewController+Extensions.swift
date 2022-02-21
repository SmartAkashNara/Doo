//
//  UIViewController+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 25/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

//MARK:- UIViewController
extension UIViewController{
    func showAlert(withTitle title: String = AppInfo.appDisplayName, withMessage message: String, withActions actions: UIAlertAction... ,withStyle style:UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        if actions.count == 0 {
            alert.addAction(UIAlertAction(title: NSLocalizedString(cueAlert.Button.oK, comment: ""), style: .default, handler: nil))
        } else {
            for action in actions {
                alert.addAction(action)
            }
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showDeleteAlert(deleted:(()->())? = nil, canceled:(()->())? = nil) {
        let alertCancel = UIAlertAction.init(title: cueAlert.Button.cancel, style: UIAlertAction.Style.default, handler: { (actionInstance) in
            canceled?()
        })
        
        let alertYes = UIAlertAction.init(title: cueAlert.Button.yes, style: UIAlertAction.Style.default, handler: { (actionInstance) in
            deleted?()
        })
        showAlert(withMessage: cueAlert.Message.deleteAlert, withActions: alertCancel,alertYes)
    }
    
    func className() -> String {
        return String(describing: self.classForCoder)
    }
    
    static func className() -> String {
        return String(describing: self.classForCoder())
    }
}

extension UIViewController {
    func popupAlert(title: String? = nil, message: String?, actionTitles: [String?] = [], actions: [((UIAlertAction) -> Void)?] = []) {
        var finalTitle = title
        if title == nil {
            finalTitle = AppInfo.appName // if nil, assign app name
        }
        
        guard actionTitles.count == actions.count else{
            debugPrint("No of action title passed must match to actions...")
            // No of action title passed must match to actions.
            return
        }
        
        let alert = UIAlertController(title: finalTitle, message: message, preferredStyle: .alert) // Alert instance
        
        var finalActionTitles = actionTitles
        var finalActions = actions
        if finalActionTitles.count == 0 {
            // Add okay by default
            finalActionTitles = ["OK"]
            finalActions = [{ (actionInstance) in
                alert.dismiss(animated: true, completion: nil)
            }]
        }
        
        for (index, title) in finalActionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: finalActions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func topMostViewController() -> UIViewController? {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController?.topMostViewController()
    }    
}
