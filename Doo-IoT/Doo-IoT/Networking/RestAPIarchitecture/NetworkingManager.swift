//
//  NetworkingManager.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 16/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import Alamofire

var API_SERVICES = NetworkingManager.shared

// MARK:- Auth interceptor
class AuthInterceptor: RequestInterceptor {
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        debugPrint("\(#function) : request : \(request), retryCount : \(request.retryCount)")
        // let noOfTimesRetried = request.retryCount
        
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        
        switch statusCode {
        case 200...299:
            completion(.doNotRetry)
        default:
            completion(.doNotRetry)
            /*
            if noOfTimesRetried < 1 {
                // Above condition will retry two times.
                // When no of times retried is 0, it means one call already being made, which made by developer
                // When no of times retried is 1, it means one more call has been made by retry, which made by above condition.
                completion(.retry) // Retry only for three times
            }else{
                completion(.doNotRetry)
            }
 */
        }
    }
}

class NetworkingManager {
    
    /// Custom header field
    var headerForNetworking: [String: String]  = ["Content-Type":"application/json"]
    
    // Singleton instance of networking...
    private static var networkingManager: NetworkingManager? = nil
    static var shared: NetworkingManager {
        if networkingManager == nil {
            networkingManager = NetworkingManager()
        }
        return networkingManager!
    }
    
    // Networking stuff using Alamofire...
    private var defaultSession = Session.default
    
    init() {
        // default configuration...
        let configuration = URLSessionConfiguration.af.default
        configuration.httpMaximumConnectionsPerHost = 10    // Limits the no of requests simultaneously can be made.
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        // As Apple states in their documentation, mutating URLSessionConfiguration properties after the instance has been added to a URLSession (or, in Alamofire’s case, used to initialize aSession) has no effect.
        // What above sentance indicates: Changing instance properties of 'configuration' later, won't have any effect. You can say that it won't work like class instance.
        self.defaultSession = Session(configuration: configuration, interceptor: AuthInterceptor())
    }
    
    // Additional vaiables
    private let VERIFICATION_TOKEN_KEY = "Verification-Token"
    private let AUTHORIZATION_KEY = "Authorization"
    private let ACCEPT_LANG_KEY = "Accept-Language"
    
    // BASE URL
    private let BASE_URL = Environment.APIBasePath()
}

// MARK: VERIFICATION TOKEN WORK
extension NetworkingManager{
    /// Set Bearer token with this method
    func setAuthorization(_ authorization : String) {
        self.headerForNetworking.removeValue(forKey: VERIFICATION_TOKEN_KEY)
        self.headerForNetworking[AUTHORIZATION_KEY] = "Bearer \(authorization)"
        self.headerForNetworking[ACCEPT_LANG_KEY] = Locale.current.languageCode?.lowercased() ?? "en"
    }
    func getAuthorization() -> String? {
        if let authorization = self.headerForNetworking[AUTHORIZATION_KEY], !authorization.isEmpty {
            return authorization
        }
        return nil
    }
    /// Verification Token
    func setVerificationToken(_ verificationToken : String) {
        self.headerForNetworking[VERIFICATION_TOKEN_KEY] = "Bearer " + verificationToken
        self.headerForNetworking[ACCEPT_LANG_KEY] = Locale.current.languageCode?.lowercased() ?? "en"
    }
    func getVerificationToken() -> String? {
        if let verificationToken = self.headerForNetworking[VERIFICATION_TOKEN_KEY], !verificationToken.isEmpty {
            return verificationToken
        }
        return nil
    }
    func isVerificationTokenExists() -> Bool {
        if let verificationToken = self.headerForNetworking[VERIFICATION_TOKEN_KEY], !verificationToken.isEmpty {
            return true
        }
        return false
    }
    
    func removeAuthorizationAndVarification() {
        self.headerForNetworking.removeValue(forKey: VERIFICATION_TOKEN_KEY)
        self.headerForNetworking.removeValue(forKey: AUTHORIZATION_KEY)
    }
}


