//
//  EditProfileViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 30/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class EditProfileViewModel {
    
    enum ErrorState { case firstname, lastname, email, country, mobile, none }

    var selectedCountry: CountrySelectionViewModel.CountryDataModel?
    
    func validateFields(firstname: String?, lastname: String?, email: String?, country: String?, mobile: String?) -> (state:ErrorState, errorMessage:String){
        
        if InputValidator.checkEmpty(value: firstname){
            return (.firstname , localizeFor("first_name_is_required"))
        }
        if !InputValidator.isFirstOrLastNameLength(firstname){
            return (.firstname , localizeFor("first_name_2_to_40"))
        }
        if !InputValidator.isFirstOrLastName(firstname){
            return (.firstname , localizeFor("plz_valid_first_name"))
        }
        if InputValidator.checkEmpty(value: lastname){
            return (.lastname , localizeFor("last_name_is_required"))
        }
        if !InputValidator.isFirstOrLastNameLength(lastname){
            return (.lastname , localizeFor("last_name_2_to_40"))
        }
        if !InputValidator.isFirstOrLastName(lastname){
            return (.lastname , localizeFor("plz_valid_last_name"))
        }
        
        if !InputValidator.isEmailLength(email){
            return (.email, localizeFor("email_length_6_to_50"))
        }
        if !InputValidator.isEmail(email), !(email ?? "").isEmpty{
            return (.email, localizeFor("plz_valid_email"))
        }
        
        if !InputValidator.checkEmpty(value: mobile){
            if InputValidator.checkEmpty(value: country) {
                return (.country, localizeFor("country_code_is_required"))
            }
            if !InputValidator.isMobileLength(mobile){
                return (.mobile, localizeFor("mobile_number_4_to_13"))
            }
            if !InputValidator.isMobile(mobile){
                return (.mobile, localizeFor("plz_valid_mobile_number"))
            }
        }else if !InputValidator.checkEmpty(value: email){
            if !InputValidator.isEmailLength(email){
                return (.email, localizeFor("email_length_6_to_50"))
            }
            if !InputValidator.isEmail(email){
                return (.email, localizeFor("plz_valid_email"))
            }
        }
        return (.none ,"")
    }
    
    func callUpdateProfileDataAPI(param:[String:Any], success: @escaping (Int)->(), failure: @escaping (String?)->(), internetFailure: @escaping ()->(), failureInform: @escaping ()->()) {
        API_SERVICES.callAPI(param, path: .updateUserProfile, method:.put) { (parsingResponse) in
            if let jsonResponse = parsingResponse{
                let timeout = self.parseProfileData(JSON(rawValue: jsonResponse) ?? 0).1
                success(timeout)
            }
        } failure: { (failureMessage) in
            failure(failureMessage)
        } internetFailure: {
            internetFailure()
        } failureInform: {
            failureInform()
        }
    }
    
    func parseProfileData(_ response: JSON) -> (Bool, Int) {
        guard let payload = response.dictionaryValue["payload"] else { return (false, 0) }
        if let user = APP_USER {
            user.update(profileResponse: payload)
            UserManager.storeCertifUser(user)
            return (true, payload["timeout"].intValue)
        }
        return (false, 0)
    }
}
