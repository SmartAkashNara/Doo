//
//  SceneViewInSmartMainVc.swift
//  Doo-IoT
//
//  Created by Shraddha on 16/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
import Intents
import IntentsUI

class SceneViewInSmartMainVc: UIView {
    
    @IBOutlet weak var dooNoDataView: DooNoDataView_1!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView! {
        didSet {
            mainView.delegateOfSWWalert = self
        }
    }
    
    @IBOutlet weak var tableViewScenesList: SayNoForDataTableView! {
        didSet {
            tableViewScenesList.delegate = self
            tableViewScenesList.dataSource = self
        }
    }
    
    @IBOutlet weak var bottomTableConstraint: NSLayoutConstraint!
    
    // MARK: - Variable declaration
    var viewModel = SmartMainViewModel()
    var sceneViewModel = SceneViewModel()
    weak var smartMainVc: UIViewController?
    var voiceShortcuts: [INVoiceShortcut] = []
    var isSearch: Bool = false
    
    var arraySearchScenesListInSiri = [SRSceneDataModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addKeyboardNotifs()
        self.defaultConfig()
        self.addObserverToRefreshOnArrivalFromBg()
    }
    
    func addObserverToRefreshOnArrivalFromBg() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(apiCallAfterAppCameFromBg),
                                               name: NSNotification.Name(rawValue: REFRESH_SCENE_LIST_TO_CHECK_SIRI_SHORTCUTS),
                                               object: nil)
    }
    
    @objc func apiCallAfterAppCameFromBg() {
        DispatchQueue.getMain(delay: 0.1) {
            
            if self.isSearch {
                for i in 0..<self.arraySearchScenesListInSiri.count {
            INVoiceShortcutCenter.shared.getAllVoiceShortcuts(completion: { (voiceShortcutsFromCenter, error) in
                if let voiceShortcuts = voiceShortcutsFromCenter {
                    
                    if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? SceneExecutionIntent)?.sceneId as? Int == self.arraySearchScenesListInSiri[i].id && ($0.shortcut.intent as? SceneExecutionIntent)?.userId as? Int == APP_USER?.userId}) {
                        self.arraySearchScenesListInSiri[i].isAddedToSiri = true
                        self.arraySearchScenesListInSiri[i].shortcutUUID = shortcutImnt.identifier.uuidString
                    } else {
                        self.arraySearchScenesListInSiri[i].isAddedToSiri = false
                        self.arraySearchScenesListInSiri[i].shortcutUUID = UUID().uuidString
                    }
                } else {
                    if let error = error as NSError? {
                        print(error.debugDescription)
                    }
                }
            })
                }
            } else {
                for i in 0..<self.sceneViewModel.arraySceneList.count {
            INVoiceShortcutCenter.shared.getAllVoiceShortcuts(completion: { (voiceShortcutsFromCenter, error) in
                if let voiceShortcuts = voiceShortcutsFromCenter {
                    
                    if let shortcutImnt = voiceShortcuts.first(where: { ($0.shortcut.intent as? SceneExecutionIntent)?.sceneId as? Int == self.sceneViewModel.arraySceneList[i].id && ($0.shortcut.intent as? SceneExecutionIntent)?.userId as? Int == APP_USER?.userId}) {
                        self.sceneViewModel.arraySceneList[i].isAddedToSiri = true
                        self.sceneViewModel.arraySceneList[i].shortcutUUID = shortcutImnt.identifier.uuidString
                    } else {
                        self.sceneViewModel.arraySceneList[i].isAddedToSiri = false
                        self.sceneViewModel.arraySceneList[i].shortcutUUID = UUID().uuidString
                    }
                } else {
                    if let error = error as NSError? {
                        print(error.debugDescription)
                    }
                }
            })
                }
            }
            
            self.tableViewScenesList.reloadData()
    }
        
    }
    
    func defaultConfig(viewModel: SmartMainViewModel? = nil, viewController: UIViewController? = nil) {
        if let viewModel = viewModel, let viewController = viewController {
            self.viewModel = viewModel
            self.sceneViewModel.isFromSiri = viewModel.isFromSiri
            self.viewModel.selectdEnumSmartMenuType = .schedule
            self.smartMainVc = viewController
        }
        self.callGetSceneListAPI()
        self.configureTableView()
    }
    
    func searchConfig(viewController: UIViewController? = nil, strSearch: String) {
        if let viewController = viewController {
            self.smartMainVc = viewController
        }
        self.getSearchArrayContains(strSearch)
    }
    
    func clearSearch(isClosePressed: Bool) {
        if isClosePressed {
            if let vc = (self.smartMainVc as? AskSiriMainViewController) {
                vc.searchBar.text = ""
                vc.searchBar.resignFirstResponder()
                self.arraySearchScenesListInSiri.removeAll()
                
                UIView.animate(withDuration: 0.2, animations: {
                    vc.rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
                    vc.viewNavigationBar.layoutIfNeeded()
                }) { (_) in
                }
                
            }
        }
        DispatchQueue.getMain(delay: 0.1) {
        self.arraySearchScenesListInSiri.removeAll()
        self.isSearch = false
        self.tableViewScenesList.reloadData()
        }
    }
    
    func getSearchArrayContains(_ text : String) {
        
        let arrayDummy = self.sceneViewModel.arraySceneList
        self.arraySearchScenesListInSiri.removeAll()
        let results = arrayDummy.filter({
            $0.sceneName.lowercased().contains("\(text.lowercased())")
        })
        self.arraySearchScenesListInSiri = results
//        arrayDummy.forEach({ (siriDataModel) in
//            let results = siriDataModel.arrayTargetApplience.filter { $0.applianceName.lowercased().contains("\(text.lowercased())") }
//            var arraySiriAppliances = [TargetApplianceDataModel]()
//            let dataModel = SiriApplianceDataModel(param: "")
//            dataModel.groupDetail = siriDataModel.groupDetail
//            arraySiriAppliances = results
//            dataModel.arraySiriAppliances = arraySiriAppliances
//            if results.count > 0 {
//                self.arraySearchScenesListInSiri.append(dataModel)
//            }
//        })
        isSearch = true
        tableViewScenesList.reloadData()
    }
    
    func setDummyData() {
        self.sceneViewModel.loadStaticData()
    }
    
    func configureTableView() {        
        tableViewScenesList.bounces = true
        tableViewScenesList.registerCellNib(identifier: OneStripeViewCell.identifier)
        tableViewScenesList.registerCellNib(identifier: SmartHomeSceneTVCell.identifier)
        tableViewScenesList.registerCellNib(identifier: SmartHomeSectionTVCell.identifier)
        tableViewScenesList.addRefreshControlForPullToRefresh {
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.tableViewScenesList.stopPullToRefresh()
                self.sceneViewModel.loadStaticData()
                self.loadNoDataPlaceholder()
                return
            }
            self.callGetSceneListAPI(isPullToRefresh: true)
        }
        tableViewScenesList.sayNoSection = .noSceneListFound("SCENES")
        tableViewScenesList.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 15, right: 0)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewScenesList.tableHeaderView = v
        tableViewScenesList.reloadData()
    }
    
    func loadNoDataPlaceholder() {
        self.tableViewScenesList.changeIconAndTitleAndSubtitle(title: "SCENES", detailStr: "No scenes have been created yet", icon: "noDataScene")
        self.tableViewScenesList.figureOutAndShowNoResults()
    }
    
    // when object gets removed from its detail... 
    func removeObjectAndReload(id:Int){
        self.sceneViewModel.removeSelectedObject(id: id)
        self.tableViewScenesList.reloadData()
        loadNoDataPlaceholder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension SceneViewInSmartMainVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.sceneViewModel.isScenesFetched else {
            return 10
        }
        
        if isSearch {
            return self.arraySearchScenesListInSiri.count
        }
        else {
            if (self.sceneViewModel.getTotalElements > self.sceneViewModel.arraySceneList.count)
                && self.sceneViewModel.arraySceneList.count != 0 {
                
                return sceneViewModel.arraySceneList.count + 1
            }else{
                return sceneViewModel.arraySceneList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.sceneViewModel.isScenesFetched else {
            let cell = tableView.dequeueReusableCell(withIdentifier: OneStripeViewCell.identifier) as! OneStripeViewCell
            cell.startAnimating()
            return cell
        }
        guard self.sceneViewModel.arraySceneList.indices.contains(indexPath.row) else {
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "identifier")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "identifier")
            }
            if let activityView = cell.contentView.viewWithTag(102) as? UIActivityIndicatorView {
                activityView.startAnimating()
            }else{
                let activityIndicator = UIActivityIndicatorView.init(style: .medium)
                activityIndicator.tag = 102
                activityIndicator.center = CGPoint.init(x: tableView.center.x, y: 14)
                activityIndicator.startAnimating()
                cell.contentView.addSubview(activityIndicator)
            }
            cell.backgroundColor = .clear
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSceneTVCell.identifier) as! SmartHomeSceneTVCell
        cell.isFromSiri = viewModel.isFromSiri
        if isSearch {
            cell.cellConfigForSceneList(dataModel: self.arraySearchScenesListInSiri[indexPath.row])
        } else {
            cell.cellConfigForSceneList(dataModel: sceneViewModel.arraySceneList[indexPath.row])
        }
        
        cell.buttonExecute.tag = indexPath.row
        cell.buttonExecute.addTarget(self, action: #selector(cellButtonExcuteClicked(sender:)), for: .touchUpInside)
        
        cell.buttonAddToSiri.tag = indexPath.row
        cell.buttonAddToSiri.addTarget(self, action: #selector(addUserActivityToButton(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func cellButtonExcuteClicked(sender:UIButton) {
        excuteSceneApi(id: sceneViewModel.arraySceneList[sender.tag].id)
    }
    
    @IBAction func addUserActivityToButton(_ sender: UIButton) {
        if isSearch {
            let activity = NSUserActivity(activityType:
                                            "activity\(self.arraySearchScenesListInSiri[sender.tag].id)")
            activity.title = "Execute \(self.arraySearchScenesListInSiri[sender.tag].sceneName)"
            activity.suggestedInvocationPhrase = "Execute \(self.arraySearchScenesListInSiri[sender.tag].sceneName)"
            activity.userInfo = ["id": self.arraySearchScenesListInSiri[sender.tag].id]
            activity.persistentIdentifier = "\(self.arraySearchScenesListInSiri[sender.tag].id)"
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForHandoff = true
            //        sender.userActivity = activity
            self.presentAddOpenBoardToSiriViewController(userActivity: activity, objectSceneDetails: self.arraySearchScenesListInSiri[sender.tag])
        } else {
            let activity = NSUserActivity(activityType:
                                            "activity\(sceneViewModel.arraySceneList[sender.tag].id)")
            activity.title = "Execute \(sceneViewModel.arraySceneList[sender.tag].sceneName)"
            activity.suggestedInvocationPhrase = "Execute \(sceneViewModel.arraySceneList[sender.tag].sceneName)"
            activity.userInfo = ["id": sceneViewModel.arraySceneList[sender.tag].id]
            activity.persistentIdentifier = "\(sceneViewModel.arraySceneList[sender.tag].id)"
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForHandoff = true
            //        sender.userActivity = activity
            self.presentAddOpenBoardToSiriViewController(userActivity: activity, objectSceneDetails: sceneViewModel.arraySceneList[sender.tag])
            //        sender.shortcut = INShortcut(userActivity: activity)
        }
    }
    
    func presentAddOpenBoardToSiriViewController(userActivity: NSUserActivity?, objectSceneDetails: SRSceneDataModel) {
        guard let userActivity = userActivity else { return }
        let intent = SceneExecutionIntent()
        intent.userId = APP_USER?.userId as NSNumber?
        intent.sceneName = objectSceneDetails.sceneName
        intent.sceneId = objectSceneDetails.id as NSNumber
        //        intent.suggestedInvocationPhrase = "Execute \(objectSceneDetails.sceneName)"
        self.checkForVoiceShortcuts(completion: {
            print(self.voiceShortcuts)
            DispatchQueue.getMain(delay: 0.1) {
                print("Already exist")
                if let vShortcut = self.voiceShortcuts.first(where: { ($0.shortcut.intent as? SceneExecutionIntent)?.sceneId == intent.sceneId && ($0.shortcut.intent as? SceneExecutionIntent)?.userId == intent.userId}) {
                    let viewController = INUIEditVoiceShortcutViewController(voiceShortcut: vShortcut)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.smartMainVc?.present(viewController, animated: true, completion: nil)
                } else {
                    let shortcut = INShortcut(intent: intent)
                    let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut!)
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.delegate = self
                    self.smartMainVc?.present(viewController, animated: true, completion: nil)
                }
            }
        })
    }
    
    func checkForVoiceShortcuts(completion: (() -> Void)?) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcutsFromCenter, error) in
            if let voiceShortcutsFromCenter = voiceShortcutsFromCenter {
                self.voiceShortcuts = voiceShortcutsFromCenter
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.isFromSiri {
            return 0
        }
        return 42
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}

