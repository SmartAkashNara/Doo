//
//  ApplianceActionRgbIntentHandler.swift
//  DooIotExtension
//
//  Created by Shraddha on 06/01/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import Foundation
import UIKit


class ApplianceActionRgbIntentHandler: NSObject, ApplianceActionRgbIntentHandling {
    func handle(intent: ApplianceActionRgbIntent, completion: @escaping (ApplianceActionRgbIntentResponse) -> Void) {
        let defaults = UserDefaults.init(suiteName: "group.com.ss.doo")
        if let userId = defaults?.object(forKey: "UserIdForAllTargets") {
            if (userId as! NSNumber) != intent.userId {
                let response = ApplianceActionRgbIntentResponse.success(message: "Please login to execute this command.")
                completion(response)
            }
        }
        if (defaults?.object(forKey: "AccessTokenForAllTargets")) != nil
        {
            let response = ApplianceActionRgbIntentResponse(code: ApplianceActionRgbIntentResponseCode.continueInApp,
                        userActivity: nil)
            completion(response)
            
            
        } else {
            let response = ApplianceActionRgbIntentResponse.success(message: "Please login to execute this command.")
            completion(response)
        }
    }
}
