//
//  SmartRuleDetailViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 12/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class SmartRuleDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var buttonFavourite: UIButton!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewDetail: UITableView!
    
    var viewModel = SmartRuleDetailViewModel()
    var dataModdel: (bindingRule: SRBindingRuleDataModel?, scheduler: SRSchedulerDataModel?, scene: SRSceneDataModel?)? = nil
    var isLoad = false
    var enumSmartMenuType : SmartMainViewModel.EnumSmartMenuType = .bindingRule
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTableView()
        isLoad = true
        
        switch enumSmartMenuType {
        case .bindingRule:
            viewModel.preparedFirstSectionBindingRuleData(srBindingRuleDataModel: dataModdel?.bindingRule)
        case .schedule:
            viewModel.preparedFirstSectionSchedulerData(smartDataModel: dataModdel?.scheduler)
        case .scenes:
            setFavouriteIconOnButton()
            buttonFavourite.isHidden = false
            buttonFavourite.addTarget(self, action: #selector(buttonFavouriteClick), for: .touchUpInside)
            viewModel.preparedFirstSectionSceneData(smartDataModel: dataModdel?.scene)
        }
    }
    
    func setFavouriteIconOnButton(){
        if let sceneModel = dataModdel?.scene{
            buttonFavourite.setImage(UIImage.init(named: sceneModel.favouriteIcon), for: .normal)
        }else{
            buttonFavourite.setImage(UIImage.init(named: "imgHeartFavouriteUnfill"), for: .normal)
        }
    }
    
    @objc func buttonFavouriteClick(){
        callSceneToggleFavouriteAPI(status: !(dataModdel?.scene?.isFavouriteScene ?? false))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isLoad {
            loadNavigationBar()
            tableViewDetail.reloadData()
        }
        isLoad = true
    }
}

// MARK: - User defined methods
extension SmartRuleDetailViewController {
    func configureTableView() {
        tableViewDetail.dataSource = self
        tableViewDetail.delegate = self
        tableViewDetail.registerCellNib(identifier: DooHeaderDetail_1TVCell.identifier, commonSetting: true)
        tableViewDetail.registerCellNib(identifier: DooDetail_1TVCell.identifier)
        tableViewDetail.registerCellNib(identifier: SeparatorFooterTVCell.identifier)
        tableViewDetail.registerCellNib(identifier: SmartTargetApplianceTVCell.identifier)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewDetail.tableHeaderView = viewNavigationBarDetail
        tableViewDetail.estimatedRowHeight = 50
        tableViewDetail.addBounceViewAtTop()
        tableViewDetail.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewDetail.sectionHeaderHeight = 0
        tableViewDetail.separatorStyle = .none
        tableViewDetail.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        
        buttonBack.addTarget(self, action: #selector(self.backActionListener(sender:)), for: .touchUpInside)
        buttonMenu.addTarget(self, action: #selector(self.menuActionListener(sender:)), for: .touchUpInside)
        
        if dataModdel?.scheduler?.viewEditMode == .viewEdit || dataModdel?.scene?.viewEditMode == .viewEdit {
            buttonMenu.isHidden = false
        } else {
            buttonMenu.isHidden = true
        }
    }
    
    func loadNavigationBar() {
        var title = ""
        switch enumSmartMenuType {
        case .scenes:
            title = localizeFor("scene")
        default:
            title = enumSmartMenuType.title.capitalized
        }
        let str  = viewModel.arrayOfApplienceList.count > 1 ? localizeFor("target_appliances").lowercased() : localizeFor("target_appliance").lowercased()
        let subTitle = "\(viewModel.arrayOfApplienceList.count) \(str)"
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: subTitle)
        navigationTitle.text = title
    }
}

// MARK: - UITableViewDataSource
extension SmartRuleDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SmartRuleDetailViewModel.EnumSection.deviceDetail.index:
            return viewModel.firstSectionData.count
        case SmartRuleDetailViewModel.EnumSection.appliances.index:
            return viewModel.arrayOfApplienceList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SmartRuleDetailViewModel.EnumSection.deviceDetail.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: DooDetail_1TVCell.identifier, for: indexPath) as! DooDetail_1TVCell
            cell.cellConfig(data: viewModel.firstSectionData[indexPath.row])
            cell.selectionStyle = .none
            return cell
            
        case SmartRuleDetailViewModel.EnumSection.appliances.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: SmartTargetApplianceTVCell.identifier, for: indexPath) as! SmartTargetApplianceTVCell
            cell.cellConfig(dataModel: viewModel.arrayOfApplienceList[indexPath.row])
            return cell
        default:
            return tableView.getDefaultCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension SmartRuleDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.arrayOfApplienceList.count == 0 ? 0.001 : DooHeaderDetail_1TVCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooHeaderDetail_1TVCell.identifier) as! DooHeaderDetail_1TVCell
        cell.cellConfig(title: viewModel.sections[section])
        return viewModel.arrayOfApplienceList.count == 0 ? nil : cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case SmartRuleDetailViewModel.EnumSection.deviceDetail.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: SeparatorFooterTVCell.identifier)
            return cell
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case SmartRuleDetailViewModel.EnumSection.deviceDetail.index:
            return 10
        default:
            return 0.001
        }
    }
}

