//
//  EditProfileViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 30/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EditProfileViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldViewFirstname: DooTextfieldView!
    @IBOutlet weak var textFieldViewLastname: DooTextfieldView!
    @IBOutlet weak var textFieldViewEmail: DooTextfieldView!
    @IBOutlet weak var textFieldViewCountry: DooTextfieldView!
    @IBOutlet weak var textFieldViewMobile: DooTextfieldView!
    @IBOutlet weak var buttonUpdate: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!

    // MARK: - Variables
    let editProfileViewModel = EditProfileViewModel()
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        loadDataEditTime()
    }
    
}

// MARK: API
extension EditProfileViewController {
    func callUpdateProfileDataAPI() {
        guard let firstname = textFieldViewFirstname.getText,
            let lastname = textFieldViewLastname.getText,
            let email = textFieldViewEmail.getText,
            let mobile = textFieldViewMobile.getText else { return }

        var param: [String: Any] = [
            "firstName": firstname,
            "lastName": lastname,
            "email": email,
            "mobileNumber": mobile,
        ]
        
        if let selectedCountry = editProfileViewModel.selectedCountry, !selectedCountry.id.isEmpty {
            param["countryCode"] = selectedCountry.id
        }else if textFieldViewCountry.disabled, let user = APP_USER, !user.countryCode.isZero() {
            param["countryCode"] = user.countryCode
        }else{
            param["countryCode"] = "100"
        }
        param.removeEmptyOrZeroValues()
        
        API_LOADER.show(animated: true)
        editProfileViewModel.callUpdateProfileDataAPI(param: param) { (otpTimeOut) in
            API_LOADER.dismiss(animated: true)
            self.redirectToOTPOrSendBack(otpTimeOut: otpTimeOut)
            } failure: { msg in
                CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
            } internetFailure: {
            } failureInform: {
                API_LOADER.dismiss(animated: true)
            }
    }
    
