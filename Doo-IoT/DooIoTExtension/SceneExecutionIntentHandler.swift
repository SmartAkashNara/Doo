//
//  SceneExecutionIntentHandler.swift
//  DooIotExtension
//
//  Created by Shraddha on 16/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
import Intents

class SceneExecutionIntentHandler: NSObject, SceneExecutionIntentHandling {
        
        func resolveSceneName(for intent: SceneExecutionIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
            guard let sceneName = intent.sceneName else {
                completion(INStringResolutionResult.needsValue())
                return
            }
            completion(INStringResolutionResult.success(with: sceneName))
        }
        func handle(intent: SceneExecutionIntent, completion: @escaping (SceneExecutionIntentResponse) -> Void) {
            print(intent.sceneName)
            let defaults = UserDefaults.init(suiteName: "group.com.ss.doo")
            if let userId = defaults?.object(forKey: "UserIdForAllTargets") {
                if (userId as! NSNumber) != intent.userId {
                    let response = SceneExecutionIntentResponse.success(message: "Please login to execute this command.")
                    completion(response)
                }
            }
            if (defaults?.object(forKey: "AccessTokenForAllTargets")) != nil
            {
            self.excuteSceneApi(id: intent.sceneId as! Int) { (sceneInfo) in
              if let sceneInfo = sceneInfo {
                  print(sceneInfo)
                    DispatchQueue.main.async {
                        let response = SceneExecutionIntentResponse.success(message: "\(sceneInfo)")
                        completion(response)
                    }
                }
            } failure: { (error) in
                let response = SceneExecutionIntentResponse.success(message: "\(error ?? "Something went wrong")")
                completion(response)
            }
        } else {
             let response = SceneExecutionIntentResponse.success(message: "Please login to execute this command.")
             completion(response)
         }
            
            
//            let response = SceneExecutionIntentResponse.success(message: "Scene executed")
//            completion(response)
            
        }
    
    func excuteSceneApi(id:Int, completion: @escaping (String?) -> Void, failure: ((String?) -> ())? = nil) {
        let param: [String: Any] = ["id":id]
        let path = Routing.excuteScene(param)
        let completePath = Environment.APIBasePath() + path.getPath

        let Url = String(format: completePath)
            guard let serviceUrl = URL(string: Url) else { return }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "PUT"
        
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

    //    func handle(intent: SceneExecutionIntent) async -> SceneExecutionIntentResponse {
    //        let sceneName = SceneExecutionIntentResponse().sceneName
    //
    //        let response = SceneExecutionIntentResponse.success(sceneName: sceneName ?? "")
    //        completion(response)
    //    }
    
    
    
    }
