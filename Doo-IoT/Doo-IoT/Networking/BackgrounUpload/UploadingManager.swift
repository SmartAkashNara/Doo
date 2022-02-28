//
//  UploadingManager.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 26/07/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class UploadingManager: NSObject {
    
    var session: URLSession?
    
    // Singleton instance of networking...
    private static var uploadingManager: UploadingManager? = nil
    static var shared: UploadingManager {
        if uploadingManager == nil {
            uploadingManager = UploadingManager()
            uploadingManager?.sessionConfig()
        }
        return uploadingManager!
    }
    
    func sessionConfig() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "background.upload.session")
        configuration.httpMaximumConnectionsPerHost = 5;
        self.session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    // Extension Properties
    var successClosure: ((JSON?)->())? = nil
    var progressClosure: ((Double)->())? = nil
    var failedClosure: (()->())? = nil
    var responseData: [Int: Data] = [:]
    var isCancelledManually: Bool = false // tracks that task cancelled manually, if yes don't show failed alert.
}

// Developer Call.
extension UploadingManager {
    func uploadDocs(parameters: [String: Any],
                    routing: Routing,
                    method: UploadHTTPMethod = .post,
                    keyName: String,
                    localUrls: [URL],
                    customFileNames: [String] = [],
                    uploadProgress: ((Double)->())? = nil,
                    success: @escaping ((JSON?)->()),
                    failed: @escaping (()->())) {
        
        isCancelledManually = false // reset to false.
        
        // Assign closures
        self.progressClosure = uploadProgress
        self.successClosure = success
        self.failedClosure = failed
        
        // Set filenames as it is if custom filenames not given.
        var fileNames = customFileNames
        if fileNames.count == 0 {
            fileNames = localUrls.map({ (url) -> String in
                return url.lastPathComponent
            })
        }
        
        // Prepare Uploading URL
        let completePath = Environment.APIBasePath() + routing.getPath
        let trimmedURL = completePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" // Replacing space to %20
        guard let urlToUploadAt = URL.init(string: trimmedURL) else {
            dismissLoader()
            return
        }
        
        // temporary url to story data while uploding.
        let tempDir = FileManager.default.temporaryDirectory
        let temporaryFileURL = tempDir.appendingPathComponent("throwaway")
        
        if let task = try? self.session?.uploadMultipartTaskWithURL(URL: urlToUploadAt,
                                                            method: method,
                                                           parameters: parameters as [String : AnyObject],
                                                           fileKeyName: keyName,
                                                           fileURLs: localUrls,
                                                           customFileNames: fileNames,
                                                           localFileURL: temporaryFileURL) {
            
            task.resume()
        }else{
            debugPrint("File fetch issue.")
            dismissLoader()
        }
    }
    
    func cancelTasks() {
        isCancelledManually = true // don't show alert in this case.
        UploadingManager.shared.session?.getAllTasks(completionHandler: { (tasks) in
            for task in tasks {
                task.cancel()
            }
        })
    }
}

// Tracking.
extension UploadingManager: URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        debugPrint("error: \(error)")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            debugPrint("Failed Task")
            DispatchQueue.main.async {
                self.dismissLoader()
            }
        }else{
            debugPrint("Completed uploading")
            if let responseData = self.responseData[task.taskIdentifier],
               let jsonInfo = responseData.dataToJSON() {
                debugPrint("json info: \(jsonInfo)")
                DispatchQueue.main.async {
                    let verifyErrorPolicy = self.verifyErrorPossiblities(jsonResponse: JSON.init(jsonInfo), isHandleFailure: true)
                    if verifyErrorPolicy.isClearForSuccess {
                        // debugPrint("Task desc: \(task.)")
                        self.successClosure?(JSON.init(jsonInfo))                        
                    }else{
                        self.dismissLoader()
                    }
                }
            }else{
                // debugPrint("Task desc: \(task.)")
                DispatchQueue.main.async {
                    self.dismissLoader()
                }
            }
        }
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        debugPrint("did received data: \(data)")
        if let location = (dataTask.response as? HTTPURLResponse)?.allHeaderFields["Location"] as? String,
            let uploadedURL = URL.init(string: location){
            debugPrint("uploading url: \(uploadedURL)")
        }
        
        self.responseData[dataTask.taskIdentifier] = data // assign new data.
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        // debugPrint("send body data")
        
        let uploadProgress: Double = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressClosure?(uploadProgress)
        }
        debugPrint("\n\nprogress of --------- \(uploadProgress)")
    }
}

// MARK: PASS SOMETHING WENT WRONG!
extension UploadingManager {
    
    @discardableResult
    func verifyErrorPossiblities(jsonResponse: JSON, isHandleFailure: Bool = true) -> (isClearForSuccess: Bool, customErrorMessage: String) {
        
        guard let statusCode = jsonResponse["status"].int else {
            if isHandleFailure {
                showSomethingWentWrong()
            }
            return (false, "")
        }
        switch statusCode {
        case 200...299:
            return (true, "")
        case 401:
            if let customMessage = jsonResponse["payload"].dictionaryValue["error"]?
                .dictionaryValue["message"]?.stringValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    CustomAlertView.init(title: customMessage).showForWhile(animated: true)
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    CustomAlertView.init(title: localizeFor("auth_required_try_login_agian"))
                        .showForWhile(animated: true)
                }
            }
            UserManager.logoutMethod()
        default:
            debugPrint("Networking error message: \(String(describing:   jsonResponse["payload"].dictionaryValue["message"]?.stringValue))")
            
            func showAlert(withCustomMessage customMessage: String) {
                CustomAlertView.init(title: customMessage).showForWhile(animated: true)
                // Stop loader if working
                API_LOADER.dismiss(animated: true)
            }
            
            if let customMessage = jsonResponse["payload"].dictionaryValue["message"]?.stringValue {
                if isHandleFailure {
                    showAlert(withCustomMessage: customMessage)
                }else{
                    return (false, customMessage)
                }
            }else if let customMessage = jsonResponse["message"].string {
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

// Loader
extension UploadingManager {
    func showLoader() {
        DispatchQueue.main.async {
            API_LOADER.show(animated: true)
        }
    }
    func dismissLoader(withFailedAlert: Bool = true) {
        // is it failed alert and should be cancelled task manually.
        if withFailedAlert && !isCancelledManually {
            CustomAlertView.init(title: localizeFor("something_went_wrong_while_uploading")).showForWhile(animated: true)
            DispatchQueue.main.async {
                self.failedClosure?()
            }
        }
        DispatchQueue.main.async {
            API_LOADER.dismiss(animated: true)
        }
    }
}
