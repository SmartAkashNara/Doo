//
//  MQTTSwift.swift
//  MQTTSwift
//
//  Created by Christoph Krey on 23.05.16.
//  Copyright © 2016 OwnTracks. All rights reserved.
//

import MQTTClient
import Foundation

class MQTTSwift: NSObject, MQTTSessionDelegate  {
    
    var isAvoidToStopLoader = false
    var sessionConnected = false
    var sessionError = false
    var sessionReceived = false
    var sessionSubAcked = false
    var session: MQTTSession?
    var gatewayMachAddress: String = "+"
    
    //    // EnterPrise
    //    let server = "3.214.104.246"
    //    let port:UInt32 = 1883
    //    let username = "ss_mqtt_cloud_client"
    //    let password = "uM3yvX9vw2gWAsa3fMh"
    //    let BROKE_SUBSCRIPTION_CHANNEL = "SS_BROKER_IOT_OFFICE"
    //    let BROKE_LISTEN_CHANNEL = "SS_SUB_NOTIFICATION_IOT_OFFICE"
    
    
    // production
    //    let BROKE_SUBSCRIPTION_CHANNEL = "SS_BROKER_IOT_AUTOMATION_MASTER"
    //    let BROKE_LISTEN_CHANNEL = "SS_NOTIFICATION_SUB_IOT"
    //    let server = "mqtt.smartsensesolutions.com"
    //    let username = "ss_mqtt_iot_user"
    //    let password = "YLX8AvGdk5JMJBwx6FExJWtQ4H5993An"
    //    let port:UInt32 = 1883
    
    var BROKE_ACTION_SUB_CHANNEL: String {
        return "doo/cloud/+/core/\(self.gatewayMachAddress)/action"
    }
    var BROKE_GATEWAY_SUB_CHANNEL: String {
        return "doo/cloud/+/core/\(self.gatewayMachAddress)/presence"
    }
    let server = Environment.mqtt.serverHost
    let username = Environment.mqtt.username
    let password = Environment.mqtt.password
    let port:UInt32 = Environment.mqtt.port
    
    
    var seconds:DispatchTime!
    let objAESSecuritySmartOffice = AESSecuritySmartOffice()
    
    static private var sharedInstance: MQTTSwift? = nil
    static var shared: MQTTSwift {
        if MQTTSwift.sharedInstance == nil {
            MQTTSwift.sharedInstance = MQTTSwift()
        }
        return MQTTSwift.sharedInstance!
    }
    
