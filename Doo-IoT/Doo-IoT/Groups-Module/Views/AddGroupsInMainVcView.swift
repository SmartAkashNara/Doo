import UIKit
import Foundation

// banner list for the banner images on Group main screen
enum bannerOfGroupImages:  CaseIterable {
    static var allCases: [bannerOfGroupImages] {
        return [.backgorundImage1, .backgorundImage2, .backgorundImage3, .backgorundImage4, .backgorundImage5, .backgorundImage6, .backgorundImage7, .backgorundImage8, .backgorundImage9]
    }
    
    case backgorundImage1
    case backgorundImage2
    case backgorundImage3
    case backgorundImage4
    case backgorundImage5
    case backgorundImage6
    case backgorundImage7
    case backgorundImage8
    case backgorundImage9
    
    var randomImageName: String {
        switch self {
        case .backgorundImage1:
            return "background_1.png"
        case .backgorundImage2:
            return "background_2.png"
        case .backgorundImage3:
            return "background_3.png"
        case .backgorundImage4:
            return "background_4.png"
        case .backgorundImage5:
            return "background_5.png"
        case .backgorundImage6:
            return "background_6.png"
        case .backgorundImage7:
            return "background_7.png"
        case .backgorundImage8:
            return "background_8.png"
        case .backgorundImage9:
            return "background_9.png"
        }
    }
}

class AddGroupsInMainVcView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableViewAddGroups: SayNoForDataTableView!
    var isShowLoader: Bool = false
    
    var groupID: Int = 0 // group this view holder, group id of it.
    var isRequiredToRemoved: Bool = false // This property will help developer to inform that this group should be removed now, as this user don't have access of this group any more.
    
    // MARK: - Variable declaration
    var rectInsideScroll = CGRect.zero
    var headerCollectionView: GroupCardTVCell? = nil
    var selectedGroupDetails : GroupDataModel? = nil
    weak var groupMainVC: UIViewController? // GroupsMainViewController
    var selectedIndexpath:IndexPath? = nil
    
    // For group detail API tracking
    var isGroupDetailsFetched: Bool = false
    var isGroupDetailAPIWorking: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.defaultConfig()
        
        // observer for on off status
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStateOfApplience(notification:)), name: Notification.Name(APPLIENCE_ON_OFF_UPDATE_STATUS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateOnlineOfflineDeviceStatus(notification:)), name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(APPLIENCE_ON_OFF_UPDATE_STATUS), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)

    }
    
    // MARK: - Other Methods
    
    // Default configure for setting data of selected group
    func defaultConfig(_ objGroupDetails: GroupDataModel? = nil, selectedGroupId: Int? = 0, selectedGroupName: String? = "", isGroupEnabled: Bool? = false) {
        self.backgroundColor = .clear
        if let groupDetail = objGroupDetails {
            self.groupID = groupDetail.id // hold group id
            self.selectedGroupDetails = groupDetail
        }
        self.configureTableView()
    }
    
    // configure tableView
    func configureTableView() {
        tableViewAddGroups.dataSource = self
        tableViewAddGroups.delegate = self
        tableViewAddGroups.bounces = true
        tableViewAddGroups.separatorStyle = .none
        tableViewAddGroups.registerCellNib(identifier: GroupCardSkeletonTVCell.identifier)
        tableViewAddGroups.registerCellNib(identifier: CollectionViewTVCell.identifier)
        tableViewAddGroups.registerCellNib(identifier: GroupCardTVCell.identifier)
        tableViewAddGroups.registerCellNib(identifier: DooHeaderTitleRightIconTVCell.identifier)
        tableViewAddGroups.registerCellNib(identifier: ApplianceHorizontalCollectionTVCell.identifier)
        tableViewAddGroups.registerCellNib(identifier: GroupDeviceSectionTVCell.identifier)
        tableViewAddGroups.addRefreshControlForPullToRefresh {
            guard !self.isGroupDetailAPIWorking else { return }
            self.callGetGroupDetailAPI(isPullToRefresh: true)
        }
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableViewAddGroups.tableHeaderView = UIView(frame: frame)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewAddGroups.tableHeaderView = v
    }
}

