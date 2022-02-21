//
//  MenuViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SwiftUI

class MenuViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var buttonArrowDownIcon: UIButton!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var textFlippingContentView: TextFlippingContentView!
    @IBOutlet weak var widthConstrainOfTextFlippingContentView: NSLayoutConstraint!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    
    var menuViewModel = MenuViewModel()
    var isViewDidLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Global
        HOMESETUP()
        
        setupDefault()
        defaultTextFlippingConfig()
        
        // this indicates that there are enterprises and its better to call. If you don't have enterprises, then there is no point of calling list of enterprises.
        if let user = APP_USER, user.userSelectedEnterpriseID != nil {
            callGetEnterprises()
        }
        
        self.menuViewModel.prepareMenuLayout()
    }
    
    func HOMESETUP() {
        IS_USER_INSIDE_APP = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isViewDidLoaded = true
        self.wheneverUserVisitsScreenWorkAround()
        
        // Enterprises list at top card closures configurations and declaration.
        self.configureTopEnterprisesListCardClosures()
    }
    
    // This will refresh Menu View if in case new enterprise switched from somewhere.
    func viewAppearedUsingTab() {
        if isViewLoaded {
            self.wheneverUserVisitsScreenWorkAround()
        }
    }
    
    
    func wheneverUserVisitsScreenWorkAround() {
        guard let _ = APP_USER else { return }
        
        // profile picture
        self.assignProfilePicture()
        
        self.callGetEnterprises(callSilently: true)
        
        // Auto refresh of updated enterprise
        // self.textFlippingContentView.tableView.reloadData()
        // self.configureTextFlipAndPick()
    }
    
    // calling from tabbar instance
    func switchToNewEnterpriseAndRefreshMenulistUsingAPI() {
        // if view once, loaded then only refresh it.
        if self.isViewDidLoaded {
            self.configureTextFlipAndPick()
            self.reRenderMenu()
        }
    }
    
    // MARK: - ViewDidAppear stuffs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = self
    }
}

extension MenuViewController{
    func setupDefault(){
        buttonArrowDownIcon.isHidden = true
        configureCollectionViews()
        self.buttonProfile.imageView?.backgroundColor = .black
        self.mainView.delegateOfSWWalert = self // handle retry part.
    }
    
    func assignProfilePicture() {
        self.buttonProfile.layer.cornerRadius = self.buttonProfile.bounds.size.width/2
        // load picture
        if let user = APP_USER, let thumbNail = URL.init(string: user.thumbnailImage) {
            // self.buttonProfile.sd_setImage(with: thumbNail, for: .normal, completed: nil) // previously kept.
            self.buttonProfile.imageView?.contentMode = .scaleAspectFill
            self.buttonProfile.sd_setImage(with: thumbNail, for:.normal, placeholderImage: UIImage.init(named: "placeholderOfProfilePicture")!, options: .continueInBackground, context: nil)
            
        }
    }
    
    func configureCollectionViews() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 13
        layout.minimumInteritemSpacing = 0
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.registerCellNib(identifier: MenuCellFullWidthHeight.identifier, commonSetting: true)
        collectionView.registerCellNib(identifier: MenuCellHalfHeight.identifier, commonSetting: true)
        collectionView.registerCellNib(identifier: MenuCellFullWidth.identifier, commonSetting: true)
        collectionView.registerCellNib(identifier: MenuCellHalfWidth.identifier, commonSetting: true)
        
        collectionView.reloadData()
    }
}

// MARK: Something went wrong or no internet
extension MenuViewController: SomethingWentWrongAlertViewDelegate{
    func retryTapped() {
        // dismiss both and try again.
        // TO-DO Refresh only home screen
        self.mainView.dismissAnyAlerts()
        self.callGetEnterprises()
    }
}

// MARK: Enterprise API and switchings
extension MenuViewController{
    func callGetEnterprises(callSilently: Bool = false) {
        // API_LOADER.show(animated: true)
        if !callSilently {
            self.menuViewModel.isMenuListUpdatedBasedOnEnterprise = false // show skeleton.
            self.collectionView.reloadData() // show skeleton
        }
        
        self.menuViewModel.callGetEnterprises { [weak self] in
            debugPrint("Load enterprises")
            // API_LOADER.dismiss(animated: true)
            self?.configureTextFlipAndPick()
            self?.reRenderMenu()
        } failure: {
            // TO-DO: handle
            // Show failure part
            if !callSilently {
                self.mainView.showSomethingWentWrong()
            }
        } internetFailure: {
            // TO-DO: handle
            // Show internet failure part
            self.mainView.showInternetOff()
        } failureInform: {
            if !MQTTSwift.shared.isAvoidToStopLoader{
                API_LOADER.dismiss(animated: true)
            }
        } switchToAddEnteprise: {
            SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.addEnterpriseWhenNotAvailable
        }
    }
    
