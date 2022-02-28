//
//  UIStoryboard+Controllers.swift
//  BaseProject
//
//  Created by MAC240 on 04/06/18.
//  Copyright © 2018 MAC240. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static var home: UIStoryboard {
        return UIStoryboard(name: "Home", bundle: nil)
    }
    
    static var menu: UIStoryboard {
        return UIStoryboard(name: "Menu", bundle: nil)
    }
    
    static var dooTabbar: UIStoryboard {
        return UIStoryboard(name: "DooTabbar", bundle: nil)
    }
    
    static var onboarding: UIStoryboard {
        return UIStoryboard(name: "Onboarding", bundle: nil)
    }
    
    static var kiran: UIStoryboard {
        return UIStoryboard(name: "Kiran", bundle: nil)
    }
    
    static var akash: UIStoryboard {
        return UIStoryboard(name: "Akash", bundle: nil)
    }
    
    static var common: UIStoryboard {
        return UIStoryboard(name: "Common", bundle: nil)
    }
    
    static var krunal: UIStoryboard {
        return UIStoryboard(name: "Krunal", bundle: nil)
    }
    
    static var enterprise: UIStoryboard {
        return UIStoryboard(name: "Enterprise", bundle: nil)
    }
    
    static var enterpriseUsers: UIStoryboard {
        return UIStoryboard(name: "EnterpriseUsers", bundle: nil)
    }
    
    static var profile: UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    
    static var devices: UIStoryboard {
        return UIStoryboard(name: "Devices", bundle: nil)
    }
    
    static var group: UIStoryboard {
        return UIStoryboard(name: "Groups", bundle: nil)
    }
    
    static var setting: UIStoryboard {
           return UIStoryboard(name: "Setting", bundle: nil)
       }

    static var smart: UIStoryboard {
           return UIStoryboard(name: "Smart", bundle: nil)
       }

    static var siri: UIStoryboard {
           return UIStoryboard(name: "AskSiri", bundle: nil)
       }
    
}



extension UIStoryboard {
    
    var onboardingAnimationsVC: OnboardingAnimationsViewController? {
        return getViewController(vcClass: OnboardingAnimationsViewController.self)
    }
    
    var homeVC: HomeViewController? {
        return getViewController(vcClass: HomeViewController.self)
    }
    
    var homeLayoutSettingVC: HomeLayoutSettingViewController? {
        return getViewController(vcClass: HomeLayoutSettingViewController.self)
    }
    
    var menuVC: MenuViewController? {
        return getViewController(vcClass: MenuViewController.self)
    }
    
    var countrySelectionVC: CountrySelectionViewController? {
        return getViewController(vcClass: CountrySelectionViewController.self)
    }
    
    var passwordInAllVC: PasswordInAllViewController? {
        return getViewController(vcClass: PasswordInAllViewController.self)
    }
    
    var signupWithEmailVC: SignWithEmailViewController? {
        return getViewController(vcClass: SignWithEmailViewController.self)
    }
    
    var signupWithMobileNoVC: SignupWithMobileNoViewController? {
        return getViewController(vcClass: SignupWithMobileNoViewController.self)
    }
    
    var otpVerificationVC: OTPVerificationViewController? {
        return getViewController(vcClass: OTPVerificationViewController.self)
    }
    
    var loginVC: LoginViewController? {
        return getViewController(vcClass: LoginViewController.self)
    }
    
    var loginViaSMSVC: LoginViaSMSViewController? {
        return getViewController(vcClass: LoginViaSMSViewController.self)
    }
    
    var forgotPasswordInitialVC: ForgotPasswordInitialViewController? {
        return getViewController(vcClass: ForgotPasswordInitialViewController.self)
    }
    
    var addEnterpriseVC: AddEnterpriseViewController? {
        return getViewController(vcClass: AddEnterpriseViewController.self)
    }
    
    var selectEnterpriseGroupsVC: SelectEnterpriseGroupsViewController? {
        return getViewController(vcClass: SelectEnterpriseGroupsViewController.self)
    }
    
    var enterpriseTopMenuVC: EnterpriseTopMenuViewController? {
        return getViewController(vcClass: EnterpriseTopMenuViewController.self)
    }
    
    var enterpriseTopLayoutVC: EnterpriseTopLayoutViewController? {
        return getViewController(vcClass: EnterpriseTopLayoutViewController.self)
    }
    
