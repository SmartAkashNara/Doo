//
//  AESSecuritySmartOffice.swift
//  AESEncreptDecreptDemoSmartOffice
//
//  Created by smartSense on 14/05/18.
//  Copyright © 2018 smartSense. All rights reserved.
//

import UIKit

class AESSecuritySmartOffice: NSObject {
    
    private var cipher:AESSmartOffice
    private var secKey:[UInt8] = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa, 0xb, 0xc, 0xd, 0xe, 0xf, 0x1]
    private var iv:[UInt8] = [0x11, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]
    
    override init() {
        cipher = AESSmartOffice(key: secKey, iv: iv)
    }
    
    public func encrypt(message:String) -> String {
        var text:String = cipher.fillBlock(text: message)
        let textArray:[UInt8] = Array(text.utf8)
        let cipherBytes:[UInt8] = cipher.CBC_encrypt(text: textArray)
        let cipherData = Data(bytes: cipherBytes)
        if let cipherText = String(data: cipherData, encoding: String.Encoding.utf8){
            return cipherText
        } else {
            print("Error in encrypt.")
            return ""
        }
    }
    
    public func encryptBytes(message:String) -> [UInt8] {
        var text:String = cipher.fillBlock(text: message)
        let textArray:[UInt8] = Array(text.utf8)
        let cipherBytes:[UInt8] = cipher.CBC_encrypt(text: textArray)
        return cipherBytes
    }
    
    public func decrypt(message:String) -> String {
        let messageArray:[UInt8] = Array(message.utf8)
        let plainBytes:[UInt8] = cipher.CBC_decrypt(text: messageArray)
        let plainData = Data(bytes: plainBytes)
        if let plainText = String(data: plainData, encoding: String.Encoding.utf8){
            return plainText
        } else {
            print("Error in decrypt.")
            return ""
        }
    }
    
    public func decrypt(message:[UInt8]) -> String {
        let plainBytes:[UInt8] = cipher.CBC_decrypt(text: message)
        let plainData = Data(bytes: plainBytes)
        //        if let plainText = String(data: plainData, encoding: String.Encoding.utf8){
        //            print("Plain Text UTF8 : \(plainText.trimmingCharacters(in: .whitespaces))")
        //        }
        //        if let plainText = String(data: plainData, encoding: String.Encoding.utf16){
        //            print("Plain Text UTF16 : \(plainText.trimmingCharacters(in: .whitespaces))")
        //        }
        if let plainText = String(data: plainData, encoding: String.Encoding.ascii){
            return plainText.trimmingCharacters(in: .whitespaces)
        } else {
            print("Error in decrypt.")
            return ""
        }
    }
    
}

