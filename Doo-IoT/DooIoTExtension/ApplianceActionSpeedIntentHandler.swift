//
//  ApplianceActionSpeedIntentHandler.swift
//  DooIotExtension
//
//  Created by Shraddha on 30/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
import UIKit

public class ApplianceActionSpeedIntentHandler: NSObject, ApplianceActionSpeedIntentHandling {
    
    struct ApplianceSpeedRecord {
        var applianceId: Int = 0
        var applianceName: String = ""
        var applianceSpeed: EnumFanSpeedForIntent = .unknown
        var action: Int = 0
        var value: Int = 0
        var endpointId: Int = 0
    }
    
    private var allSpeed: ApplianceSpeedRecord?
        
         init(speed: ApplianceSpeedRecord? = nil) {
            self.allSpeed = speed
        }
        
        static func speed(for intent: ApplianceActionSpeedIntent) -> ApplianceSpeedRecord? {
            let applianceId = intent.applianceId
            guard let applianceName = intent.applianceName else { return nil }
            guard let applianceSpeed = EnumFanSpeedForIntent(rawValue: intent.speedValue.rawValue) else { return nil }
            let endpointId = intent.endpointId
            return ApplianceSpeedRecord(applianceId: applianceId as! Int, applianceName: applianceName, applianceSpeed: applianceSpeed, endpointId: endpointId as! Int)
        }
    
    public func handle(intent: ApplianceActionSpeedIntent, completion: @escaping (ApplianceActionSpeedIntentResponse) -> Void) {
        
        if ApplianceActionSpeedIntentHandler.speed(for: intent) != nil {
//            completion(ApplianceActionSpeedIntentResponse(code: .ready, userActivity: nil))
            let defaults = UserDefaults.init(suiteName: "group.com.ss.doo")
            if let userId = defaults?.object(forKey: "UserIdForAllTargets") {
                if (userId as! NSNumber) != intent.userId {
                    let response =  ApplianceActionSpeedIntentResponse.success(message: "Please login to execute this command.")
                    completion(response)
                }
            }
            if (defaults?.object(forKey: "AccessTokenForAllTargets")) != nil
            {
                
                self.excuteApplianceOnOffApi(objApplianceIntent: intent) { (applianceInfo) in
                  if let applianceInfo = applianceInfo {
                      print(applianceInfo)
                        DispatchQueue.main.async {
                            completion(ApplianceActionSpeedIntentResponse.success(message: applianceInfo))
                        }
                    }
                } failure: { (error) in
                    let response = ApplianceActionSpeedIntentResponse.success(message: "\(error ?? "Something went wrong")")
                    completion(response)
                }
            } else {
                 let response = ApplianceActionSpeedIntentResponse.success(message: "Please login to execute this command.")
                 completion(response)
             }
        }
//        else {
//
//            self.excuteApplianceOnOffApi(objApplianceIntent: intent) { (applianceInfo) in
//              if let applianceInfo = applianceInfo {
//                  print(applianceInfo)
//                    DispatchQueue.main.async {
//                        completion(ApplianceActionSpeedIntentResponse.success(message: "Action performed successfully1"))
//                    }
//                }
//            }
//
//
//        }
    }
    
    public func resolveSpeedValue(for intent: ApplianceActionSpeedIntent, with completion: @escaping (EnumFanSpeedForIntentResolutionResult) -> Void) {
        if intent.speedValue == EnumFanSpeedForIntent.unknown {
            completion(EnumFanSpeedForIntentResolutionResult.needsValue())
        } else {
            completion(EnumFanSpeedForIntentResolutionResult.success(with: intent.speedValue))
        }
    }
    
    public func confirm(intent: ApplianceActionSpeedIntent, completion: @escaping (ApplianceActionSpeedIntentResponse) -> Void) {
        if ApplianceActionSpeedIntentHandler.speed(for: intent) != nil {
            completion(ApplianceActionSpeedIntentResponse(code: .ready, userActivity: nil))
        } else {
//            completion(ApplianceActionsIntentResponse(code: .failure, userActivity: nil))
            completion(ApplianceActionSpeedIntentResponse.success(message: "Action performed successfully123"))
                       }
    }
    
    
    func excuteApplianceOnOffApi(objApplianceIntent: ApplianceActionSpeedIntent, completion: @escaping (String?) -> Void, failure: ((String?) -> ())? = nil) {
        
        let applienceValue = self.getSpeedValueFromSelectedSpeed(speed: EnumFanSpeedForIntent(rawValue: objApplianceIntent.speedValue.rawValue) ?? .unknown)
        
        let param: [String:Any] = [
            "applianceId": objApplianceIntent.applianceId ?? 0,
            "endpointId": objApplianceIntent.endpointId ?? 0,
            "applianceData": ["action": 2, "value": applienceValue] // here passed action static 1 for on off only
        ]
        
        // API_LOADER.show(animated: true)
//        API_SERVICES.callAPI(param, path: .applienceONOFF, method:.post) { (parsingResponse) in
//            debugPrint("REst Api Response:", parsingResponse!)
//        } failureInform: {
//        }
        
        
        
        let path = Routing.applienceONOFF
        let completePath = Environment.APIBasePath() + path.getPath

        let Url = String(format: completePath)
            guard let serviceUrl = URL(string: Url) else { return }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: [])

//        access token will be fetched from the app groups userdefaults suite
        let defaults = UserDefaults.init(suiteName: "group.com.ss.doo")
        let accessToken = defaults?.object(forKey: "AccessTokenForAllTargets") ?? ""
        request.allHTTPHeaderFields = [
          "Content-Type": "application/json",
          "Accept-Language": Locale.current.languageCode?.lowercased() ?? "en",
          "Authorization" : "Bearer \(accessToken)"
        ]
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let jsonData = json as? [String:Any]
                        let message = jsonData?["message"] as? String
                        completion(message)
                        print(json)
                    } catch {
                        print(error)
                        failure?(error.localizedDescription)
                        print(error)
                    }
                } else {
                    failure?(error?.localizedDescription)
                    print(error ?? "Something went wrong")
                }
            } .resume()

        completion(nil)
    }
    
    func getSpeedValueFromSelectedSpeed(speed: EnumFanSpeedForIntent) -> Int {
        switch speed {
        case .verySlow:
            return 30
        case .slow:
            return 40
        case .medium:
            return 50
        case .fast:
            return 100
        default:break
        }
        return 0
    }
}