// MARK: SINGLE REQUEST
extension NetworkingManager{
    func callAPI(_ params: [String: Any] = [:],
                 path: Routing,
                 method: HTTPMethod = .post,
                 encoding: ParameterEncoding = JSONEncoding.prettyPrinted,
                 success: (([String: JSON]?) -> ())? = nil,
                 failure: ((String?) -> ())? = nil,
                 internetFailure: (() -> ())? = nil,
                 failureInform: (() -> ())? = nil) {
        debugPrint("API Call ----------------------------")
        debugPrint("Header: \(self.headerForNetworking) -------\n")
        debugPrint("URL Access: \(BASE_URL + path.getPath) -------\n")
        debugPrint("Params: \(params) -------\n")
        debugPrint("API Call ----------------------------")
        
        guard SSReachabilityManager.shared.isNetworkAvailable else {
            // SceneDelegate.findOutUIAndShowNoInternetConnectionPopup() // default alert, show from anywhere.
            failureInform?()
            if let internetFailureClosure = internetFailure {
                DispatchQueue.main.async {
                    internetFailureClosure()
                }
            }else{
                DispatchQueue.main.async {
                    CustomAlertView.init(title: localizeFor("internet_failure")).showForWhile(animated: true)
                }
            }
            // Stop loader if working
            DispatchQueue.main.async {
                API_LOADER.dismiss(animated: true)
            }
            return
        }
        
        // For better understanding - https://stackoverflow.com/questions/43282281/how-to-add-alamofire-url-parameters
        var encodingReceived: ParameterEncoding = encoding
        if method == .get {
            encodingReceived = URLEncoding.default
        }
        
        let completePath = BASE_URL + path.getPath
        let trimmedURL = completePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" // Replacing space to %20
        
        let request = self.defaultSession.request(trimmedURL, method: method, parameters: params, encoding: encodingReceived, headers: HTTPHeaders.init(self.headerForNetworking))
        /// request.validate().responseJSON { (dataResponse) in  // Validate in all errors, even the custom one sent by Your networking guys.
        request.responseJSON { (dataResponse) in
                debugPrint(dataResponse)

            switch dataResponse.result {
            case .success(let value):
                let parsingJSON = JSON.init(value).dictionaryValue
                debugPrint(parsingJSON)

                let verifyErrorPolicy = self.verifyErrorPossiblities(dataResponse, parsingJSON, isHandleFailure: (failure == nil))
                if verifyErrorPolicy.isClearForSuccess {
                    debugPrint("Go ahead with success!")
                    success?(parsingJSON) // closure call
                }else{
                    if verifyErrorPolicy.customErrorMessage.count != 0 {
                        failure?(verifyErrorPolicy.customErrorMessage) // closure call
                    }else{
                        failure?(nil) // closure call
                    }
                    failureInform?()
                }
            case .failure(let error):
                // manually cancelled
                guard !error.localizedDescription.contains("cancelled") else { return }
                
                switch error {
                case .explicitlyCancelled:
                    break // Ignore: these are manually cancelled requests
                default:
                    if let errorDesc = dataResponse.error?.errorDescription,
                       errorDesc == "URLSessionTask failed with error: The request timed out." {
                        DispatchQueue.main.async {
                            API_LOADER.dismiss(animated: true)
                            CustomAlertView.init(title: localizeFor("slow_or_internet_failure")).showForWhile(animated: true)
                            internetFailure?()
                        }
                    }else{
                        self.verifyErrorPossiblities(dataResponse, isHandleFailure: (failure == nil)) // if failure part not handled manually
                        failure?(nil) // closure call
                    }
                    debugPrint("Networking error message: \(String(describing: error.errorDescription))")
                }
                failureInform?()
            }
            
        }
    }
}

