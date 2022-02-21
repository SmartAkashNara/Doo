//
//  PrivilegesViewController.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class PrivilegesViewController: UIViewController {
    
    enum RedirectedFrom {
        
        // loadstaticDataFromJsonFile case is added for design purpose only that loads static data from json file, remove this case when api integration is done fully for all enum cases
        case enterpriseUsersPrivilegesSelection(InfinityTree?, String?),
             createGroupDevicesSelection,
             specificGroupDevicesSelection(GroupDataModel),
             applienceSelectionForSmartRule(Int?, Int?, Int?),
             loadstaticDataFromJsonFile
        
        func getTitle() -> String {
            switch self {
//            case .specificEnterpriseUserPrivilegesSelection:
//                return localizeFor("manage_privileges")
            case .enterpriseUsersPrivilegesSelection:
                return "Manage Privileges"
            case .createGroupDevicesSelection,.specificGroupDevicesSelection:
                return localizeFor("select_devices")
            case .applienceSelectionForSmartRule:
                return localizeFor("select_appliance")
            case .loadstaticDataFromJsonFile:
                return localizeFor("select_devices")
            }
        }
        
        func getSubTitle() -> String {
            switch self {
//            case .specificEnterpriseUserPrivilegesSelection:
//                return localizeFor("manage_privileges")
            case .enterpriseUsersPrivilegesSelection:
                return "Manage privileges to selected users"
            case .createGroupDevicesSelection,.specificGroupDevicesSelection:
                return "Select the appliance to assign in group"
            case .applienceSelectionForSmartRule:
                return "Select appliance you are planning to target"
            case .loadstaticDataFromJsonFile:
                return localizeFor("select_devices")
            }
        }
        
        func getButtonTitle() -> String{
            switch self {
//            case .specificEnterpriseUserPrivilegesSelection:
//                return cueAlert.Button.update
            case .enterpriseUsersPrivilegesSelection(_ ,let buttonTitle):
                if buttonTitle == nil{
                    return cueAlert.Button.save
                }
                return buttonTitle ?? ""
            case .createGroupDevicesSelection,.specificGroupDevicesSelection:
                return cueAlert.Button.addGroup
            case .applienceSelectionForSmartRule:
                return ""
            case .loadstaticDataFromJsonFile:
                return cueAlert.Button.addGroup
            }
        }
    }
    
    var redirectedFrom: RedirectedFrom = .enterpriseUsersPrivilegesSelection(nil,nil) // default, coming from manage privileges for specific enterprise user.
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var tableViewForTree: SayNoForDataTableView!
    @IBOutlet weak var constrainHeightOfBottomButton: NSLayoutConstraint!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    
    var privilegesViewModel: PrivilegesViewModel = PrivilegesViewModel()
    
    // for case - specificEnterpriseUserPrivilegesSelection
    var selectedUsersId = ""
    private var arrayOfSelectedUserIds:[String]{
        return selectedUsersId.components(separatedBy: ",")
    }
    weak var objEnterpriseUserDetailVC: EnterpriseUserDetailViewController? = nil
    // for case - enterpriseUsersPrivilegesSelection
    weak var objSelectUsersForAssignPrivilegesVC: SelectUsersForAssignPrivilegesViewController? = nil
    
    // for case - specificGroupDevicesSelection
    weak var objAddGroupVC: AddEditGroupViewController? = nil
    
    
    var callBackWithSelectedData: ((UserPrivilegeDataModel?, UserPrivilegeDataModel?, PrivilegeGroupDeviceDataModel?)->())? = nil
    var didAddedOrUpdatedGroupApplience:(()->())? = nil
    
    private var allSelectionOption :String {
        switch redirectedFrom {
//        case .specificEnterpriseUserPrivilegesSelection:
//            return "All Devices"
        case .enterpriseUsersPrivilegesSelection:
            return "All Groups"
        case .loadstaticDataFromJsonFile:
            return "All Devices"
        default:
            return ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTableView()
        
        switch redirectedFrom {
//        case .specificEnterpriseUserPrivilegesSelection:
//            self.tableViewForTree.sayNoSection = .noPrivilegeFound("Privilege")
//            getUserPrivilegesForEnterpriseUsers()
        case .applienceSelectionForSmartRule:
            self.tableViewForTree.sayNoSection = .noDeviceListFound("Device")
            self.getUserPrivilegesForEnterpriseSpecificUser()
        case .enterpriseUsersPrivilegesSelection(let infinityTree, _):
            self.tableViewForTree.sayNoSection = .noPrivilegeFound("Privilege")
            self.getUserPrivilegesForEnterpriseUsers(existingTree: infinityTree)
        case .loadstaticDataFromJsonFile:
            self.tableViewForTree.sayNoSection = .noDeviceListFound("Device")
            self.loadStaticDataFromJsonFile()
        default:
            // For groupDeviceList & groupMain
            self.tableViewForTree.sayNoSection = .noDeviceListFound("Device")
            self.getGroupDevices()
        }
    }
    
    func setUpRetryApiCalls() {
        switch redirectedFrom {
//        case .specificEnterpriseUserPrivilegesSelection:
//            getUserPrivilegesForEnterpriseUsers()
        case .applienceSelectionForSmartRule:
            self.getUserPrivilegesForEnterpriseSpecificUser()
        case .enterpriseUsersPrivilegesSelection:
            self.getUserPrivilegesForEnterpriseUsers()
        case .loadstaticDataFromJsonFile:
            self.loadStaticDataFromJsonFile()
        default:
            // For groupDeviceList & groupMain
            self.getGroupDevices()
        }
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.text = self.redirectedFrom.getTitle()
        buttonSave.setTitle(self.redirectedFrom.getButtonTitle(), for: .normal)
        navigationTitle.isHidden = true
        
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
        buttonSave.alpha = 0.5
        buttonSave.isUserInteractionEnabled = false
        buttonSave.setThemeAppBlueWithArrow(self.redirectedFrom.getButtonTitle())
        self.mainView.delegateOfSWWalert = self
        self.setNavigationTitle()
        switch redirectedFrom {
        case .applienceSelectionForSmartRule:
            constrainHeightOfBottomButton.constant = 0
        case .enterpriseUsersPrivilegesSelection:break
        //            buttonSave.alpha = 1
        //            buttonSave.isUserInteractionEnabled = true
        default:
            break
        }
        
        privilegesViewModel.allSelectionOption = allSelectionOption // Assign all selection option.
    }
    
    func setNavigationTitle() {
        let  title = self.redirectedFrom.getTitle()
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: self.redirectedFrom.getSubTitle())
        navigationTitle.text = title
    }
    
    func configureTableView() {
        self.tableViewForTree.dataSource = self
        self.tableViewForTree.delegate = self
        self.tableViewForTree.rowHeight = UITableView.automaticDimension
        self.tableViewForTree.estimatedRowHeight = 44
        tableViewForTree.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewForTree.sectionHeaderHeight = 0
        tableViewForTree.addBounceViewAtTop()
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewForTree.tableHeaderView = viewNavigationBarDetail
        self.tableViewForTree.registerCellNib(identifier: DooTree_1TVCell.identifier, commonSetting: true)
        // self.tableViewForTree.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 0, right: 16)
    }
    
    // loading dummy data from Privileges file
    func loadStaticDataFromJsonFile() {
        if let path = Bundle.main.path(forResource: "Privileges", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if self.privilegesViewModel.parseAllDeviceForGroup(JSON(rawValue: jsonResult) ?? ""), let payload = JSON(rawValue: jsonResult)?.dictionaryValue["payload"]?.array {
                    self.privilegesViewModel.configureTreeForEnterpriseUserPrivileges(jsonDataOptions: payload)
                    self.createTreeForStaticDataFromJsonFile()
                }
            } catch {
                // handle error
            }
        }
    }
    
    // data structure creation from josn received from privileges json file
    func createTreeForStaticDataFromJsonFile() {
        if (self.privilegesViewModel.infinityTree?.trees.count ?? 0) > 0 {
            let groupIds = self.objEnterpriseUserDetailVC?.privilegesViewModel.getGroupDeviceApplienceIds().groupIds ?? []
            let deviceIds = self.objEnterpriseUserDetailVC?.privilegesViewModel.getGroupDeviceApplienceIds().deviceIds ?? []
            let applincesIds = self.objEnterpriseUserDetailVC?.privilegesViewModel.getGroupDeviceApplienceIds().applienceIds ?? []
            self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
                if let parent = obj.value as? UserPrivilegeDataModel, groupIds.contains(parent.dataId){
                    obj.children.forEach { (obj1) in
                        if let deviceId = (obj1.value as? UserPrivilegeDataModel)?.dataId, deviceIds.contains(deviceId), (obj1.value as? UserPrivilegeDataModel)?.devices.count != 0 {
                            
                            obj1.children.forEach { (obj2) in
                                if let applienceId = (obj2.value as? UserPrivilegeDataModel)?.dataId, applincesIds.contains(applienceId){
                                    if let model2 = obj2.value as? UserPrivilegeDataModel, model2.selected{
                                        obj2.isMarked = true
                                    }else{
                                        obj2.isMarked = false
                                    }
                                }
                            }
                            
                            if obj1.children.count != 0 && obj1.children.map({$0.isMarked}).count == obj1.children.count{
                                obj1.isMarked = true
                            }else{
                                obj1.isMarked = false
                            }
                        }
                    }
                    if obj.children.count != 0 && obj.children.map({$0.isMarked}).count == obj.children.count{
                        obj.isMarked = true
                    }else{
                        obj.isMarked = false
                    }
                }
            })
        }
        self.tableViewForTree.reloadData()
        self.saveButtonEnableDisable()
    }
    
    @IBAction func backActionListener(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: User privileges list. (Case - .specificEnterpriseUserPrivilegesSelection)
extension PrivilegesViewController {
    func getUserPrivilegesForEnterpriseSpecificUser() {
        getUserPrivilegesListForEnterpriseUsers()
    }
    
    func getUserPrivilegesListForEnterpriseUsers(isFromPullToRefresh: Bool = false) {
        if !isFromPullToRefresh {
            API_LOADER.show(animated: true)
        }
        privilegesViewModel.callGetUserSelectedAllDevicesAPI(routingParam: ["userId": selectedUsersId]) {
            if !isFromPullToRefresh {
                API_LOADER.dismiss(animated: true)
            }
            
            self.ifRedirecFromSmartRuleEnumSelected()
            let groupIds = self.objEnterpriseUserDetailVC?.privilegesViewModel.getGroupDeviceApplienceIds().groupIds ?? []
            let deviceIds = self.objEnterpriseUserDetailVC?.privilegesViewModel.getGroupDeviceApplienceIds().deviceIds ?? []
            let applincesIds = self.objEnterpriseUserDetailVC?.privilegesViewModel.getGroupDeviceApplienceIds().applienceIds ?? []
            self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
                if let parent = obj.value as? UserPrivilegeDataModel, groupIds.contains(parent.dataId){
                    obj.children.forEach { (obj1) in
                        if let deviceId = (obj1.value as? UserPrivilegeDataModel)?.dataId, deviceIds.contains(deviceId), (obj1.value as? UserPrivilegeDataModel)?.devices.count != 0 {
                            
                            obj1.children.forEach { (obj2) in
                                if let applienceId = (obj2.value as? UserPrivilegeDataModel)?.dataId, applincesIds.contains(applienceId){
                                    if let model2 = obj2.value as? UserPrivilegeDataModel, model2.selected{
                                        obj2.isMarked = true
                                    }else{
                                        obj2.isMarked = false
                                    }
                                }
                            }
                            
                            if obj1.children.count != 0 && obj1.children.map({$0.isMarked}).count == obj1.children.count{
                                obj1.isMarked = true
                            }else{
                                obj1.isMarked = false
                            }
                        }
                    }
                    if obj.children.count != 0 && obj.children.map({$0.isMarked}).count == obj.children.count{
                        obj.isMarked = true
                    } else {
                        obj.isMarked = false
                    }
                }
            })
            self.tableViewForTree.reloadData()
            self.tableViewForTree.figureOutAndShowNoResults()
            self.saveButtonEnableDisable()
        }  failureMessageBlock: { msg in
            // TO-DO Block the view.
            self.mainView.showSomethingWentWrong()
        } internetFailureBlock: {
            self.mainView.showInternetOff()
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
    
    func ifRedirecFromSmartRuleEnumSelected() {
        switch redirectedFrom {
        case .applienceSelectionForSmartRule(let parentId, let deviceId, let applinceId):
            self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
                if let parent = obj.value as? UserPrivilegeDataModel, parent.dataId == parentId{
                    obj.children.forEach { (obj1) in
                        if let devicesId = (obj1.value as? UserPrivilegeDataModel)?.dataId, devicesId == deviceId, (obj1.value as? UserPrivilegeDataModel)?.devices.count != 0 {
                            obj1.children.forEach { (obj2) in
                                if let appliencesId = (obj2.value as? UserPrivilegeDataModel)?.dataId, appliencesId == applinceId{
                                    obj2.isMarked = true
                                }
                            }
                            
                            if obj1.children.count != 0 && obj1.children.map({$0.isMarked}).count == obj1.children.count{
                                obj1.isMarked = true
                            }else{
                                obj1.isMarked = false
                            }
                        }
                    }
                    
                    if obj.children.count != 0 && obj.children.map({$0.isMarked}).count == obj.children.count{
                        obj.isMarked = true
                    }else{
                        obj.isMarked = false
                    }
                }
            })
        default:
            break
        }
    }
}

