//
//  OTPVerificationViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class OTPVerificationViewController: UIViewController {
    
    enum RredirectedFrom {
        case signupEmail(String, Int), signupMobileNo(String, Int), forgotPassword(String, Int), loginViaSMS(String, Int), updateProfile(String, String, Int)
        
        func getAssociatedEmailOrMobileValue() -> String {
            switch self {
            case .signupEmail(let emailOrMobile, _):
                return emailOrMobile
            case .signupMobileNo(let emailOrMobile, _):
                return emailOrMobile
            case .forgotPassword(let emailOrMobile, _):
                return emailOrMobile
            case .loginViaSMS(let emailOrMobile, _):
                return emailOrMobile
            case .updateProfile(let emailOrMobile, _, _):
                return emailOrMobile
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var labelOfTitle: UILabel!
    @IBOutlet weak var otpHolderView: AutoOTPStackView!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var countDownOTPWSHandler: OTPCountdown!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var buttonBack: UIButton!
    
    var splashModel: SplashViewModel = SplashViewModel() // Session configuration API after successful signin.
    let loginViewModel: LoginViewModel = LoginViewModel()
    
    // MARK: - Variables
    var redirectedFrom: OTPVerificationViewController.RredirectedFrom = .signupEmail("abc@gmail.com", 1)
    var otpValue: String = ""
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLayouts()
    }
    
    // MARK: - User defined methods
    func configureLayouts() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        imageViewLogo.image = UIImage(named: "signUpAppLogo")
        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)
        
        var emailOrMobile = ""
        var timeOut = 1
        func setPreText(emailOrMobile: String) {
            if InputValidator.isNumber(emailOrMobile.trimSpaceAndNewline) {
                labelOfTitle.text = localizeFor("enter_the_mobile_otp_pretext") + " " + emailOrMobile
            }else if InputValidator.isEmail(emailOrMobile.trimSpaceAndNewline) {
                labelOfTitle.text = localizeFor("enter_the_email_otp_pretext") + " " + emailOrMobile
            }
            
        }
        switch self.redirectedFrom {
        case .signupEmail(let email, let timeOutCount):
            emailOrMobile = email
            timeOut = timeOutCount
        case .signupMobileNo(let mobile, let timeOutCount):
            emailOrMobile = mobile
            timeOut = timeOutCount
        case .forgotPassword(let emailOrMobileValue, let timeOutCount):
            emailOrMobile = emailOrMobileValue
            timeOut = timeOutCount
        case .loginViaSMS(let emailOrMobileValue, let timeOutCount):
            emailOrMobile = emailOrMobileValue
            timeOut = timeOutCount
        case .updateProfile(let emailOrMobileValue, _, let timeOutCount):
            emailOrMobile = emailOrMobileValue
            timeOut = timeOutCount
        }
        setPreText(emailOrMobile: emailOrMobile)
        labelOfTitle.font = UIFont.Poppins.regular(20)
        labelOfTitle.textColor = UIColor.blueHeading
        labelOfTitle.addAttribute(targets: localizeFor("otp"), emailOrMobile, font: UIFont.Poppins.medium(20))
        
        // OTP Stackview
        self.otpHolderView.delegateOfAutoOTPStackView = self
        self.otpHolderView.setFocusToTextfield()
        
        buttonNext.setThemeOnboardingNext()
        buttonNext.isHidden = true
        
        // Count down...
        COUNT_DOWN_VIEW = self.countDownOTPWSHandler // assign to global variable, so we can show elapsed time when app goes to background and comes back again.
        self.setCountdownValues(timeOut,isShowTimerNow: true)
    }
    
    func setEnableFinishButton() {
        buttonNext.isHidden = false
    }
    func setDisableFinishButton() {
        buttonNext.isHidden = true
    }
    
    func setCountdownValues(_ timeOut: Int, isShowTimerNow:Bool=false) {
        // set timer
        self.countDownOTPWSHandler.delegate = self
        self.countDownOTPWSHandler.setOTPCountDownState = .sending
        self.countDownOTPWSHandler.otpTimeOut = 60 * timeOut
        let delayTime:DispatchTime = isShowTimerNow ? .now() : .now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.countDownOTPWSHandler.setOTPCountDownState = .timer
        }
    }
}

// MARK: - Action listeners
extension OTPVerificationViewController{
    