// MARK: Send array directly.
extension NetworkingManager {
    func callAPIWithCollection(_ collection: [Any] = [],
                 path: Routing,
                 method: HTTPMethod = .post,
                 encoding: ParameterEncoding = JSONEncoding.prettyPrinted,
                 success: (([String: JSON]?) -> ())? = nil,
                 failure: ((String?) -> ())? = nil,
                 internetFailure: (() -> ())? = nil,
                 failureInform: (() -> ())? = nil) {
        
        guard let requestingURL = URL.init(string: Environment.APIBasePath()+path.getPath) else {
            debugPrint("Requesting URL!")
            CustomAlertView.init(title: localizeFor("something_went_wrong")).showForWhile(animated: true)
            return
        }
        
        var request = URLRequest(url: requestingURL)
        request.httpMethod = method.rawValue
        request.setHeader(fields: HTTPHeaders.init(self.headerForNetworking).dictionary)
        request.httpBody = try! JSONSerialization.data(withJSONObject: collection)
        
        self.defaultSession.request(request).responseJSON { (dataResponse) in
            switch dataResponse.result {
            case .success(let value):
                let parsingJSON = JSON.init(value).dictionaryValue
                
                let verifyErrorPolicy = self.verifyErrorPossiblities(dataResponse, parsingJSON, isHandleFailure: (failure == nil))
                if verifyErrorPolicy.isClearForSuccess {
                    debugPrint("Go ahead with success!")
                    success?(parsingJSON) // closure call
                }else{
                    if verifyErrorPolicy.customErrorMessage.count != 0 {
                        failure?(verifyErrorPolicy.customErrorMessage) // closure call
                    }else{
                        failure?(nil) // closure call
                    }
                    failureInform?()
                }
            case .failure(let error):
                // manually cancelled
                guard !error.localizedDescription.contains("cancelled") else { return }
                
                switch error {
                case .explicitlyCancelled:
                    break // Ignore: these are manually cancelled requests
                default:
                    debugPrint("Networking error message: \(String(describing: error.errorDescription))")
                    self.verifyErrorPossiblities(dataResponse, isHandleFailure: (failure == nil)) // if failure part not handled manually
                    failure?(nil) // closure call
                }
                failureInform?()
            }
        }
    }
}

extension URLRequest{
    mutating func setHeader(fields: [String:String?]) {
        fields.forEach { (headerDict) in
            self.setValue(headerDict.value, forHTTPHeaderField: headerDict.key)
        }
    }
}


// MARK: PASS SOMETHING WENT WRONG!
extension NetworkingManager {
    
//    Kindly refer below list of status codes being returned by Golang service:
//    200  - Successful Operation
//    202 -  Device Offline
//    400 - Bad Request (invalid request body)
//    401 - If user is not having appliance access, Invalid token, session expired
//    403 - no enterprise selected
//    500 - Internal server error
//    503 - Gateway offline
    
    @discardableResult
    func verifyErrorPossiblities(_ dataResponse: AFDataResponse<Any>, _ jsonResponse: [String: JSON]? = nil, isHandleFailure: Bool = true) -> (isClearForSuccess: Bool, customErrorMessage: String) {
        
        guard let statusCode = dataResponse.response?.statusCode else {
            if isHandleFailure {
                showSomethingWentWrong()
            }
            return (false, "")
        }
        switch statusCode {
        case 200...201, 203...299:
            return (true, "")
        case 202:
            // Light Error.
            func showAlert(withCustomMessage customMessage: String) {
                CustomAlertView.init(title: customMessage, forPurpose: .success).showForWhile(animated: true)
                // Stop loader if working
                API_LOADER.dismiss(animated: true)
            }
            
            if let customMessage = jsonResponse?["payload"]?.dictionaryValue["error"]?.dictionaryValue["message"]?.stringValue {
                if isHandleFailure {
                    showAlert(withCustomMessage: customMessage)
                }else{
                    return (false, customMessage)
                }
            }else if let customMessage = jsonResponse?["message"]?.stringValue {
                if isHandleFailure {
                    showAlert(withCustomMessage: customMessage)
                }else{
                    return (false, customMessage)
                }
            }else{
                if isHandleFailure {
                    showSomethingWentWrong()
                }
            }
        case 403:
            // Enterprise Revoked
            self.switchToFirstEnterpriseOrAddEnterprise()
            API_LOADER.dismiss(animated: true)
        case 401:
            // Unauthorization
            if let customMessage = jsonResponse?["payload"]?.dictionaryValue["error"]?
                .dictionaryValue["message"]?.stringValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    CustomAlertView.init(title: customMessage).showForWhile(animated: true)
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    CustomAlertView.init(title: "Invalid username/password")
                        .showForWhile(animated: true)
                }
            }
            // Stop loader if working
            API_LOADER.dismiss(animated: true)
            if APP_USER != nil {
                UserManager.logoutMethod()
            }
        default:
            debugPrint("Networking error message: \(String(describing:   jsonResponse?["payload"]?.dictionaryValue["error"]?.dictionaryValue["message"]?.stringValue))")
            
