//
//  AddEnterpriseWhenNotAvailableViewController.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 23/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class AddEnterpriseWhenNotAvailableViewController: UIViewController {
    
    @IBOutlet weak var dooNoDataView: DooNoDataView_1!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNoEnterpriseView()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddEnterpriseWhenNotAvailableViewController: DooNoDataView_1Delegate {
    func showNoEnterpriseView() {
        self.dooNoDataView.initSetup(.noEnterprises)
        self.dooNoDataView.allocateView()
        self.dooNoDataView.delegate = self
    }
    func dismissNoEnterpriseView() {
        self.dooNoDataView.delegate = nil
        self.dooNoDataView.dismissView()
    }
    func buttonAction1Tapped() {
        // print("Add enterprise tapped")
        if let addEnterprisesVC = UIStoryboard.enterprise.addEnterpriseVC {
            addEnterprisesVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addEnterprisesVC, animated: true)
        }
    }
    func buttonContentAction1Tapped() {
        if let receivedInvitationsVC = UIStoryboard.enterprise.receivedInvitationsVC {
            receivedInvitationsVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(receivedInvitationsVC, animated: true)
        }
    }
    func buttonLogoutTapped() {
        debugPrint("Logout tapped.")
        showLogoutAlert()
        
    }
    
    func showLogoutAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.notNow, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.logout, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    self.callLogoutApi()
                    
                }
                let title = localizeFor("are_you_sure_want_to_logout_from_doo")
                alertVC.setAlert(alertTitle: title, leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    func callLogoutApi(){
        API_SERVICES.callAPI(path: .logout, method: .get) { parsingResponse in
            UserManager.logoutMethod()
        }
    }
    
}
