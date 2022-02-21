//
//  ForgotPasswordInitialViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 03/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class ForgotPasswordInitialViewController: BaseViewController {
    
    enum ErrorState { case country, emailOrMobile, none }
    
    // MARK: - Outlets
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var textFieldViewCountry: DooTextfieldView!
    @IBOutlet weak var textFieldViewEmailOrMobile: DooTextfieldView!
    @IBOutlet weak var buttonNext: UIButton!
    
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
    func addCountry() {
        guard let countryObject = COUNTRY_SELECTION_VIEWMODEL.selectedCountry else {
            textFieldViewCountry.setText = "India (+91)"
            return
        }
        textFieldViewCountry.setText = countryObject.dialCode != "" ? countryObject.countryName + " (\(countryObject.dialCode))" : countryObject.countryName
    }
}

// MARK: - Action listeneres
extension ForgotPasswordInitialViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields(){
            callForgotPasswordAPI(InputValidator.isNumber(textFieldViewEmailOrMobile.getText!))
        }
    }
    
    @IBAction func unwindSegueFromCountrySelectionToLogin(segue: UIStoryboardSegue) {
        if let _ = segue.source as? CountrySelectionViewController,
            let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry {
            textFieldViewCountry.setText = selectedCountry.countryName
        }
    }
    
    public func validateFields(country: String?, emailOrMobile: String?) -> (state: ErrorState, errorMessage: String){
        let validationStatus = InputValidator.validateCountryWithEmailOrMobile(country: country, emailOrMobile: emailOrMobile)
        if !validationStatus.error.isEmpty {
            return (validationStatus.isErrorInCountry ? .country : .emailOrMobile , validationStatus.error)
        }
        return (.none ,"")
    }
    
    func callForgotPasswordAPI(_ isLoginThroughMobile: Bool = false) {
        
        guard let emailOrMobileText = textFieldViewEmailOrMobile.getText else { return }
        var param: [String: Any] = [:]
        if isLoginThroughMobile {
            /* // below line commneted by divay changes as of now disabale intraction fo country changes
            guard let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry else { return }
            param["dialCodeId"] = selectedCountry.id
             */
            param["dialCodeId"] = "100"
            param["mobile"] = emailOrMobileText
        } else {
            param["email"] = emailOrMobileText
        }
        let routingParam = ["emailOrMobile": isLoginThroughMobile ? "mobile" : "email"] // Rounting parameters
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .forgotPasswordInitial(routingParam)) { (parsingResponse) in
            guard let payload = parsingResponse?["payload"]?.dictionaryValue,
                let verificationToken = payload["verificationToken"]?.stringValue else { return }
            API_LOADER.dismiss(animated: true)
            NetworkingManager.shared.setVerificationToken(verificationToken)
            
            var timeout = 1
            if let timeOutValue = payload["timeOut"]?.intValue { timeout = timeOutValue }
            
            if let destView = UIStoryboard.onboarding.otpVerificationVC {
                destView.redirectedFrom = .forgotPassword(emailOrMobileText, timeout)
                self.navigationController?.pushViewController(destView, animated: true)
            }
        }
    }
    
}

// MARK: - User defined methods
extension ForgotPasswordInitialViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)
        imageViewLogo.image = UIImage(named: "signUpAppLogo")
        
        let headingBoldText1 = localizeFor("email")
        let headingBoldText2 = localizeFor("mobile_number")
        labelHeading.font = UIFont.Poppins.regular(20)
        labelHeading.textColor = UIColor.blueHeading
        labelHeading.numberOfLines = 0
        labelHeading.text = localizeFor("forgot_password_subtitle")
        labelHeading.addAttribute(targets: headingBoldText1, headingBoldText2, font: UIFont.Poppins.medium(20))
        
        textFieldViewCountry.textfieldType = .rightIcon
        textFieldViewCountry.rightIconTextfield?.addThemeToTextarea(cueString.countryPlaceholder)
//        textFieldViewCountry.rightIconTextfield?.rightIcon = UIImage(named: "imgDropDownArrow")! below line commneted by divay changes as of now not allow to change country
        textFieldViewCountry.rightIconTextfield?.delegate = self
        textFieldViewCountry.setText = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.countryName ?? ""
        
        textFieldViewEmailOrMobile.textfieldType = .generic
        textFieldViewEmailOrMobile.genericTextfield?.addThemeToTextarea(localizeFor("email_or_mobile_placeholder"))
        textFieldViewEmailOrMobile.genericTextfield?.returnKeyType = .done
        textFieldViewEmailOrMobile.genericTextfield?.delegate = self
        textFieldViewEmailOrMobile.genericTextfield?.clearButtonMode = .whileEditing

        buttonNext.setThemeOnboardingNext()
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = self.validateFields(country: textFieldViewCountry.getText, emailOrMobile: textFieldViewEmailOrMobile.getText)
        switch validationStatus.state{
        case .country:
            textFieldViewCountry.showError(validationStatus.errorMessage)
        case .emailOrMobile:
            textFieldViewEmailOrMobile.showError(validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
}

// MARK: - UITextFieldDelegate
extension ForgotPasswordInitialViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewCountry.rightIconTextfield:
            textFieldViewCountry.dismissError()
            /* below line commneted by divay changes as of now not allow to change country
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
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ForgotPasswordInitialViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