    func reRenderMenu() {
        if let user = APP_USER, let selectedEnterprise = user.selectedEnterprise {
            switch selectedEnterprise.userRole {
            case .owner, .admin:
                self.menuViewModel.addInviteUsersAndUserAndPrivilegesOptionsIfNotAvailable()
            case .applicationUser, .user:
                self.menuViewModel.removeInviteUsersAndUserAndPrivilegesOptionsIfAvailable()
            }
            self.collectionView.reloadData()
        }
    }
    
    // check here is alexa skill already enable or not
    func checkAlexaSkillEnabledOrNotApi(){
        API_SERVICES.callAPI([:], path: .checkAlexaSkillEnable, method: .get) { response in
            if let alexaEnable = response?["payload"]?["alexaEnable"].boolValue{
                debugPrint(alexaEnable)
                self.checkEnableFlagAndRedirectNextScrenn(isEnableAlexa: alexaEnable)
            }
        } failure: { str in
            self.checkEnableFlagAndRedirectNextScrenn(isEnableAlexa: false)
        }
    }
    
    // here redirect screen based on is enable alexa already or not
    func checkEnableFlagAndRedirectNextScrenn(isEnableAlexa:Bool){

        if isEnableAlexa{
            guard let linkWithAlexaVC = UIStoryboard.menu.linkWithAlexaVC else { return }
            linkWithAlexaVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(linkWithAlexaVC, animated: true)
        }else{
            guard let signInWithAlexaAmazonVC = UIStoryboard.menu.signInWithAlexaAmazonVC else { return }
            signInWithAlexaAmazonVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(signInWithAlexaAmazonVC, animated: true)
        }
    }
    
    
}

