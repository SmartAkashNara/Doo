//
//  NSMutableData+AppendString.swift
//  NSURLSessionMultipart
//
//  Created by Robert Ryan on 10/6/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//

import Foundation

extension Data {

    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.

    public mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }

    func dataToJSON() -> Any? {
       do {
           return try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
       } catch let myJSONError {
          debugPrint(myJSONError)
       }
       return nil
    }
}
