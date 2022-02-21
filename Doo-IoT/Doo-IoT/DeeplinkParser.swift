//
//  DeeplinkParser.swift
//  Deeplinks
//
//  Created by Stanislav Ostrovskiy on 5/25/17.
//  Copyright © 2017 Stanislav Ostrovskiy. All rights reserved.
//

import Foundation

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let _ = components.host else {
            return nil
        }
        
        switch components.path {
        case "/app":
            
            if let query = components.query, let startEndex = query.range(of: "code=")?.upperBound, let endIndex =  query.range(of: "&")?.lowerBound{
                let trimmedCode = query[startEndex..<endIndex]
                return DeeplinkType.authSignin(code: String(trimmedCode))
            }
            
            /*
             if let query = components.query, query.contains("code=") {
             let code = query.replacingOccurrences(of: "code=", with: "")
             print("query:\(code)")
             
             if let endIndex = code.range(of: "&")?.lowerBound, !code[..<endIndex].isEmpty {
             return DeeplinkType.authSignin(code: String(code[..<endIndex]))
             }
             }*/
        default:
            // Remove last value of componennt path
            break
        }
        return nil
    }
}