// MARK: - UITableViewDAtaSource
extension AddGroupsInMainVcView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isShowLoader {
            return 1
        }else{
            // add two rows for top bar section and device title
            return ((self.selectedGroupDetails?.devices.count ?? 0) + 2)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // no rows for 1st section to dislpay only Devices title
        guard !isShowLoader else {
            return 1
        }
        if section == 1 {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !isShowLoader else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupCardSkeletonTVCell.identifier) as! GroupCardSkeletonTVCell
            cell.showSekeletonAnimation()
            return cell
        }
        
        // top header for Group actions and details with banner image
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupCardTVCell.identifier) as! GroupCardTVCell
            // Switch Work
            cell.switchGroupEnableDisableStatus.switchStatusChanged = { currentStatus in
//                self.showEnableDisableGroupAction()
                self.callEnableDisableGroupAPI()
            }
            cell.buttonMore.tag = indexPath.row
            cell.buttonMore.addTarget(self, action: #selector(buttonGroupOptionsClicked(sender:)), for: .touchUpInside)
            cell.cellConfig(deviceCount: self.selectedGroupDetails?.devices.count ?? 0, strGroupName: self.selectedGroupDetails?.name ?? "", isOn: self.selectedGroupDetails?.enable ?? false, bannerImage: self.selectedGroupDetails?.bannerImage ?? "background_1")
            cell.configureControlsAsPerGroupId(groupId: self.selectedGroupDetails?.id ?? 0)
            return cell
            
            // header to show only Device title and add device button
        } else if indexPath.section == 1 {
            return tableView.getDefaultCell()
            
            // Default cells for displaying each device and its appliances
        } else {
            let cellDevices = tableView.dequeueReusableCell(withIdentifier: ApplianceHorizontalCollectionTVCell.identifier, for: indexPath) as! ApplianceHorizontalCollectionTVCell
            cellDevices.cellConfigFromGroup()
            
            cellDevices.cellConfig(data: selectedGroupDetails?.devices[indexPath.section - 2].appliances ?? [])
            cellDevices.selectionStyle = .none
            
            cellDevices.collectionViewFavouriteDevices.tag = indexPath.section - 2
            
            // longPress action for appliance, Navigate to selected appliance details
            cellDevices.didTapLongGesture = { (row, section) in
                guard let destView = UIStoryboard.group.applianceDetailInGroupVC else { return }
                destView.hidesBottomBarWhenPushed = true
                destView.deviceDetails = self.selectedGroupDetails?.devices[section]
                destView.selectedApplinceRow = row
                destView.groupEnableDisable = self.selectedGroupDetails?.enable ?? false
                self.groupMainVC?.navigationController?.pushViewController(destView, animated: true)
            }
            
            // set status on/off on tap
            cellDevices.didTap = { (row, section) in
                self.selectedIndexpath = IndexPath.init(row: row, section: section)
                self.callApplienceONOFFAPI()
            }
            // hide seperator line for the last row in last section
            if indexPath.section == ((selectedGroupDetails?.devices.count ?? 0) + 2 ) - 1{
                cellDevices.sepratorView.isHidden = true
            }
            return cellDevices
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !isShowLoader else {
            return 0.01
        }
        
        if section == 0 {
            return 0
        }
        // if default group and devcie count 0 the hide header section device title and plus button
        return 45.0//(selectedGroupDetails?.devices.count  == 0 && selectedGroupDetails?.id == 0) ? 0 : 45 // change by divay letter shared sheet point
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate Methods
extension AddGroupsInMainVcView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        guard !isShowLoader else {
            return nil
        }
        
        // no view for first top banner section
        if section == 0 {
            return nil
            
            // Section which will show Devce title with add button option
        } else if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupDeviceSectionTVCell.identifier) as! GroupDeviceSectionTVCell
            cell.cellConfig(title: "DEVICES")
            cell.buttonPlus.tag = section
            if let dataModel = selectedGroupDetails{
                cell.buttonPlus.isHidden = ((dataModel.enumGroupType == .simpleGroup && dataModel.id == 0) || (APP_USER?.selectedEnterprise?.userRole == .user)) ? true : false
            }
            cell.buttonPlus.addTarget(self, action: #selector(cellAddDeviceClicked(sender:)), for: .touchUpInside)
            return cell
            
            // default section which will show device name
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupDeviceSectionTVCell.identifier) as! GroupDeviceSectionTVCell
            cell.cellConfig(title: self.selectedGroupDetails?.devices[section - 2].deviceName ?? "")
            cell.buttonPlus.isHidden = true
            
            return cell
        }
    }
    
    @objc func cellAddDeviceClicked(sender:UIButton) {
        debugPrint("Add Device clicked...")
        guard let userPrivilegesVC = UIStoryboard.enterpriseUsers.userPrivilegesVC, let groupDataModel = selectedGroupDetails else {
            return
        }
        userPrivilegesVC.hidesBottomBarWhenPushed = true
        userPrivilegesVC.redirectedFrom = .specificGroupDevicesSelection(groupDataModel)
        userPrivilegesVC.didAddedOrUpdatedGroupApplience = {
            self.recallGroupDetailApi()
        }
        self.groupMainVC?.navigationController?.pushViewController(userPrivilegesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    // another solution for the bounce issue at the end of table view scrolling found in group main vc. Its commented so as to remove the conflict between this delegate method and its super view controller's delegate method.
    /*
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
     // solving issue of tableview bouncing at the end of the content.
     // bounce property will keep on changing based on in content offset.
     if scrollView == tableViewAddGroups {
     tableViewAddGroups.bounces = tableViewAddGroups.contentOffset.y <  (tableViewAddGroups.contentSize.height - tableViewAddGroups.frame.height)
     }
     }
     */
}

// MARK: - IBACtions
extension AddGroupsInMainVcView {
    
    // Showing edit delete or other options on click of More button clicked
    @objc func buttonGroupOptionsClicked(sender: UIButton){
        
        guard let dataModel = selectedGroupDetails else { return }
        let groupName = dataModel.name
        let status = dataModel.enable ?? false
        
        let totalDevice = dataModel.devices.count
        let str = totalDevice > 1 ? "\(totalDevice) \(localizeFor("devices"))" : "\(totalDevice) \(localizeFor("device"))"
        
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            var actions = [DooBottomPopupActions_1ViewController.PopupOption]()
            
            
            let actionEnableDisable = DooBottomPopupActions_1ViewController.PopupOption.init(title: status ? localizeFor("groupDisable") : localizeFor("groupEnable"), color: UIColor.blueHeading, action: {
//                self.showEnableDisableGroupAction()
                self.callEnableDisableGroupAPI()
            })
            
            // Edit action for Group name edit
            let editGroupTitle = "\(localizeFor("edit_group"))"
            let actionEditgroup = DooBottomPopupActions_1ViewController.PopupOption.init(title: editGroupTitle, color: UIColor.blueHeading, action: {
                guard let groupVC = UIStoryboard.group.addGroupVC else {
                    return
                }
                groupVC.isEditFlow = true
                groupVC.groupModel = self.selectedGroupDetails
                
                groupVC.enumAddGroupScreenFlow = .fromGroup
                groupVC.hidesBottomBarWhenPushed = true
                groupVC.didAddedOrUpdatedGroup = { [weak self] (dataModel, isUpdated) in
                    guard let strongSelf = self else {return}
                    if isUpdated{
                        guard let groupsMainVC = strongSelf.groupMainVC as? GroupsMainViewController else {
                            return
                        }
                        if let index = groupsMainVC.groupMainViewModel.groups.firstIndex(where: {$0.id == dataModel.id}){
                            groupsMainVC.groupMainViewModel.groups[index].name = dataModel.name
                            groupsMainVC.groupMainViewModel.groups = groupsMainVC.groupMainViewModel.groups.map({ groupDataModel in
                                groupDataModel.tabSelected = false
                                return groupDataModel
                            })
                            groupsMainVC.groupMainViewModel.groups[index].tabSelected = true // currently selected index...
                            
                            
                            strongSelf.selectedGroupDetails?.name = dataModel.name
                            strongSelf.tableViewAddGroups.reloadData()
                            groupsMainVC.justResetHorizontalCollectionTitles()
                        }
                    }
                }
                self.groupMainVC?.navigationController?.pushViewController(groupVC, animated: true)
            })
            
            if dataModel.enumGroupType != .masterGroup && dataModel.id != 0{
                actions.append(actionEditgroup)
            }
            
            actions.append(actionEnableDisable)
            //Delete action for group name delete
            let actionDeleteGroup = DooBottomPopupActions_1ViewController.PopupOption.init(title: "\(localizeFor("delete_group"))", color: UIColor.textFieldErrorColor, action: {
                self.showDeleteAlert()
            })
            
            if dataModel.id != 0{
                actions.append(actionDeleteGroup)
            }
            
            actionsVC.popupType = .generic(groupName , str,  actions)
            actionsVC.titleTextColor = UIColor.blueHeading
            actionsVC.subTitleTextColor = UIColor.blueHeadingAlpha60
            self.groupMainVC?.present(actionsVC, animated: true) {
            }
        }
    }
    
    func showDeleteAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.white, backgroundColor: UIColor.blueSwitch) {
                    debugPrint("cancel tapped")
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.delete, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    DispatchQueue.getMain(delay: 0.2) {
                        self.callDeleteGroupsAPI()
                    }
                }
                alertVC.setAlert(alertTitle: localizeFor("are_you_sure_want_to_delete_this_group"), leftButton: cancelAction, rightButton: deleteAction)
                self.groupMainVC?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
}

