//
//  LoginViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class LoginViewController: BaseViewController {
    
    enum ErrorState { case country, emailOrMobile, password, none } // For local viewcontroller use only.

    // MARK: - Outlets
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var textFieldViewCountry: DooTextfieldView!
    @IBOutlet weak var textFieldViewEmailOrMobile: DooTextfieldView!
    @IBOutlet weak var textFieldViewPassword: DooTextfieldView!
    @IBOutlet weak var buttonForgotPassword: UIButton!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var labelLoginViaSMS: TTTAttributedLabel!
    
    let loginViewModel: LoginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // When user directly auto logs in inside the app and logging out, that time we need country fetch to load country if not fetched before.
        if COUNTRY_SELECTION_VIEWMODEL.selectedCountry == nil {
            COUNTRY_SELECTION_VIEWMODEL.callCountrySelectionAPI(param: [:]) {
                self.view.layoutIfNeeded() // This will going to call viewDidLoad of login vc so it lays its layout.
                self.addCountry() // add country after adding layout.
            }
        }else{
            self.addCountry() // add country after adding layout.
        }
    }
}

// MARK: - Action listeneres
extension LoginViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPasswordActionListener(_ sender: UIButton) {
        if let destView = UIStoryboard.onboarding.forgotPasswordInitialVC{
            navigationController?.pushViewController(destView, animated: true)
        }
    }
    
    
    @IBAction func unwindSegueFromCountrySelectionToLogin(segue: UIStoryboardSegue) {
        if let _ = segue.source as? CountrySelectionViewController,
            let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry {
            textFieldViewCountry.setText = selectedCountry.countryName
        }
    }
    
    @IBAction func loginActionListener(_ sender: UIButton) {
        view.endEditing(true)
        guard self.textFieldViewCountry.isValidated() &&
                self.textFieldViewEmailOrMobile.isValidated() &&
                self.textFieldViewPassword.isValidated() else {
            return
        }
        //if isValidateFields(){
            callLoginAPI(InputValidator.isNumber(textFieldViewEmailOrMobile.getText!))
        //}
    }
}

// MARK: - User defined methods
extension LoginViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)
        imageViewLogo.image = UIImage(named: "signUpAppLogo")

        let headingBoldText = localizeFor("for_authorisation")
        labelHeading.font = UIFont.Poppins.regular(20)
        labelHeading.textColor = UIColor.blueHeading
        labelHeading.numberOfLines = 0
        labelHeading.text = localizeFor("login_subtitle")
        labelHeading.addAttribute(targets: headingBoldText, font: UIFont.Poppins.medium(20))

        textFieldViewCountry.textfieldType = .rightIcon
        textFieldViewCountry.rightIconTextfield?.addThemeToTextarea(cueString.countryPlaceholder)