// MARK: - UITableViewDelegate
extension SceneViewInSmartMainVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        if self.viewModel.isFromSiri {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSectionTVCell.identifier) as! SmartHomeSectionTVCell
        cell.cellConfig(title: SmartMainViewModel.EnumSmartMenuType.scenes.title.uppercased())
        cell.buttonPlus.tag = section
        cell.buttonPlus.addTarget(self, action: #selector(cellAddDeviceClicked(sender:)), for: .touchUpInside)
        cell.buttonDots.tag = section
        cell.buttonDots.addTarget(self, action: #selector(cellButtonMoreClicked(sender:)), for: .touchUpInside)
        cell.buttonDots.isHidden = true
        return cell
    }
    
    @objc func cellButtonMoreClicked(sender:UIButton){
        debugPrint("cellButtonMoreClicked...")
    }
    
    @objc func cellAddDeviceClicked(sender:UIButton){
        /*
         if SMARTRULE_OFFLINE_LOAD_ENABLE{
         CustomAlertView.init(title: "Comming soon").showForWhile(animated: true)
         return
         }*/
        guard let selectSceneListVC = UIStoryboard.smart.selectSceneListVC else { return }
        selectSceneListVC.hidesBottomBarWhenPushed = true
        selectSceneListVC.objSceneViewInMainVC = self
        self.smartMainVc?.navigationController?.pushViewController(selectSceneListVC, animated: true)
    }
    
    // This function will be called when any scene will be added or updated...
    func addOrUpdateScene(objectModel: SRSceneDataModel){
        if let index = self.sceneViewModel.arraySceneList.firstIndex(where: {$0.id == objectModel.id}){
            self.sceneViewModel.arraySceneList[index] = objectModel
        }else{
            self.sceneViewModel.arraySceneList.insert(objectModel, at: 0) // Insert at first.
        }
        self.tableViewScenesList.reloadData()
        self.tableViewScenesList.figureOutAndShowNoResults()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
         if SMARTRULE_OFFLINE_LOAD_ENABLE{
         CustomAlertView.init(title: "Comming soon").showForWhile(animated: true)
         return
         }*/
        guard let smartRuleDetailVC = UIStoryboard.smart.smartRuleDetailVC else { return }
        smartRuleDetailVC.enumSmartMenuType = .scenes
        smartRuleDetailVC.hidesBottomBarWhenPushed = true
        smartRuleDetailVC.dataModdel = (nil, nil, self.sceneViewModel.arraySceneList[indexPath.row])
        if !isSearch {
        self.smartMainVc?.navigationController?.pushViewController(smartRuleDetailVC, animated: true)
        }
    }
}

