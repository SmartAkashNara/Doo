//
//  AppliancesViewInAskSiriMainVc.swift
//  Doo-IoT
//
//  Created by Shraddha on 17/02/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
import Intents
import IntentsUI
import DooIotExtension
import simd

class AppliancesViewInAskSiriMainVc: UIView {
    
    @IBOutlet weak var dooNoDataView: DooNoDataView_1!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView! {
        didSet {
            mainView.delegateOfSWWalert = self
        }
    }
    @IBOutlet weak var bottomTableConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var tableViewApplianceList: SayNoForDataTableView! {
        didSet {
            tableViewApplianceList.delegate = self
            tableViewApplianceList.dataSource = self
        }
    }
    
    // MARK: - Variable declaration
    var viewModel = SmartMainViewModel()
    var applianceViewModel = AppliancesListInSiriViewModel()
    var arraySearchAppliancesListInSiri = [SiriApplianceDataModel]()
    
    
    weak var askSiriMainVc: UIViewController?
    var isShowLoader: Bool = false
    var voiceShortcutsBasic: [INVoiceShortcut] = []
    var voiceShortcutsFanSpeed: [INVoiceShortcut] = []
    var voiceShortcutsRgb: [INVoiceShortcut] = []
    var isSearch: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addKeyboardNotifs()
        self.defaultConfig()
//        self.callGetAppliancesListAPI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 0.3) {
            self.bottomTableConstraint.constant = 0
        }
    }

    func defaultConfig(viewController: UIViewController? = nil) {
        if let viewController = viewController {
            self.askSiriMainVc = viewController
        }
        self.configureTableView()
        self.callGetAppliancesListAPI()
    }
    
    func searchConfig(viewController: UIViewController? = nil, strSearch: String) {
        if let viewController = viewController {
            self.askSiriMainVc = viewController
        }
        self.getSearchArrayContains(strSearch)
    }
    
    func clearSearch(isClosePressed: Bool) {
        if isClosePressed {
            if let vc = (self.askSiriMainVc as? AskSiriMainViewController) {
                vc.searchBar.text = ""
                vc.searchBar.resignFirstResponder()
                self.arraySearchAppliancesListInSiri.removeAll()
                
                UIView.animate(withDuration: 0.2, animations: {
                    vc.rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
                    vc.viewNavigationBar.layoutIfNeeded()
                }) { (_) in
                }
                
            }
        }
        DispatchQueue.getMain(delay: 0.1) {
        self.arraySearchAppliancesListInSiri.removeAll()
        self.isSearch = false
        self.tableViewApplianceList.reloadData()
        }
    }
    
    func getSearchArrayContains(_ text : String) {
        
        let arrayDummy = self.applianceViewModel.arrayAppliancesListInSiri
        self.arraySearchAppliancesListInSiri.removeAll()
        arrayDummy.forEach({ (siriDataModel) in
            let results = siriDataModel.arraySiriAppliances.filter { $0.applianceName.lowercased().contains("\(text.lowercased())") }
            var arraySiriAppliances = [TargetApplianceDataModel]()
            let dataModel = SiriApplianceDataModel(param: "")
            dataModel.groupDetail = siriDataModel.groupDetail
            arraySiriAppliances = results
            dataModel.arraySiriAppliances = arraySiriAppliances
            if results.count > 0 {
                self.arraySearchAppliancesListInSiri.append(dataModel)
            }
        })
        isSearch = true
        tableViewApplianceList.reloadData()
    }
    
    func setDummyData() {
        self.applianceViewModel.loadStaticData()
    }
    
    func configureTableView() {
        tableViewApplianceList.bounces = true
        tableViewApplianceList.registerCellNib(identifier: OneStripeViewCell.identifier)
        tableViewApplianceList.registerCellNib(identifier: SiriAppliancesTVCell.identifier)
        tableViewApplianceList.registerCellNib(identifier: SmartHomeSectionTVCell.identifier)
        tableViewApplianceList.addRefreshControlForPullToRefresh {
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.tableViewApplianceList.stopPullToRefresh()
                self.applianceViewModel.loadStaticData()
                self.loadNoDataPlaceholder()
                return
            }
            self.callGetAppliancesListAPI(isPullToRefresh: true)
        }
        tableViewApplianceList.dataSource = self
        tableViewApplianceList.sayNoSection = .noGroupsListFound("Groups")
        tableViewApplianceList.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 15, right: 0)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewApplianceList.tableHeaderView = v
        tableViewApplianceList.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - DooNoDataView_1Delegate
