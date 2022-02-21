//
//  LoginViaSMSViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 03/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class LoginViaSMSViewController: BaseViewController {
    
    enum ErrorState {
        case country
        case mobile
        case none
    }
    
    // MARK: - Outlets
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var textFieldViewCountry: DooTextfieldView!
    @IBOutlet weak var textFieldViewMobile: DooTextfieldView!
    @IBOutlet weak var buttonNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
extension LoginViaSMSViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields(){
            loginWIthSMS()
        }
    }
    
    func loginWIthSMS() {    
//        guard let countryCode = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.id, !countryCode.isEmpty else {return} below line commneted by divay changes as of now not allow to change country
        guard let mobile = self.textFieldViewMobile.genericTextfield?.getText(), !mobile.isEmpty else {return}
        let param = [
//            "dialCode": countryCode, // below line commneted by divay changes as of now not allow to change country
            "dialCode":"100",
            "mobile": mobile,
            ] as [String : Any]
        
        API_SERVICES.callAPI(param, path: .loginWithSMS) { (parsingResponse) in
            if let payload = parsingResponse?["payload"]?.dictionaryValue, let verificationToken = payload["verificationToken"]?.stringValue, let timeOut = payload["timeout"]?.intValue {
                // If verification token is there
                NetworkingManager.shared.setVerificationToken(verificationToken)
                if let destView = UIStoryboard.onboarding.otpVerificationVC {
                    destView.redirectedFrom = .loginViaSMS(mobile, timeOut)
                    self.navigationController?.pushViewController(destView, animated: true)
                }
            }
        }
    }
        
    @IBAction func unwindSegueFromCountrySelectionToLogin(segue: UIStoryboardSegue) {
        if let _ = segue.source as? CountrySelectionViewController,
            let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry {
            textFieldViewCountry.setText = selectedCountry.countryName
        }
    }
    
    func addCountry() {
        guard let countryObject = COUNTRY_SELECTION_VIEWMODEL.selectedCountry else { return }
        textFieldViewCountry.setText = countryObject.dialCode != "" ? countryObject.countryName + " (\(countryObject.dialCode))" : countryObject.countryName
    }
}

// MARK: - User defined methods
extension LoginViaSMSViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)
        imageViewLogo.image = UIImage(named: "signUpAppLogo")
        
        let headingBoldText = localizeFor("mobile_number")
        labelHeading.font = UIFont.Poppins.regular(20)
        labelHeading.textColor = UIColor.blueHeading
        labelHeading.numberOfLines = 0
        labelHeading.text = localizeFor("login_via_sms_subtitle")
        labelHeading.addAttribute(targets: headingBoldText, font: UIFont.Poppins.medium(20))
        
        textFieldViewCountry.textfieldType = .rightIcon
        textFieldViewCountry.rightIconTextfield?.addThemeToTextarea(cueString.countryPlaceholder)
//        textFieldViewCountry.rightIconTextfield?.rightIcon = UIImage(named: "imgDropDownArrow")! // below line commneted by divay changes as of now not allow to change country
        textFieldViewCountry.rightIconTextfield?.delegate = self
        textFieldViewCountry.setText = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.countryName ?? ""
        
        textFieldViewMobile.textfieldType = .generic
        textFieldViewMobile.genericTextfield?.addThemeToTextarea(localizeFor("mobile_no_placeholder"))
        textFieldViewMobile.genericTextfield?.keyboardType = .numberPad
        textFieldViewMobile.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewMobile.genericTextfield?.addToolBar()

        buttonNext.setThemeOnboardingNext()
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = self.validateFields(country: textFieldViewCountry.getText, mobile: textFieldViewMobile.getText)
        switch validationStatus.state{
        case .country:
            textFieldViewCountry.showError(validationStatus.errorMessage)
        case .mobile:
            textFieldViewMobile.showError(validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
    
    public func validateFields(country: String?, mobile: String?) -> (state:ErrorState, errorMessage:String){
        if InputValidator.checkEmpty(value: country){
            return (.country , localizeFor("country_code_is_required"))
        }
        if InputValidator.checkEmpty(value: mobile){
            return (.mobile , localizeFor("mobile_number_is_required"))
        }
        if !InputValidator.isMobileLength(mobile){
            return (.mobile , localizeFor("mobile_number_4_to_13"))
        }
        if !InputValidator.isMobile(mobile){
            return (.mobile , localizeFor("plz_valid_mobile_number"))
        }
        return (.none ,"")
    }
}

// MARK: - UITextFieldDelegate
extension LoginViaSMSViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewCountry.rightIconTextfield:
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
extension LoginViaSMSViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