// MARK: - Actions
extension SmartRuleDetailViewController {
    @objc func backActionListener(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func menuActionListener(sender: UIButton) {
        var enableDisble = ""
        var editText = ""
        var deleteText = ""
        var alertMsgEnableDisable = ""
        var alertMsgDelete = ""
        var status = false
        var id = 0
        switch enumSmartMenuType {
        case .bindingRule:
            guard let dataModel = self.dataModdel?.bindingRule else {
                return
            }
            enableDisble = !dataModel.enable ? localizeFor("enable_binding_Rule") : localizeFor("disable_binding_Rule")
            editText = localizeFor("edit_binding_Rule")
            deleteText = localizeFor("delete_binding_Rule")
            alertMsgEnableDisable = !dataModel.enable ? "Are you sure you want to Enable rule?" : "Are you sure you want to Disable rule?"
            alertMsgDelete = localizeFor("are_you_sure_want_to_delete_this_binding_rule")
            status = !dataModel.enable
            id = dataModel.id
        case .schedule:
            guard let dataModel = self.dataModdel?.scheduler else {
                return
            }
            enableDisble = !dataModel.enable ? localizeFor("enable_schedule") : localizeFor("disable_schedule")
            editText = localizeFor("edit_schedule")
            deleteText = localizeFor("delete_schedule")
            alertMsgEnableDisable = !dataModel.enable ? "Are you sure you want to Enable rule?" : "Are you sure you want to Disable rule?"
            alertMsgDelete = localizeFor("are_you_sure_want_to_delete_this_schedule")
            status = !dataModel.enable
            id = dataModel.id
            
        case .scenes:
            guard let dataModel = self.dataModdel?.scene else {
                return
            }
            enableDisble = ""//!dataModel.enable ? localizeFor("enable_scene") : localizeFor("disable_scene") here we set empty becouse dont want to show enable disable option in scene
            editText = localizeFor("edit_scene")
            deleteText = localizeFor("delete_scene")
            alertMsgEnableDisable = ""
            alertMsgEnableDisable = !dataModel.enable ? "Are you sure you want to Enable rule?" : "Are you sure you want to Disable rule?"
            alertMsgDelete = localizeFor("are_you_sure_want_to_delete_this_scene")
            status = !dataModel.enable
            id = dataModel.id
        }
        
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption(
                title: enableDisble.capitalized,
                color: UIColor.blueHeading, action: {
                    if SMARTRULE_OFFLINE_LOAD_ENABLE {
                        CustomAlertView.init(title: "Comming soon").showForWhile(animated: true)
                        return
                    }
                    
                    if SMARTRULE_OFFLINE_LOAD_ENABLE{
                        CustomAlertView.init(title: "Coming soon").showForWhile(animated: true)
                        return
                    }
                    switch self.enumSmartMenuType {
                    case .bindingRule:
                        
                        //                        self.showEnableDisableRuleAction(titleMsg: alertMsgEnableDisable, status: status, id: id)
                        self.callEnableDisableBindingRuleAPI(status: status, id: id) { (status) in
                            self.dataModdel?.bindingRule?.enable = status
                        }
                        
                    case .schedule:
                        //                        self.showEnableDisableRuleAction(titleMsg: alertMsgEnableDisable, status: status, id: id)
                        self.callEnableDisableSchedulerAPI(status: status, id: id) { (status) in
                            self.dataModdel?.scheduler?.enable = status
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                        // here enable and disbale scene feature hidden
                        /*
                         case .scenes:
                         self.callEnableDisableSceneAPI(status: status, id: id) { (status) in
                         self.dataModdel?.scene?.enable = status
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                         self.navigationController?.popViewController(animated: true)
                         }
                         }
                         break
                         */
                    default:break
                    }
                })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption(
                title: editText.capitalized,
                color: UIColor.blueHeading, action: {
                    self.redirectEditScreen()
                })
            
            let action3 = DooBottomPopupActions_1ViewController.PopupOption(
                title: deleteText.capitalized,
                color: UIColor.textFieldErrorColor, action: {
                    self.showDeleteAlert(titleMsg: alertMsgDelete)
                })
            
            var arrayOfActions = [action1, action2, action3]
            if enableDisble.isEmpty{
                // here removed enable disble for scene use case
                arrayOfActions.remove(at: 0)
            }
            actionsVC.popupType = .generic(localizeFor("quick_actions"), "", arrayOfActions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
    
    // redirection edit screen
    func redirectEditScreen(){
        switch enumSmartMenuType {
        case .bindingRule:
            guard let addEditBindingRuleVC = UIStoryboard.smart.addEditBindingRuleVC else { return }
            addEditBindingRuleVC.didAddedOrUpdatedSmartRule = { dataModel in
                guard let objDataModel = dataModel else { return }
                
                // current screen updated data model
                self.updateBindingRuleAndUpdateArrayOfTargets(objModel: objDataModel)
                
                // smart home update data model
                //                if let smartHomeVC = self.getSmartHomeMainVC(){
                //                    smartHomeVC.addOrUpdateBindingRule(objectModel: objDataModel)
                //                }
            }
            addEditBindingRuleVC.bindingRuleDataModel = self.dataModdel?.bindingRule
            self.navigationController?.pushViewController(addEditBindingRuleVC, animated: true)
            
        case .scenes:
            guard let addEditSceneVC = UIStoryboard.smart.addEditSceneVC else { return}
            addEditSceneVC.isEditFlow = true
            addEditSceneVC.sceneDataModel = self.dataModdel?.scene
            addEditSceneVC.didAddedOrUpdatedScene = { dataModel in
                guard let objDataModel = dataModel else { return }
                // current screen updated data model
                self.updateSceneAndUpdateArrayOfTargets(objModel: objDataModel)
                
                // smart home update data model
                if let smartSceneVC = self.getSmartSceneVC(){
                    smartSceneVC.addOrUpdateScene(objectModel: objDataModel)
                }
            }
            addEditSceneVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addEditSceneVC, animated: true)
            
        case .schedule:
            guard let addEditSchedulerVC = UIStoryboard.smart.addEditSchedulerVC else { return }
            addEditSchedulerVC.didAddedOrUpdatedScheduler = { dataModel in
                guard let objDataModel = dataModel else { return }
                
                // current screen updated data model
                self.updateSchedulerRuleAndUpdateArrayOfTargets(objModel: objDataModel)
                
                // smart home update data model
                if let smartScheduleVC = self.getSmartScheduleVC(){
                    smartScheduleVC.addOrUpdateScheduler(objectModel: objDataModel)
                }
            }
            addEditSchedulerVC.schedulerDataModel = self.dataModdel?.scheduler
            self.navigationController?.pushViewController(addEditSchedulerVC, animated: true)
        }
    }
    
    // get smart scene view in main vc
    func getSmartSceneVC() -> SceneViewInSmartMainVc? {
        let count = self.navigationController?.viewControllers.count ?? 0
        if count > 1 {
            if let smartMainVc = self.navigationController?.viewControllers[0] as? SmartMainViewController {
                for listView in smartMainVc.scrollViewMain.subviews {
                    if let slideView = listView as? SceneViewInSmartMainVc {
                        return slideView
                    }
                }
            }
        }
        return nil
    }
    
    // get smart schedule view in main vc
    func getSmartScheduleVC() -> ScheduleViewInSmartMainVc? {
        let count = self.navigationController?.viewControllers.count ?? 0
        if count > 1 {
            if let smartMainVc = self.navigationController?.viewControllers[0] as? SmartMainViewController {
                for listView in smartMainVc.scrollViewMain.subviews {
                    if let slideView = listView as? ScheduleViewInSmartMainVc {
                        return slideView
                    }
                }
            }
        }
        return nil
    }
    
    func updateSceneAndUpdateArrayOfTargets(objModel: SRSceneDataModel) {
        if let index = self.viewModel.sections.firstIndex(where: {$0 == "\(localizeFor("target_appliance")) (\(self.viewModel.arrayOfApplienceList.count))"}){
            self.viewModel.arrayOfApplienceList = objModel.arrayTargetApplience
            self.viewModel.sections[index] = "\(localizeFor("target_appliance")) (\(objModel.arrayTargetApplience.count))"
        }
        
        viewModel.firstSectionData.removeAll()
        viewModel.preparedFirstSectionSceneData(smartDataModel: objModel)
        self.dataModdel?.scene = objModel
        setFavouriteIconOnButton()
        self.tableViewDetail.reloadData()
    }
    
    func updateBindingRuleAndUpdateArrayOfTargets(objModel:SRBindingRuleDataModel) {
        if let index = self.viewModel.sections.firstIndex(where: {$0 == "\(localizeFor("target_appliance")) (\(self.viewModel.arrayOfApplienceList.count))"}){
            self.viewModel.arrayOfApplienceList = objModel.arrayTargetApplience
            self.viewModel.sections[index] = "\(localizeFor("target_appliance")) (\(objModel.arrayTargetApplience.count))"
        }
        viewModel.firstSectionData.removeAll()
        viewModel.preparedFirstSectionBindingRuleData(srBindingRuleDataModel: objModel)
        self.dataModdel?.bindingRule = objModel
        self.tableViewDetail.reloadData()
    }
    
    func updateSchedulerRuleAndUpdateArrayOfTargets(objModel: SRSchedulerDataModel) {
        if let index = self.viewModel.sections.firstIndex(where: {$0 == "\(localizeFor("target_appliance")) (\(self.viewModel.arrayOfApplienceList.count))"}){
            self.viewModel.arrayOfApplienceList = objModel.arrayTargetApplience
            self.viewModel.sections[index] = "\(localizeFor("target_appliance")) (\(objModel.arrayTargetApplience.count))"
        }
        viewModel.firstSectionData.removeAll()
        viewModel.preparedFirstSectionSchedulerData(smartDataModel: objModel)
        self.dataModdel?.scheduler = objModel
        self.tableViewDetail.reloadData()
    }
    
    func showEnableDisableRuleAction(titleMsg:String, status: Bool,id:Int) {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let enableDisableAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: status ? cueAlert.Button.enable : cueAlert.Button.disable, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    
                    if SMARTRULE_OFFLINE_LOAD_ENABLE{
                        CustomAlertView.init(title: "Coming soon").showForWhile(animated: true)
                        return
                    }
                    switch self.enumSmartMenuType {
                    case .bindingRule:
                        self.callEnableDisableBindingRuleAPI(status: status, id: id) { (status) in
                            self.dataModdel?.bindingRule?.enable = status
                        }
                    case .schedule:
                        self.callEnableDisableSchedulerAPI(status: status, id: id) { (status) in
                            self.dataModdel?.scheduler?.enable = status
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    default: break
                    }
                }
                let title = titleMsg
                alertVC.setAlert(alertTitle: title, leftButton: cancelAction, rightButton: enableDisableAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    func showDeleteAlert(titleMsg:String) {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.delete, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    
                    if SMARTRULE_OFFLINE_LOAD_ENABLE{
                        CustomAlertView.init(title: "Comming soon").showForWhile(animated: true)
                        return
                    }
                    switch self.enumSmartMenuType {
                    case .bindingRule:
                        self.callDeleteBindingRuleAPI()
                    case .schedule:
                        self.callDeleteScheduleAPI()
                    case .scenes:
                        self.callDeleteSceneAPI()
                    }
                }
                let title = titleMsg
                alertVC.setAlert(alertTitle: title, leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SmartRuleDetailViewController: UIScrollViewDelegate {
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

// MARK: - UIGestureRecognizerDelegate
extension SmartRuleDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: Service Scheduler
extension SmartRuleDetailViewController {
    // delete schedule
    func callDeleteScheduleAPI() {
        guard let id = dataModdel?.scheduler?.id else { return }
        API_SERVICES.callAPI(path: .deleteSchedule(["id": id]),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                self.getSmartScheduleVC()?.removeObjectAndReload(id: id)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //============================ Enable Disble Scheduler  ============================
    func callEnableDisableSchedulerAPI(status: Bool,id:Int, complitionBlock: @escaping (Bool)->()) {
        API_LOADER.show(animated: true)
        let param: [String: Any] = ["status":status ? 1 : 2, "id":id]
        API_SERVICES.callAPI(path: .scheduleEnableDisable(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                self.dataModdel?.scheduler?.enable = status
                self.getSmartScheduleVC()?.addOrUpdateScheduler(objectModel: (self.dataModdel?.scheduler)!)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                complitionBlock(status)
            }
        }
    }
}

// MARK: Service Bindig Rule
extension SmartRuleDetailViewController {
    //============================ delete binding rule  ============================
    func callDeleteBindingRuleAPI() {
        guard let id = dataModdel?.bindingRule?.id else { return }
        API_SERVICES.callAPI(path: .deleteBindingRule(["id": id]),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                // self.getSmartHomeMainVC()?.removeObjectAndReload(id: id)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //============================ Enable Disble Binding rule  ============================
    func callEnableDisableBindingRuleAPI(status: Bool,id:Int, complitionBlock: @escaping (Bool)->()) {
        API_LOADER.show(animated: true)
        let param: [String: Any] = ["status":status ? 1 : 2, "id":id]
        API_SERVICES.callAPI(path: .bindingRuleEnableDisable(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                complitionBlock(status)
            }
        }
    }
}

// MARK: Service Scene
extension SmartRuleDetailViewController {
    // delete Scene
    func callDeleteSceneAPI() {
        guard let id = dataModdel?.scene?.id else { return }
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .deleteScene(["id": id]),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                self.getSmartSceneVC()?.removeObjectAndReload(id: id)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //============================ Enable Disble Scene  ============================
    func callEnableDisableSceneAPI(status: Bool,id: Int, complitionBlock: @escaping (Bool)->()) {
        API_LOADER.show(animated: true)
        let param: [String: Any] = ["status":status ? 1 : 2, "id": id]
        API_SERVICES.callAPI(path: .sceneEnableDisable(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                self.dataModdel?.scene?.enable = status
                self.getSmartSceneVC()?.addOrUpdateScene(objectModel: (self.dataModdel?.scene)!)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                complitionBlock(status)
            }
        }
    }
}

// MARK: - Scene Favourite UnFavourite APi
extension SmartRuleDetailViewController {
    func callSceneToggleFavouriteAPI(status:Bool) {
        guard let sceneDataModel =  dataModdel?.scene else { return }
        let param: [String:Any] = [
            "id": sceneDataModel.id,
            "status": status ? 1 : 0,
        ]
        
        API_SERVICES.callAPI(path: .sceneFavouriteUnFavourite(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                self.dataModdel?.scene?.isFavouriteScene = status
                self.setFavouriteIconOnButton()
                self.getSmartSceneVC()?.addOrUpdateScene(objectModel: (self.dataModdel?.scene)!)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_APPLIENCE_FAVOURITE), object: nil)
            }
        }
    }
}