// MARK: User privileges list. (Case - .selectedUsersToAssign)
extension PrivilegesViewController {
    func getUserPrivilegesForEnterpriseUsers(isFromPullToRefresh: Bool = false, existingTree: InfinityTree? = nil) {
        
        if !isFromPullToRefresh {
            API_LOADER.show(animated: true)
        }
        // privilegesViewModel.callGetUserSelectedAllDevicesAPI(userId: "",routingParam: [:]) { [weak self] in
        privilegesViewModel.callGetUserSelectedAllDevicesAPI(userId: arrayOfSelectedUserIds.count == 1 ? selectedUsersId : "",routingParam: [:]) { [weak self] in
            API_LOADER.dismiss(animated: true)
            
            self?.privilegesViewModel.infinityTree?.selectParentsAndChildsFromTree(tree: existingTree)
            self?.tableViewForTree.reloadData()
            self?.tableViewForTree.figureOutAndShowNoResults()
            self?.saveButtonEnableDisable()
        } failureMessageBlock: { msg in
            // TO-DO Block the view.
            self.mainView.showSomethingWentWrong()
        } internetFailureBlock: {
            self.mainView.showInternetOff()
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

// MARK: Get All Device of Group
extension PrivilegesViewController {
    func getGroupDevices() {
        
        buttonSave.alpha = 1
        buttonSave.isUserInteractionEnabled = true
        selectedUsersId = String(APP_USER?.userId ?? 0)
        
        self.callGetAllDeviceListApi()
    }
    
    func callGetAllDeviceListApi(isFromPullToRefresh: Bool = false) {
        if !isFromPullToRefresh{
            API_LOADER.show(animated: true)
        }
        privilegesViewModel.callGetSelectedAllDevicesAPI{
            API_LOADER.dismiss(animated: true)
            
            // here save buttton will be disbale becouse array of count zero
//            if (self.privilegesViewModel.infinityTree?.trees.count ?? 0).isZero(){
//                self.buttonSave.alpha = 0
//            }
            
            self.setSelectedGroupDeviceSelected()
        } failureMessageBlock: { msg in
            // TO-DO Block the view.
            self.mainView.showSomethingWentWrong()
        } internetFailureBlock: {
            self.mainView.showInternetOff()
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
    
    func setSelectedGroupDeviceSelected() {
        switch redirectedFrom {
        case .specificGroupDevicesSelection(let selectedGroup):
            selectedGroup.devices.forEach { (objSelectedGroupDevice) in
                let applienceIds = objSelectedGroupDevice.appliances.map({$0.id})
                self.privilegesViewModel.infinityTree?.trees.forEach({ (objDevice) in
                    if let deviceObj =  objDevice.value as? DeviceDataModel,
                       objSelectedGroupDevice.productId == deviceObj.enterpriseDeviceId {
                        var totalMarked = 0
                        
                        objDevice.children.forEach { (objApplince) in
                            if let applinceObjct =  objApplince.value as? ApplianceDataModel, applienceIds.contains(applinceObjct.id){
                                objApplince.isMarked = true
                                totalMarked += 1
                            }
                        }
                        // if totalMarked == objDevice.children.count {
                        if totalMarked >= 1 {
                            objDevice.isMarked = true
                        }
                    }
                })
            }
            self.saveButtonEnableDisable()
            self.tableViewForTree.reloadData()
            self.tableViewForTree.figureOutAndShowNoResults()
        default:
            self.saveButtonEnableDisable()
            self.tableViewForTree.reloadData()
            self.tableViewForTree.figureOutAndShowNoResults()
        }
    }
    
}

// MARK: Load tableview datasource and delegates
extension PrivilegesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.privilegesViewModel.infinityTree?.getNumberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = self.privilegesViewModel.infinityTree?.infinityCellForRowAtIndex(indexPath.row)
        
        if let value = node?.value as? UserPrivilegeDataModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: DooTree_1TVCell.identifier) as! DooTree_1TVCell
            
            cell.cellConfig(value: value, deepAtLevel: node!.deepAtLevel, marked: node!.isMarked,
                            isContainsChilds: (node!.children.count != 0), isExpanded: node!.isVisible)
            
            cell.buttonCheckmark.addTarget(self, action: #selector(self.checkmarkOrUnmarkAcitonListener(sender:)), for: .touchUpInside)
            
            cell.buttonCheckmark.identity = node!.identity
            cell.selectionStyle = .none
            
            switch redirectedFrom {
            case .applienceSelectionForSmartRule(let groupId, let deviceId, let applienceId):
                
                cell.labelTitle.textColor = UIColor.blueHeading
                
                if groupId == value.dataId , (node!.deepAtLevel == 1){
                    cell.labelTitle.textColor = UIColor.blueSwitch
                }
                
                if deviceId == value.dataId , (node!.deepAtLevel == 2){
                    cell.labelTitle.textColor = UIColor.blueSwitch
                }
                
                if applienceId == value.dataId , (node!.deepAtLevel == 3){
                    cell.labelTitle.textColor = UIColor.blueSwitch
                }
                
                cell.buttonCheckmark.isHidden = true
                let calculateLeading = (node!.deepAtLevel) * 20
                cell.leftConstraintToContent.constant = CGFloat(calculateLeading)
                
            default:
                break
            }
            
            return cell
        }else if let value = node?.value as? DeviceDataModel{
            let cell = tableView.dequeueReusableCell(withIdentifier: DooTree_1TVCell.identifier) as! DooTree_1TVCell
            cell.cellConfig(deviceDetail: value, deepAtLevel: node!.deepAtLevel, marked: node!.isMarked,
                            isContainsChilds: (node!.children.count != 0), isExpanded: node!.isVisible)
            cell.buttonCheckmark.addTarget(self, action: #selector(self.checkmarkOrUnmarkAcitonListener(sender:)), for: .touchUpInside)
            cell.buttonCheckmark.identity = node!.identity
            cell.selectionStyle = .none
            return cell
        }else if let value = node?.value as? ApplianceDataModel{
            let cell = tableView.dequeueReusableCell(withIdentifier: DooTree_1TVCell.identifier) as! DooTree_1TVCell
            cell.cellConfig(deviceApplinceDetail: value, deepAtLevel: node!.deepAtLevel, marked: node!.isMarked,
                            isContainsChilds: (node!.children.count != 0), isExpanded: node!.isVisible)
            cell.buttonCheckmark.addTarget(self, action: #selector(self.checkmarkOrUnmarkAcitonListener(sender:)), for: .touchUpInside)
            cell.buttonCheckmark.identity = node!.identity
            
            cell.selectionStyle = .none
            return cell
        }
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "identifier")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "identifier")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selection = self.privilegesViewModel.infinityTree?.infinityDidSelectAtIndex(indexPath.row) {
            
            switch redirectedFrom {
            case .applienceSelectionForSmartRule:
                if selection.selectedNode.deepAtLevel == 3{
                    
                    let group = self.privilegesViewModel.infinityTree?.infinityCellForRowAtIndex(indexPath.row).parent?.parent?.value as? UserPrivilegeDataModel
                    let device = self.privilegesViewModel.infinityTree?.infinityCellForRowAtIndex(indexPath.row).parent?.value as? UserPrivilegeDataModel
                    
                    let selectedNode:UserPrivilegeDataModel = selection.selectedNode.value as? UserPrivilegeDataModel ?? UserPrivilegeDataModel.init(withJSON: JSON())
                    
                    if let arrayDevice = device?.devices, let index = arrayDevice.firstIndex(where: {$0.dataId == selectedNode.dataId}){
                        callBackWithSelectedData?(group, device, arrayDevice[index])
                    }
                    self.navigationController?.popViewController(animated: true)
                }
//            case .specificEnterpriseUserPrivilegesSelection:
//                saveButtonEnableDisable()
            default:
                break
            }
            
            switch selection.actionPerformed {
            case .expanded:
                tableView.beginUpdates()
                tableView.reloadRows(at: selection.refreshed, with: .fade)
                tableView.insertRows(at: selection.rowsAddedOrRemoved, with: .fade)
                tableView.endUpdates()
            case .collapsed:
                tableView.beginUpdates()
                tableView.reloadRows(at: selection.refreshed, with: .fade)
                tableView.deleteRows(at: selection.rowsAddedOrRemoved, with: .fade)
                tableView.endUpdates()
            }
        }
    }
    
    
    func saveButtonEnableDisable(){
        
        switch redirectedFrom {
//        case .specificEnterpriseUserPrivilegesSelection:
//            buttonSave.alpha = 1
//            buttonSave.isUserInteractionEnabled = true
        case .enterpriseUsersPrivilegesSelection, .loadstaticDataFromJsonFile :
            var buttonShow = false
            self.privilegesViewModel.infinityTree?.trees.forEach { (obj1) in
                obj1.children.forEach { (obj2) in
                    obj2.children.forEach { (obj3) in
                        if obj3.isMarked{
                            buttonShow = true
                        }
                    }
                    if obj2.isMarked{
                        buttonShow = true
                    }
                }
                if obj1.isMarked {
                    buttonShow = true
                }
            }
            
            if buttonShow{
                buttonSave.alpha = 1
                buttonSave.isUserInteractionEnabled = true
            } else {
                buttonSave.alpha = 0.5
                buttonSave.isUserInteractionEnabled = false
            }
        case .specificGroupDevicesSelection:
            var buttonShow = false
            if self.privilegesViewModel.infinityTree?.trees.count ?? 0 > 0 {
                buttonShow = true
            }
            if buttonShow {
                buttonSave.alpha = 1
                buttonSave.isUserInteractionEnabled = true
            }else{
                buttonSave.alpha = 0.5
                buttonSave.isUserInteractionEnabled = false
            }
        default:
            break
        }
    }
}


// MARK: - UIGestureRecognizerDelegate
extension PrivilegesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


// MARK: - Assignment Action
extension PrivilegesViewController {
    @IBAction func assignPrivilegesActionListener(_ sender: UIButton) {
        switch redirectedFrom {
        case .specificGroupDevicesSelection(let selectedGroup):
            self.specificGroupDevicesAssignementMethod(selectedGroup.id)
        case .createGroupDevicesSelection:
            self.createGroupDevicesAssignmentMethod()
        case .applienceSelectionForSmartRule:break // never comes here this case
        case .loadstaticDataFromJsonFile:
            self.navigationController?.popToRootViewController(animated: true)
        default:
            // (Case - .specificEnterpriseUserPrivilegesSelection) & (Case - .enterpriseUsersPrivilegesSelection)
            self.verifyUserPrivilegesAssignementBeforeSaving()
        }
    }
}

// MARK: Checkmark Uncheckmark Methods
extension PrivilegesViewController {
    // healper actions
    @objc func checkmarkOrUnmarkAcitonListener(sender: ButtonOfInfinityTree) {
        if let indexPaths = self.privilegesViewModel.infinityTree?.mark(identitiyOfNode: sender.identity),
           let firstIndex = indexPaths.first {
            
            switch redirectedFrom {
            case .createGroupDevicesSelection:
                debugPrint("Cleared-1")
                break
            case .specificGroupDevicesSelection:
                debugPrint("Cleared-2")
                break
            case .enterpriseUsersPrivilegesSelection:
                debugPrint("Cleared-3")
                if firstIndex.row == 0 {
                    // debugPrint("firstindex row: \(firstIndex.row)")
                    // All groups selection
                    self.privilegesViewModel.infinityTree?.isAllSelected = !(self.privilegesViewModel.infinityTree?.isAllSelected ?? false)
                    let boolValue =  (self.privilegesViewModel.infinityTree?.isAllSelected ?? false)
                    self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
                        obj.children.forEach({$0.isMarked = boolValue; $0.children.forEach({$0.isMarked = boolValue})})
                        obj.isMarked = boolValue
                    })
                    self.tableViewForTree.reloadData()
                }
                break
            default:
                debugPrint("Not Cleared")
                // ISSUE AREA... UNCERTAIN....
                // (Case - .specificEnterpriseUserPrivilegesSelection)
                if (self.privilegesViewModel.infinityTree?.trees.indices.contains(firstIndex.row) ?? false),
                   let objUserPri = self.privilegesViewModel.infinityTree?.trees[firstIndex.row].value as? UserPrivilegeDataModel,
                   objUserPri.title == allSelectionOption {
                    
                    self.privilegesViewModel.infinityTree?.isAllSelected = !(self.privilegesViewModel.infinityTree?.isAllSelected ?? false)
                    let boolValue =  (self.privilegesViewModel.infinityTree?.isAllSelected ?? false)
                    self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
                        obj.children.forEach({$0.isMarked = boolValue; $0.children.forEach({$0.isMarked = boolValue})})
                        obj.isMarked = boolValue
                    })
                    self.tableViewForTree.reloadData()
                }else{
                    
                    if self.privilegesViewModel.infinityTree?.trees.indices.contains(firstIndex.row) ?? false,
                       let model = self.privilegesViewModel.infinityTree?.trees[firstIndex.row].value as? UserPrivilegeDataModel,
                       model.devices.count == 0{
                        CustomAlertView.init(title: "Appliance is not available.").showForWhile(animated: true)
                        return
                    }
                    checkIsAllCheckmarkedThenSelectAllGroupOption()
                    unSelectedAllGroupeOption()
                }
            }
            self.tableViewForTree.reloadRows(at: indexPaths, with: .fade)
            saveButtonEnableDisable()
        }
    }
    
    func checkIsAllCheckmarkedThenSelectAllGroupOption(){
        var iCheckMark = false
        self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
            if obj.children.count == obj.children.map({$0.isMarked}).count{
                iCheckMark = true
            }
        })
        
        if iCheckMark{
            self.privilegesViewModel.infinityTree?.trees[0].isMarked = true
            self.tableViewForTree.reloadData()
        }
    }
    
    func unSelectedAllGroupeOption(){
        var isUnMark = false
        self.privilegesViewModel.infinityTree?.trees.forEach { (obj1) in
            obj1.children.forEach { (obj2) in
                obj2.children.forEach { (obj3) in
                    if !obj3.isMarked{
                        isUnMark = true
                    }
                }
            }
        }
        
        if isUnMark{
            self.privilegesViewModel.infinityTree?.trees[0].isMarked = false
            self.tableViewForTree.reloadData()
        }
    }
}