// MARK: - internet & something went wrong work
extension SceneViewInSmartMainVc: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        self.callGetSceneListAPI(isNextPageRequest: false, isPullToRefresh: false)
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}

// MARK: - DooNoDataView_1Delegate
extension SceneViewInSmartMainVc: DooNoDataView_1Delegate {
    func showNoEnterpriseView() {
        self.tableViewScenesList.isScrollEnabled = false
        self.dooNoDataView.initSetup(.noEnterprises)
        self.dooNoDataView.allocateView()
        self.dooNoDataView.delegate = self
    }
    func dismissNoEnterpriseView() {
        self.dooNoDataView.delegate = nil
        self.tableViewScenesList.isScrollEnabled = true
        self.dooNoDataView.dismissView()
    }
}

// MARK: - UIScrollViewDelegate
extension SceneViewInSmartMainVc: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if sceneViewModel.getTotalElements > sceneViewModel.getAvailableElements &&
                !tableViewScenesList.isAPIstillWorking {
                self.callGetSceneListAPI(isNextPageRequest: true, isPullToRefresh: false)
            }
        }
    }
}

// MARK: - API Calls
extension SceneViewInSmartMainVc {
    func callGetSceneListAPI(isNextPageRequest: Bool = false, isPullToRefresh:Bool = false) {
        
        guard !self.tableViewScenesList.isAPIstillWorking else { return } // Shouldn't me making another call if already running.
        
        if !isNextPageRequest && !isPullToRefresh{
            // API_LOADER.show(animated: true)
            self.sceneViewModel.isScenesFetched = false // show skeleton
            self.tableViewScenesList.reloadData() // show skeleton
        }
        
        if isNextPageRequest && !isPullToRefresh {
            // API_LOADER.show(animated: true)
        }
        let param = sceneViewModel.getPageDict(isPullToRefresh)
        self.tableViewScenesList.isAPIstillWorking = true
        
        sceneViewModel.callGetSceneListAPI(param: param) { [weak self] in
            if self?.isSearch == true {
                self?.clearSearch(isClosePressed: true)
            }
            // API_LOADER.dismiss(animated: true)
            if isPullToRefresh{
                self?.tableViewScenesList.stopPullToRefresh()
            }
            self?.stopLoaders()
            self?.loadNoDataPlaceholder()
            
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
        self.sceneViewModel.isScenesFetched = true // hide skeleton
        self.tableViewScenesList.isAPIstillWorking = false
        self.tableViewScenesList.stopPullToRefresh()
        self.tableViewScenesList.reloadData()
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
}

extension SceneViewInSmartMainVc:  INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        print(voiceShortcut)
        for i in 0..<sceneViewModel.arraySceneList.count {
            
            if (sceneViewModel.arraySceneList[i].id as NSNumber) == ((voiceShortcut?.shortcut.intent as? SceneExecutionIntent)?.sceneId) {
                sceneViewModel.arraySceneList[i].isAddedToSiri = true
                sceneViewModel.arraySceneList[i].shortcutUUID = voiceShortcut!.identifier.uuidString
                break
            }
        }
        self.tableViewScenesList.reloadData()
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
        self.sceneViewModel.arraySceneList.removeAll(where: { UUID(uuidString: $0.shortcutUUID) == deletedVoiceShortcutIdentifier})
        self.tableViewScenesList.reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: Keyboard notifications
extension SceneViewInSmartMainVc {
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