            func showAlert(withCustomMessage customMessage: String) {
                CustomAlertView.init(title: customMessage).showForWhile(animated: true)
                // Stop loader if working
                API_LOADER.dismiss(animated: true)
            }
            
            if let customMessage = jsonResponse?["payload"]?.dictionaryValue["error"]?.dictionaryValue["message"]?.stringValue {
                if isHandleFailure {
                    showAlert(withCustomMessage: customMessage)
                }else{
                    return (false, customMessage)
                }
            }else if let customMessage = jsonResponse?["message"]?.stringValue {
                if isHandleFailure {
                    showAlert(withCustomMessage: customMessage)
                }else{
                    return (false, customMessage)
                }
            }else{
                if isHandleFailure {
                    showSomethingWentWrong()
                }
            }
        }
        
        return (false, "")
    }
    
    func showSomethingWentWrong() {
        CustomAlertView.init(title: localizeFor("something_went_wrong")).showForWhile(animated: true)
        debugPrint("Show: Something went wrong! please try again after sometime!")
        
        // Stop loader if working
        API_LOADER.dismiss(animated: true)
    }
}

extension NetworkingManager {
    func switchToFirstEnterpriseOrAddEnterprise() {
        
        // This will switch to first enterprise by omitting the current one (If enterprises available)
        // This will switch to 'Add Enterprise' view. (If no other enterprises available)
        guard let currentlySelectedEnterpriseID = APP_USER?.selectedEnterprise?.id else {
            return
        }
        guard let enterpriseIndex = ENTERPRISE_LIST.firstIndex(where: {$0.id == currentlySelectedEnterpriseID}) else {
            return
        }
        
        let currentEnterprise = ENTERPRISE_LIST[enterpriseIndex]
        (TABBAR_INSTANCE as? DooTabbarViewController)?.showAlert(withMessage: "Your access to '\(currentEnterprise.name)' enterprise has been revoked!", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: { alertAction in
            
            // Process to remove current enterprise from available and show case screen accordingly.
            ENTERPRISE_LIST.remove(at: enterpriseIndex)
            (TABBAR_INSTANCE as? DooTabbarViewController)?.topUpdatedLayoutCard?.resetEnterpriseList() // Reset list.
            if ENTERPRISE_LIST.count != 0, let firstEnterprise = ENTERPRISE_LIST.first{
                // If more enterprises are there to switch.
                if let dooTabbar = TABBAR_INSTANCE as? DooTabbarViewController {
                    dooTabbar.topUpdatedLayoutCard?.callSwitchEnterpriseAPI(firstEnterprise, atIndex: 0)
                    dooTabbar.showAlert(withMessage: "You have switched to Enterprise: \(firstEnterprise.name)", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: { action in
                        
                        // SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.instantiateInitialViewController() // reset to home...
                        (dooTabbar.viewControllers?[DooTabs.home.rawValue] as? UINavigationController)?.popToRootViewController(animated: true)
                        // ((dooTabbar.viewControllers?[DooTabs.home.rawValue] as? UINavigationController)?.viewControllers.first as? HomeViewController)?.viewAppearedUsingTab()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dooTabbar.dooTabbarSelection.selection = DooTabs.home.rawValue // Switch to home manually.
                        }
                    }))
                }else{
                    SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.instantiateViewController(identifier: "SplashViewController")
                }
                
            }else{
                // Add Enterprise
                SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.addEnterpriseWhenNotAvailable
            }
        }))
        
    }
}