//============================Enable Disble Group ============================
extension AddGroupsInMainVcView{
    
    func showEnableDisableGroupAction() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                    self.tableViewAddGroups.reloadData()
                }
                let enableDisableAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: self.selectedGroupDetails?.enable == false ? cueAlert.Button.enable : cueAlert.Button.disable, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    self.callEnableDisableGroupAPI()
                }
                alertVC.setAlert(alertTitle: self.selectedGroupDetails?.enable == false ? "Are you sure you want to enable group?" : "Are you sure you want to disable group?", leftButton: cancelAction, rightButton: enableDisableAction)
                self.groupMainVC?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    func callEnableDisableGroupAPI() {
        
        guard let groupId = self.selectedGroupDetails?.id, let status = self.selectedGroupDetails?.enable else { return }
        
        let finalStatus = !status
        let param:[String:Any] = ["groupId":groupId, "status":finalStatus]
        API_SERVICES.callAPI(param, path: .groupEnableDisable(groupId, finalStatus), method:.put) { (parsingResponse) in
            if let _ = parsingResponse?["payload"]{
                self.selectedGroupDetails?.enable = !(self.selectedGroupDetails?.enable ?? true)
                self.tableViewAddGroups.reloadData()
                 CustomAlertView.init(title: parsingResponse?["message"]?.stringValue ?? "" , forPurpose: .success).showForWhile(animated: true)
            }
        }
    }
}

