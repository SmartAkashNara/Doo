//
//  AddEditSchedulerViewModel.swift
//  Doo-IoT
//
//  Created by Akash Nara on 03/02/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class AddEditSchedulerViewModel { }
extension AddEditSchedulerViewModel{
    //============================ Add Scheduler   ============================
    func callAddSchedulerAPI(param:[String:Any], success: @escaping (String, SRSchedulerDataModel?)->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(param, path: .addScheduler) { [weak self] (parsingResponse)  in
            if let jsonResponse = parsingResponse{
                if let selfStrong = self, let modelObject = selfStrong.parseAddUpdateScheduler(jsonResponse){
                    success(jsonResponse["message"]?.stringValue ?? "", modelObject)
                }
            }
            debugPrint("response: \(String(describing: parsingResponse))")
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    //============================ Update pr edit Scheduler  ============================
    func callUpdateSchedulerAPI(param:[String:Any], success: @escaping (String, SRSchedulerDataModel?)->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(param, path: .updateSchedule) { [weak self] (parsingResponse)  in
            if let jsonResponse = parsingResponse{
                if let selfStrong = self, let modelObject = selfStrong.parseAddUpdateScheduler(jsonResponse){
                    success(jsonResponse["message"]?.stringValue ?? "", modelObject)
                }
            }
            debugPrint("response: \(String(describing: parsingResponse))")
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    func parseAddUpdateScheduler(_ response: [String:JSON]) -> SRSchedulerDataModel? {
        guard let payload = response["payload"]?.dictionary?["data"] else { return nil }
        return SRSchedulerDataModel.init(param: payload)
    }
}