    func redirectToOTPOrSendBack(otpTimeOut:Int) {
        func redirectToOTP(emailOrMobile: String, emailOrMobileToken: String, timeOutOTP:Int) {
            guard let destView = UIStoryboard.onboarding.otpVerificationVC else { return }
            destView.redirectedFrom = .updateProfile(emailOrMobile, emailOrMobileToken,timeOutOTP)
            self.navigationController?.pushViewController(destView, animated: true)
        }
        if let user = APP_USER {
            if !user.emailToken.isEmpty, let email = textFieldViewEmail.getText {
                redirectToOTP(emailOrMobile: email, emailOrMobileToken: user.emailToken, timeOutOTP: otpTimeOut)
                return
            } else if !user.mobileToken.isEmpty, let mobile = textFieldViewMobile.getText {
                redirectToOTP(emailOrMobile: mobile, emailOrMobileToken: user.mobileToken, timeOutOTP: otpTimeOut)
                return
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Action listeners
extension EditProfileViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields() {
            callUpdateProfileDataAPI()
        }
    }

    @IBAction func unwindSegueFromCountrySelectionToLogin(segue: UIStoryboardSegue) {
        if let _ = segue.source as? CountrySelectionViewController,
            let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry {
            editProfileViewModel.selectedCountry = selectedCountry
            textFieldViewCountry.setText = selectedCountry.dialCode != "" ? selectedCountry.countryName + " (\(selectedCountry.dialCode))" : selectedCountry.countryName
        }
    }
    
    func isValidateFields() -> Bool {
        if textFieldViewFirstname.isValidated() && textFieldViewLastname.isValidated() && textFieldViewCountry.isValidated() && textFieldViewMobile.isValidated() && textFieldViewEmail.isValidated(){
            return true
        }
        return false
    }
    /*
    func isValidateFields() -> Bool {
        let validationStatus = editProfileViewModel.validateFields(firstname: textFieldViewFirstname.getText, lastname: textFieldViewLastname.getText, email: textFieldViewEmail.getText, country: textFieldViewCountry.getText, mobile: textFieldViewMobile.getText)
        
        switch validationStatus.state{
        case .email:
            textFieldViewEmail.showError(validationStatus.errorMessage)
        case .country:
            textFieldViewCountry.showError(validationStatus.errorMessage)
        case .mobile:
            textFieldViewMobile.showError(validationStatus.errorMessage)
        case .firstname, .lastname, .none:
            return true
        }
        return false
    }*/
}

// MARK: - User defined methods
extension EditProfileViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        let title = localizeFor("edit_profile_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Fill in the below details for your profile")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        textFieldViewFirstname.titleValue = localizeFor("first_name")
        textFieldViewFirstname.textfieldType = .generic
        textFieldViewFirstname.genericTextfield?.addThemeToTextarea(localizeFor("enter_first_name"))
        textFieldViewFirstname.genericTextfield?.returnKeyType = .next
        textFieldViewFirstname.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewFirstname.genericTextfield?.delegate = self
        textFieldViewFirstname.activeBehaviour = true
        textFieldViewFirstname.validateTextForError = { textField in
            if !InputValidator.checkEmpty(value: textField) && !InputValidator.isFirstOrLastNameLength(textField) {
                return "First name length should be between 2 to 40 characters"
            }
            return nil
        }
        
        textFieldViewLastname.titleValue = localizeFor("last_name")
        textFieldViewLastname.textfieldType = .generic
        textFieldViewLastname.genericTextfield?.addThemeToTextarea(localizeFor("enter_last_name"))
        textFieldViewLastname.genericTextfield?.returnKeyType = .done
        textFieldViewLastname.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewLastname.genericTextfield?.delegate = self
        textFieldViewLastname.activeBehaviour = true
        textFieldViewLastname.validateTextForError = { textField in
            if !InputValidator.checkEmpty(value: textField) && !InputValidator.isFirstOrLastNameLength(textField) {
                return "Last name length should be between 2 to 40 characters"
            }
            return nil
        }
        
        textFieldViewEmail.titleValue = localizeFor("email_address")
        textFieldViewEmail.textfieldType = .generic
        textFieldViewEmail.genericTextfield?.addThemeToTextarea(localizeFor("enter_email_address"))
        textFieldViewEmail.genericTextfield?.keyboardType = .emailAddress
        textFieldViewEmail.genericTextfield?.returnKeyType = .done
        textFieldViewEmail.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewEmail.genericTextfield?.delegate = self
        textFieldViewEmail.activeBehaviour = true
        textFieldViewEmail.validateTextForError = { textField in
            
            if !InputValidator.checkEmpty(value: textField) && !(self.textFieldViewMobile.getText ?? "").isEmpty{
                if !InputValidator.isEmailLength(textField){
                    return localizeFor("email_length_6_to_50")
                }
                if !InputValidator.isEmail(textField){
                    return localizeFor("plz_valid_email")
                }
            }
            return nil
        }

        textFieldViewCountry.titleValue = localizeFor("country")
        textFieldViewCountry.textfieldType = .rightIcon
        textFieldViewCountry.rightIconTextfield?.addThemeToTextarea(localizeFor("select_country"))
//        textFieldViewCountry.rightIconTextfield?.rightIcon = UIImage(named: "arrowDownBlue")! // // this line commneted by divay changes as of now disbale intraction fo country changes
        textFieldViewCountry.rightIconTextfield?.delegate = self

        textFieldViewMobile.titleValue = localizeFor("mobile")
        textFieldViewMobile.textfieldType = .generic
        textFieldViewMobile.genericTextfield?.addThemeToTextarea(localizeFor("enter_mobile"))
        textFieldViewMobile.genericTextfield?.keyboardType = .numberPad
        textFieldViewMobile.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewMobile.genericTextfield?.delegate = self
        textFieldViewMobile.genericTextfield?.isShowDoneToolbar = true
        textFieldViewMobile.activeBehaviour = true
        textFieldViewMobile.validateTextForError = { textField in
            
            if InputValidator.checkEmpty(value: self.textFieldViewCountry.getText) {
                return localizeFor("country_code_is_required")
            }
            
            if !InputValidator.checkEmpty(value: textField) && !(self.textFieldViewEmail.getText ?? "").isEmpty{
                if !InputValidator.isMobileLength(textField){
                    return localizeFor("mobile_number_4_to_13")
                }
                if !InputValidator.isMobile(textField){
                    return localizeFor("plz_valid_mobile_number")
                }
            }
            return nil
        }
        //set button type Custom from storyboard
        buttonUpdate.setThemeAppBlueWithArrow(localizeFor("update_button"))
        
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")

        scrollView.addBounceViewAtTop()
        scrollView.delegate = self
    }
    
    func loadDataEditTime() {
        guard let user = APP_USER else { return }
        textFieldViewFirstname.setText = user.firstName
        textFieldViewLastname.setText = user.lastName
        textFieldViewEmail.setText = user.email
        if user.countryName.isEmpty{
            textFieldViewCountry.setText = "India (+91)"
        }else{
            textFieldViewCountry.setText = user.dialCode != "" ? user.countryName + " (\(user.dialCode))" : user.countryName
        }
        
        textFieldViewMobile.setText = user.mobileNumber
        textFieldViewEmail.disabledIfNonEmpty()
        textFieldViewCountry.disabledIfNonEmpty()
        textFieldViewMobile.disabledIfNonEmpty()
        
        if !textFieldViewEmail.disabled {
            textFieldViewLastname.genericTextfield?.returnKeyType = .next
        }
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewCountry.rightIconTextfield:
            textFieldViewCountry.dismissError()
            /* // this line commneted by divay changes as of now disbale intraction fo country changes
            if let destView = UIStoryboard.common.countrySelectionVC {
                navigationController?.pushViewController(destView, animated: true)
            }
             */
            return false
        default:
            break
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewFirstname.genericTextfield:
            textFieldViewLastname.genericTextfield?.becomeFirstResponder()
        case textFieldViewLastname.genericTextfield where !textFieldViewEmail.disabled:
            textFieldViewEmail.genericTextfield?.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EditProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension EditProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
    }
    
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            navigationTitle.isHidden = false
        } else {
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 76.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        } else {
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}
