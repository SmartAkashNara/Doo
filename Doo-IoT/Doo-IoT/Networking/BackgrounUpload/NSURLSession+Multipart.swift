//
//  NSURLSession+Multipart.swift
//  NSURLSessionMultipart
//
//  Created by Robert Ryan on 10/6/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//

import Foundation
import MobileCoreServices

extension URLSession {

    /// Create multipart upload task.
    ///
    /// If using background session, you must supply a `localFileURL` with a `NSURL` where the
    /// body of the request should be saved.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    /// - parameter localFileURL:       The optional file `NSURL` where the body of the request should be stored. If using non-background session, pass `nil` for the `localFileURL`.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func uploadMultipartTaskWithURL(URL: URL, method: UploadHTTPMethod = .post, parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [URL]?, customFileNames: [String]?, localFileURL: URL? = nil) throws -> URLSessionUploadTask {
        let (request, data) = try createMultipartRequestWithURL(URL: URL, method: method, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs, customFileNames: customFileNames)
        if let localFileURL = localFileURL {
            try data.write(to: localFileURL)
            return uploadTask(with: request as URLRequest, fromFile: localFileURL)
        }
        
        return uploadTask(with: request, from: data)
    }
    
    /// Create multipart upload task.
    ///
    /// This should not be used with background sessions. Use the rendition without
    /// `completionHandler` if using background sessions.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    /// - parameter completionHandler:  The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.

    public func uploadMultipartTaskWithURL(URL: URL, parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [URL]?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionUploadTask {
        let (request, data) = try createMultipartRequestWithURL(URL: URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        return uploadTask(with: request, from: data, completionHandler: completionHandler)
    }
    
    /// Create multipart data task.
    ///
    /// This should not be used with background sessions. Use `uploadMultipartTaskWithURL` with
    /// `localFileURL` and without `completionHandler` if using background sessions.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func dataMultipartTaskWithURL(URL: URL, parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [URL]?) throws -> URLSessionDataTask {
        var (request, data) = try createMultipartRequestWithURL(URL: URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        request.httpBody = data
        return dataTask(with: request as URLRequest)
    }
    
    /// Create multipart data task.
    ///
    /// This should not be used with background sessions. Use `uploadMultipartTaskWithURL` with
    /// `localFileURL` and without `completionHandler` if using background sessions.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    /// - parameter completionHandler:  The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func dataMultipartTaskWithURL(URL: URL, parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [URL]?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionDataTask {
        var (request, data) = try createMultipartRequestWithURL(URL: URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        
        request.httpBody = data
        
        return dataTask(with: request as URLRequest, completionHandler: completionHandler)
    }
    
    /// Create upload request.
    ///
    /// With upload task, we return separate `NSURLRequest` and `NSData` to be passed to `uploadTaskWithRequest(fromData:)`.
    ///
    /// - parameter URL:          The `NSURL` for the web service.
    /// - parameter parameters:   The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:  The name of the key to be used for files included in the request.
    /// - parameter fileURLs:     An optional array of `NSURL` for local files to be included in `NSData`.
    ///
    /// - returns:                The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func createMultipartRequestWithURL(URL: URL, method: UploadHTTPMethod = .post, parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [URL]?, customFileNames: [String]? = nil) throws -> (URLRequest, Data) {
        let boundary = URLSession.generateBoundaryString()
        
        var request = URLRequest.init(url: URL)
        debugPrint("Uploading URL: \(URL)")
        request.httpMethod = method.rawValue
        debugPrint("Post Value: \(method.rawValue)")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(API_SERVICES.getAuthorization(), forHTTPHeaderField: "authorization")
        request.setValue("accept-language", forHTTPHeaderField: Locale.current.languageCode?.lowercased() ?? "en")
        
        let data = try createDataWithParameters(parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs, customFileNames: customFileNames, boundary: boundary)
        
        return (request, data)
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// - parameter parameters:   The optional dictionary of parameters to be included.
    /// - parameter fileKeyName:  The name of the key to be used for files included in the request.
    /// - parameter boundary:     The multipart/form-data boundary.
    ///
    /// - returns:                The `NSData` of the body of the request. This throws error if there was problem opening file in the `fileURLs`.
    
    private func createDataWithParameters(parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [URL]?, customFileNames: [String]? = nil, boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        if fileURLs != nil {
            if fileKeyName == nil {
                throw NSError(domain: Bundle.main.bundleIdentifier ?? "NSURLSession+Multipart", code: -1, userInfo: [NSLocalizedDescriptionKey: "If fileURLs supplied, fileKeyName must not be nil"])
            }
            
            for index in 0..<fileURLs!.count {
                let fileURL = fileURLs![index] // local url to upload from...
                var filename = fileURL.lastPathComponent
                if let passedFileNames = customFileNames,
                    passedFileNames.indices.contains(index),
                    !passedFileNames[index].isEmpty {
                    
                    filename = passedFileNames[index] // custom name passed by developer...
                }
                
                let data = try Data(contentsOf: fileURL)
                let mimetype = URLSession.mimeTypeForPath(path: fileURL.path)
                
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(fileKeyName!)\"; filename=\"\(filename)\"\r\n")
                body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
                body.append(data)
                body.appendString(string: "\r\n")
            }
        }
        
        body.appendString(string: "--\(boundary)--\r\n")
       debugPrint("-- \(String(data: body, encoding: String.Encoding.utf8))")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    private class func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    class func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
    
}