//==============Delete Group====================
extension AddGroupsInMainVcView{
    func callDeleteGroupsAPI() {
        guard let groupId = self.selectedGroupDetails?.id else { return }
        // self.removeIndexFromBothafterDelete(groupId: groupId) // Check delete without API call...
        API_SERVICES.callAPI(path: .removeGroup(groupId), method:.put) {(parsingResponse) in
            if let _ = parsingResponse?["payload"]{
                // CustomAlertView.init(title: parsingResponse?["message"]?.stringValue ?? "" , forPurpose: .success).showForWhile(animated: true)
                // here to delete
                
                self.removeIndexFromBothafterDelete(groupId: groupId)
            }
        }
    }
    
    func removeIndexFromBothafterDelete(groupId: Int) {
        guard let groupsMainVC = groupMainVC as? GroupsMainViewController else {
            return
        }
        
        if let index = groupsMainVC.groupMainViewModel.groups.firstIndex(where: {$0.id == groupId}){
            DispatchQueue.main.async {
                
                // Process One...
                // This will remove view from scrollview but space of it would be there as it is.
                guard let xib = groupsMainVC.scrollViewMain.viewWithTag(index + 100) else {return}
                xib.removeFromSuperview()
                
                // Process Two...
                // Process One is optional, as we are already removing XIB's view from 'viewsToLoadInsideScroll' list and reset all content views...
                // Remove XIB from array of groups and reset content views inside scrollview...
                groupsMainVC.groupMainViewModel.groups.remove(at: index) // Remove from data models list. Specific data model will be removed from groups list in view model.
                groupsMainVC.viewsToLoadInsideScroll.remove(at: index) // Remove from XIBs list. This is the View holding content of group deleted.
                groupsMainVC.setupSlideScrollView(slidesInsideScroll: groupsMainVC.viewsToLoadInsideScroll)
                groupsMainVC.scrollViewMain.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                
                
                // Horizontal titles collection configuration, Remove and set selected index to first.
                groupsMainVC.groupMainViewModel.groups.forEach { dataModel in dataModel.tabSelected = false } // here tabSelected set false
                groupsMainVC.groupMainViewModel.groups.first?.tabSelected = true // make first true
                groupsMainVC.setGroupArrayToHorizontalTitleCollectionAndReload()
                /*
                 groupsMainVC.selectedGroupMenuTab = 0
                 groupsMainVC.groupMainViewModel.groups.forEach({$0.tabSelected = false})
                 groupsMainVC.groupMainViewModel.groups[0].tabSelected = true
                 groupsMainVC.groupMainViewModel.groups.remove(at: index)
                 groupsMainVC.viewsToLoadInsideScroll.remove(at: index)
                 
                 groupsMainVC.horizontalTitleCollection.selectedIndex = 0
                 groupsMainVC.horizontalTitleCollection.dataModel = groupsMainVC.groupMainViewModel.groups.map({return HorizontalTitleCollectionDataModel.init(title: $0.name, isSelected: $0.tabSelected)})
                 groupsMainVC.horizontalTitleCollection.resetData()
                 // groupsMainVC.horizontalTitleCollection.didScrollEvent(groupsMainVC.scrollViewMain)
                 */
                
            }
        }
    }
}

