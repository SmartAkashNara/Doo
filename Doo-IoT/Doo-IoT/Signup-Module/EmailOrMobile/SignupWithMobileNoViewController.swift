//
//  SignupWithMobileNoViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SignupWithMobileNoViewController: BaseViewController {
    
    // Just used for this vc...
    enum ErrorState {
        case country
        case mobile
        case termsCondition
        case none
    }
    
    // MARK: - Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var countryTextInput: DooTextfieldView!
    @IBOutlet weak var mobileTextInput: DooTextfieldView!
    @IBOutlet weak var buttonCheckUnChecked: UIButton!
    @IBOutlet weak var labelTermsAndCondition: TTTAttributedLabel!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var labelSignupWith: TTTAttributedLabel!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var buttonBack: UIButton!
    
    // Helper properties
    var isTermsConditionChecked = false
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefaults()
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

// MARK: - Actions listeners
extension SignupWithMobileNoViewController{
    @IBAction func buttonTermsConditionTapped(_ sender:UIButton) {
        self.isTermsConditionChecked = !self.isTermsConditionChecked
        setTermsConditionStatus()
    }
    
    func setTermsConditionStatus() {
        buttonCheckUnChecked.setImage(self.isTermsConditionChecked ? #imageLiteral(resourceName: "checkIn") : #imageLiteral(resourceName: "unchecked"), for: .normal)
    }
    
    @IBAction func buttonBackTapped(_ sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonNextTapped(_ sender:UIButton) {
        view.endEditing(true)
        if isValidateFields() {
            callRegisterWithMobileAPI()
        }
    }
    
    func callRegisterWithMobileAPI() {
        
//        guard let countryCode = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.id, !countryCode.isEmpty else {return} // below line commneted by divay changes as of now not allow to change country
        guard let mobile = self.mobileTextInput.genericTextfield?.getText(), !mobile.isEmpty else {return}
        let param = [
//            "dialCodeId": countryCode, // below line commneted by divay changes as of now not allow to change country
            "dialCodeId":"100",
            "mobile": mobile,
            "termsAgree": true
        ] as [String : Any]
        
        API_LOADER.show(animated: true)
        API_LOADER.delegate = self
        API_SERVICES.callAPI(param, path: .registerUsingMobileNo) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            // debugPrint("parsingResponse: \(parsingResponse)")
            guard let jsonObject = parsingResponse, let payload = jsonObject["payload"]?.dictionary else{ return }
            guard let verificationToken = payload["verificationToken"]?.stringValue, let timeOut = payload["timeout"]?.intValue else{ return }
            
            NetworkingManager.shared.setVerificationToken(verificationToken)
            if let destView = UIStoryboard.onboarding.otpVerificationVC {
                destView.redirectedFrom = .signupMobileNo(mobile, timeOut)
                self.navigationController?.pushViewController(destView, animated: true)
            }
        }
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = self.validateFields(country: countryTextInput.rightIconTextfield?.text, mobile: mobileTextInput.genericTextfield?.text)
        switch validationStatus.state{
        case .country:
            self.countryTextInput.showError(validationStatus.errorMessage)
        case .mobile:
            self.mobileTextInput.showError(validationStatus.errorMessage)
        case .termsCondition:
            CustomAlertView.init(title: validationStatus.errorMessage).showForWhile(animated: true)
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
        if !isTermsConditionChecked{
            return (.termsCondition, localizeFor("plz_agree_terms_condition"))
        }
        return (.none ,"")
    }
    
    @IBAction func unwindSegueFromCountrySelectionToLogin(segue: UIStoryboardSegue) {
        if let _ = segue.source as? CountrySelectionViewController,
            let selectedCountry = COUNTRY_SELECTION_VIEWMODEL.selectedCountry {
            countryTextInput.setText = selectedCountry.countryName
        }
    }
    
    func addCountry() {
        if let countryObject = COUNTRY_SELECTION_VIEWMODEL.selectedCountry {
            countryTextInput.setText = countryObject.dialCode != "" ? countryObject.countryName + " (\(countryObject.dialCode))" : countryObject.countryName
        }else{
            countryTextInput.setText = "India (+91)"
        }
    }
}

// MARK: - User defiend methods
extension SignupWithMobileNoViewController{
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        imageViewLogo.image = UIImage(named: "signUpAppLogo")
        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)
        
        let titleBoldText = localizeFor("mobile_number_question_mark")
        labelTitle.font = UIFont.Poppins.regular(16)
        labelTitle.textColor = UIColor.blueHeading
        labelTitle.text = localizeFor("sign_with_mobile_number_subtitle")
        labelTitle.addAttribute(targets: titleBoldText, font: UIFont.Poppins.medium(16))
        
        countryTextInput.textfieldType = .rightIcon
        countryTextInput.rightIconTextfield?.addThemeToTextarea(cueString.countryPlaceholder)
//        countryTextInput.rightIconTextfield?.rightIcon = UIImage(named: "imgDropDownArrow")! // below line commneted by divay changes as of now not allow to change country
        countryTextInput.rightIconTextfield?.delegate = self
        countryTextInput.setText = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.countryName ?? ""
        
        mobileTextInput.textfieldType = .generic
        mobileTextInput.genericTextfield?.addThemeToTextarea(localizeFor("mobile_no_placeholder"))
        mobileTextInput.genericTextfield?.keyboardType = .numberPad
        mobileTextInput.genericTextfield?.addToolBar()
        
        buttonNext.setThemeOnboardingNext()
        
        // check and un check
        buttonCheckUnChecked.cornerRadius = 2.7
        
        labelSignupWith.configureLink(
            textString: localizeFor("signup_with_email_address"),
            targets: cueString.linkKeywordEmailAddress,
            color: UIColor.blueHeading,
            font: UIFont.Poppins.semiBold(14),
            fontNormal: UIFont.Poppins.regular(14))
        labelSignupWith.delegate = self
        
        labelTermsAndCondition.configureLink(
            textString: cueString.iAgreeUserAgreementAndPrivacyPolicy,
            targets: cueString.linkKeywordUserAgreement, cueString.linkKeywordPrivacyPolicy,
            color: UIColor.blueHeading,
            font: UIFont.Poppins.medium(12),
            fontNormal: UIFont.Poppins.regular(12))
        labelTermsAndCondition.delegate = self
        
        self.isTermsConditionChecked = true
        setTermsConditionStatus()
        
    }
}

// MARK: - UITextFieldDelegate
extension SignupWithMobileNoViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case countryTextInput.rightIconTextfield:
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

// MARK: - TTTAttributedLabelDelegate Delgates
extension SignupWithMobileNoViewController: TTTAttributedLabelDelegate{
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        guard let data = components["data"] as? String else { return }
        switch data {
        case cueString.linkKeywordEmailAddress:
            print(cueString.linkKeywordEmailAddress)
            navigationController?.popViewController(animated: true)
        case cueString.linkKeywordUserAgreement:
            Utility.openSafariBrowserWithUrl(cueString.userAgreementUrl)
        case cueString.linkKeywordPrivacyPolicy:
            Utility.openSafariBrowserWithUrl(cueString.privacyPolicyUrl)
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SignupWithMobileNoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension SignupWithMobileNoViewController: GenericLoaderViewDelegate {
    func apiCancellationRequested() {
        API_SERVICES.cancelAllRequests() // cancel api requests...
    }
}
