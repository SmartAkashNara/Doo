//
//  DeviceDetailViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewDetail: SayNoForDataTableView!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    
    private var viewModel = DeviceDetailViewModel()
    private var isLoad = false
    var deviceData: DeviceDataModel!
    var isFromAddDevice = false
    var isOnOFF = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.deviceData = deviceData
        setDefaults()
        configureTableView()
        callGetDeviceDetailFromDeviceIdAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isLoad {
            loadNavigationBar()
            tableViewDetail.reloadData()
        }
        isLoad = true
        
        // Role based work
        if let userRole = APP_USER?.selectedEnterprise?.userRole {
            switch userRole {
            case .admin, .owner:
                self.buttonMenu.isHidden = false
            default:
                self.buttonMenu.isHidden = true
            }
        }
        
        // if device detail opened from Add Device. Show alert that device has been added and appliances will be activated automatically after some time.
        if isFromAddDevice {
            self.showAlert(withMessage: "Device added successfully. Appliances will be auto activated in 10 minutes!", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)
    }

}

// MARK: - Applience Detail APi
extension DeviceDetailViewController {
    func callGetDeviceDetailFromDeviceIdAPI(isPullToRefresh:Bool=false) {
        guard let device = viewModel.deviceData else { return }
        if !isPullToRefresh{
            API_LOADER.show(animated: true)
        }
        
        viewModel.callGetDeviceDetailFromDeviceIdAPI(deviceID: device.enterpriseDeviceId) { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.loadNavigationBar()
            self?.tableViewDetail.stopPullToRefresh()
            self?.tableViewDetail.reloadData()
            self?.tableViewDetail.figureOutAndShowNoResults()
        } failure:  { [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewDetail.stopPullToRefresh()
        }
    }
}

// MARK: - Applience Favourite UnFavourite APi
extension DeviceDetailViewController {
    func callApplianceToggleFavouriteAPI(index: Int) {
        guard let objDeviceDataModel =  viewModel.deviceData else { return }
        let param: [String:Any] = [
            "id": objDeviceDataModel.appliances[index].id,
            "flag": !objDeviceDataModel.appliances[index].isFavourite,
        ]
        viewModel.callApplianceToggleFavouriteAPI(param) { [weak self] (msg) in
            self?.viewModel.deviceData?.appliances[index].isFavourite.toggle()
            // reload whole tableview instead of single row. beacuse by reloading single row it cause bug -> section will disappear.
            self?.tableViewDetail.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_APPLIENCE_FAVOURITE), object: nil)
        } failureMessageBlock: { msg in
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        }
    }
}