//============== Reload Group Detail Api====================
extension AddGroupsInMainVcView {
    func recallGroupDetailApi() {
        guard !self.isGroupDetailAPIWorking else { return }        
        self.callGetGroupDetailAPI()
    }
}

// MARK: - Get Group Detail API
extension AddGroupsInMainVcView {
    func callGetGroupDetailAPI(_ apiCallBackground:Bool = false, isPullToRefresh:Bool = false){
        self.isGroupDetailAPIWorking = true
        self.isShowLoader = true // for showing skeleton
        if let groupsMainVC = self.groupMainVC as? GroupsMainViewController{
            groupsMainVC.mainView.dismissAnyAlerts()
        }
        // API....
        let groupId = selectedGroupDetails?.id ?? 0
        if !apiCallBackground && !isPullToRefresh{
            // API_LOADER.show(animated: true)
        }
        API_SERVICES.callAPI(path: .getGroupDetail(groupId), method:.get) { [weak self] (parsingResponse) in
            
            self?.tableViewAddGroups.stopPullToRefresh()
            if !apiCallBackground && !isPullToRefresh{ API_LOADER.dismiss(animated: true) } // loader will call when pull to refresh and background api false
            
            self?.isGroupDetailAPIWorking = false // make it false, so it can allow to call again.
            if let json = parsingResponse, let payload = json["payload"]?.dictionaryValue{
                let groupModel = GroupDataModel.init(dict: JSON(rawValue: payload) ?? [])
                
                self?.isShowLoader = false // for hiding skeleton
                
                // Keep banner image as it is.
                let previousBannerImage = self?.selectedGroupDetails?.bannerImage
                self?.selectedGroupDetails = groupModel  // assign latest data model of detail
                self?.selectedGroupDetails?.bannerImage = previousBannerImage
                
                self?.tableViewAddGroups.reloadData()
            }else{
                self?.isShowLoader = false // for hiding skeleton
                CustomAlertView.init(title: localizeFor("something_went_wrong")).showForWhile(animated: true)
            }
        } failure: { [weak self] (msg) in
            CustomAlertView.init(title: msg ?? "", forPurpose: .failure).showForWhile(animated: true)
            if let groupsMainVC = self?.groupMainVC as? GroupsMainViewController{
                groupsMainVC.mainView.showSomethingWentWrong()
            }
        } internetFailure: { [weak self] in
            CustomAlertView.init(title: localizeFor("internet_failure")).showForWhile(animated: true)
            if let groupsMainVC = self?.groupMainVC as? GroupsMainViewController{
                groupsMainVC.mainView.showInternetOff()
            }
        } failureInform: { [weak self] in
            self?.isGroupDetailAPIWorking = false // make it false, so it can allow to call again.
            self?.tableViewAddGroups.stopPullToRefresh()
            self?.isShowLoader = false // for hiding skeleton
        }
    }
}

