//
//  SignWithEmailViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SignWithEmailViewController: BaseViewController {
    
    // Just used for this vc...
    enum ErrorState {
        case email
        case termsCondition
        case none
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var emailTextFieldView: DooTextfieldView!
    @IBOutlet weak var buttonCheckUnChecked: UIButton!
    @IBOutlet weak var labelTermsAndCondition: TTTAttributedLabel!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var labelSighUpWithMobileNumber: TTTAttributedLabel!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var buttonBack: UIButton!
    
    // Helper properties
    var isTermsConditionChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
    }
}

// MARK: - Action listeners
extension SignWithEmailViewController{
    @IBAction func buttonTermsConditionTapped(_ sender:UIButton) {
        self.isTermsConditionChecked = !self.isTermsConditionChecked
        self.setTermsConditionStatus()
    }
    
    func setTermsConditionStatus() {
        buttonCheckUnChecked.setImage(self.isTermsConditionChecked ? #imageLiteral(resourceName: "checkIn") : #imageLiteral(resourceName: "unchecked"), for: .normal)
    }
    
    @IBAction func buttonBackTapped(_ sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonNextTapped(_ sender:UIButton) {
        view.endEditing(true)
        // callRegisterWithEmailAPI()
        
        if isValidateFields(){
            callRegisterWithEmailAPI()
        }
    }
    
    func callRegisterWithEmailAPI() {
        
        guard let email = self.emailTextFieldView.genericTextfield?.getText(), !email.isEmpty else {return}
        let param = [
            "email": email.lowercased(),
            "termsAgree": true
        ] as [String : Any]
        
        API_LOADER.show(animated: true)
        API_LOADER.delegate = self
        API_SERVICES.callAPI(param, path: .registerUsingEmail) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            // debugPrint("parsingResponse: \(parsingResponse)")
            if let payload = parsingResponse?["payload"]?.dictionaryValue, let verificationToken = payload["verificationToken"]?.stringValue, let timeOut = payload["timeout"]?.intValue {
                NetworkingManager.shared.setVerificationToken(verificationToken)
                if let destView = UIStoryboard.onboarding.otpVerificationVC {
                    destView.redirectedFrom = .signupEmail(email,timeOut)
                    self.navigationController?.pushViewController(destView, animated: true)
                }
            }
        }
    }
    
    public func validateSignUpEmail(email:String?) -> (state: ErrorState, errorMessage:String){
        if let strEmail = email, InputValidator.checkEmpty(value: strEmail){
            return (.email , localizeFor("email_is_required"))
        }
        if !InputValidator.isEmailLength(email){
            return (.email, localizeFor("email_length_6_to_50"))
        }
        if !InputValidator.isEmail(email){
            return (.email, localizeFor("plz_valid_email"))
        }
        if !isTermsConditionChecked{
            return (.termsCondition, localizeFor("plz_agree_terms_condition"))
        }
        return (.none ,"")
    }
}

// MARK: - User defined methods
extension SignWithEmailViewController{
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        imageViewLogo.image = UIImage(named: "signUpAppLogo")
        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)

        let titleBoldText = localizeFor("email_address_question_mark")
        labelTitle.font = UIFont.Poppins.regular(20)
        labelTitle.text = localizeFor("sign_with_email_subtitle")
        labelTitle.textColor = UIColor.blueHeading
        labelTitle.addAttribute(targets: titleBoldText, font: UIFont.Poppins.medium(20))
        
        emailTextFieldView.textfieldType = .generic
        emailTextFieldView.genericTextfield?.addThemeToTextarea(localizeFor("email_placeholder"))
        emailTextFieldView.genericTextfield?.keyboardType = .emailAddress
        emailTextFieldView.genericTextfield?.returnKeyType = .done
        emailTextFieldView.genericTextfield?.delegate = self
        
        buttonNext.setThemeOnboardingNext()

        // check and un check
        buttonCheckUnChecked.cornerRadius = 2.7
        labelSighUpWithMobileNumber.configureLink(
            textString: localizeFor("signup_with_mobile_number"),
            targets: cueString.linkKeywordMobileNo,
            color: UIColor.blueHeading,
            font: UIFont.Poppins.semiBold(14),
            fontNormal: UIFont.Poppins.regular(14))
        labelSighUpWithMobileNumber.delegate = self

        labelTermsAndCondition.configureLinkWithUnderline(
            textString: cueString.iAgreeUserAgreementAndPrivacyPolicy,
            targets: cueString.linkKeywordUserAgreement, cueString.linkKeywordPrivacyPolicy,
            color: UIColor.blueHeading,
            font: UIFont.Poppins.medium(12),
            fontNormal: UIFont.Poppins.regular(12))
        labelTermsAndCondition.delegate = self
        
        self.isTermsConditionChecked = true
        setTermsConditionStatus()
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = self.validateSignUpEmail(email: self.emailTextFieldView.genericTextfield!.text)
        switch validationStatus.state{
        case .email:
            emailTextFieldView.showError(validationStatus.errorMessage)
        case .termsCondition:
            CustomAlertView.init(title: validationStatus.errorMessage).showForWhile(animated: true)
        case .none:
            return true
        }
        return false
    }
}

// MARK: - UITextFieldDelegate
extension SignWithEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - TTTAttributedLabelDelegate Delgates
extension SignWithEmailViewController: TTTAttributedLabelDelegate{
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        guard let data = components["data"] as? String else { return }
        switch data {
        case cueString.linkKeywordMobileNo:
            // print(cueString.linkKeywordMobileNo)
            if let signupWithMobileNoVC = UIStoryboard.onboarding.signupWithMobileNoVC {
                navigationController?.pushViewController(signupWithMobileNoVC, animated: true)
            }
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
extension SignWithEmailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SignWithEmailViewController: GenericLoaderViewDelegate {
    func apiCancellationRequested() {
        API_SERVICES.cancelAllRequests() // cancel api requests...
    }
}