// MARK: User privileges assignment API. (Case - .specificEnterpriseUserPrivilegesSelection)
extension PrivilegesViewController {
    func verifyUserPrivilegesAssignementBeforeSaving() {
        // Just check that any privilege has been selected?
        var isValidAssignCheckMark = false
        self.privilegesViewModel.infinityTree?.trees.forEach { (obj1) in
            obj1.children.forEach { (obj2) in
                obj2.children.forEach { (obj3) in
                    if obj3.isMarked{
                        isValidAssignCheckMark = true
                    }
                }
            }
        }
        // If one of it is selected.
        if isValidAssignCheckMark{
            switch redirectedFrom {
//            case .specificEnterpriseUserPrivilegesSelection, .enterpriseUsersPrivilegesSelection:
            case .enterpriseUsersPrivilegesSelection:
                assignPrivilegesToEnterpriseUsers()
            default:
                CustomAlertView.init(title: "Please select applinces.").showForWhile(animated: true)
            }
        }else{
            switch redirectedFrom {
//            case .enterpriseUsersPrivilegesSelection, .specificEnterpriseUserPrivilegesSelection:
            case .enterpriseUsersPrivilegesSelection:
                assignPrivilegesToEnterpriseUsers()
            default:
                CustomAlertView.init(title: "Please select applinces.").showForWhile(animated: true)
            }
        }
    }
    
