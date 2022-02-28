//
//  IntentHandler.swift
//  DooIotExtension
//
//  Created by Shraddha on 07/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Intents
import Intents
import IntentsUI

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        
        if intent is SceneExecutionIntent {
            return SceneExecutionIntentHandler()
        }
        
        if intent is ApplianceActionsBasicIntent {
            return ApplianceActionsBasicIntentHandler()
        }
        
        if intent is ApplianceActionSpeedIntent {
            return ApplianceActionSpeedIntentHandler()
        }
        if intent is ApplianceActionRgbIntent {
            return ApplianceActionRgbIntentHandler()
        }
        fatalError("Unhandled Intent error : \(intent)")
    }
}