extension AppliancesViewInAskSiriMainVc: DooNoDataView_1Delegate {
    func showNoEnterpriseView() {
        self.tableViewApplianceList.isScrollEnabled = false
        self.dooNoDataView.initSetup(.noEnterprises)
        self.dooNoDataView.allocateView()
        self.dooNoDataView.delegate = self
    }
    
    func dismissNoEnterpriseView() {
        self.dooNoDataView.delegate = nil
        self.tableViewApplianceList.isScrollEnabled = true
        self.dooNoDataView.dismissView()
    }
}

// MARK: - internet & something went wrong work
extension AppliancesViewInAskSiriMainVc: SomethingWentWrongAlertViewDelegate {
    
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        //        self.callGetSceneListAPI(isNextPageRequest: false, isPullToRefresh: false)
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}

// MARK: - UITableViewDelegate
extension AppliancesViewInAskSiriMainVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard self.applianceViewModel.isAppliancesListInSiriFetched else {
            return nil
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSectionTVCell.identifier) as! SmartHomeSectionTVCell
        
        if isSearch {
            cell.cellConfigForSiri(title: arraySearchAppliancesListInSiri[section].groupDetail?.name.uppercased() ?? "")
        } else {
            cell.cellConfigForSiri(title: applianceViewModel.arrayAppliancesListInSiri[section].groupDetail?.name.uppercased() ?? "")
        }
        
        cell.buttonPlus.isHidden = true
        cell.buttonDots.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearch {
            
            self.checkAndUpdateForSiriAvailabilityForCurrentApplianceFromSearch(indexPath: indexPath, finished: {
                DispatchQueue.getMain(delay:0.1) {
                    self.openAppliancesActionsForSiri(objAppliance: self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row])
                }
            })
        } else {
            self.checkAndUpdateForSiriAvailabilityForCurrentAppliance(indexPath: indexPath, finished: {
                DispatchQueue.getMain(delay:0.1) {
                self.openAppliancesActionsForSiri(objAppliance: self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row])
                }
            })
        }
    }
    
    func checkAndUpdateForSiriAvailabilityForCurrentApplianceFromSearch(indexPath: IndexPath, finished: () -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts(completion: { (voiceShortcutsFromCenter, error) in
            if let voiceShortcuts = voiceShortcutsFromCenter {
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId as? Int == self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent == .on}) {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[0].isAddedToSiri = true
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[0].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[0].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId as? Int == self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent == .off}) {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[1].isAddedToSiri = true
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[1].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[1].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.applianceId as? Int == self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.actionTypeForIntent == .fanspeed}) {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[2].isAddedToSiri = true
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[2].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[2].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionRgbIntent)?.applianceId as? Int == self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.actionTypeForIntent == .rgb}) {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[3].isAddedToSiri = true
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[3].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[3].isAddedToSiri = false
                }
                
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
        })
        finished()
    }
    
    func checkAndUpdateForSiriAvailabilityForCurrentAppliance(indexPath: IndexPath, finished: () -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts(completion: { (voiceShortcutsFromCenter, error) in
            if let voiceShortcuts = voiceShortcutsFromCenter {
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId as? Int == self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent == .on}) {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[0].isAddedToSiri = true
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[0].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[0].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId as? Int == self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent == .off}) {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[1].isAddedToSiri = true
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[1].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[1].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.applianceId as? Int == self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.actionTypeForIntent == .fanspeed}) {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[2].isAddedToSiri = true
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[2].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[2].isAddedToSiri = false
                }
                
                if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? ApplianceActionRgbIntent)?.applianceId as? Int == self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].applianceId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.userId as? Int == APP_USER?.userId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.actionTypeForIntent == .rgb}) {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[3].isAddedToSiri = true
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[3].shortcutUUID = shortcutImnt.identifier.uuidString
                } else {
                    self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row].arrOperationsForIntent[3].isAddedToSiri = false
                }
                
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
            
        })
        finished()
    }
    
    func openAppliancesActionsForSiri(objAppliance: TargetApplianceDataModel) {
        if let actionsVC = UIStoryboard.siri.bottomGenericActionsPopupForSiriVC {
            let isFanControlSupportedThenToShow = objAppliance.checkApplianceTypeSupportedOrNot(enumType: .fan)
            let isRGBControlSupportedThenToShow = objAppliance.checkApplianceTypeSupportedOrNot(enumType: .rgb)
            
            var isAddedToSiri = false
            if let row = objAppliance.arrOperationsForIntent.firstIndex(where: { ($0.commandType == .on)}) {
                    isAddedToSiri = objAppliance.arrOperationsForIntent[row].isAddedToSiri
                }
            let action1 = BottomPopupForSiriViewController.PopupOptionForSiri (
                title: "Turn On", color: UIColor.blueHeading, buttonTitle: isAddedToSiri == true ? "Added to Siri" : "Add to Siri", buttonColor: isAddedToSiri == true ? UIColor.greenOnline : UIColor.purpleButtonText, buttonBackgroundColor: isAddedToSiri == true ? UIColor.white : UIColor.graySceneCard, action: {
                    self.addUserActivityToButton(objAppliance: objAppliance, isTurnOn: true)
                })
            isAddedToSiri = false
            if let row = objAppliance.arrOperationsForIntent.firstIndex(where: { ($0.commandType == .off)}) {
                    isAddedToSiri = objAppliance.arrOperationsForIntent[row].isAddedToSiri
                }
            let action2 = BottomPopupForSiriViewController.PopupOptionForSiri (
                title: "Turn Off", color: UIColor.blueHeading, buttonTitle: isAddedToSiri == true ? "Added to Siri" : "Add to Siri", buttonColor: isAddedToSiri == true ? UIColor.greenOnline : UIColor.purpleButtonText, buttonBackgroundColor: isAddedToSiri == true ? UIColor.white : UIColor.graySceneCard, action: {
                    self.addUserActivityToButton(objAppliance: objAppliance, isTurnOff: true)
                })
            
            
            // here if rgb supported and is it rgb
            
            if isRGBControlSupportedThenToShow{
                isAddedToSiri = false
                if let row = objAppliance.arrOperationsForIntent.firstIndex(where: { ($0.commandType == .rgb)}) {
                        isAddedToSiri = objAppliance.arrOperationsForIntent[row].isAddedToSiri
                    }
                let action3 = BottomPopupForSiriViewController.PopupOptionForSiri (
                    title: "Change Colour", color: UIColor.blueHeading, buttonTitle: isAddedToSiri == true ? "Added to Siri" : "Add to Siri", buttonColor: isAddedToSiri == true ? UIColor.greenOnline : UIColor.purpleButtonText, buttonBackgroundColor: isAddedToSiri == true ? UIColor.white : UIColor.graySceneCard, action: {
                        self.addUserActivityToButton(objAppliance: objAppliance, isRgb: true)
                    })
                actionsVC.popupType = .generic("Actions", "Appliance options", [action1, action2, action3])
            }else if isFanControlSupportedThenToShow{
                isAddedToSiri = false
                if let row = objAppliance.arrOperationsForIntent.firstIndex(where: { ($0.commandType == .fanspeed)}) {
                        isAddedToSiri = objAppliance.arrOperationsForIntent[row].isAddedToSiri
                    }
                let action3 = BottomPopupForSiriViewController.PopupOptionForSiri (
                    title: "Change Speed", color: UIColor.blueHeading, buttonTitle: isAddedToSiri == true ? "Added to Siri" : "Add to Siri", buttonColor: isAddedToSiri == true ? UIColor.greenOnline : UIColor.purpleButtonText, buttonBackgroundColor: isAddedToSiri == true ? UIColor.white : UIColor.graySceneCard, action: {
                        self.addUserActivityToButton(objAppliance: objAppliance, isFanSpeed: true)
                    })
                actionsVC.popupType = .generic("Actions", "Appliance options", [action1, action2, action3])
            } else {
                actionsVC.popupType = .generic("Actions", "Appliance options", [action1, action2])
            }
            self.askSiriMainVc?.present(actionsVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension AppliancesViewInAskSiriMainVc: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.applianceViewModel.isAppliancesListInSiriFetched else {
            return 1
        }
        if isShowLoader {
            return 1
        }else{
            // add two rows for top bar section and device title
            if isSearch {
                return self.arraySearchAppliancesListInSiri.count
            }
            return ((self.applianceViewModel.arrayAppliancesListInSiri.count))
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard self.applianceViewModel.isAppliancesListInSiriFetched else {
            return 10
        }

        guard !isShowLoader else {
            return 1
        }
        if isSearch {
            return self.arraySearchAppliancesListInSiri[section].arraySiriAppliances.count
        }
        return applianceViewModel.arrayAppliancesListInSiri[section].arraySiriAppliances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.applianceViewModel.isAppliancesListInSiriFetched else {
            let cell = tableView.dequeueReusableCell(withIdentifier: OneStripeViewCell.identifier) as! OneStripeViewCell
            cell.startAnimating()
            return cell
        }
        //        if indexPath.section == 1 {
        //            return tableView.getDefaultCell()
        //
        //            // Default cells for displaying each device and its appliances
        //        } else {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SiriAppliancesTVCell.identifier) as! SiriAppliancesTVCell
        if isSearch {
            cell.cellConfig(data: self.arraySearchAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row])
        } else {
            cell.cellConfig(data: self.applianceViewModel.arrayAppliancesListInSiri[indexPath.section].arraySiriAppliances[indexPath.row])
        }
        return cell
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.applianceViewModel.isAppliancesListInSiriFetched else {
            return 0.001
        }
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func addUserActivityToButton(objAppliance: TargetApplianceDataModel, isTurnOn: Bool = false, isTurnOff: Bool = false, isFanSpeed: Bool = false, isRgb: Bool = false) {
        let activity = NSUserActivity(activityType:
                                        "activity\(objAppliance.id)")
        var strTitle = ""
        if isTurnOn {
            strTitle = "Turn On \(objAppliance.applianceName)"
        } else if isTurnOff  {
            strTitle = "Turn Off \(objAppliance.applianceName)"
        }  else if isFanSpeed  {
            strTitle = "Change speed of \(objAppliance.applianceName)"
        } else if isRgb  {
            strTitle = "Change colour of \(objAppliance.applianceName)"
        }
        activity.title = strTitle
        activity.suggestedInvocationPhrase = strTitle
        activity.userInfo = ["id": objAppliance.applianceId]
        activity.persistentIdentifier = "\(objAppliance.applianceId)"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.isEligibleForHandoff = true
        //        sender.userActivity = activity
        self.presentAddOpenBoardToSiriViewController(userActivity: activity, objectApplianceDetails: objAppliance, isTurnOn: isTurnOn, isTurnOff: isTurnOff, isFanSpeed: isFanSpeed, isRgb: isRgb)
        //        sender.shortcut = INShortcut(userActivity: activity)
    }
    
    func presentAddOpenBoardToSiriViewController(userActivity: NSUserActivity?, objectApplianceDetails: TargetApplianceDataModel, isTurnOn: Bool = false, isTurnOff: Bool = false, isFanSpeed: Bool = false, isRgb: Bool = false) {
        guard let userActivity = userActivity else { return }
        let intentBasic = ApplianceActionsBasicIntent()
        intentBasic.userId = APP_USER?.userId as NSNumber?
        intentBasic.applianceName = objectApplianceDetails.applianceName
        intentBasic.applianceId = objectApplianceDetails.applianceId as NSNumber
        intentBasic.endpointId = objectApplianceDetails.endpointId as NSNumber
        
        if isTurnOn {
            intentBasic.value = 1 as NSNumber
            intentBasic.actionTypeForIntent = .on
        } else if isTurnOff {
            intentBasic.value = 0 as NSNumber
            intentBasic.actionTypeForIntent = .off
        }
        let intentFanSpeed = ApplianceActionSpeedIntent()
        intentFanSpeed.userId = APP_USER?.userId as NSNumber?
        intentFanSpeed.applianceName = objectApplianceDetails.applianceName
        intentFanSpeed.applianceId = objectApplianceDetails.applianceId as NSNumber
        intentFanSpeed.endpointId = objectApplianceDetails.endpointId as NSNumber
        intentFanSpeed.actionTypeForIntent = .fanspeed
        intentFanSpeed.speedValue = self.getFanValueFromSpeedValue(value: objectApplianceDetails.speedOfFanForSiri)
        intentFanSpeed.speedValue = .unknown
        
        let intentRgb = ApplianceActionRgbIntent()
        intentRgb.userId = APP_USER?.userId as NSNumber?
        intentRgb.applianceName = objectApplianceDetails.applianceName
        intentRgb.applianceId = objectApplianceDetails.applianceId as NSNumber
        intentRgb.endpointId = objectApplianceDetails.endpointId as NSNumber
        intentRgb.action = objectApplianceDetails.targetAction as NSNumber
        intentRgb.value = objectApplianceDetails.rgbForSiri as NSNumber
        intentRgb.actionTypeForIntent = .rgb
        
        if isTurnOn{
            presentVoiceShortcutVcForBasic(action: .onOff, intent: intentBasic, objectApplianceDetails: objectApplianceDetails)
        } else if isTurnOff{
            presentVoiceShortcutVcForBasic(action: .onOff, intent: intentBasic, objectApplianceDetails: objectApplianceDetails)
        } else if isFanSpeed {
            presentVoiceShortcutVcForFanSpeed(action: .fan, intent: intentFanSpeed, objectApplianceDetails: objectApplianceDetails)
        } else if isRgb{
            presentVoiceShortcutVcForRgb(action: .rgb, intent: intentRgb, objectApplianceDetails: objectApplianceDetails)
        }
        //        intent.suggestedInvocationPhrase = "Execute \(objectSceneDetails.sceneName)"
    }
    
    private func donateIntent(intent: ApplianceActionsBasicIntent){
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: \(error.description)")
                } else {
                    print("Successfully donated interaction")
                }
            } else {
                print("Successfully donated interaction123")
            }
        }
    }
    
    func getFanValueFromSpeedValue(value: Int) -> EnumFanSpeedForIntent{
        if value > 0 {
            switch value {
            case 30:
                return .verySlow
            case 40:
                return .slow
            case 50:
                return .medium
            case 100:
                return .fast
            default:
                return .unknown
            }
        }
        
        
        
        
        return .unknown
    }
    
    func presentVoiceShortcutVcForBasic(action: EnumApplianceAction, intent: ApplianceActionsBasicIntent, objectApplianceDetails: TargetApplianceDataModel) {
        self.checkForVoiceShortcutsBasics(completion: {
            print(self.voiceShortcutsBasic)
            DispatchQueue.getMain(delay: 0.1) {
                print("Already exist")
                if let vShortcut = self.voiceShortcutsBasic.first(where: { ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId == intent.applianceId && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.actionTypeForIntent.rawValue == intent.actionTypeForIntent.rawValue && ($0.shortcut.intent as? ApplianceActionsBasicIntent)?.userId == intent.userId}) {
                    let viewController = INUIEditVoiceShortcutViewController(voiceShortcut: vShortcut)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.askSiriMainVc?.present(viewController, animated: true, completion: nil)
            }
                else {

                    if let shortcut = INShortcut(intent: intent) {
                    let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.askSiriMainVc?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    func presentVoiceShortcutVcForFanSpeed(action: EnumApplianceAction, intent: ApplianceActionSpeedIntent, objectApplianceDetails: TargetApplianceDataModel) {
        self.checkForVoiceShortcutsFanSpeed(completion: {
            print(self.voiceShortcutsFanSpeed)
            DispatchQueue.getMain(delay: 0.1) {
                    
                   if let vShortcut = self.voiceShortcutsFanSpeed.first(where: { ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.applianceId == intent.applianceId && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.actionTypeForIntent.rawValue == intent.actionTypeForIntent.rawValue && ($0.shortcut.intent as? ApplianceActionSpeedIntent)?.userId == intent.userId}) {
                       print("Already exist")
                    let viewController = INUIEditVoiceShortcutViewController(voiceShortcut: vShortcut)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.askSiriMainVc?.present(viewController, animated: true, completion: nil)
                } else {
                    if let shortcut = INShortcut(intent: intent) {
                        let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                            viewController.modalPresentationStyle = .overCurrentContext
                            viewController.delegate = self
                            self.askSiriMainVc?.present(viewController, animated: true, completion: nil)
                        
                    }
                }
            }
        })
    }
    
    func presentVoiceShortcutVcForRgb(action: EnumApplianceAction, intent: ApplianceActionRgbIntent, objectApplianceDetails: TargetApplianceDataModel) {
        self.checkForVoiceShortcutsRgb(completion: {
            print(self.voiceShortcutsRgb)
            DispatchQueue.getMain(delay: 0.1) {
                    if let vShortcut = self.voiceShortcutsRgb.first(where: { ($0.shortcut.intent as? ApplianceActionRgbIntent)?.applianceId == intent.applianceId && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.actionTypeForIntent.rawValue == intent.actionTypeForIntent.rawValue && ($0.shortcut.intent as? ApplianceActionRgbIntent)?.userId == intent.userId}) {
                        print("Already exist")
                    let viewController = INUIEditVoiceShortcutViewController(voiceShortcut: vShortcut)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.askSiriMainVc?.present(viewController, animated: true, completion: nil)
                } else {
                    if let shortcut = INShortcut(intent: intent) {
                        
                    let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.askSiriMainVc?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    func checkForVoiceShortcutsBasics(completion: (() -> Void)?) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcutsFromCenter, error) in
            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
                if voiceShortcutsFromCenter.count > 0 {
                    self.voiceShortcutsBasic.removeAll()
                    for shortc in voiceShortcutsFromCenter {
                        if ((shortc.shortcut.intent?.isEqual(ApplianceActionsBasicIntent.self)) != nil) {
                            self.voiceShortcutsBasic.append(shortc)
                        }
                    }
                }
                //                self.voiceShortcuts = voiceShortcutsFromCenter
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func checkForVoiceShortcutsFanSpeed(completion: (() -> Void)?) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcutsFromCenter, error) in
            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
                if voiceShortcutsFromCenter.count > 0 {
                    self.voiceShortcutsFanSpeed.removeAll()
                    for shortc in voiceShortcutsFromCenter {
                        if ((shortc.shortcut.intent?.isEqual(ApplianceActionSpeedIntent.self)) != nil) {
                            self.voiceShortcutsFanSpeed.append(shortc)
                        }
                    }
                }
                //                self.voiceShortcuts = voiceShortcutsFromCenter
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func checkForVoiceShortcutsRgb(completion: (() -> Void)?) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcutsFromCenter, error) in
            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
                if voiceShortcutsFromCenter.count > 0 {
                    self.voiceShortcutsRgb.removeAll()
                    for shortc in voiceShortcutsFromCenter {
                        if ((shortc.shortcut.intent?.isEqual(ApplianceActionSpeedIntent.self)) != nil) {
                            self.voiceShortcutsRgb.append(shortc)
                        }
                    }
                }
                //                self.voiceShortcuts = voiceShortcutsFromCenter
            } else {
                if let error = error as NSError? {
                    print(error.debugDescription)
                }
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
}

// MARK: - API Calls
extension AppliancesViewInAskSiriMainVc {
    func callGetAppliancesListAPI(isNextPageRequest: Bool = false, isPullToRefresh:Bool = false) {
        
        guard !self.tableViewApplianceList.isAPIstillWorking else { return } // Shouldn't me making another call if already running.
        
        if !isNextPageRequest && !isPullToRefresh{
            // API_LOADER.show(animated: true)
//            DispatchQueue.getMain {
                self.applianceViewModel.isAppliancesListInSiriFetched = false // show skeleton
                self.tableViewApplianceList.reloadData() // show skeleton
//            }
        }
        
        if isNextPageRequest && !isPullToRefresh {
            // API_LOADER.show(animated: true)
        }
        let param = applianceViewModel.getPageDict(isPullToRefresh)
        self.tableViewApplianceList.isAPIstillWorking = true
        
        applianceViewModel.callGetAppliancesListInSiriAPI(param: param) { [weak self] in
            if self?.isSearch == true {
                self?.clearSearch(isClosePressed: true)
            }
            // API_LOADER.dismiss(animated: true)
            if isPullToRefresh{
                self?.tableViewApplianceList.stopPullToRefresh()
            }

            DispatchQueue.getMain {
                self?.stopLoaders()
                self?.loadNoDataPlaceholder()
            }
        } failure: {  [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            // API_LOADER.dismiss(animated: true)
            self?.stopLoaders()
        }
    }
    
    func stopLoaders() {
        self.applianceViewModel.isAppliancesListInSiriFetched = true // hide skeleton
        self.tableViewApplianceList.isAPIstillWorking = false
        self.tableViewApplianceList.stopPullToRefresh()
        self.tableViewApplianceList.reloadData()
    }
    
    func excuteSceneApi(id:Int) {
        let param: [String: Any] = ["id":id]
        
        // API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .excuteScene(param),method: .put) { (parsingResponse) in
            // API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
            }
        }
    }
    
    func loadNoDataPlaceholder() {
        self.tableViewApplianceList.changeIconAndTitleAndSubtitle(title: "Groups", detailStr: "No groups have been created yet", icon: "noGroupFound")
        self.tableViewApplianceList.figureOutAndShowNoResults()
    }
}

extension AppliancesViewInAskSiriMainVc:  INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print(voiceShortcut)
        
        for i in 0..<applianceViewModel.arrayAppliancesListInSiri.count {
            for j in 0..<applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances.count {
                if (applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].applianceId as NSNumber) == (voiceShortcut?.shortcut.intent as? ApplianceActionsBasicIntent)?.applianceId {
                    if let intent = voiceShortcut?.shortcut.intent as? ApplianceActionsBasicIntent {
                        //                    if intent.actionTypeForIntent == .on {
                        if let row = applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent.firstIndex(where: { ($0.commandType == intent.actionTypeForIntent)}) {
                            applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].shortcutUUID = voiceShortcut!.identifier.uuidString
                            applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].isAddedToSiri = true
                        }
//                        self.donateIntent(intent: intent)
                        //                        applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[]
                        //                    }
                    }
                } else if (applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].applianceId as NSNumber) == (voiceShortcut?.shortcut.intent as? ApplianceActionSpeedIntent)?.applianceId {
                    if let intent = voiceShortcut?.shortcut.intent as? ApplianceActionSpeedIntent {
                        //                    if intent.actionTypeForIntent == .on {
                        if let row = applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent.firstIndex(where: { ($0.commandType == intent.actionTypeForIntent)}) {
                            applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].shortcutUUID = voiceShortcut!.identifier.uuidString
                            applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].isAddedToSiri = true
                        }
                        //                        applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[]
                        //                    }
                    }
                } else if (applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].applianceId as NSNumber) == (voiceShortcut?.shortcut.intent as? ApplianceActionRgbIntent)?.applianceId {
                    if let intent = voiceShortcut?.shortcut.intent as? ApplianceActionRgbIntent {
                        //                    if intent.actionTypeForIntent == .on {
                        if let row = applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent.firstIndex(where: { ($0.commandType == intent.actionTypeForIntent)}) {
                            applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].shortcutUUID = voiceShortcut!.identifier.uuidString
                            applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].isAddedToSiri = true
                        }
                    }
                }
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        print(deletedVoiceShortcutIdentifier)
        
        for i in 0..<applianceViewModel.arrayAppliancesListInSiri.count {
            for j in 0..<applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances.count {
                if let row = applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent.firstIndex(where: { (UUID(uuidString: $0.shortcutUUID) == deletedVoiceShortcutIdentifier)}) {
                    applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].shortcutUUID = UUID().uuidString
                    applianceViewModel.arrayAppliancesListInSiri[i].arraySiriAppliances[j].arrOperationsForIntent[row].isAddedToSiri = false
                }
            }
        }
    controller.dismiss(animated: true, completion: nil)
}

func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
    controller.dismiss(animated: true, completion: nil)
}
}


// MARK: Keyboard notifications
extension AppliancesViewInAskSiriMainVc {
    func addKeyboardNotifs(){
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.bottomTableConstraint.constant = keyboardSize.height - cueSize.bottomHeightOfSafeArea
//            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.bottomTableConstraint.constant = 0
//            self.view.layoutIfNeeded()
        }
    }
}