    // Assignment API:
    func assignPrivilegesToEnterpriseUsers() {        
        // Create above formatted params from selected values in tree.
        var groupArray: [Any] = []
        self.privilegesViewModel.infinityTree?.trees.forEach { (obj1) in
            var parseApplianceValues = [Int]()
            obj1.children.forEach { (obj2) in
                obj2.children.forEach { (obj3) in
                    if obj3.isMarked{
                        if let objModel = obj3.value as? UserPrivilegeDataModel{
                            parseApplianceValues.append(Int(objModel.dataId))
                        }
                    }
                }
            }
            
            if let objModel = obj1.value as? UserPrivilegeDataModel, parseApplianceValues.count != 0{
                groupArray.append(["appliances": parseApplianceValues, "id": Int(objModel.dataId)])
            }
        }
        
        let usersId: [String] = selectedUsersId.components(separatedBy: ",")
        guard let selectedUserIds = usersId.map({Int($0)}) as? [Int] else { return }
        var params:[String: Any] = [:]
        if groupArray.count != 0, selectedUserIds.count != 0{
            params = ["groups":  groupArray, "users": selectedUserIds]
        }else{
            
            // here else work for when we dont want to assign any of devcie then pass just group id and applience empty array
            let groupIds = self.privilegesViewModel.infinityTree?.trees.map({($0.value as! UserPrivilegeDataModel).dataId})
            var dictGroupArray = [[String:Any]]()
            groupIds?.forEach({ id in
                dictGroupArray.append(["appliances": [], "id": id])
            })
            params = ["groups":  dictGroupArray, "users": selectedUserIds]
        }
        print("user privileges passed param: \(params)")
        
        
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(params, path: .assignDeviceToUserEnterprise, method: .put) { [weak self] (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            self?.objEnterpriseUserDetailVC?.viewDidLoad() // Only when privileges changes from user detail...
            self?.objSelectUsersForAssignPrivilegesVC?.resetAllSelectedData() // When selecting user and assigning privileges from 'Users & Privileges'
            self?.navigationController?.popViewController(animated: true)
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

// MARK: User privileges assignment API. (Case - .createGroupDevicesSelection)
extension PrivilegesViewController {
    func specificGroupDevicesAssignementMethod(_ selectedGroupID: Int) {
        var deviceIds = [Int]()
        self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
            obj.children.forEach { (childObj) in
                if childObj.isMarked, let devieObject = childObj.value as? ApplianceDataModel{
                    deviceIds.append(Int(devieObject.id) ?? 0)
                }
            }
        })
        
        self.updateDevicesForSpecificGroup(groupId: selectedGroupID)
    }
    
    func updateDevicesForSpecificGroup(groupId:Int){
        var param:[String:Any] = [:]
        var deviceIds = [Int]()
        self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
            obj.children.forEach { (childObj) in
                if childObj.isMarked, let devieObject = childObj.value as? ApplianceDataModel{
                    deviceIds.append(Int(devieObject.id) ?? 0)
                }
            }
        })
        
        param["applianceIds"] = deviceIds
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .updateDeviceInGroup(groupId), method: .post) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let _ = parsingResponse?["payload"]?.dictionary{
                self.didAddedOrUpdatedGroupApplience?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension PrivilegesViewController {
    func createGroupDevicesAssignmentMethod() {
        var deviceIds = [Int]()
        
        self.privilegesViewModel.infinityTree?.trees.forEach({ (obj) in
            obj.children.forEach { (childObj) in
                if childObj.isMarked, let devieObject = childObj.value as? ApplianceDataModel{
                    deviceIds.append(Int(devieObject.id) ?? 0)
                }
            }
        })
        objAddGroupVC?.callCreateGroupsAPI(applienceIds: deviceIds)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIScrollViewDelegate Methods
extension PrivilegesViewController: UIScrollViewDelegate {
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

// MARK: - Something went wrong
extension PrivilegesViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.dismissAnyAlerts()
        self.setUpRetryApiCalls()
    }
}
