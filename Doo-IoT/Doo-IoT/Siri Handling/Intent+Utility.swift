//
//  Intent+Utility.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 08/02/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import Foundation
import Intents

struct ShortcutHandler {
    static func getAllVoiceShortcuts(withCompletion completion: @escaping ([INVoiceShortcut]?, Error?)->()) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts(completion: { (voiceShortcutsFromCenter, error) in
            if error == nil {
                completion(voiceShortcutsFromCenter, nil)
            }else{
                completion(nil, error)
            }
        })
    }
}
