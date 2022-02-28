//
//  PasswordInAllViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 31/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class PasswordInAllViewController: BaseViewController {
    
    enum RredirectedFrom {
        case createPassword, forgotPassword, changePassword
        
        var getTitle: String {
            switch self {
            case .createPassword:
                return localizeFor("create_password_subtitle")
            case .forgotPassword:
                return localizeFor("forgot_reset_password_subtitle")
            case .changePassword:
                return localizeFor("change_password_subtitle")
            }
        }
    }
    
    var redirectedFrom: RredirectedFrom = .changePassword

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textfieldOfOldPassword: EyePasswordTextField!
    @IBOutlet weak var textfieldOfNewPassword: EyePasswordTextField!
    @IBOutlet weak var passwordValidationsComponent: SetPasswordComponent!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var buttonBack: UIButton!
    
    var splashModel: SplashViewModel = SplashViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        
        textfieldOfOldPassword.tag = 80 // to set the keyboard gap up to 80
        textfieldOfNewPassword.tag = 30 // to set the keyboard gap up to 30

        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setDefaults() {
        imageViewLogo.image = UIImage(named: "signUpAppLogo")
        buttonBack.setImage(UIImage(named: "leftArrowGray"), for: .normal)
        
        labelTitle.font = UIFont.Poppins.regular(20)
        labelTitle.textColor = UIColor.blueHeading
        labelTitle.numberOfLines = 0
        labelTitle.text = redirectedFrom.getTitle
        labelTitle.addAttribute(targets: localizeFor("password_subtitle_bold"), font: UIFont.Poppins.medium(20))

        // set placeholders
        textfieldOfOldPassword.delegate = self
        textfieldOfOldPassword.textContentType = .oneTimeCode
        textfieldOfOldPassword.addThemeToTextarea(localizeFor("old_password_placeholder"), trailing: 0)
        textfieldOfOldPassword.delegate = self
        
        textfieldOfNewPassword.delegate = self
        textfieldOfNewPassword.textContentType = .oneTimeCode
        textfieldOfNewPassword.delegate = self

        buttonNext.setThemeOnboardingNext()
        
        // show old password only while change password redirection done
        switch redirectedFrom {
        case .changePassword:
            textfieldOfOldPassword.isHidden = false
            textfieldOfNewPassword.addThemeToTextarea(localizeFor("new_password_placeholder"), trailing: 0)
            textfieldOfOldPassword.returnKeyType = .next
            textfieldOfNewPassword.returnKeyType = .done
            textfieldOfOldPassword.addTarget(self, action: #selector(passwordEditingChanged(_:)), for: .editingChanged)
        default:
            textfieldOfOldPassword.isHidden = true
            textfieldOfNewPassword.addThemeToTextarea(localizeFor("password_placeholder"), trailing: 0)
            textfieldOfNewPassword.returnKeyType = .done
        }

        textfieldOfNewPassword.addTarget(self, action: #selector(passwordEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc func passwordEditingChanged(_ sender: UITextField) {
        if let text = sender.text {
            passwordValidationsComponent.textfieldEditingChanged(text)
        }
    }
}

extension PasswordInAllViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        passwordValidationsComponent.textFieldShouldBeginEditing(textField)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if redirectedFrom == .changePassword, textField == textfieldOfOldPassword {
            textfieldOfNewPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Action listeners
extension PasswordInAllViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextActionListener(_ sender: UIButton) {
        if validatePasswords() {
            switch redirectedFrom {
            case .createPassword:
                callSetPasswordAPI()
            case .forgotPassword:
                callSetPasswordForForgotPasswordAPI()
            case .changePassword:
                callChangePasswordAPI()
            }
        }
    }
    
    func callSetPasswordAPI() {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(["password": self.textfieldOfNewPassword.text ?? ""], path: .setPasswordWhileSignup) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let payload = parsingResponse?["payload"]?.dictionaryValue,
               let accessToken = payload["accessToken"]?.stringValue,
               let _ = payload["refreshToken"]?.stringValue {
                NetworkingManager.shared.setAuthorization(accessToken)
                let defaults = UserDefaults(suiteName: "group.com.ss.doo")
                defaults?.set(accessToken, forKey: "AccessTokenForAllTargets")
                defaults?.synchronize()
                self.splashModel.accessToken = accessToken // Passing accesstoken to store in newly created user.
                self.splashModel.doWaitForAnimation = false // don't wait for animation.
                self.splashModel.callFetchProfileInfo() //ARCH TODO: Won't work as we are not setting userinfo inside splash model
            }
        }
    }
    
    func callSetPasswordForForgotPasswordAPI() {
        guard let password = textfieldOfNewPassword.text, !password.isEmpty else {return}
        let param = [
            "password": password,
            ] as [String : Any]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .setForgotPasswordReset) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            let okAlert = UIAlertAction.init(title: cueAlert.Button.oK, style: .default) { (alert) in
                if let loginVC = self.navigationController?.viewControllers[1] {
                    self.navigationController?.popToViewController(loginVC, animated: true)
                }
            }
            self.showAlert(withMessage: localizeFor("password_reset_successfully"), withActions: okAlert)
        }
    }
    
    func callChangePasswordAPI() {
        guard let oldPassword = textfieldOfOldPassword.text, !oldPassword.isEmpty,
            let newPassword = textfieldOfNewPassword.text, !newPassword.isEmpty else {return}
        let param = ["currentPassword": oldPassword,
                      "newPassword": newPassword]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .changePassword) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonObject = parsingResponse, let msg = jsonObject["message"]?.stringValue{
                CustomAlertView.init(title: msg,forPurpose: .success).showForWhile(animated: true)
            }
            DispatchQueue.getMain(delay: 0.5) {
                UserManager.logoutMethod()
            }
        }
    }

    func validatePasswords() -> Bool{
        switch redirectedFrom {
        case .createPassword:
            if passwordValidationsComponent.validateTextfieldPasswordAndFocus(textfieldOfNewPassword) {
                return true
            } else {
                textfieldOfNewPassword.becomeFirstResponder()
            }
        case .forgotPassword:
            if passwordValidationsComponent.validateTextfieldPasswordAndFocus(textfieldOfNewPassword) {
                return true
            } else {
                textfieldOfNewPassword.becomeFirstResponder()
            }
        case .changePassword:
            if passwordValidationsComponent.validateTextfieldPasswordAndFocus(textfieldOfOldPassword) {
                if passwordValidationsComponent.validateTextfieldPasswordAndFocus(textfieldOfNewPassword) {
                    /*if textfieldOfOldPassword.text == textfieldOfNewPassword.text {
                        return true
                    } else {
                        self.showAlert(withMessage: localizeFor("old_and_new_password_doesnot_match"))
                    }*/
                     return true
                } else {
                    textfieldOfNewPassword.becomeFirstResponder()
                }
            } else {
                textfieldOfOldPassword.becomeFirstResponder()
            }
            
        }
        return false
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension PasswordInAllViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
