//
//  OnboardingAnimationsViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 27/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class OnboardingAnimationsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var labelIntroText: UILabel!
    @IBOutlet weak var labelNavTitle: UILabel!
    @IBOutlet weak var imageOnboarding: UIImageView!
    @IBOutlet weak var labelExistUserLogin: TTTAttributedLabel!
    @IBOutlet weak var buttonLogin: UIButton!

    // MARK: - Variables
    let arrayOnboarding = [UIImage(named: "onboardinImage7"),UIImage(named: "onboardinImage8"),UIImage(named: "onboardinImage9"),UIImage(named: "onboardinImage10")] // Show random images in onboarding screen.
    
    let loginVC = UIStoryboard.onboarding.loginVC! // To assign default country before user reaches there.
    let loginButtonTile = localizeFor("login_button")

    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefualts()
        
        DooAPILoader.shared.allocate() // allocate loader
        
        // Fetch default country right here using API to load it in login view. Instance of login view has been taken right here to load country code.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             self.setDefaultCountry()
        }
    }
    
    // MARK: - ViewDidAppear stuffs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = self
    }
    
    func setDefaultCountry() {
        // Fetch default country right here using API to load it in login view. Instance of login view has been taken right here to load country code.
        COUNTRY_SELECTION_VIEWMODEL.callCountrySelectionAPI(param: [:]) {
            self.loginVC.view.layoutIfNeeded() // This will going to call viewDidLoad of login vc so it lays its layout.
            self.loginVC.addCountry() // add country after adding layout.
        }
    }
}

// MARK: - Action listeners
extension OnboardingAnimationsViewController{
    @IBAction func buttonSignUpTapped(_ sender: UIButton){
        if let signupWithEmailVC = UIStoryboard.onboarding.signupWithEmailVC {
            navigationController?.pushViewController(signupWithEmailVC, animated: true)
        }
        /*
        if let destView = UIStoryboard.onboarding.otpVerificationVC {
            // destView.redirectedFrom = .signupEmail("kiran104@mailsac.com")
            // destView.redirectedFrom = .signupMobileNo("9823983498")
            self.navigationController?.pushViewController(destView, animated: true)
        }
 */
        /*
        if let destView = UIStoryboard.onboarding.passwordInAllVC {
            destView.redirectedFrom = .createPassword
            self.navigationController?.pushViewController(destView, animated: true)
        }
 */
    }
}

// MARK: - User defiend methods
extension OnboardingAnimationsViewController {
    func setDefualts(){
        labelNavTitle.font = UIFont.Poppins.semiBold(19)
        labelNavTitle.textColor =  UIColor.blueHeading
        labelNavTitle.text = localizeFor("doo")
        
        let titleBoldText = localizeFor("smart_home")
        labelIntroText.font = UIFont.Poppins.regular(17)
        labelIntroText.text = "\(localizeFor("intro_subtitle"))\n\(titleBoldText)"
        labelIntroText.textColor = UIColor.blueHeading
        labelIntroText.addAttribute(targets: titleBoldText, font: UIFont.Poppins.semiBold(17))

        
        buttonLogin.setTitle(localizeFor("login_button")+".", for: .normal)
        buttonLogin.addTarget(self, action: #selector(buttonLoginTapped), for: .touchUpInside)
        buttonLogin.setTitleColor(UIColor.black, for: .normal)
        buttonLogin.titleLabel?.font = UIFont.Poppins.semiBold(12)
        
        // sign up button
        buttonSignUp.setThemePurple(localizeFor("signup_button"), fontSize: 11)
        
        labelExistUserLogin.configureLink(
            textString: "\(localizeFor("existing_user_question_mark"))",
            targets: "",
            color: UIColor.blueHeading,
            font: UIFont.Poppins.semiBold(12),
            fontNormal: UIFont.Poppins.regular(12))
        labelExistUserLogin.delegate = self

        // rondom onBoarding image will be load every time when load this screen
        if let randomOnBoardingImage = arrayOnboarding.shuffled().randomElement(){
            imageOnboarding.image = randomOnBoardingImage
        }
    }
    
    @objc func buttonLoginTapped(){
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}

// MARK: - TTTAttributedLabelDelegate
extension OnboardingAnimationsViewController: TTTAttributedLabelDelegate{
    // Mobile no tapped....
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        guard let data = components["data"] as? String else { return }
        if data == loginButtonTile {
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
}


// MARK: - Initial Handlings
extension OnboardingAnimationsViewController: UINavigationControllerDelegate {
   func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
       let isRootVC = viewController == navigationController.viewControllers.first
       navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
   }
}
