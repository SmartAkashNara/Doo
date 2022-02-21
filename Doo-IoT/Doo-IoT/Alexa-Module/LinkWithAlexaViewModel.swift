//
//  LinkWithAlexaViewModel.swift
//  Doo-IoT
//
//  Created by Akash on 31/01/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import Foundation
import SafariServices

class LinkWithAlexaViewModel{
    
    func getAuthCodeForAlexaApi(viewController:UIViewController){
        //alexa api call for get code
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI([:], path: .getAuth2Code, method: .get) { response in
            let alexaURLKey = Utility.checkIsAlexaInstalledorNot(appScheme: alexaURLSchema) ? "alexaUrl" : "lwaUrl"
            if let alexaUrl = response?["payload"]?["urls"][alexaURLKey].stringValue{
                debugPrint(alexaUrl)
                
                guard let url = URL.init(string: alexaUrl) else {
                    return
                }
                
                UIApplication.shared.open(url, options: [.universalLinksOnly: false]) { (success) in
                    if !success {
                        // not a universal link or app not installed
                        let vc = SFSafariViewController(url: url)
                        viewController.present(vc, animated: true)
                    }
                }
            }
        }
    }
}
