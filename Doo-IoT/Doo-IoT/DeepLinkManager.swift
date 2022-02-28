//
//  DeepLinkManager.swift
//  Deeplinks
//
//  Created by Stanislav Ostrovskiy on 5/25/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation
import UIKit

enum DeeplinkType: Equatable {
    
    enum Messages {
        case root
        case details(id: String)
    }
    case messages(Messages)
    case authSignin(code: String)
    
    func compareLhsRhs() -> String {
        switch self {
        case .messages(_):
            return "messages"
        case .authSignin(_):
            return "authSignin"
        }
    }
    
    static func == (lhs: DeeplinkType, rhs: DeeplinkType) -> Bool {
        return (lhs.compareLhsRhs() == rhs.compareLhsRhs())
    }
}


let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}
    
    private var deeplinkType: DeeplinkType?
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
    
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
        
        // reset deeplink after handling
        self.deeplinkType = nil
    }
    
    func getDeepLinkType() -> DeeplinkType? {
        return self.deeplinkType
    }
}
