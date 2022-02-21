//
//  ChangeEnterpriseUserRoleViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 14/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class ChangeEnterpriseUserRoleViewController: CardBaseViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldViewRole: DooTextfieldView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    let inviteEnterpriseUsersViewModel = InviteEnterpriseUsersViewModel()
    var enterpriseUser: DooUser?
    var didChangedEnterpriseUserRole:((DooUser) -> ())? = nil
    
    // Card Work
    var bottomCard: DooBottomPopUp_1ViewController? = UIStoryboard.common.bottomGenericVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        scrollView.addBounceViewAtTop()
        callGetUserRolesAPI()
    }
    
    @IBAction func updateRoleActionListener(sender: UIButton) {
        callChangeRoleOfEnterpriseUserAPI()
    }
}

// MARK: - Action listeners
extension ChangeEnterpriseUserRoleViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension ChangeEnterpriseUserRoleViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = "Change role"
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Change enterprise role of user here")
        self.navigationTitle.text = title
        self.navigationTitle.font = UIFont.Poppins.medium(14)
        self.navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        textFieldViewRole.titleValue = localizeFor("role")
        textFieldViewRole.textfieldType = .rightIcon
        textFieldViewRole.rightIconTextfield?.addThemeToTextarea(localizeFor("select_role"))
        textFieldViewRole.rightIconTextfield?.rightIcon = UIImage(named: "arrowDownBlue")!
        textFieldViewRole.rightIconTextfield?.delegate = self
        
        scrollView.delegate = self
        
        //set button type Custom from storyboard
        buttonUpdate.setThemeAppBlueWithArrow(cueAlert.Button.update)
    }
}

// MARK: - Services
extension ChangeEnterpriseUserRoleViewController {
    func callGetUserRolesAPI() {
        func showPreviouslySelectedRoleOfUser() {
            if let index = self.inviteEnterpriseUsersViewModel.listOfRoles.firstIndex(where: {$0.dataId == self.enterpriseUser?.roleId}) {
                let role = self.inviteEnterpriseUsersViewModel.listOfRoles[index]
                self.textFieldViewRole.setText = role.dataValue
            }
        }
        
        inviteEnterpriseUsersViewModel.callGetUserRolesAPI([:], startLoader: {
            API_LOADER.show(animated: true)
        }, stopLoader: {
            API_LOADER.dismiss(animated: true)
        }, successBlock: {
            showPreviouslySelectedRoleOfUser()
        }) { (failureMeessage) in
        }
    }
    
    func callChangeRoleOfEnterpriseUserAPI() {
        guard let enterpriseUserStrong = enterpriseUser,
              let currentSelectedRole = inviteEnterpriseUsersViewModel.currentSelectedRole else { return }
        let routingParam = [
            "userId" : "\(enterpriseUserStrong.userId)",
            "enterpriseId" : "\(enterpriseUserStrong.enterpriseId)",
            "roleId" : currentSelectedRole.dataId,
        ]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .changeRoleOfEnterpriseUser(routingParam), method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            self.enterpriseUser?.roleId = currentSelectedRole.dataId
            guard let payload = parsingResponse?["payload"] else { return }
            self.enterpriseUser = DooUser(dict: payload)
            self.didChangedEnterpriseUserRole?(self.enterpriseUser!)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ChangeEnterpriseUserRoleViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewRole.rightIconTextfield:
            if let bottomView = self.bottomCard {
                self.setLayout(withCard: bottomView, cardPosition: .bottom)
                bottomView.selectionType = .roleSelectionToInviteUser(self.inviteEnterpriseUsersViewModel.listOfRoles)
                bottomView.openCard(dynamicHeight: true)
                bottomView.selectionData = { [weak self] (dataModel) in
                    self?.textFieldViewRole.setText = dataModel.dataValue
                    self?.inviteEnterpriseUsersViewModel.currentSelectedRole = dataModel
                }
            }else{
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
            }
            return false
        default:
            break
        }
        return true
    }
    
    // Card Work
    func setLayout(withCard cardVC: CardGenericViewController, cardPosition: CardPosition) {
        // Setup dynamic card.
        // card setup
        self.cardPosition = cardPosition
        self.setupCard(cardVC)
        
        self.setCardHandleAreaHeight = 0
        // self.offCurveInCard()
        self.applyDarkOnlyOnCard = true
        self.updateProgress = { name in
            // print("Happy birthday, \(name)!")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - UIScrollViewDelegate Methods
extension ChangeEnterpriseUserRoleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.addNavigationAnimation(scrollView)
    }
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            self.navigationTitle.isHidden = false
        } else {
            self.navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 76.0 {
            self.viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        } else {
            self.viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ChangeEnterpriseUserRoleViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
