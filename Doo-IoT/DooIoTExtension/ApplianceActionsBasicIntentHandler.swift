//
//  ApplianceActionsIntentHandler.swift
//  DooIotExtension
//
//  Created by Shraddha on 28/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

public class ApplianceActionsBasicIntentHandler: NSObject, ApplianceActionsBasicIntentHandling {
    
//    public func resolveValue(for intent: ApplianceActionsIntent, with completion: @escaping (ApplianceActionsValueResolutionResult) -> Void) {
//        if ((intent.value as? Int) != 0) {
//            completion(ApplianceActionsValueResolutionResult.needsValue())
//        } else {
//            completion(ApplianceActionsValueResolutionResult.success(with: intent.value as? Int ?? 0))
//        }
//    }

    public func handle(intent: ApplianceActionsBasicIntent, completion: @escaping (ApplianceActionsBasicIntentResponse) -> Void) {
        let defaults = UserDefaults.init(suiteName: "group.com.ss.doo")
        if let userId = defaults?.object(forKey: "UserIdForAllTargets") {
            if (userId as! NSNumber) != intent.userId {
                let response = ApplianceActionsBasicIntentResponse.success(message: "Please login to execute this command.")
                completion(response)
            }
        }
        if (defaults?.object(forKey: "AccessTokenForAllTargets")) != nil
        {
            self.callApplianceOnOffApi(intent: intent) { (applianceInfo) in
              if let applianceInfo = applianceInfo {
                  print(applianceInfo)
                    DispatchQueue.main.async {
                        let response = ApplianceActionsBasicIntentResponse.success(message: "\(applianceInfo)")
                        completion(response)
                    }
              }
            } failure: { (error) in
                let response = ApplianceActionsBasicIntentResponse.success(message: "\(error ?? "Something went wrong")")
                completion(response)
            }
        } else {
             let response = ApplianceActionsBasicIntentResponse.success(message: "Please login to execute this command.")
             completion(response)
         }
    }
    
    
    func callApplianceOnOffApi(intent: ApplianceActionsBasicIntent, completion: @escaping (String?) -> Void, failure: ((String?) -> ())? = nil) {
        
//        guard let val = intent.value else {
//            return
//        }
        let val = intent.value
        let param: [String:Any] = [
            "applianceId": intent.applianceId ?? 0,
            "endpointId": intent.endpointId ?? 0,
            "applianceData": ["action": 1, "value": val] // here passed action static 1 for on off only
        ]
        
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
}
