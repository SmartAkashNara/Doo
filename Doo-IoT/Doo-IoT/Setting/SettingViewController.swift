//
//  SettingViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import Toast_Swift
import Intents

class SettingViewController: KeyboardNotifBaseViewController {
    
    enum EnumSettingMenu:Int {
        case profile = 0, changePassword, enablePin, notification, firmwareUpdate, appUpdate, logout
    }
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewSettingList: SayNoForDataTableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    
    // MARK: - Variables
    var arraySettings = [MenuDataModel]()
    var appStoreUrl:String? = nil
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        self.loadData() // load settings
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
}

// MARK: - Action listeners
extension SettingViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Service
extension SettingViewController {

    func loadData(){
        self.preparedArrayOfMenu(isAppUpdateOptionToAdd: false)
        self.tableViewSettingList.reloadData()

        checkAppUpdateAvailableOrNot { isAvailabel, eror in
            DispatchQueue.getMain {
                self.arraySettings.removeAll()
                if let flag = isAvailabel, flag{
                    self.preparedArrayOfMenu(isAppUpdateOptionToAdd: true)
                }else{
                    self.preparedArrayOfMenu(isAppUpdateOptionToAdd: false)
                }
            }
        }
    }
    
    func preparedArrayOfMenu(isAppUpdateOptionToAdd:Bool=false){
        arraySettings.append(MenuDataModel.init(id: 0, title: localizeFor("profile"), image: "settingProfile"))
        arraySettings.append(MenuDataModel.init(id: 1, title: localizeFor("change_password"), image: "changePassword"))
        //arraySettings.append(MenuDataModel.init(id: 2, title: localizeFor("enable_pin"), image: "changePin"))
        //arraySettings.append(MenuDataModel.init(id: 3, title: localizeFor("notification"), image: "iconNotification"))
        //arraySettings.append(MenuDataModel.init(id: 4, title: localizeFor("firmware_update"), image: "firmwareUpdate"))
        
        if isAppUpdateOptionToAdd{
            self.arraySettings.append(MenuDataModel.init(id: 5, title: localizeFor("app_update"), image: "appUpdate"))
        }
        
        self.arraySettings.append(MenuDataModel.init(id: 6, title: localizeFor("logout"), image: "settingLogout"))
        self.tableViewSettingList.reloadData()
    }
}