    var yourEnterprisesVC: YourEnterprisesViewController? {
        return getViewController(vcClass: YourEnterprisesViewController.self)
    }
    
    var manageEnterpriseVC: ManageEnterpriseViewController? {
        return getViewController(vcClass: ManageEnterpriseViewController.self)
    }
    
    var notificationsListVC: NotificationsViewController? {
        return getViewController(vcClass: NotificationsViewController.self)
    }
    
    var bottomGenericVC: DooBottomPopUp_1ViewController? {
        return getViewController(vcClass: DooBottomPopUp_1ViewController.self)
    }
    
    var bottomGenericActionsVC: DooBottomPopupActions_1ViewController? {
        let getVC = getViewController(vcClass: DooBottomPopupActions_1ViewController.self)
        getVC?.modalPresentationStyle = .overFullScreen;
        getVC?.modalTransitionStyle = .crossDissolve
        return getVC
    }
    
    var bottomGenericAlertsVC: DooBottomPopupAlerts_1ViewController? {
        let getVC = getViewController(vcClass: DooBottomPopupAlerts_1ViewController.self)
        getVC?.modalPresentationStyle = .overFullScreen;
        getVC?.modalTransitionStyle = .crossDissolve
        return getVC
    }
    
    var bottomAlertsLogoutWithShortcutRemoveOptionVC: DooBottomPopUpShortcutOptionsForLogout_ViewController? {
        let getVC = getViewController(vcClass: DooBottomPopUpShortcutOptionsForLogout_ViewController.self)
        getVC?.modalPresentationStyle = .overFullScreen;
        getVC?.modalTransitionStyle = .crossDissolve
        return getVC
    }
    
    var bottomPopupSelectAvatarVC: DooBottomPopupSelectAvatarViewController? {
        let getVC = getViewController(vcClass: DooBottomPopupSelectAvatarViewController.self)
        getVC?.modalPresentationStyle = .overFullScreen;
        getVC?.modalTransitionStyle = .crossDissolve
        return getVC
    }
    
    var enterpriseDetailVC: EnterpriseDetailViewController? {
        return getViewController(vcClass: EnterpriseDetailViewController.self)
    }
    
    var enterpriseUsers: EnterpriseUsersViewController? {
        return getViewController(vcClass: EnterpriseUsersViewController.self)
    }
    
    var enterpriseUserDetail: EnterpriseUserDetailViewController? {
        return getViewController(vcClass: EnterpriseUserDetailViewController.self)
    }
    
    var userPrivilegesVC: PrivilegesViewController? {
        return getViewController(vcClass: PrivilegesViewController.self)
    }

    var inviteEnterpriseUsersVC: InviteEnterpriseUsersViewController? {
        return getViewController(vcClass: InviteEnterpriseUsersViewController.self)
    }
    
    var selectDooUserVC: SelectDooUserViewController? {
        return getViewController(vcClass: SelectDooUserViewController.self)
    }
    
    var removeDooUserInvitesVC: RemoveDooUserInvitesViewController? {
        return getViewController(vcClass: RemoveDooUserInvitesViewController.self)
    }
    
    var changeUserRoleVC: ChangeEnterpriseUserRoleViewController? {
        return getViewController(vcClass: ChangeEnterpriseUserRoleViewController.self)
    }
    
    var selectUsersForAssignPrivilegesVC: SelectUsersForAssignPrivilegesViewController? {
        return getViewController(vcClass: SelectUsersForAssignPrivilegesViewController.self)
    }
    
    var receivedInvitationsVC: ReceivedInvitationsViewController? {
        return getViewController(vcClass: ReceivedInvitationsViewController.self)
    }
    
    var devicesListVC: DevicesListViewController? {
        return getViewController(vcClass: DevicesListViewController.self)
    }
    
    var profileVC: ProfileViewController? {
        return getViewController(vcClass: ProfileViewController.self)
    }
    
    var editProfileVC: EditProfileViewController? {
        return getViewController(vcClass: EditProfileViewController.self)
    }
    
    var devicesTypesList: DevicesTypesListViewController? {
        return getViewController(vcClass: DevicesTypesListViewController.self)
    }
    
    var addDeviceVC: AddDeviceViewController? {
        return getViewController(vcClass: AddDeviceViewController.self)
    }
    