    @IBAction func buttonBackTapped(_ sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonNextTapped(_ sender:UIButton) {
        
        API_LOADER.delegate = self // API cancellation work
        
        guard self.otpValue.count == 6 else {return}
        let param = ["otp": self.otpValue]
        
        switch self.redirectedFrom {
        case .forgotPassword(_, _):
            signupProcessAndForgotPasswordOTPVerificationAPI(.verifyOTPForgotPassword(param))
        case .signupEmail(_,_), .signupMobileNo(_):
            signupProcessAndForgotPasswordOTPVerificationAPI(.verifySignupAuthenticationOTP(param))
        case .loginViaSMS(_,_):
            self.loginViaSMSAPI(param)
        case .updateProfile(_, let emailOrMobileToken, _):
            updateContactInExistingProfile(emailOrMobileToken: emailOrMobileToken, param)
        }
    }
    
    func signupProcessAndForgotPasswordOTPVerificationAPI(_ routing: Routing) {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: routing) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            self.setVerificationTokenAndTimerIfAvailable(parsingResponse, isSetTimer: false)
            if let destView = UIStoryboard.onboarding.passwordInAllVC {
                
                switch routing {
                case .verifySignupAuthenticationOTP(_):
                    destView.redirectedFrom = .createPassword
                case .verifyOTPForgotPassword(_):
                    destView.redirectedFrom = .forgotPassword
                default: return
                }
                self.navigationController?.pushViewController(destView, animated: true)
            }
        }
    }
    
    
    // to get login via sms OTP while resend,
    func loginViaSMSAPI(_ param: [String: Any]) {
        self.loginViewModel.callLoginAPI([:], routing: .loginWithSMSOTP(param))
    }
    
    func updateContactInExistingProfile(emailOrMobileToken: String, _ param: [String: Any]) {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .verifyOTPUpdateProfile(emailOrMobileToken)) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            guard let payload = parsingResponse?["payload"] else { return }
            APP_USER?.update(profileResponse: payload)
            if let destView = UIStoryboard.profile.profileVC{
                self.navigationController?.popToViewControllerCustom(destView: destView, animated: true)
            }
        }
    }
}

// MARK: - AutoOTPStackViewDelegate
extension OTPVerificationViewController: AutoOTPStackViewDelegate {
    func didReceivedOTP(_ otpValue: String) {
        self.otpValue = otpValue
        self.setEnableFinishButton()
    }
    func didModifyingOTP() {
        self.otpValue = ""
        self.setDisableFinishButton()
    }
}

// MARK: - OTPCountDownDelegate
extension OTPVerificationViewController: OTPCountDownDelegate {
    func resendOTPTapped() {
        switch self.redirectedFrom {
        case .forgotPassword(_, _):
            resendOTPCommonAPICaller(.resendForgotPassword)
        case .signupEmail(_,_), .signupMobileNo(_, _):
            resendOTPCommonAPICaller(.resendRegisterWithEmailOrMobileOTP)
        case .loginViaSMS(_,_):
            resendOTPViaLoginViaSMSAPI()
        case .updateProfile(_, let emailOrMobileToken, _):
            callResendOTPForUpdateProfileContactAPI(emailOrMobileToken)
        }
    }
    
    // Common work .forgotPassword, .signupEmail & .signupMobileNo
    func resendOTPCommonAPICaller(_ routing: Routing) {
        self.countDownOTPWSHandler.setOTPCountDownState = .sending
        API_SERVICES.callAPI([:], path: routing, method: .get) { (parsingResponse) in
            self.setVerificationTokenAndTimerIfAvailable(parsingResponse)
        } failureInform: {
            self.resendOTPCommonFailure()
        }
    }
    func setVerificationTokenAndTimerIfAvailable(_ parsingResponse: [String: JSON]?, isSetTimer: Bool = true) {
        if let payload = parsingResponse?["payload"]?.dictionaryValue, let verificationToken = payload["verificationToken"]?.stringValue {
            // If verification token is there
            NetworkingManager.shared.setVerificationToken(verificationToken)
            // if timeout is there
            if let timeOut = payload["timeOut"]?.intValue {
                self.countDownOTPWSHandler.otpTimeOut = 60 * timeOut
            }
        }
        if isSetTimer {
            self.countDownOTPWSHandler.setOTPCountDownState = .timer
        }
    }
    func resendOTPCommonFailure() {
        NetworkingManager.shared.showSomethingWentWrong()
        self.countDownOTPWSHandler.setOTPCountDownState = .resend
    }
    
    func resendOTPViaLoginViaSMSAPI() {
        guard let countryCode = COUNTRY_SELECTION_VIEWMODEL.selectedCountry?.id, !countryCode.isEmpty else {return}
        self.countDownOTPWSHandler.setOTPCountDownState = .sending
        let param = [
            "dialCode": countryCode,
            "mobile": self.redirectedFrom.getAssociatedEmailOrMobileValue(),
        ] as [String : Any]
        
        API_SERVICES.callAPI(param, path: .loginWithSMS) { (parsingResponse) in
            self.setVerificationTokenAndTimerIfAvailable(parsingResponse)
        } failureInform: {
            self.resendOTPCommonFailure()
        }
    }
    
    func callResendOTPForUpdateProfileContactAPI(_ emailOrMobileToken: String) {
        self.countDownOTPWSHandler.setOTPCountDownState = .sending
        let param = [
            "otpUuid": emailOrMobileToken
        ] as [String : Any]
        API_SERVICES.callAPI(path: .resendOTPUpdateProfile(param), method: .get) { (parsingResponse) in
            self.setVerificationTokenAndTimerIfAvailable(parsingResponse)
        } failureInform: {
            self.resendOTPCommonFailure()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension OTPVerificationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension OTPVerificationViewController: GenericLoaderViewDelegate {
    func apiCancellationRequested() {
        API_SERVICES.cancelAllRequests() // cancel api requests...
    }
}
