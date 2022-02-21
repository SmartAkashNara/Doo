//
//  InputValidator.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 06/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import Foundation


struct InputValidator {
    private static func isValid(text:String?, regex:String) -> Bool {
        guard let textStrong = text else{ return false }
        return NSPredicate(format: cueRegex.selfMatch, regex).evaluate(with: textStrong)
    }

    private static func checkEmptyByTrimSpace(_ candidate: String) -> Bool {
        return (candidate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "")
    }

    static func isRange(_ candidate:String?, lowerLimit:Int = 0, uperLimit:Int) -> Bool {
        let regexRange = "[[^a][a]]{\(lowerLimit),\(uperLimit)}$"
        return isValid(text: candidate, regex: regexRange)
    }
    
    static func checkEmpty(value: String?) -> Bool{
        guard let text = value, !InputValidator.checkEmptyByTrimSpace(text) else{ return true }
        return false
    }

    static func isEmailLength(_ candidate: String?) -> Bool {
        return isRange(candidate, lowerLimit: 6, uperLimit: 50)
    }
    
    static func isEmail(_ candidate: String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.emailId)
    }
    
    static func isMobileLength(_ candidate: String?) -> Bool {
        return isRange(candidate, lowerLimit: 4, uperLimit: 13)
    }

    static func isMobile(_ candidate: String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.mobile)
    }

    static func isEnterpriseName(_ candidate: String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.enterpriseName)
    }

    static func isEnterpriseNameLength(_ candidate: String?) -> Bool {
        return isRange(candidate, lowerLimit: 2, uperLimit: 40)
    }
    
    static func isFirstOrLastName(_ candidate: String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.firstOrLastName)
    }

    static func isFirstOrLastNameLength(_ candidate: String?) -> Bool {
        return isRange(candidate, lowerLimit: 2, uperLimit: 40)
    }
    
    static func isDeviceName(_ candidate: String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.deviceName)
    }

    static func isDeviceNameLength(_ candidate: String?) -> Bool {
        return isRange(candidate, lowerLimit: 2, uperLimit: 40)
    }
    
    static func isApplianceName(_ candidate: String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.applianceName)
    }

    static func isApplianceNameLength(_ candidate: String?) -> Bool {
        return isRange(candidate, lowerLimit: 2, uperLimit: 40)
    }

    static func isPassword(_ candidate : String?) -> Bool {
        return isContainsCapitalLetter(candidate)
            && isContainsSmallLetter(candidate)
            && isContainsNumber(candidate)
            && isContainsSpecialChar(candidate)
            && isRange(candidate, lowerLimit: 8, uperLimit: 50)
    }

    static func isContainsCapitalLetter(_ candidate : String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.Password.capitalLetter)
    }

    static func isContainsSmallLetter(_ candidate : String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.Password.smallLetter)
    }

    static func isContainsNumber(_ candidate : String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.Password.numberLetter)
    }

    static func isContainsSpecialChar(_ candidate : String?) -> Bool {
        return isValid(text: candidate, regex: cueRegex.Password.specialChar)
    }
    
    static func isNumber(_ candidate: String) -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        return !candidate.isEmpty && candidate.rangeOfCharacter(from: numberCharacters) == nil
    }
    
    static func checkLength(_ candidate : String?, lengthTill:Int) -> Bool {
        guard let textStrong = candidate else{ return false }
        return textStrong.count >= lengthTill
    }

    static func checkAnyOneEmpty(candidates:[String?]) -> Bool {
        for (_,candidate) in candidates.enumerated(){
            if let text = candidate{
                if checkEmpty(value: text){
                    return true
                }
            }
        }
        return false
    }
    
    static func checkAllEmpty(candidates:[String?]) -> Bool {
        for (_,candidate) in candidates.enumerated(){
            if let text = candidate{
                if !checkEmpty(value: text){
                    return false
                }
            }
        }
        return true
    }
    
    static func isShowNext(candidates:[String?]) -> Bool {
        for (_,candidate) in candidates.enumerated(){
            if let text = candidate{
                if !checkEmpty(value: text){
                    return true
                }
            }
        }
        return false
    }
    
    static func isValidImageSize(_ pickedImage: UIImage, mb: Double) -> Bool {
        //get the size of image
        guard let imgData = pickedImage.jpegData(compressionQuality: 0) else { return false }
        let imageSize = Double(imgData.count) / 1024.0 / 1024.0
        print("size of image in MB: %f ", imageSize)
        if imageSize <= mb && imageSize >= 0 {
            return true
        } else {
            return false
        }
    }

    static func validateCountryWithEmailOrMobile(country: String?, emailOrMobile: String?) -> (isErrorInCountry: Bool, isMobile: Bool, error: String) {
        
        var isCountryMandatory = true
        if InputValidator.checkEmpty(value: country),
            !InputValidator.checkEmpty(value: emailOrMobile),
            !InputValidator.isNumber(emailOrMobile!.trimSpaceAndNewline) {
            isCountryMandatory = false
        }
        if isCountryMandatory, InputValidator.checkEmpty(value: country) {
            // If there is number in 'emailOrMobile' and its empty.
            return (true , false, localizeFor("country_code_is_required"))
        }

        let validationStatus = validateEmailOrMobile(emailOrMobile)
        if !validationStatus.error.isEmpty {
            return (false, validationStatus.isMobile , validationStatus.error)
        }
        return (false, validationStatus.isMobile , "")
    }
    
    static func validateEmailOrMobile(_ emailOrMobile: String?) -> (isMobile: Bool, error: String) {
        var isMobile = false
        if InputValidator.checkEmpty(value: emailOrMobile){
            return (isMobile , localizeFor("mobile_number_or_email_is_required"))
        }
        guard let emailOrMobileStrong = emailOrMobile else { return (isMobile ,"") }
        isMobile = InputValidator.isNumber(emailOrMobileStrong.trimSpaceAndNewline)
        if isMobile {
            if !InputValidator.isMobileLength(emailOrMobile){
                return (isMobile , localizeFor("mobile_number_4_to_13"))
            }
            if !InputValidator.isMobile(emailOrMobile){
                return (isMobile , localizeFor("plz_valid_mobile_number"))
            }
        } else {
            if !InputValidator.isEmailLength(emailOrMobile){
                return (isMobile, localizeFor("email_length_6_to_50"))
            }
            if !InputValidator.isEmail(emailOrMobile){
                return (isMobile , localizeFor("plz_valid_email"))
            }
        }
        return (isMobile ,"")
    }

}
