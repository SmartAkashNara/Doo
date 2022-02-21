//
//  AddEditSceneViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 03/02/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class AddEditSceneViewModel {}

extension AddEditSceneViewModel{
    //============================ Add Scene  ============================
    func callAddSceneAPI(param:[String:Any],
                         success: @escaping (String, SRSceneDataModel?)->(),
                         failure: @escaping (String?)->(),
                         internetFailure: @escaping ()->(),
                         failureInform: @escaping ()->()) {
        
        API_SERVICES.callAPI(param, path: .addScene) { [weak self] (parsingResponse)  in
            if let jsonResponse = parsingResponse{
                if let selfStrong = self, let modelObject = selfStrong.parseAddORUpdateScenes(jsonResponse){
                    success(jsonResponse["message"]?.stringValue ?? "", modelObject)
                }
            }
            debugPrint("response: \(String(describing: parsingResponse))")
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    //============================ update Scene  ============================
    func callUpdateSceneAPI(param:[String:Any], success: @escaping (String, SRSceneDataModel?)->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(param, path: .updateScene) { [weak self] (parsingResponse)  in
            if let jsonResponse = parsingResponse{
                if let selfStrong = self, let modelObject = selfStrong.parseAddORUpdateScenes(jsonResponse){
                    success(jsonResponse["message"]?.stringValue ?? "", modelObject)
                }
            }
            debugPrint("response: \(String(describing: parsingResponse))")
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    func parseAddORUpdateScenes(_ response: [String:JSON]) -> SRSceneDataModel? {
        guard let newScene = response["payload"]?.dictionaryValue["data"]?.dictionaryValue else { return nil }
        return SRSceneDataModel.init(param: JSON.init(newScene))
    }
}
