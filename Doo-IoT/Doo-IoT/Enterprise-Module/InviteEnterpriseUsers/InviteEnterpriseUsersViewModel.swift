//
//  InviteUserRolesViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class InviteEnterpriseUsersViewModel {
    
    enum ErrorState { case country, emailOrMobile, role, none }
    var selectedUsers = [DooUser]()
    var currentSelectedUser: DooUser?
    
    // role handler
    var currentSelectedRole: DooBottomPopupGenericDataModel? = nil
    var listOfRoles: [DooBottomPopupGenericDataModel] = []
    
    public func validateFields(emailOrMobile: String?, role: String?, countryCode:String?) -> (state:ErrorState, errorMessage:String){
        let validationStatus = InputValidator.validateEmailOrMobile(emailOrMobile)
        
        if let code = countryCode, code.isEmpty && InputValidator.isMobile(emailOrMobile){
            return (.country , "country selection is required")
        }
        if !validationStatus.error.isEmpty {
            return (.emailOrMobile , validationStatus.error)
        }
        if InputValidator.checkEmpty(value: role){
            return (.role , localizeFor("role_is_required"))
        }
        return (.none ,"")
    }
    
    // ||================ Get Role List ===================================================
    func callGetUserRolesAPI(_ param: [String: Any],
                             startLoader: @escaping ()->(),
                             stopLoader: @escaping ()->() ,
                             successBlock: @escaping ()->(),
                             failureMessageBlock: @escaping (String) -> ()) {
        
        API_SERVICES.callAPI(param, path: .getUserRoles, method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse, self.parseUserRoles(jsonResponse){
                successBlock()
            }
        }
    }
    func parseUserRoles(_ response: [String:JSON]) -> Bool {
        guard let roles = response["payload"]?.arrayValue else { return false }
        listOfRoles.removeAll()
        for role in roles {
            listOfRoles.append(DooBottomPopupGenericDataModel.init(dataId: role["id"].stringValue, dataValue: role["name"].stringValue))
        }
        return true
    }
    
    // ||================ Get Enterprise List ===================================================
    func callInviteEnterpriseUsersAPI(_ param: [[String: Any]],
                                      successBlock: @escaping (String)->(),
                                      failureMessageBlock: @escaping () -> ()) {
        API_SERVICES.callAPIWithCollection(param, path: .inviteEnterpriseUsers, method: .post) { parsingResponse in
            if let jsonObject = parsingResponse{
                successBlock(jsonObject["message"]?.stringValue ?? "")
            }
        } failureInform: {
            failureMessageBlock()
        }
    }
}
