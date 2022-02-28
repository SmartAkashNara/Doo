//
//  Environment.swift
//  BaseProject
//
//  Created by MAC240 on 04/06/18.
//  Copyright © 2018 MAC240. All rights reserved.
//

import Foundation
//import PubNub

enum Server {
    case developement
    case staging
    case demo
    case production
}

struct MQTTData {
    var serverHost:String = ""
    var username:String = ""
    var password:String = ""
    var port:UInt32 = 0
}


class Environment {
    
    static let server: Server = .developement
    static var mqtt: MQTTData = Environment.MQTT()

//    static let jitsiServerUrl = "https://telesense-mvp.smartsenselabs.com"
 
    // To print the log set true.
    static let debug: Bool = true
//    static let imageBasePath: String =  "https://s3.ap-south-1.amazonaws.com/certifid-expert-profile-dev/"
//    static let imageBasePathInstituteCourse: String =  "https://s3.ap-south-1.amazonaws.com/certifid-institute-profile-dev/"
    
    class func APIBasePath() -> String {
        /*
        #if DEVELOPMENT
            return "http://13.235.123.99:30018/"//"http://dev-api.certif-id.com/"
        #else
            return ConfigurationManager.shared.getBackendUrlInString()
        #endif
        */
        switch self.server {
            case .developement:
            
                return "http://doo-api-dev.smartsensesolutions.com:30017/"
            case .staging:
                return "https://test-eapi.thedoo.io/"
            case .demo:
                return "https://demo-api.certif-id.com/"
            case .production:
                return "https://eapi.thedoo.io/"
        }
    }
    
    
//"http://16c6-203-129-213-178.ngrok.io/job/Doo/buildWithParameters?token=glpat-XnfaVQiN5Le87F6gkqwp"
    
    class func GoogleSignInAuthKey() -> String {
        switch self.server {
            case .developement:
                return "614348739610-k71etbt4e88vvg1dtj9ocgpsjnt81ils.apps.googleusercontent.com"
            case .staging:
                return "614348739610-62j0hmukk7j1cd4ttofjltlp83oa0qcm.apps.googleusercontent.com"
            case .demo:
                // TODO LATER: Inform backend (dilip) about key before uploading to demo.
                return "614348739610-lm87ml1ktn66mf8nol6rnq4m7vc7q18m.apps.googleusercontent.com"
            case .production:
                // TODO LATER: Info backend (dilip) abput key before uploading to production.
                return "614348739610-mnis5f8m2ns8pq2b4age9rf7kkthsjfp.apps.googleusercontent.com"
        }
    }
    
    class func WebFrontEnd() -> String {
        switch self.server {
            case .developement:
                return "https://dev.thedoo.io/"
            case .staging:
                return "https://dev.thedoo.io/"
            case .demo:
                return "https://dev.thedoo.io/"
            case .production:
                return "https://thedoo.io/"
        }
    }
    
    class func ImagePathofAvtarIcon() -> String {
        switch self.server {
            case .developement:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/defaults/Asset"
            case .staging:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/defaults/Asset"
            case .demo:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/defaults/Asset"
            case .production:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/defaults/Asset"
        }
    }
    
    class func ImagePathBaseURL() -> String {
        switch self.server {
            case .developement:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/"
            case .staging:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/"
            case .demo:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/"
            case .production:
                return "https://s3.ap-south-1.amazonaws.com/doo-assets/"
        }
    }
    
    class func IntituteLogoImageBaseURL() -> String {
        switch self.server {
            case .developement:
                return "https://institute-profile-dev.certif-id.com/"
            case .staging:
                return "https://institute-profile-test.certif-id.com/"
            case .demo:
                return "https://institute-profile-demo.certif-id.com/"
            case .production:
                return "https://institute-profile.certif-id.com/"
        }
    }
    
    class func pubnubKey() -> String {
        switch self.server {
        case .developement:
            return "sub-c-ada850d6-cdaa-11ea-bdca-26a7cd4b6ab5"
        case .staging:
            // publish_key: "pub-c-467d4ea5-84cc-4bbc-96fa-7bf80c8ad626"
            // subscribe_key: "sub-c-df048c78-94e1-11ea-8dc6-429c98eb9bb1"
            return "sub-c-20a88290-cdab-11ea-9c7f-8a446e84d7d1"
        case .demo:
            return "sub-c-2fae344c-cdab-11ea-b3f2-c27cb65b13f4"
        case .production:
            return "sub-c-3d7be3ee-cdab-11ea-bdca-26a7cd4b6ab5"
        }
    }
    
    /*
    class func punubPushNotificationEnvironment() -> PNAPNSEnvironment {
        switch self.server {
        case .developement:
            return .development
        case .staging:
            return .production
        case .demo:
            return .production
        case .production:
            return .production
        }
    }
 */
    
    class func getVersionAndEnvironmentOfRelease() -> String {
        if let info = Bundle.main.infoDictionary {
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            
            switch self.server {
            case .developement:
                return "Development - \(appVersion) (\(appBuild))"
            case .staging:
                return "QA - \(appVersion) (\(appBuild))"
            case .demo:
                return "Demo - \(appVersion) (\(appBuild))"
            case .production:
                return ""
            }
        }
        return ""
    }
    
    
    static var getEnvironmentName: String {
        switch self.server {
        case .developement:
            return "dev"
        case .staging:
            return "qa"
        case .demo:
            return "demo"
        case .production:
            return "prod"
        }
    }
    
    static var getAddEditSkillPassURL: String {
        return WebFrontEnd()+"expert/profile/skill-view/"
    }
    
    static var getCVGeneratorTemplateURL: String {
        return WebFrontEnd()+"expert/skill-passport/choose-cv"
    }
    
    static var getMyInterviewApiKey: String {
        return "qyx76XuNj2G41NosOD6b"
    }
    
    static var getSkilpassAdvertisementURL: String {
        return "https://skillpass.certif-id.com/"
    }

    static func MQTT() -> MQTTData {
         var objMqTT = MQTTData()
         switch Environment.server {
         case .developement:
             // developement
             objMqTT.serverHost = "3.214.104.246"
             objMqTT.username = "mqtt_dev_user"
             objMqTT.password = "Sm@rt#123$"
             objMqTT.port = 1883
             print("MQTT Environment developement:--->")
         case .staging:
            objMqTT.serverHost = "3.214.104.246"
            objMqTT.username = "mqtt_dev_user"
            objMqTT.password = "Sm@rt#123$"
            objMqTT.port = 1883
            print("MQTT Environment developement:--->")
         case .demo:
            objMqTT.serverHost = "3.214.104.246"
            objMqTT.username = "mqtt_dev_user"
            objMqTT.password = "Sm@rt#123$"
            objMqTT.port = 1883
            print("MQTT Environment developement:--->")
         case .production:
             // production
             objMqTT.serverHost = "mqtt.thedoo.io"
             objMqTT.username = "doo_mqtt"
             objMqTT.password = "LemHVZC3mBg6TsV2ZvDuA9vArpgapzNr"
             objMqTT.port =  8883//1883 // 8883 => TLS 
             print("MQTT Environment Production:--->")
         }
         return objMqTT
     }
}
