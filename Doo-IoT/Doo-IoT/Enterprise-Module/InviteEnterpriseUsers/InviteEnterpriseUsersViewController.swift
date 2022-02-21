//
//  InviteEnterpriseUsersViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class InviteEnterpriseUsersViewController: CardBaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldViewEmailorMobile: DooTextfieldView!
    @IBOutlet weak var textFieldViewRole: DooTextfieldView!
    @IBOutlet weak var buttonAddToList: UIButton!
    @IBOutlet weak var buttonSendInvitations: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var onlyPictures: OnlyHorizontalPictures!
    @IBOutlet weak var stackViewParentSelectedUser: UIStackView!
    @IBOutlet weak var labelNoteTitle: UILabel!
    @IBOutlet weak var labelNoteDetail: UILabel!
    @IBOutlet weak var viewNoteSeparator: UIView!
    @IBOutlet weak var textFieldViewCountry: DooTextfieldView!
    @IBOutlet weak var constrainHeightOfBtnSendInvitations: NSLayoutConstraint!

    // Card Work
    var bottomCard: DooBottomPopUp_1ViewController? = UIStoryboard.common.bottomGenericVC
    
    // MARK: - Variables
    let inviteEnterpriseUsersViewModel = InviteEnterpriseUsersViewModel()
    var enterpriseModel: EnterpriseModel!
    var isSearchActive = false
    var countrySelectionDataModel: CountrySelectionViewModel.CountryDataModel? = nil
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureCountry()
        scrollView.addBounceViewAtTop()
        callGetUserRolesAPI()
    }
}

// MARK: - Action listeners
extension InviteEnterpriseUsersViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func addToListActionListener(_ sender: UIButton) {
        view.endEditing(true)
        
        /*
        if isValidateFields(),
           let currentSelectedUser = inviteEnterpriseUsersViewModel.currentSelectedUser,
           let currentSelectedRole = inviteEnterpriseUsersViewModel.currentSelectedRole {
            currentSelectedUser.roleId = currentSelectedRole.dataId
            currentSelectedUser.roleName = currentSelectedRole.dataValue
            inviteEnterpriseUsersViewModel.selectedUsers.append(currentSelectedUser)
            onlyPictures.reloadData()
            selectedUsersVisibility()
            
            textFieldViewEmailorMobile.setText = ""
            textFieldViewEmailorMobile.setReturnKeyType = .done
            textFieldViewRole.setText = ""
        }
 */
        
        if isValidateFields() {
            if !inviteEnterpriseUsersViewModel.selectedUsers.contains(where: {$0.email == self.textFieldViewEmailorMobile.getText}),
               let currentSelectedRole = inviteEnterpriseUsersViewModel.currentSelectedRole {
                
                let inviteUser = DooUser.init(dict: JSON.init(["contact": self.textFieldViewEmailorMobile.getText,
                                                               "image": "\(Environment.ImagePathofAvtarIcon())\(Int.random(in: 1...11)).png"]))
                inviteUser.roleId = currentSelectedRole.dataId
                inviteEnterpriseUsersViewModel.selectedUsers.append(inviteUser)
                onlyPictures.reloadData()
                selectedUsersVisibility()
                
                textFieldViewEmailorMobile.setText = ""
                textFieldViewEmailorMobile.setReturnKeyType = .done
                textFieldViewRole.setText = ""
            }
        }
    }
    
    @IBAction func sendInvitationsActionListener(_ sender: UIButton) {
        view.endEditing(true)
        callInviteEnterpriseUsersAPI()
    }
    @IBAction func unwindSegueFromSelectDooUserToInviteEnterpriseUsers(segue: UIStoryboardSegue) {
        if let sourceView = segue.source as? SelectDooUserViewController,
           let selectedUser = sourceView.selectDooUserViewModel.selectedUser {
            textFieldViewEmailorMobile.setText = selectedUser.getEmailOrMobile
            inviteEnterpriseUsersViewModel.currentSelectedUser = selectedUser
        }
    }
    @IBAction func unwindSegueFromRemoveDooUserInvitesToInviteEnterpriseUsers(segue: UIStoryboardSegue) {
        if let sourceView = segue.source as? RemoveDooUserInvitesViewController {
            sourceView.arrayRemovedUsers.forEach { (removedUser) in
                inviteEnterpriseUsersViewModel.selectedUsers.removeAll { (selectedUser) -> Bool in
                    selectedUser.id == removedUser.id
                }
            }
            onlyPictures.reloadData()
            selectedUsersVisibility()
        }
    }
}