extension NetworkingManager {
    func cancelAllRequests() {
        self.defaultSession.cancelAllRequests()
    }
    
    func cancelRequest(routing: Routing) {
        let lastPathComponent = URL.init(string: routing.getPath)?.lastPathComponent ?? ""
        self.defaultSession.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            debugPrint("avaiable tasks: \(sessionDataTask)")
            sessionDataTask.forEach {
                if let currentRequestLastPathComponent = $0.currentRequest?.url?.lastPathComponent {
                    if lastPathComponent == currentRequestLastPathComponent {
                        $0.cancel()
                        debugPrint("Requests available to cancel: \($0.currentRequest?.url)")
                    }
                }
            }
        }
    }
    func cancelUploadRequests(routing: Routing) {
        let lastPathComponent = URL.init(string: routing.getPath)?.lastPathComponent ?? ""
        self.defaultSession.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            debugPrint("avaiable tasks: \(uploadData)")
            uploadData.forEach {
                if let currentRequestLastPathComponent = $0.currentRequest?.url?.lastPathComponent {
                    if lastPathComponent == currentRequestLastPathComponent {
                        $0.cancel()
                        debugPrint("Requests available to cancel: \($0.currentRequest?.url)")
                    }
                }
            }
        }
    }
}

// MARK: SINGLE REQUEST
extension NetworkingManager{
    func callUploadFileAPI(_ params: [String: Any] = [:],
                 localFilePaths: [URL] = [], // Local files or images
                 images: [UIImage] = [], // Local files or images
                 names: [String], // Mandatory in both cases, images & local file paths.
                 fileNames: [String] = [],
                 path: Routing,
                 method: HTTPMethod = .post,
                 withProgress progressBlock: @escaping (_ progressValue: Double) -> Void,
                 success: (([String: JSON]?) -> ())? = nil,
                 failure: ((String?) -> ())? = nil,
                 internetFailure: (() -> ())? = nil,
                 failureInform: (() -> ())? = nil) {
        
        debugPrint("API Call ----------------------------")
        debugPrint("Header: \(self.headerForNetworking) -------\n")
        debugPrint("URL Access: \(BASE_URL + path.getPath) -------\n")
        debugPrint("Params: \(params) -------\n")
        debugPrint("API Call ----------------------------")
        
        guard SSReachabilityManager.shared.isNetworkAvailable else {
            // SceneDelegate.findOutUIAndShowNoInternetConnectionPopup() // default alert, show from anywhere.
            failureInform?()
            if let internetFailureClosure = internetFailure {
                DispatchQueue.main.async {
                    internetFailureClosure()
                }
            }else{
                DispatchQueue.main.async {
                    CustomAlertView.init(title: localizeFor("internet_failure")).showForWhile(animated: true)
                }
            }
            // Stop loader if working
            DispatchQueue.main.async {
                API_LOADER.dismiss(animated: true)
            }
            return
        }
          
        let completePath = BASE_URL + path.getPath
        let trimmedURL = completePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" // Replacing space to %20
        
        self.defaultSession.upload(multipartFormData: { multipartFormData in
            for index in 0..<localFilePaths.count {
                let localFilePath = localFilePaths[index]
                multipartFormData.append(localFilePath, withName: names[index]) // filename automatically will be taken from url, including mime type...
            }
            for index in 0..<images.count {
                let imageToBeUploaded = images[index];
                let imageNameToBeAppended = names[index];
                if let imageData = imageToBeUploaded.jpegData(compressionQuality: 0) {
                    multipartFormData.append(imageData,
                                             withName: imageNameToBeAppended,
                                             fileName: fileNames[index],
                                             mimeType: "image/jpg")
                }
            }
            for (key, value) in params {
                multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
            }
        }, to: trimmedURL,
        usingThreshold: UInt64.init(),
        method: method,
        headers: HTTPHeaders.init(self.headerForNetworking))
        .uploadProgress(closure: { (progress) in
            progressBlock(progress.fractionCompleted)
        })
        .responseJSON { (dataResponse) in
            
            switch dataResponse.result {
            case .success(let value):
                let parsingJSON = JSON.init(value).dictionaryValue
                
                let verifyErrorPolicy = self.verifyErrorPossiblities(dataResponse, parsingJSON, isHandleFailure: (failure == nil))
                if verifyErrorPolicy.isClearForSuccess {
                    debugPrint("Go ahead with success!")
                    success?(parsingJSON) // closure call
                }else{
                    if verifyErrorPolicy.customErrorMessage.count != 0 {
                        failure?(verifyErrorPolicy.customErrorMessage) // closure call
                    }else{
                        failure?(nil) // closure call
                    }
                    failureInform?()
                }
            case .failure(let error):
                // manually cancelled
                guard !error.localizedDescription.contains("cancelled") else { return }
                
                switch error {
                case .explicitlyCancelled:
                    break // Ignore: these are manually cancelled requests
                default:
                    debugPrint("Networking error message: \(String(describing: error.errorDescription))")
                    self.verifyErrorPossiblities(dataResponse, isHandleFailure: (failure == nil)) // if failure part not handled manually
                    failure?(nil) // closure call
                }
                failureInform?()
            }
        }
    }
    