// MARK: On Off APIs...
extension AddGroupsInMainVcView{
    func callApplienceONOFFAPI() {
        // Continue only if group is enabled...
        guard self.selectedGroupDetails?.enable ?? false else {
            if let groupsMainVC = self.groupMainVC as? GroupsMainViewController{
                groupMainVC?.showAlert(withMessage: "Please enable group to operate appliances!", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            }
            return
        }
        
        guard let indexpath = self.selectedIndexpath else { return }
        guard let applianceObj = self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row] else { return }
        let applienceValue = applianceObj.onOffStatus ? 0 : 1
        
        let param: [String:Any] = [
            "applianceId": Int(applianceObj.id) ?? 0,
            "endpointId": applianceObj.endpointId,
            "applianceData": ["action": EnumApplianceAction.onOff.rawValue, "value": applienceValue] // here passed action static 1 for on off only
        ]
        
        // API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .applienceONOFF, method:.post) { (parsingResponse) in
            debugPrint("REst Api Response:", parsingResponse!)
        } failureInform: {
        }
    }
    
    
    // update online and offline of device
    @objc func updateOnlineOfflineDeviceStatus(notification:Notification) {
        guard let dictObj = notification.object else { return }
        guard let _ = self.selectedGroupDetails else { return }
        let json = JSON.init(dictObj)
        let macAddresss = json["macAddress"].stringValue
        let statusOnlineOffline = json["status"].boolValue
        
        self.selectedGroupDetails?.devices.forEach { objDevice in
            if objDevice.macAddress == macAddresss{
                objDevice.deviceStatus = statusOnlineOffline ? 1 : 0
                objDevice.appliances.forEach({ objApplience in
                    objApplience.deviceStatus = statusOnlineOffline
                })
            }
        }
        
        self.tableViewAddGroups.reloadData()
    }
    
    @objc func updateStateOfApplience(notification:Notification){
        
        guard let dictObj = notification.object else { return }
        guard let groupDetailObj = self.selectedGroupDetails else { return }
        
        let json = JSON.init(dictObj)
        debugPrint(json)
        
        let applianceId = json["applianceId"].intValue
        let applianceData = json["applianceData"].dictionaryValue
        let value = applianceData["value"]?.intValue ?? 0
        let action = applianceData["action"]?.intValue ?? 0
        let enumApplienceAction = EnumApplianceAction.init(rawValue: action) ?? .none
        
        //let status = value == 0 ? false : true
        let status = value >= 1 ? true : false // here we are checking if value greater than 1 that means status would be on becouse fan control we are fetching value from the same key so we have kept that condition rather than check 0 or 1
        var isMatchedApplienceId = false
        for (deviceIndex, deviceObj) in groupDetailObj.devices.enumerated(){
            for (applienceIndex, applienceObj) in deviceObj.appliances.enumerated(){
                if applienceObj.id == "\(applianceId)"{
                    isMatchedApplienceId = true
                    self.selectedIndexpath = IndexPath.init(row: applienceIndex, section: deviceIndex)
                }
            }
        }
        
        guard let indexpath = self.selectedIndexpath, isMatchedApplienceId else { return }
        switch enumApplienceAction {
        case .onOff, .none:
            
            // here update value if greathen 0 that means previous stored fan value we are getting...
            if let objGroupDetail = self.selectedGroupDetails, objGroupDetail.devices[indexpath.section].appliances[indexpath.row].arrayOprationSupported.contains(.fan) && value > 0{
                self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].speed = value.getSpeedFromPercentage()
            }else{
                self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].speed = 0
            }
            
            // here if RGB appliene get value then it set applience color
            if let objGroupDetail = self.selectedGroupDetails, objGroupDetail.devices[indexpath.section].appliances[indexpath.row].arrayOprationSupported.contains(.rgb) && value > 0{
                self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].setRGBValueIfApplienceTypeRGB(value: value)
            }else{
                self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].applianceColor = .red
            }
        case .fan:
            self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].speed = value.getSpeedFromPercentage()
        case .rgb:
            self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].setRGBValueIfApplienceTypeRGB(value: value)
        }
        
        self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].onOffStatus = status
        self.tableViewAddGroups.reloadData()
    }
    
    /*
     @objc func updateStateOfApplience(notification:Notification){
     
     guard let indexpath = self.selectedIndexpath else { return }
     guard let dictObj = notification.object else { return }
     let json = JSON.init(dictObj)
     //let applianceId = json["applianceId"].intValue
     let applianceData = json["applianceData"].dictionaryValue
     let value = applianceData["value"]?.intValue ?? 0
     let status = value == 1 ? true : false
     self.selectedGroupDetails?.devices[indexpath.section].appliances[indexpath.row].onOffStatus = status
     self.tableViewAddGroups.reloadData()
     }*/
}