    func subscribeMQTT(macAddress: String) {
        
        self.unsubscribeMQTT() // unsubscribe first and subscribe to second.
        self.gatewayMachAddress = macAddress // replace mac address...
        
        // API_LOADER.show(animated: true) // Don't show loader while connecting to MQTT...
        session = MQTTSession()
        guard (session != nil) else {
            API_LOADER.dismiss(animated: true)
            fatalError("Could not create MQTTSession")
        }
        
        session?.delegate = self
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString{
            session?.clientId = deviceId
        }
        
        let objMQTTCFSocketTransport = MQTTSSLSecurityPolicyTransport()
        objMQTTCFSocketTransport.port = port
        objMQTTCFSocketTransport.host = server
        if Environment.server == .production{
            objMQTTCFSocketTransport.tls = true
        }
        
        // for ssl sing in certificate manually her here commneted becouse using one flag .tls == true working ok no need to do mannually if any case will occure will see or uncommneted below code
        /*
         if let caClient = Bundle.main.path(forResource: "ca", ofType: "der")  {
         do{
         let caData:Data = try Data.init(contentsOf: URL.init(fileURLWithPath: caClient))
         let securityPolicy  =  MQTTSSLSecurityPolicy.init(pinningMode: .certificate)
         securityPolicy?.allowInvalidCertificates = true;
         securityPolicy?.pinnedCertificates = [caData]
         securityPolicy?.validatesCertificateChain = false;
         securityPolicy?.validatesDomainName = false
         objMQTTCFSocketTransport.securityPolicy = securityPolicy
         } catch {
         debugPrint("try catched ca certificate error occur")
         }
         }*/
        
        session?.transport = objMQTTCFSocketTransport
        session?.connect()
        session?.password = password
        session?.userName = username
        session?.cleanSessionFlag = false
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            debugPrint("Subscribed to presence: \(self.BROKE_GATEWAY_SUB_CHANNEL)")
            debugPrint("Subscribed to action: \(self.BROKE_ACTION_SUB_CHANNEL)")
            self.session?.subscribe(toTopic: self.BROKE_GATEWAY_SUB_CHANNEL, at: .atLeastOnce)
            self.session?.subscribe(toTopic: self.BROKE_ACTION_SUB_CHANNEL, at: .atLeastOnce)
        })
    }
    
    func unsubscribeMQTT() {
        session?.disconnect()
        session?.unsubscribeTopic(self.BROKE_GATEWAY_SUB_CHANNEL, unsubscribeHandler: { error in
            if error == nil {
                debugPrint("Successfully unsubscribed to MQTT channels")
            }else{
                debugPrint("Unable to unsubscribe, error occured!")
            }
        })
        session?.unsubscribeTopic(self.BROKE_ACTION_SUB_CHANNEL, unsubscribeHandler: { error in
            if error == nil {
                debugPrint("Successfully unsubscribed to MQTT channels")
            }else{
                debugPrint("Unable to unsubscribe, error occured!")
            }
        })
        session = nil // Remove session...
    }
    
    func reConnectMQTTIfNeeded(){
        if !sessionConnected{
            self.session?.connect()
        }
    }
    
    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        switch eventCode {
        case .connected:
            sessionConnected = true
        case .connectionClosed:
            sessionConnected = false
        default:
            sessionError = true
        }
    }
    
    func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        debugPrint("topic: \(String(describing: topic))")
        let topic = String(describing: topic)
        guard let dictObject = data.dataToJSON() else { return }
        let json = JSON.init(dictObject)
        if topic.contains("presence") {
            debugPrint("MQTT Response :=", dictObject)
            if self.gatewayMachAddress == json["devMac"].stringValue {
                APP_USER?.selectedEnterprise?.enterpriseGateway?.status = (json["presence"].intValue == 1) ? true : false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: GATEWAY_STATUS_CHANGE), object: nil)
            }else{
                
                // here device online and offline status
                let dict:[String:Any] = ["status":(json["presence"].intValue == 1) ? true : false, "macAddress":json["devMac"].stringValue]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: dict)
            }
        }else{
            let dict:[String:Any] = ["applianceId":json["applianceId"].intValue, "applianceData":json["applianceData"].dictionaryValue]
            debugPrint("MQTT Response :=", dictObject)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: APPLIENCE_ON_OFF_UPDATE_STATUS), object: dict)
        }
        sessionReceived = true
    }
    
    func parseEndpoint(endPointHexaValue: String) -> [Int] {
        var arrayEndPoint = [Int]()
        if let decimalInt = Int(endPointHexaValue, radix: 16) {
            for index in stride(from: 0, to: 6, by: 1){
                if ((decimalInt & (1 << index)) > 0){
                    arrayEndPoint.append(index+1)
                    print(index+1)
                }
            }
        } else {
            print("invalid input")
        }
        return arrayEndPoint
    }
    
    func subAckReceived(_ session: MQTTSession!, msgID: UInt16, grantedQoss qoss: [NSNumber]!) {
        sessionSubAcked = true;
        dissmissLoader()
    }
    
    func connectionClosed(_ session: MQTTSession!) {
        dissmissLoader()
    }
    
    func connectionError(_ session: MQTTSession!, error: Error!) {
        dissmissLoader()
    }
    
    func dissmissLoader(){
        if !isAvoidToStopLoader{
            API_LOADER.dismiss(animated: true)
        }
        
    }
}