    var addDeviceUsingQRCodeVC: AddDeviceUsingQRCodeViewController? {
        return getViewController(vcClass: AddDeviceUsingQRCodeViewController.self)
    }
    
    var deviceDetailVC: DeviceDetailViewController? {
        return getViewController(vcClass: DeviceDetailViewController.self)
    }
    
    var editApplicationVC: EditApplianceViewController? {
        return getViewController(vcClass: EditApplianceViewController.self)
    }
    
    var applianceMgntOptionsVC: ApplianceMgntOptionsViewController? {
        return getViewController(vcClass: ApplianceMgntOptionsViewController.self)
    }
    
    var settingVC: SettingViewController? {
        return getViewController(vcClass: SettingViewController.self)
    }
    
    var addGroupVC: AddEditGroupViewController? {
        return getViewController(vcClass: AddEditGroupViewController.self)
    }
    
    var applianceDetailInGroupVC: ApplianceDetailsInGroupViewController? {
        return getViewController(vcClass: ApplianceDetailsInGroupViewController.self)
    }
    
    var smartRuleDetailVC: SmartRuleDetailViewController? {
        return getViewController(vcClass: SmartRuleDetailViewController.self)
    }
    
    var addEditBindingRuleVC: AddEditBindingRuleViewController? {
        return getViewController(vcClass: AddEditBindingRuleViewController.self)
    }
    
    var addEditSchedulerVC: AddEditSchedulerViewController? {
        return getViewController(vcClass: AddEditSchedulerViewController.self)
    }
    
    var addEditSceneVC: AddEditSceneViewController? {
        return getViewController(vcClass: AddEditSceneViewController.self)
    }
    
    var timeSelectionBottomVC: TimeSelectionBottomViewController? {
        return getViewController(vcClass: TimeSelectionBottomViewController.self)
    }
    
    var scheduleTypeSelectionBottomVC: ScheduleTypeSelectionBottomViewController? {
        return getViewController(vcClass: ScheduleTypeSelectionBottomViewController.self)
    }

    var colorPickerSelectionBottomVC: ColorPickerSelectionBottomViewController? {
        return getViewController(vcClass: ColorPickerSelectionBottomViewController.self)
    }

    var selectSceneListVC: SelectSceneListViewController? {
        return getViewController(vcClass: SelectSceneListViewController.self)
    }

    var smartAddTargetVC: SmartAddTargetViewController? {
        return getViewController(vcClass: SmartAddTargetViewController.self)
    }
    
    var dooBottomPopUp_NoPullDissmiss_VC: DooBottomPopUp_NoPullDissmiss_ViewController? {
        return getViewController(vcClass: DooBottomPopUp_NoPullDissmiss_ViewController.self)
    }
    
    var dateSelectionBottomVC: DateSelectionBottomViewController? {
        return getViewController(vcClass: DateSelectionBottomViewController.self)
    }
    
    var linkWithAlexaVC: LinkWithAlexaViewController? {
        return getViewController(vcClass: LinkWithAlexaViewController.self)
    }
    
    var signInWithAlexaAmazonVC: SignInWithAlexaAmazonViewController? {
        return getViewController(vcClass: SignInWithAlexaAmazonViewController.self)
    }
    
    
    
    
    
    var addEnterpriseWhenNotAvailable: UINavigationController? {
        guard let viewController = instantiateViewController(withIdentifier: "AddEnterpriseWhenNotAvailableNavigationViewController") as? UINavigationController else {
            return nil
        }
        return viewController
    }
    
    var profileView: ProfileViewController? {
        return getViewController(vcClass: ProfileViewController.self)
    }
    
    var askSiriMainVC: AskSiriMainViewController? {
        return getViewController(vcClass: AskSiriMainViewController.self)
    }
    
    var bottomGenericActionsPopupForSiriVC: BottomPopupForSiriViewController? {
        let getVC = getViewController(vcClass: BottomPopupForSiriViewController.self)
        getVC?.modalPresentationStyle = .overFullScreen;
        getVC?.modalTransitionStyle = .crossDissolve
        return getVC
    }
}

extension UIStoryboard {
    func getViewController<T: UIViewController>(vcClass: T.Type) -> T? {
        guard let viewController = instantiateViewController(withIdentifier: vcClass.className()) as? T else {
            return nil
        }
        return viewController
    }
}
