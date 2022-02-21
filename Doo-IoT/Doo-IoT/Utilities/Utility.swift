//
//  Utility.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 03/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import Photos

class Utility {
    static func openSafariBrowserWithUrl(_ strUrl: String?){
        if let urlString = strUrl {
            let url: URL?
            if urlString.hasPrefix(cueString.httpSlash) {
                url = URL(string: urlString)
            } else {
                url = URL(string: cueString.httpSlash + urlString)
            }
            if let url = url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    static func openSafariBrowserWithOrignalUrl(_ strUrl: String?){
        if let urlString = strUrl, let url = URL(string: urlString){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func checkVideoCameraPermission(callback: @escaping (Bool)->()) {

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            callback(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
               if granted == true {
                   // User granted
                callback(true)
               } else {
                   // User rejected
                callback(false)
               }
           })
        }
    }
    
    static func getAtrributedText(contents:[String], fonts:[UIFont], colors:[UIColor]) -> NSMutableAttributedString{
        let finalMutableAttributedString = NSMutableAttributedString()
        guard contents.count == fonts.count && contents.count == colors.count else {
            return finalMutableAttributedString
        }
        
        for (index, content) in contents.enumerated(){
            let attributeDict = [NSAttributedString.Key.font : fonts[index], NSAttributedString.Key.foregroundColor : colors[index]]
            let mutableAttributedString = NSMutableAttributedString(string: content, attributes:attributeDict)
            finalMutableAttributedString.append(mutableAttributedString)
        }
        return finalMutableAttributedString
    }


    static func checkPhotoLibraryPermission(viewControler:UIViewController, callback: @escaping ()->()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            callback()
        case .denied:
            Utility.showAlertForVideoAndImage(viewControler: viewControler)
        case .restricted:
            // ToastPopUp.show(cueAlert.Message.photosAccessDenided)
            viewControler.showAlert(withMessage: cueAlert.Message.photosAccessDenided)
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    callback()
                case .denied:
                    // Utility.navigateOnSettingPermission()
                    Utility.showAlertForCameraWithSettingOption(viewControler: viewControler,
                                                                customMessage: "Kindly allow 'Doo' app to access photos from Settings!")
                case .restricted:
                    // ToastPopUp.show(cueAlert.Message.photosAccessDenided)
                    viewControler.showAlert(withMessage: cueAlert.Message.photosAccessDenided)
                case .notDetermined:
                    // won't happen but still
                    print("Not Determined")
                default:
                    break
                }
            }
        default:
            break
        }
    }

    static func showAlertForVideoAndImage(viewControler:UIViewController) {
        let settings = UIAlertAction.init(title: cueAlert.Button.settings, style: .default) { (settingsAction) in
            Utility.navigateOnSettingPermission()
        }
        let cancel = UIAlertAction.init(title: cueAlert.Button.cancel, style: .cancel) { (cancelAction) in
        }
        viewControler.showAlert(withMessage: localizeFor("turn_on_photo_services_to_allow_select_picture_or_video_or_audio"), withActions: settings, cancel)
    }

    static func showAlertForCameraWithSettingOption(viewControler: UIViewController,
                                                    customMessage: String = "Kindly allow 'Doo' app to access camera from Settings!") {
        let settings = UIAlertAction.init(title: cueAlert.Button.settings, style: .default) { (settingsAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        let cancel = UIAlertAction.init(title: cueAlert.Button.cancel, style: .cancel) { (cancelAction) in
        }
        viewControler.showAlert(withMessage: customMessage, withActions: settings, cancel)
    }

    static func navigateOnSettingPermission() {
        if let settingUrl = URL(string: UIApplication.openSettingsURLString){
            DispatchQueue.main.async {
                UIApplication.shared.open(settingUrl)
            }
        }
    }
    
    static func getHeyUserFirstName() -> String {
        if let user = APP_USER, !user.firstName.isEmpty {
            return "\(localizeFor("hey")), \(user.firstName)"
        }
        return  "\(localizeFor("hey")), \(localizeFor("user"))!"
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }


    
    static func getRandomBannerImage() -> UIImage?{
        let bannerImageArray = ["background_1.png", "background_2.png",
                       "background_3.png","background_4.png",
                       "background_5.png","background_6.png",
                       "background_7.png","background_8.png",
                       "background_9.png"]
        if let bannerImage = bannerImageArray.randomElement() {
            return UIImage.init(named: bannerImage)
        }
        return UIImage(named: "background_1.png")
    }
    
    static func getRandomBannerImageName() -> String?{
        let bannerImageArray = ["background_1.png", "background_2.png",
                       "background_3.png","background_4.png",
                       "background_5.png","background_6.png",
                       "background_7.png","background_8.png",
                       "background_9.png"]
        return bannerImageArray.randomElement()
    }

    static func checkIsAlexaInstalledorNot(appScheme:String) -> Bool {
        if let url = URL(string: appScheme), UIApplication.shared.canOpenURL(url){
            return true
        } else {
            return false
        }
    }
    
}
