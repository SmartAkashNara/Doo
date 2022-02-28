//
//  ProfileViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 30/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class ProfileViewModel {
    enum EnumSection: Int {
        case userDetail
        var index: Int {
            switch self {
            case .userDetail: return 0
            }
        }
    }
    
    struct DefaultAvatar {
        var id = 0
        var image = ""
        var name = ""
        var selected = false

        init(dict: JSON) {
            id = dict["id"].intValue
            image = dict["image"].stringValue
            name = dict["name"].stringValue
        }
    }
    
    var arrayOfUserDetailFields = [EnterpriseUserDetailViewModel.EnterpriseUserDetailField]()
    var sections = [String]()
    var arrayDefaultAvatar = [DefaultAvatar]()
    
    func callGetProfileDataAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .getUserProfile, method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseProfile(JSON(rawValue: jsonResponse) ?? 0)
                success()
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }

    func parseProfile(_ response: JSON) -> Bool {
        guard let payload = response.dictionaryValue["payload"], let user = APP_USER else { return false }
        user.update(profileResponse: payload)
        UserManager.storeCertifUser(user)
        return true
    }

    func callGetDefaultAvatarsAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .getDefaultAvatars, method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseDefaultAvatars(JSON(rawValue: jsonResponse) ?? 0)
                success()
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
       
    func parseDefaultAvatars(_ response: JSON) -> Bool {
        guard let arrayAvatar = response.dictionaryValue["payload"]?.arrayValue else { return false }
        arrayDefaultAvatar.removeAll()
        arrayAvatar.forEach { (avatarJson) in
            arrayDefaultAvatar.append(DefaultAvatar(dict: avatarJson))
        }
        return true
    }

    //// New api call
    /*
    func callUpdateProfilePictureAPI(param:[String:Any], image: UIImage, success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .updateProfilePicture, method:.post) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                self.parseProfile(JSON(rawValue: jsonResponse) ?? 0)
                success()
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    */
    
    // Old api call, Remove it once new api call is done.
    
    func callUpdateProfilePictureAPI(param: [String: Any],
                              receivedImages: [UIImage],
                              receivedImageNames: [String],
                              receivedFileNames: [String],
                              success: (()->())? = nil,
                              failure: (()->())? = nil,
                              internetFailure: (()->())? = nil,
                              commonFailure: (()->())? = nil) {
        API_SERVICES.callUploadFileAPI(
            param,
            images: receivedImages,
            names: receivedImageNames,
            fileNames: receivedFileNames,
            path: .updateProfilePicture,
            method: .post) { (progress) in
        } success: { (parsingResponse) in
            // print("avatar update response: \(parsingResponse)")
            if let jsonResponse = parsingResponse{
                self.parseProfile(JSON(rawValue: jsonResponse) ?? 0)
                success!()
            }
        } failure: { (failureMessage) in
        } internetFailure: {
        } failureInform: {
            commonFailure?()
        }
    }
    
    /*
    func callUpdateProfilePictureAPI(_ param: [String: Any],
                                     image: UIImage?,
                                     startLoader: @escaping ()->(),
                                     stopLoader: @escaping ()->() ,
                                     successBlock: @escaping ()->(),
                                     failureMessageBlock: @escaping (String) -> ()) {
        
        startLoader()
        func returnFailureMessage(_ customMesssage: String = "") {
            stopLoader()
            if !customMesssage.isEmpty {
                failureMessageBlock(customMesssage)
            }else{
                failureMessageBlock(cueAlert.Message.somethingWentWrong)
            }
        }
        /*
        self.apiManager.callRequestWithMultipartData(APIRouter.updateProfilePicture(param), image: image, imageKey: "file", imageName: "profileImage.jpg", onSuccess: { [weak self] (response) in
            if response.success {
                guard let jsonResponse = response.data else{
                    returnFailureMessage(cueAlert.Message.somethingWentWrong); return
                }
                if let errorMessage = APIManager.shared.verifyErrorPossiblities(jsonResponse){
                    returnFailureMessage(errorMessage)
                }else{
                    stopLoader()
                    if self?.parseProfile(jsonResponse) ?? false{
                        successBlock()
                    }
                }
            }else{
                returnFailureMessage(cueAlert.Message.somethingWentWrong)
            }
            }, onFailure: { (apiErrorResponse) in
                returnFailureMessage(apiErrorResponse.message)
        })
        */
    }
    */
    func callDeleteProfilePictureAPI(param:[String:Any], success: @escaping ()->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(path: .updateProfilePicture, method:.delete) { (parsingResponse) in
            print("response: \(parsingResponse)")
            if let jsonResponse = parsingResponse{
                self.parseProfile(JSON(rawValue: jsonResponse) ?? 0)
                success()
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    func loadData(user: AppUser) {
        arrayOfUserDetailFields = [
            EnterpriseUserDetailViewModel.EnterpriseUserDetailField(title: localizeFor("email_address"), value: user.email),
            EnterpriseUserDetailViewModel.EnterpriseUserDetailField(title: localizeFor("country_placeholder"), value: user.countryName),
            EnterpriseUserDetailViewModel.EnterpriseUserDetailField(title: localizeFor("mobile"), value: user.mobileNumber),
        ]
        // create sections
        sections = [localizeFor("user_detail_section")]
    }
    
}