// MARK: profile tap
extension MenuViewController{
    @IBAction func buttonProfileTap(_ sender:UIButton){
        if let profileVC = UIStoryboard.profile.profileView {
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

// MARK: Menu collection
// Create layout as per design. Text in layout can reach up to 2 lines and shows 3 dots at end if extends.
extension MenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuViewModel.arrayMenuList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let menuItem = menuViewModel.arrayMenuList[indexPath.row]
        switch menuItem.layout {
        case .box:
            // full width
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCellFullWidthHeight.identifier, for: indexPath) as! MenuCellFullWidthHeight
            
            if !self.menuViewModel.isMenuListUpdatedBasedOnEnterprise {
                cell.showSkeletonAnimation()
            }else{
                cell.cellConfig(data: menuViewModel.arrayMenuList[indexPath.row])
            }
            return cell
        case .combinedFlat(let combinedModel):
            // one cell with half width  device and scenes
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCellHalfWidth.identifier, for: indexPath) as! MenuCellHalfWidth
            if !self.menuViewModel.isMenuListUpdatedBasedOnEnterprise {
                cell.showSkeletonAnimation()
            }else{
                cell.cellConfig(data:  [menuItem, combinedModel])
            }
            cell.cellDidTapped { (id) in
                print("clicked menu:-", id)
                if self.menuViewModel.isMenuListUpdatedBasedOnEnterprise {
                    if id == 0 {
                        self.checkAlexaSkillEnabledOrNotApi()
                        
                    } else {
                        
                        // Siri
                        if let askSiriMainVc = UIStoryboard.siri.askSiriMainVC {
                            askSiriMainVc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(askSiriMainVc, animated: true)
                        }
                    }
                }
            }
            return cell
        case .combined(let combinedModel):
            // one cell with half height  device and scenes
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCellHalfHeight.identifier, for: indexPath) as! MenuCellHalfHeight
            if !self.menuViewModel.isMenuListUpdatedBasedOnEnterprise {
                cell.showSkeletonAnimation()
            }else{
                cell.cellConfig(data:  [menuItem, combinedModel])
            }
            cell.cellDidTapped { (id) in
                print("clicked menu:-", id)
                if self.menuViewModel.isMenuListUpdatedBasedOnEnterprise {
                    if id == 4 {
                        //devices
                        guard let destView = UIStoryboard.devices.devicesTypesList else { return }
                        destView.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(destView, animated: true)
                    } else {
                        // Scenes
                        (self.tabBarController as? DooTabbarViewController)?.setTabManually(.smart)
                        if let userRole = APP_USER?.selectedEnterprise?.userRole {
                            switch userRole {
                            case .user:
                                // ON THIS IF REQUIRED TO HIDE SCHEDULER BASED ON USER OR ADMIN ROLE....
                                // self.smartRuleNavigation(subIndex: 0) // Scenes shown at index 0 in user role, beause schedulers not available for users.
                                self.smartRuleNavigation(subIndex: 1) // Scenes shown at index 1.
                            default:
                                self.smartRuleNavigation(subIndex: 1) // Scenes shown at index 1.
                            }
                        }
                    }
                }
            }
            return cell
        default:
            // Flat...
            //  last 2 cell User & Privileges , Setting
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCellFullWidth.identifier, for: indexPath) as! MenuCellFullWidth
            if !self.menuViewModel.isMenuListUpdatedBasedOnEnterprise {
                cell.showSkeletonAnimation()
            }else{
                cell.cellConfig(data: menuViewModel.arrayMenuList[indexPath.row])
            }
            return cell
        }
    }
}
extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthOfCollectionView = collectionView.bounds.size.width - 40
        let minusGap = widthOfCollectionView - 16
        
        // figure out size of layout.
        let menuItem = menuViewModel.arrayMenuList[indexPath.row]
        switch menuItem.layout {
        case .flat, .combinedFlat:
            // last cell User & Privileges , Setting
            return CGSize.init(width: widthOfCollectionView, height: MenuCellFullWidth.cellHeight)
        default:
            return CGSize.init(width: (minusGap/2), height: MenuCellFullWidthHeight.cellHeight)
        }
    }
}
extension MenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // guard !self.menuViewModel.isMenuListUpdatedBasedOnEnterprise else { return }
        
        if indexPath.row != 3 && indexPath.row != 0{
            let menuItem = menuViewModel.arrayMenuList[indexPath.row]
            switch menuItem.title {
            case localizeFor("home_tab"):
                // home
                (self.tabBarController as? DooTabbarViewController)?.setTabManually(.home)
            case localizeFor("groups_menu"):
                // group menu
                (self.tabBarController as? DooTabbarViewController)?.setTabManually(.groups)
            case localizeFor("schedules_menu"):
                // Schedulers
                (self.tabBarController as? DooTabbarViewController)?.setTabManually(.smart)
                smartRuleNavigation(subIndex: 0)
            case localizeFor("invite_users_menu"):
                if let inviteEnterpriseUsersVC = UIStoryboard.enterpriseUsers.inviteEnterpriseUsersVC,
                   let selectedEnterprise = APP_USER?.selectedEnterprise {
                    inviteEnterpriseUsersVC.enterpriseModel = selectedEnterprise
                    inviteEnterpriseUsersVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(inviteEnterpriseUsersVC, animated: true)
                }
            case localizeFor("user_and_privileges_menu"):
                if let usersToAssignPrivileges = UIStoryboard.enterpriseUsers.selectUsersForAssignPrivilegesVC,
                   let selectedEnterprise = APP_USER?.selectedEnterprise {
                    usersToAssignPrivileges.enterpriseModel = selectedEnterprise
                    usersToAssignPrivileges.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(usersToAssignPrivileges, animated: true)
                }
            case localizeFor("received_invitations_menu"):
                // Received invitations
                if let receivedInvitationsVC = UIStoryboard.enterprise.receivedInvitationsVC {
                    receivedInvitationsVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(receivedInvitationsVC, animated: true)
                }
            case localizeFor("settings_button"):
                // Setting
                if let settingVC = UIStoryboard.setting.settingVC {
                    settingVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(settingVC, animated: true)
                }
            case localizeFor("firmware_upgrade_menu"):
                // Firmware Upgrade
                break
            default:
                break
            }
            print("didSelectItemAt clicked menu:-", menuViewModel.arrayMenuList[indexPath.row].title)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 0, left: 20, bottom: 20, right: 20)
    }
    
    func smartRuleNavigation(subIndex: Int) {
        if let navController = (self.tabBarController as? DooTabbarViewController)?.viewControllers?[DooTabs.smart.rawValue] as? UINavigationController,
           let smartVC = navController.viewControllers.first as? SmartMainViewController{
            if !smartVC.isViewLoaded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    smartVC.horizontalTitleCollection.shift(toIndex: subIndex)
                }
            }else{
                smartVC.horizontalTitleCollection.shift(toIndex: subIndex)
            }
        }
    }
}