// MARK: - User defined methods
extension SettingViewController {
    func configureTableView() {
        tableViewSettingList.dataSource = self
        tableViewSettingList.delegate = self
        tableViewSettingList.registerCellNib(identifier: SettingCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewSettingList.tableHeaderView = viewNavigationBarDetail
        tableViewSettingList.addBounceViewAtTop()
        tableViewSettingList.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewSettingList.sectionHeaderHeight = 0
        tableViewSettingList.getRefreshControl().tintColor = .lightGray
        tableViewSettingList.sayNoSection = .none
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = "Settings"
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Manage profile options")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
    }
    /*
    func showLogoutAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.notNow, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.logout, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    self.callLogoutApi(isChecked: false)
                    
                }
                let title = localizeFor("are_you_sure_want_to_logout_from_doo")
                alertVC.setAlert(alertTitle: title, leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    */
    
    func showLogoutAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomAlertsLogoutWithShortcutRemoveOptionVC {
                let cancelAction = DooBottomPopUpShortcutOptionsForLogout_ViewController.ActionButton.init(title: cueAlert.Button.notNow, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopUpShortcutOptionsForLogout_ViewController.ActionButton.init(title: cueAlert.Button.logout, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    self.callLogoutApi(isChecked: alertVC.checked)
//                    INInteraction.delete(with: "voiceShortcutsBasic_UserId\(APP_USER?.userId ?? 0)")
//                    UserManager.logoutMethod()
//                    self.removeAllShortcutsOfLoggedUser() {
//                        print("Removed")
//                    }
//                    self.callLogoutApi(isChecked: alertVC.checked)
                }
//                let deleteShorcutAction = DooBottomPopUpShortcutOptionsForLogout_ViewController.ActionButtonForRemovingShortcut() {
//                    alertVC.checked = !alertVC.checked
//                }
                
                let title = localizeFor("are_you_sure_want_to_logout_from_doo")
                alertVC.setAlert(alertTitle: title, alertShortcutRemoveDescription: "Siri shortcuts won't perform once logged out. You can still remove Siri Commands from Shortcuts App related to \'\(AppInfo.appName)\' app anytime" , leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    func callLogoutApi(isChecked: Bool){
        API_SERVICES.callAPI(path: .logout, method: .get) { parsingResponse in
            if isChecked {
                INInteraction.deleteAll { (error) in
                    print("all deleted")
                }
                    UserManager.logoutMethod()
            } else {
                UserManager.logoutMethod()
            }
        }
    }
    
    func removeAllShortcutsOfLoggedUser(completion: (() -> Void)?) {
//        INInteraction.delete(with: "voiceShortcutsBasic_UserId\(APP_USER?.userId ?? 0)"){
//        INInteraction.delete(with: "voiceShortcutsBasic_UserId\(APP_USER?.userId ?? 0)") { error in
//            print(error?.localizedDescription)
//            print("done execution")
//        }
        
        INInteraction.deleteAll { (error) in
            print("all deleted")
        }
        if let completion = completion {
                        completion()
                    }
        
        
//        INInteraction.delete(with: "voiceShortcutsBasic_UserId\(APP_USER?.userId)", completion: {(error) in
//            print("Deleted")
//        })
        
//        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcutsFromCenter, error) in
//            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
////                if voiceShortcutsFromCenter.contains(where: $0.map({$0.shortcut.intent.}))
////
////
////                if let r = voiceShortcutsFromCenter.removeAll(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId}) {
////                    print("Removed successfully")
////                }
////                if let count = (voiceShortcutsFromCenter.filter({ ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId}) as [INVoiceShortcut]).count > 0 {
////                    print(s)
////                    let userId =
////                }
////                if let shortcutImnt = voiceShortcutsFromCenter.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId}) {
////
////                }
//
////                if voiceShortcutsFromCenter.count > 0 {
////                    for shortc in voiceShortcutsFromCenter {
//////                        if (shortc.shortcut.intent?.isKind(of: ApplianceActionsBasicIntent.self) && (shortc.shortcut.intent?.isKind(of: ApplianceActionsBasicIntent.self).use
////                    }
////                    let arr = voiceShortcutsFromCenter.filter({$0.shortcut.intent?.isKind(of: ApplianceActionsBasicIntent.self) as! Bool})
////                    print(arr)
//////                    voiceShortcutsFromCenter.re
//////                    for shortc in voiceShortcutsFromCenter {
//////
//////                        let arrayStorage = shortc.shortcut.userActivity?.persistentIdentifier?.hasPrefix("userID\(APP_USER?.userId)")
//////                        print(arrayStorage)
////////                        if ((shortc.shortcut.intent?.isKind(of: ApplianceActionsBasicIntent.self) != nil) || (shortc.shortcut.intent?.isKind(of: ApplianceActionSpeedIntent.self) != nil) || (shortc.shortcut.intent?.isKind(of: ApplianceActionRgbIntent.self) != nil)) {
////////
////////                            let shortcutsBasic = shortc.shortcut.intent as? ApplianceActionsBasicIntent
////////                            if (shortcutsBasic?.userId)! == APP_USER?.userId
////////                            {
////////                                INInteraction.delete(with: <#T##[String]#>, completion: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
////////                            }
////////                        }
//////
//////                    }
////                }
//                //                self.voiceShortcuts = voiceShortcutsFromCenter
//            } else {
//                if let error = error as NSError? {
//                    print(error.debugDescription)
//                }
//            }
//
//            if let completion = completion {
//                completion()
//            }
//        }
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arraySettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as! SettingCell
        cell.cellConfig(data: self.arraySettings[indexPath.row])
        cell.switchStatus.tag = indexPath.row
        cell.switchStatus.switchStatusChanged = { value in
            debugPrint("Enable or Disable PIN Tapped!")
        }
        
        switch EnumSettingMenu.init(rawValue: self.arraySettings[indexPath.row].id) {
        case .enablePin:
            cell.switchStatus.isHidden = false
        default:
            cell.switchStatus.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let enumCase = EnumSettingMenu.init(rawValue: self.arraySettings[indexPath.row].id)
        switch enumCase {
        case .profile:
            if let profileVC = UIStoryboard.profile.instantiateInitialViewController() {
                profileVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        case .changePassword:
            if let destView = UIStoryboard.onboarding.passwordInAllVC {
                destView.redirectedFrom = .changePassword
                self.navigationController?.pushViewController(destView, animated: true)
            }
        case .enablePin:break
        case .notification:break
        case .firmwareUpdate:break
        case .appUpdate:
            if let strURL = self.appStoreUrl, let url = URL(string: strURL) {
                UIApplication.shared.open(url)
            }
        case .logout:
            self.showLogoutAlert()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SettingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension SettingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
    }
    
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            navigationTitle.isHidden = false
        }else{
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 76.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        }else{
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}

extension SettingViewController {
    @objc func cellSwitchValueChanged(_ sender: UISwitch) {
        print("changed status")
        self.arraySettings[sender.tag].enable = !self.arraySettings[sender.tag].enable
        tableViewSettingList.reloadData()
        sender.changeSwitchThumbColorBasedOnState()
    }
}
extension SettingViewController{
    func checkAppUpdateAvailableOrNot(completion: @escaping (Bool?, Error?) -> Void) {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                return completion(nil, nil)
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if error != nil { return completion(nil, nil) }
                guard let data = data else { return completion(nil, nil) }
                let json = try JSON.init(data: data)
                guard let resultsFirstObject = json["results"].array?.first?.dictionaryValue, let version = resultsFirstObject["version"]?.string, let appURL = resultsFirstObject["trackViewUrl"]?.string else {
                    return completion(nil, nil)
                }
                self.appStoreUrl = appURL
                debugPrint("currentVersion", currentVersion)
                debugPrint("App store version", version)
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}