//        textFieldViewCountry.rightIconTextfield?.rightIcon = UIImage(named: "imgDropDownArrow")! // this line commneted by divay changes as of now disbale intraction fo country changes
        textFieldViewCountry.rightIconTextfield?.delegate = self
        // textFieldViewCountry.rightIconTextfield?.text = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.countryName
        textFieldViewCountry.validateTextForError = { textInCountryField in
            if InputValidator.checkEmpty(value: textInCountryField),
               !InputValidator.checkEmpty(value: self.textFieldViewEmailOrMobile.getText),
                !InputValidator.isNumber(self.textFieldViewEmailOrMobile.getText!.trimSpaceAndNewline) {
                // Its Email
                return nil
            }else if InputValidator.checkEmpty(value: textInCountryField){
                return localizeFor("country_code_is_required")
            }
            return nil
        }
        
        textFieldViewEmailOrMobile.textfieldType = .generic
        textFieldViewEmailOrMobile.genericTextfield?.addThemeToTextarea(localizeFor("email_or_mobile_placeholder"))
        textFieldViewEmailOrMobile.genericTextfield?.returnKeyType = .next
        textFieldViewEmailOrMobile.genericTextfield?.delegate = self
        textFieldViewEmailOrMobile.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewEmailOrMobile.validateTextForError = { textInEmailOrMobileField in
            let validationStatus = InputValidator.validateEmailOrMobile(textInEmailOrMobileField)
            if !validationStatus.error.isEmpty {
                return localizeFor(validationStatus.error)
            }
            return nil
        }
        
        textFieldViewPassword.textfieldType = .password
        textFieldViewPassword.passwordTextfield?.addThemeToTextarea(localizeFor("password_placeholder"), trailing: 0)
        textFieldViewPassword.passwordTextfield?.returnKeyType = .done
        textFieldViewPassword.passwordTextfield?.delegate = self
        textFieldViewPassword.validateTextForError = { textInPasswordView in
            if InputValidator.checkEmpty(value: textInPasswordView){
                return localizeFor("password_is_required")
            }
            if !InputValidator.isPassword(textInPasswordView){
                // self.showAlert(withMessage: "Password must be following below criterias: \n8 characters or more.\ninclude 1 uppercase letter.\ninclude 1 lowercase letter.\ninclude 1 numeric letter.\n1 special character (@,#,$,%,&,*)", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
                return localizeFor("plz_valid_password")
            }
            return nil
        }

        buttonForgotPassword.setTitle(localizeFor("forgot_password_question_mark"), for: .normal)
        buttonForgotPassword.setTitleColor(UIColor.blueHeading, for: .normal)
        buttonForgotPassword.titleLabel?.font = UIFont.Poppins.medium(12)
        buttonLogin.setThemePurple(localizeFor("login_button"), fontSize: 14)
        labelLoginViaSMS.configureLink(
            textString: localizeFor("login_via_sms_question_mark"),
            targets: cueString.linkKeywordSMS,
            color: UIColor.blueHeading,
            font: UIFont.Poppins.medium(14),
            fontNormal: UIFont.Poppins.regular(14))
        labelLoginViaSMS.delegate = self
        

        // textFieldViewEmailOrMobile.setText = "akash1@mailsac.com"//"kiran104@mailsac.com" //"9904281043" // kiran104@mailsac.com // akash1@mailsac.com
        // textFieldViewPassword.setText = "Smart@123"//"Karan01@" //"Smart@123" //Karan01@" // Smart@123
    }
    
    func addCountry() {
        guard let countryObject = COUNTRY_SELECTION_VIEWMODEL.selectedCountry else {
            textFieldViewCountry.setText = "India (+91)"
            return
        }
        textFieldViewCountry.setText = countryObject.dialCode != "" ? countryObject.countryName + " (\(countryObject.dialCode))" : countryObject.countryName
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewCountry.rightIconTextfield:
            textFieldViewCountry.dismissError()
            
            /* below lines commneted by divay changes as of now not allow to change country
            if let destView = UIStoryboard.common.countrySelectionVC {
                navigationController?.pushViewController(destView, animated: true)
            }*/
            return false
        default:
            break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewEmailOrMobile.genericTextfield:
            textFieldViewPassword.passwordTextfield?.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Validations
extension LoginViewController {
    func isValidateFields() -> Bool {
        let validationStatus = self.validateFields(country: textFieldViewCountry.getText, emailOrMobile: textFieldViewEmailOrMobile.getText, password: textFieldViewPassword.getText)
        switch validationStatus.state{
        case .country:
            textFieldViewCountry.showError(validationStatus.errorMessage)
        case .emailOrMobile:
            textFieldViewEmailOrMobile.showError(validationStatus.errorMessage)
        case .password:
            textFieldViewPassword.showError(validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
    
    func validateFields(country: String?, emailOrMobile: String?, password: String?) -> (state: ErrorState, errorMessage: String){
        let validationStatus = InputValidator.validateCountryWithEmailOrMobile(country: country, emailOrMobile: emailOrMobile)
        if !validationStatus.error.isEmpty {
            return (validationStatus.isErrorInCountry ? .country : .emailOrMobile, validationStatus.error)
        }
        if InputValidator.checkEmpty(value: password){
            return (.password , localizeFor("password_is_required"))
        }
        if !InputValidator.isPassword(password){
            self.showAlert(withMessage: "Password must be following below criterias: \n8 characters or more.\ninclude 1 uppercase letter.\ninclude 1 lowercase letter.\ninclude 1 numeric letter.\n1 special character (@,#,$,%,&,*)", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            return (.password , localizeFor("plz_valid_password"))
        }
        return (.none ,"")
    }
}

// MARK: - API
extension LoginViewController {
    func callLoginAPI(_ isLoginThroughMobile: Bool = false) {
        
        guard let passwordText = textFieldViewPassword.getText else { return }
        var param = ["password": passwordText]
        guard let emailOrMobileText = textFieldViewEmailOrMobile.getText else { return }
        if isLoginThroughMobile {
            /*
            guard let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry else { return }
            param["dialCode"] = selectedCountry.id
             */
            param["dialCode"] = "100"
            param["mobile"] = emailOrMobileText
             
        } else {
            param["email"] = emailOrMobileText
        }
        let routingParam = ["emailOrMobile": isLoginThroughMobile ? "mobile" : "email"] // Rounting parameters
        
        self.loginViewModel.callLoginAPI(param, routing: .  normalLogin(routingParam))
    }
}

// MARK: - TTTAttributedLabelDelegate Delgates
extension LoginViewController: TTTAttributedLabelDelegate{
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        guard let data = components["data"] as? String else { return }
        if data == cueString.linkKeywordSMS {
            if let loginViaSMS = UIStoryboard.onboarding.loginViaSMSVC {
                self.navigationController?.pushViewController(loginViaSMS, animated: true)
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