// MARK: - User defined methods
extension InviteEnterpriseUsersViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = localizeFor("invite_users_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Add users and Assign the appropriate role to them")
        self.navigationTitle.text = title
        self.navigationTitle.font = UIFont.Poppins.medium(14)
        self.navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        labelNoteTitle.font = UIFont.Poppins.medium(12)
        labelNoteTitle.textColor = UIColor.blueHeadingAlpha60
        labelNoteTitle.text = localizeFor("note_title")
        
        labelNoteDetail.font = UIFont.Poppins.regular(12)
        labelNoteDetail.textColor = UIColor.blueHeadingAlpha60
        labelNoteDetail.numberOfLines = 0
        labelNoteDetail.text = localizeFor("note_detail_user")
        
        viewNoteSeparator.backgroundColor = UIColor.blueHeadingAlpha06
        
        textFieldViewEmailorMobile.titleValue = localizeFor("email_or_mobile_title")
        textFieldViewEmailorMobile.textfieldType = .generic
        textFieldViewEmailorMobile.genericTextfield?.addThemeToTextarea(localizeFor("enter_email_or_mobile"))
        textFieldViewEmailorMobile.genericTextfield?.delegate = self
        textFieldViewEmailorMobile.validateTextForError = { textField in
            return nil
        }
        textFieldViewEmailorMobile.setReturnKeyType = .done
        
        textFieldViewRole.titleValue = localizeFor("role")
        textFieldViewRole.textfieldType = .rightIcon
        textFieldViewRole.rightIconTextfield?.addThemeToTextarea(localizeFor("select_role"))
        textFieldViewRole.rightIconTextfield?.rightIcon = UIImage(named: "arrowDownBlue")!
        textFieldViewRole.rightIconTextfield?.delegate = self
        
        textFieldViewCountry.titleValue = "Country"
        textFieldViewCountry.textfieldType = .rightIcon
        textFieldViewCountry.rightIconTextfield?.addThemeToTextarea(cueString.countryPlaceholder)
