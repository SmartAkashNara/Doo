//
//  MockAPIManager.swift
//  DooTests
//
//  Created by Kiran Jasvanee on 20/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
@testable import Doo

class MockAPIManager: APIManager {
    
    override func callRequest(_ router: APIRouter, intervalTimeOut: TimeInterval = 30, mockIt: Int = 0, onSuccess success: @escaping (BaseResponse) -> Void, onFailure failure: @escaping (APICallError) -> Void) {
        
        debugPrint("Mock request called")
        
        /*
         self.header = [
         /* "Authorization": "your_access_token",  in case you need authorization header */
         "Authorization": self.header["Authorization"]!,
         "Content-type": cueField.ApiManager.appJson
         ]
         */
        
        let baseResponse: BaseResponse = BaseResponse.init()
        baseResponse.status = 200
        baseResponse.success = true
        baseResponse.message = ""
        let url = router.getJSONurl(Bundle(for: type(of: self)), mockIt: mockIt)
        
        guard url != nil else{
            fatalError("Missing json file")
        }
        do {
            let data = try Data.init(contentsOf: url!)
            let json = try JSON.init(data: data)
            print(json)
            baseResponse.data = json
            success(baseResponse)
        }catch{
            failure(APICallError.init(status: .failed))
        }
    }
}


extension Bundle {
    func getJsonFileUrl(name:String) -> URL? {
        guard let url = self.url(forResource: name, withExtension: "json") else {
            fatalError("Missing json file named \(name)")
        }
        return url
    }
}
extension APIRouter {
    func getJSONurl(_ bundle: Bundle, mockIt: Int = 0) -> URL? {
        switch self {
        case .countrySelection(_):
            return bundle.getJsonFileUrl(name: "getCountries")
        case .registerUsingEmail(_):
            return bundle.getJsonFileUrl(name: "registerUsingEmail")
        case .registerUsingMobileNo(_):
            return bundle.getJsonFileUrl(name: "registerUsingMobileNo")
        case .resendOTP(_):
            return bundle.getJsonFileUrl(name: "resendOTP")
        case .verifyOTP(_):
            return bundle.getJsonFileUrl(name: "verifyOTP")
        case .registerUsingPassword(_):
            return bundle.getJsonFileUrl(name: "registerUsingPassword")
        case .login(_):
            return bundle.getJsonFileUrl(name: "login")
        case .loginWithSMS(_):
            return bundle.getJsonFileUrl(name: "loginWithSMS")
        case .loginWithSMSOTP(_):
            return bundle.getJsonFileUrl(name: "loginWithSMSOTP")
        case .forgotPassword(_):
            return bundle.getJsonFileUrl(name: "forgotPassword")
        case .resendForgotPassword(_):
            return bundle.getJsonFileUrl(name: "resendForgotPassword")
        case .verifyOTPForgotPassword(_):
            return bundle.getJsonFileUrl(name: "verifyOTPForgotPassword")
        case .resetPasswordForgotPassword(_):
            return bundle.getJsonFileUrl(name: "resetPasswordForgotPassword")
        case .getTypesOfEnterprises(_):
            return nil
        case .addEnterprise(_):
            return nil
        case .getEnterprises(_):
            return nil
        case .getEnterpriseGroups(_):
            return nil
        }
    }
}