// MARK: - Applience Enable disable APi
extension DeviceDetailViewController {
    func callUpdateAccessOfApplianceToggle(index: Int, status:Int) {
        // 1 for enable
        //2 for disable
        guard let objDeviceDataModel =  viewModel.deviceData else { return }
        let enableStatus = objDeviceDataModel.appliances[index].accessStatus ? false : true
        guard let applianceId =  Int(objDeviceDataModel.appliances[index].id) else { return }
        
        API_SERVICES.callAPI(path: .applianceToggleEnable(["applianceId": applianceId, "flag": enableStatus ? 1 : 2]), method:.put) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let strongSelf = self{
                debugPrint(json)
                API_LOADER.dismiss(animated: true)
                strongSelf.animateSwitchNReloadAppliance(index: index,status: enableStatus)
            }
        } internetFailure: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

// MARK: - Applience Delete APi
extension DeviceDetailViewController {
    func callDeleteDeviceAPI() {
        guard let objDeviceObject  = viewModel.deviceData else { return }
        guard let id = Int(objDeviceObject.enterpriseDeviceId) else { return}
        let param:[String:Any] = ["deviceId":id]
        API_LOADER.show(animated: true)
        viewModel.callDeleteDeviceAPI(param, isGateway: objDeviceObject.productIsGateway) {
            API_LOADER.dismiss(animated: true)
            if self.isFromAddDevice {
                self.backToDeviceTypeList()
            } else {
                self.performSegue(withIdentifier: "unwindSegueFromDeviceDetailToDevicesList", sender: nil)
            }
        } failureMessageBlock: { msg in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        }
    }
}

// MARK: - User defined methods
extension DeviceDetailViewController {
    func configureTableView() {
        tableViewDetail.dataSource = self
        tableViewDetail.delegate = self
        tableViewDetail.registerCellNib(identifier: DooHeaderDetail_1TVCell.identifier, commonSetting: true)
        tableViewDetail.registerCellNib(identifier: DooDetail_1TVCell.identifier)
        tableViewDetail.registerCellNib(identifier: DeviceApplianceCell.identifier)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewDetail.tableHeaderView = viewNavigationBarDetail
        tableViewDetail.addBounceViewAtTop()
        tableViewDetail.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewDetail.sectionHeaderHeight = 0
        tableViewDetail.separatorStyle = .none
        tableViewDetail.sayNoSection = .noDeviceListFound("No device detail found")
        tableViewDetail.addRefreshControlForPullToRefresh {
            self.callGetDeviceDetailFromDeviceIdAPI(isPullToRefresh: true)
        }
        tableViewDetail.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func setDefaults() {
        // swipe to back work
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        mainView.delegateOfSWWalert = self
        
        buttonBack.addTarget(self, action: #selector(self.backActionListener(sender:)), for: .touchUpInside)
        buttonMenu.addTarget(self, action: #selector(self.menuActionListener(sender:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateOnlineOfflineDeviceStatus(notification:)), name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)

    }
    
    
    func loadNavigationBar() {
        guard let objDeviceObject  = viewModel.deviceData else { return }
        let title = objDeviceObject.deviceName
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: objDeviceObject.productTypeName)
        navigationTitle.text = title
    }
    
    @objc func updateOnlineOfflineDeviceStatus(notification:Notification) {
        guard let dictObj = notification.object else { return }
        let json = JSON.init(dictObj)
        let macAddresss = json["macAddress"].stringValue
        let statusOnlineOffline = json["status"].boolValue
        
        viewModel.deviceData?.appliances.forEach { objApplience in
            if objApplience.macAddress == macAddresss{
                objApplience.deviceStatus = statusOnlineOffline
                viewModel.deviceData?.deviceStatus = statusOnlineOffline ? 1 : 0
            }
        }
        tableViewDetail.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension DeviceDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case DeviceDetailViewModel.EnumSection.deviceDetail.index:
            return viewModel.firstSectionData.count
        case DeviceDetailViewModel.EnumSection.appliances.index:
            guard let objDeviceObject  = viewModel.deviceData else {
                return 0
            }
            return objDeviceObject.appliances.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case DeviceDetailViewModel.EnumSection.deviceDetail.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: DooDetail_1TVCell.identifier, for: indexPath) as! DooDetail_1TVCell
            cell.cellConfig(data: viewModel.firstSectionData[indexPath.row])
            cell.selectionStyle = .none
            return cell
            
        case DeviceDetailViewModel.EnumSection.appliances.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: DeviceApplianceCell.identifier, for: indexPath) as! DeviceApplianceCell
            
            if let objDeviceObject  = self.viewModel.deviceData{
                cell.cellConfig(objDeviceObject.appliances[indexPath.row],deviceStatus: (viewModel.deviceData?.deviceStatus  == 1  ? true : false))
            }
            cell.switchStatus.tag = indexPath.row
            cell.buttonFav.tag = indexPath.row
            cell.switchStatus.switchStatusChanged = { value in
                self.callUpdateAccessOfApplianceToggle(index: cell.switchStatus.tag, status: value)
            }
            cell.buttonFav.addTarget(self, action: #selector(cellFavouriteActionListener(_:)), for: .touchUpInside)
            return cell
        default: return tableView.getDefaultCell()
        }   
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DooHeaderDetail_1TVCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let objDeviceObject  = viewModel.deviceData else { return 0.001 }
        
        if section == DeviceDetailViewModel.EnumSection.deviceDetail.index, !objDeviceObject.appliances.count.isZero() { return 1
        }else{ return 0.001 }
    }
}

// MARK: - UITableViewDelegate
extension DeviceDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooHeaderDetail_1TVCell.identifier) as! DooHeaderDetail_1TVCell
        cell.cellConfig(title: viewModel.sections[section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == DeviceDetailViewModel.EnumSection.deviceDetail.index {
            return tableView.dequeueReusableCell(withIdentifier: SeparatorFooterTVCell.identifier)
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == DeviceDetailViewModel.EnumSection.appliances.index {
            guard let objEnterprise = APP_USER?.selectedEnterprise else { return }
            if objEnterprise.userRole == .admin || objEnterprise.userRole == .owner
            {
                guard let destView = UIStoryboard.devices.editApplicationVC else { return }
                guard let objDeviceObject  = viewModel.deviceData else { return }
                destView.applianceData = objDeviceObject.appliances[indexPath.row]
                destView.applianceUpdated = { [ weak self] (objApplianceDetails) in
                    guard let strongSelf = self else { return }
                    strongSelf.viewModel.deviceData?.appliances[indexPath.row] = objApplianceDetails
                    strongSelf.tableViewDetail.reloadData()
                }
                self.navigationController?.pushViewController(destView, animated: true)
            }
        }
        
        /*
         if indexPath.section == DeviceDetailViewModel.EnumSection.appliances.index {
         guard let destView = UIStoryboard.devices.applianceMgntOptionsVC else { return }
         guard let objDeviceObject  = viewModel.deviceData else {
         return
         }
         destView.applianceData = objDeviceObject.appliances[indexPath.row]
         navigationController?.pushViewController(destView, animated: true)
         }
         */
    }
}

// MARK: - Actions
extension DeviceDetailViewController {
    @objc func cellFavouriteActionListener(_ sender: UIButton) {
        callApplianceToggleFavouriteAPI(index: sender.tag)
    }
    
    @objc func backActionListener(sender: UIButton) {
        if isFromAddDevice {
            self.backToDeviceTypeList()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func backToDeviceTypeList() {
        guard let destView = UIStoryboard.devices.devicesTypesList else { return }
        self.navigationController?.popToViewControllerCustom(destView: destView, animated: true)
    }
    
    @objc func menuActionListener(sender: UIButton) {
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            guard let objDeviceObject  = self.viewModel.deviceData else {
                return
            }
            let action1 = DooBottomPopupActions_1ViewController.PopupOption(
                title: localizeFor(objDeviceObject.productIsGateway ? "edit_gateway" : "edit_device"),
                color: UIColor.blueHeading, action: {
                    DispatchQueue.getMain(delay: 0.1) {
                        guard let destView = UIStoryboard.devices.addDeviceVC else { return }
                        destView.deviceData = self.viewModel.deviceData
                        destView.isEdit = true
                        self.navigationController?.pushViewController(destView, animated: true)
                    }
                })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption(
                title: localizeFor(objDeviceObject.productIsGateway ? "delete_gateway" : "delete_device"),
                color: UIColor.textFieldErrorColor, action: {
                    self.showDeleteAlert()
                })
            actionsVC.popupType = .generic(localizeFor("quick_actions"), "Device management options", [action1, action2])
            actionsVC.isShowSubtitle = false
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
    
    func showDeleteAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                guard let objDeviceObject  = self.viewModel.deviceData else {
                    return
                }
                
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.delete, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    self.callDeleteDeviceAPI()
                }
                let title = localizeFor(objDeviceObject.productIsGateway ? "are_you_sure_want_to_delete_this_gateway" : "are_you_sure_want_to_delete_this_device")
                alertVC.setAlert(alertTitle: title, leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
}

extension DeviceDetailViewController {
    func animateSwitchNReloadAppliance(index: Int, status:Bool) {
        viewModel.deviceData?.appliances[index].accessStatus = status
        self.tableViewDetail.reloadData()
    }
}

// MARK: - UIScrollViewDelegate
extension DeviceDetailViewController: UIScrollViewDelegate {
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
extension DeviceDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - internet & something went wrong work
extension DeviceDetailViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        self.callGetDeviceDetailFromDeviceIdAPI()
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}