    func downloadFile(url: String,
                      fileName: String,
                      isSetHeaderNil:Bool = false,
                      withProgress progressBlock: @escaping (_ progressValue: Double) -> Void,
                      onSuccess success: @escaping (_ responsePathURL: URL?, _ isAvailabelFile:Bool) -> Void,
                      failure: ((String?) -> ())? = nil,
                      internetFailure: (() -> ())? = nil,
                      failureInform: (() -> ())? = nil){
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
        let fileURL = documentsURL.appendingPathComponent(fileName)
        if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathComponent = documentsPathURL.appendingPathComponent(fileURL.lastPathComponent)
            let filePath = pathComponent.path
            
            if FileManager.default.fileExists(atPath: filePath) {
                if let _ = try? FileManager.default.removeItem(atPath: filePath) {
                    debugPrint("FILE NOT AVAILABLE")
                }else{
                    debugPrint("FILE AVAILABLE")
                    success(fileURL, true)
                    return
                }
            } else {
                debugPrint("FILE NOT AVAILABLE")
            }
        }

        debugPrint("url to call: \(url)")
        let destination: DownloadRequest.Destination = { _, _ in
           debugPrint(fileURL)
            return (fileURL, [.removePreviousFile])
        }
            
        // change in inteval timeout for specific request
        self.defaultSession.download(
            url,
            headers: isSetHeaderNil ? nil : HTTPHeaders.init(self.headerForNetworking),
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
                progressBlock(progress.fractionCompleted)
            }).response(completionHandler: { (dataResponse) in
                //here you able to access the DefaultDownloadResponse
                //result closure
                
                switch dataResponse.result {
                case .success(_):
                    success(dataResponse.value as? URL, false) // closure call
                    // failureInform?()
                case .failure(let error):
                    // manually cancelled
                    guard !error.localizedDescription.contains("cancelled") else { return }
                    
                    switch error {
                    case .explicitlyCancelled:
                        break // Ignore: these are manually cancelled requests
                    default:
                        debugPrint("Networking error message: \(String(describing: error.errorDescription))")
                        failure?(nil) // closure call
                    }
                    failureInform?()
                }
            })
    }
    
}