// MARK: Textfliping content view.
extension MenuViewController {
    func configureTextFlipAndPick(){
        // Swipe Top or Bottom to switch between Enterprices.
        // Call enterprises list and add selected enterprise at top. Set enterprise width dynamic and set max size as per device width. Once max width reached, show ... after enterprise.
        // assign array of enterpirse to textFlippingContentView component
        textFlippingContentView.enterPrices = ENTERPRISE_LIST
        // hide and show based on enterpise array count
        
        guard textFlippingContentView.enterPrices.count != 0 else {return}
        buttonArrowDownIcon.isHidden = false
        
        func doTextFlippingWork() {
            // defualt set width contarin based selected enterpise
            self.textFlippingContentView.selectedPosition = self.menuViewModel.selectedPosition
            if !self.textFlippingContentView.getCurrentEnterprise.isEmpty {
                self.widthConstrainOfTextFlippingContentView.constant = self.textFlippingContentView.getCurrentEnterprise.widthOfString(usingFont: UIFont.Poppins.medium(13)) - 38
            }else{
                // Logout if no more enterprise found.
                UserManager.logoutMethod()
            }
            
            // Show selected enterprise
            if let user = APP_USER, let index = ENTERPRISE_LIST.firstIndex(where: { $0.id == user.userSelectedEnterpriseID }) {
                self.textFlippingContentView.finalizeIndexWithScroll(index)
                // set selected enterprise from enterprise id received in profile response.
                user.selectedEnterprise = ENTERPRISE_LIST[index]
                self.setWidthOfTextfliping(user)
            }
            
            // call back once changed enterpirse
            textFlippingContentView.switchedEnterpriseBySwipeUpOrDown { [weak self] (index) in
                print("selected index \(index)")
                if let user = APP_USER {
                    self?.callSwitchEnterprise(atIndex: index, withUser: user)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            doTextFlippingWork()
        }
    }
    
    func callSwitchEnterprise(atIndex index: Int, withUser dooUser: AppUser) {
        guard let topCardView = (self.tabBarController as? DooTabbarViewController)?.topUpdatedLayoutCard else { return }
        let enterprise = ENTERPRISE_LIST[index]
        topCardView.callSwitchEnterpriseAPI(enterprise, atIndex: index)
    }
    
    @IBAction func openEnterpriseSwitchTopLayout(sender: UIButton) {
        (self.tabBarController as? DooTabbarViewController)?.openEnterpriseSwitchMenuCard()
    }
    
    func configureTopEnterprisesListCardClosures() {
        if let topCard = (self.tabBarController as? DooTabbarViewController)?.topUpdatedLayoutCard {
            topCard.enterpriseChanged = { index in
                // print("selected index: \(index)")
                if let user = APP_USER, let index = ENTERPRISE_LIST.firstIndex(where: { $0.id == user.userSelectedEnterpriseID }) {
                    self.textFlippingContentView.finalizeIndexWithScroll(index)
                    self.setWidthOfTextfliping(user)
                    self.reRenderMenu()
                }
            }
            topCard.manageEnterpriseOptionTapped = {
                // print("manage enterprise tapped.")
                if let yourEnterprisesVC = UIStoryboard.enterprise.yourEnterprisesVC {
                    yourEnterprisesVC.hidesBottomBarWhenPushed = true
                    yourEnterprisesVC.arrayAllEnterprises = ENTERPRISE_LIST
                    self.navigationController?.pushViewController(yourEnterprisesVC, animated: true)
                }
            }
            topCard.addEnterpriseOptionTapped = {
                // print("manage enterprise tapped.")
                if let addEnterprisesVC = UIStoryboard.enterprise.addEnterpriseVC {
                    addEnterprisesVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(addEnterprisesVC, animated: true)
                }
            }
        }
    }
    
    func setWidthOfTextfliping(_ user: AppUser) {
        // update width constraint based on enterprise selection text
        if let enterprise = user.selectedEnterprise {
            self.widthConstrainOfTextFlippingContentView.constant = enterprise.name.widthOfString(usingFont: UIFont.Poppins.medium(13)) - 38
        }
    }
}

// MARK: - Initial Handlings
extension MenuViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}

// MARK: - Text fliping stuff
extension MenuViewController {
    func defaultTextFlippingConfig() {
        self.textFlippingContentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.openEnterpriseSwitchTopLayout(sender:))))
    }
    @objc func openEnterpriseCardUponTapOfTextFlippingArea(sender: UIButton) {
        (self.tabBarController as? DooTabbarViewController)?.openEnterpriseSwitchMenuCard()
    }
}