//        textFieldViewCountry.rightIconTextfield?.rightIcon = UIImage(named: "imgDropDownArrow")! //below line commneted by divay changes as of now not allow to change country
        textFieldViewCountry.rightIconTextfield?.delegate = self
        // textFieldViewCountry.rightIconTextfield?.text = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.countryName
        textFieldViewCountry.validateTextForError = { textInCountryField in
            if InputValidator.checkEmpty(value: textInCountryField),
               !InputValidator.checkEmpty(value: self.textFieldViewEmailorMobile.getText),
                !InputValidator.isNumber(self.textFieldViewEmailorMobile.getText!.trimSpaceAndNewline) {
                // Its Email
                return nil
            }else if InputValidator.checkEmpty(value: textInCountryField){
                return localizeFor("country_code_is_required")
            }
            return nil
        }
        
        buttonAddToList.setTitle(localizeFor("add_to_list_button"), for: .normal)
        buttonAddToList.setTitleColor(UIColor.blueSwitch, for: .normal)
        buttonAddToList.cornerRadius = 6.7
        buttonAddToList.borderWidth = 1.3
        buttonAddToList.borderColor = UIColor.blueSwitch
        
        //set button type Custom from storyboard
        buttonSendInvitations.setThemeAppBlueWithArrow(localizeFor("send_invitations_button"))
        
        scrollView.delegate = self
        
        let imageWidth:CGFloat = 37
        let gap: CGFloat = 9
        onlyPictures.backgroundColor = UIColor.clear
        onlyPictures.alignment = .left
        onlyPictures.imageInPlaceOfCount = UIImage(named: "imgMoreUsers")
        onlyPictures.countPosition = .right
        onlyPictures.spacing = 0
        onlyPictures.gap = Float(imageWidth + gap)
        onlyPictures.dataSource = self
        onlyPictures.delegate = self
        onlyPictures.reloadData()
        
        selectedUsersVisibility()
    }
    
    func configureCountry(){
        // When user directly auto logs in inside the app and logging out, that time we need country fetch to load country if not fetched before.
        countrySelectionDataModel = COUNTRY_SELECTION_VIEWMODEL.selectedCountry
        if countrySelectionDataModel == nil {
            COUNTRY_SELECTION_VIEWMODEL.callCountrySelectionAPI(param: [:]) {
                self.view.layoutIfNeeded() // This will going to call viewDidLoad of login vc so it lays its layout.
                self.addCountry() // add country after adding layout.
            }
        }else{
            self.addCountry() // add country after adding layout.
        }
    }
    
    func addCountry() {
        guard let countryObject = countrySelectionDataModel else {
            textFieldViewCountry.setText = "India (+91)"
            return
        }
        textFieldViewCountry.setText = countryObject.dialCode != "" ? countryObject.countryName + " (\(countryObject.dialCode))" : countryObject.countryName
    }
    
    func selectedUsersVisibility(animated: Bool = false) {
        func hideShow(isHidden: Bool) {
            stackViewParentSelectedUser.isHidden = isHidden
            stackViewParentSelectedUser.alpha = isHidden.isHiddenToAlpha
            constrainHeightOfBtnSendInvitations.constant = isHidden ? 0 : 50
        }
        let isHidden = inviteEnterpriseUsersViewModel.selectedUsers.count.isZero()
        guard isHidden != stackViewParentSelectedUser.isHidden else { return }
        if animated {
            UIView.animate(withDuration: 0.3) {
                hideShow(isHidden: isHidden)
            }
        } else {
            hideShow(isHidden: isHidden)
        }
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = inviteEnterpriseUsersViewModel.validateFields(emailOrMobile: textFieldViewEmailorMobile.getText, role: textFieldViewRole.getText,countryCode: textFieldViewCountry.getText)
        switch validationStatus.state{
        case .country:
            textFieldViewCountry.showError(validationStatus.errorMessage)
        case .emailOrMobile:
            textFieldViewEmailorMobile.showError(validationStatus.errorMessage)
        case .role:
            textFieldViewRole.showError(validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
    
    func callGetUserRolesAPI() {
        inviteEnterpriseUsersViewModel.callGetUserRolesAPI([:], startLoader: {
        }, stopLoader: {
        }, successBlock: {
        }) { (failureMeessage) in
        }
    }
    
    func callInviteEnterpriseUsersAPI() {
//        guard let selectedCountry = countrySelectionDataModel else { return } //below line commneted by divay changes as of now not allow to change country
        let paramArray = inviteEnterpriseUsersViewModel.selectedUsers.map { (user) -> [String : Any] in
            return [
                "roleId": user.roleId,
                "enterpriseId": enterpriseModel.id,
//                "dialCode": selectedCountry.id, // below line commneted by divay changes as of now not allow to change country
                "dialCode":"100",
                "contact": user.contact.lowercased(),
            ]
        }
        
        API_LOADER.show(animated: true)
        inviteEnterpriseUsersViewModel.callInviteEnterpriseUsersAPI(paramArray) { [weak self]  msg in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg,forPurpose: .success).showForWhile(animated: true)
            self?.navigationController?.popViewController(animated: true)
        } failureMessageBlock: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension InviteEnterpriseUsersViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewCountry.rightIconTextfield:
            textFieldViewCountry.dismissError()
            /* below line commneted by divay changes as of now not allow to change country
            if let destView = UIStoryboard.common.countrySelectionVC {
                destView.selectCountryClouser = { [weak self] selectedCountryObject in
                    self?.countrySelectionDataModel = selectedCountryObject
                    self?.addCountry()
                }
                navigationController?.pushViewController(destView, animated: true)
            }
             */
            return false
        case textFieldViewEmailorMobile.genericTextfield:
            /*
            if let destView = UIStoryboard.enterpriseUsers.selectDooUserVC {
                destView.arrayUsersPreSelected = inviteEnterpriseUsersViewModel.selectedUsers
                destView.enterpriseId = "\(enterpriseModel.id)"
                navigationController?.pushViewController(destView, animated: true)
            }
 */
            // Allow typing now.
            return true
        case textFieldViewRole.rightIconTextfield:
            self.view.endEditing(true)
            if let bottomView = self.bottomCard {
                self.setLayout(withCard: bottomView, cardPosition: .bottom)
                bottomView.selectionType = .roleSelectionToInviteUser(self.inviteEnterpriseUsersViewModel.listOfRoles)
                bottomView.openCard(dynamicHeight: true)
                bottomView.selectionData = { [weak self] (dataModel) in
                    self?.textFieldViewRole.setText = dataModel.dataValue
                    self?.inviteEnterpriseUsersViewModel.currentSelectedRole = dataModel
                }
            }else{
                CustomAlertView.init(title: cueAlert.Message.somethingWentWrong).showForWhile(animated: true)
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

// MARK: - UIGestureRecognizerDelegate
extension InviteEnterpriseUsersViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension InviteEnterpriseUsersViewController: UIScrollViewDelegate {
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

// MARK: - OnlyPicturesDataSource
extension InviteEnterpriseUsersViewController: OnlyPicturesDataSource {
    func numberOfPictures() -> Int {
        return inviteEnterpriseUsersViewModel.selectedUsers.count
    }
    func visiblePictures() -> Int {
        return cueDevice.isDeviceSEOrLower ? 5 : 6
    }
    func pictureViews(_ imageView: UIImageView, index: Int) {
        let calculateMinusValue = (inviteEnterpriseUsersViewModel.selectedUsers.count-6)
        let actualIndex = index - ((calculateMinusValue >= 0) ? calculateMinusValue : 0)
        //        imageView.image = UIImage(named: inviteEnterpriseUsersViewModel.selectedUsers[actualIndex].image)
        imageView.contentMode = .scaleAspectFill
        imageView.setImage(url: inviteEnterpriseUsersViewModel.selectedUsers[actualIndex].image, placeholder: cueImage.userPlaceholder)
//        let imageUrl = URL(string: inviteEnterpriseUsersViewModel.selectedUsers[actualIndex].image)
//        imageView.sd_setImage(with: imageUrl, placeholderImage: cueImage.userPlaceholder, options: .fromCacheOnly, completed: nil)
    }
}

// MARK: - OnlyPicturesDelegate
extension InviteEnterpriseUsersViewController: OnlyPicturesDelegate {
    func pictureView(_ imageView: UIImageView, didSelectAt index: Int) {
        inviteEnterpriseUsersViewModel.selectedUsers.remove(at: index)
        onlyPictures.reloadData()
        selectedUsersVisibility(animated: true)
    }
    func pictureViewCountDidSelect() {
        if let destView = UIStoryboard.enterpriseUsers.removeDooUserInvitesVC {
            destView.arraySelectedUsers = inviteEnterpriseUsersViewModel.selectedUsers
            navigationController?.pushViewController(destView, animated: true)
        }
    }
}
