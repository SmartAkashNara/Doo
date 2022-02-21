//
//  DevicesListViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DevicesListViewController: KeyboardNotifBaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewDeviceList: SayNoForDataTableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var searchBar: RightIconTextField!
    @IBOutlet weak var rightConstraintOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    
    // MARK: - Variables
    var selectedDeviceType: DeviceTypeDataModel!
    private var devicesListViewModel = DevicesListViewModel()
    private var isLoad = false
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard selectedDeviceType != nil else { return }
        
        self.configureTableView()
        self.setDefaults()
        self.callGetDeviceListByTypeAPI()
    }
    override func viewWillAppear(_ animated: Bool) {
        if isLoad {
            tableViewDeviceList.reloadData()
        }
        isLoad = true
    }
    
    override func keyboardShown(keyboardHeight: CGFloat, duration: Double) {
        UIView.animate(withDuration: duration) {
            self.constraintBottomTableView.constant = keyboardHeight - cueSize.bottomHeightOfSafeArea
            self.view.layoutIfNeeded()
        }
    }
    override func keyboardDismissed(keyboardHeight: CGFloat, duration: Double) {
        UIView.animate(withDuration: duration) {
            self.constraintBottomTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func updateOnlineOfflineDeviceStatus(notification:Notification) {
        guard let dictObj = notification.object else { return }
        let json = JSON.init(dictObj)
        let macAddresss = json["macAddress"].stringValue
        let statusOnlineOffline = json["status"].boolValue
        devicesListViewModel.devices.forEach { objDevice in
            if objDevice.macAddress == macAddresss{
                objDevice.deviceStatus = statusOnlineOffline ? 1 : 0
                objDevice.appliances.forEach { objApplience in
                    objApplience.deviceStatus = statusOnlineOffline
                }
            }
        }
        tableViewDeviceList.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)
    }


}

// MARK: - Action listeners
extension DevicesListViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func searchActionListener(_ sender: UIButton) {
        openSearchBar()
    }
    @IBAction func unwindSegueFromDeviceDetailToDevicesList(segue: UIStoryboardSegue) {
        if let sourceView = segue.source as? DeviceDetailViewController, let deviceData = sourceView.deviceData {
            devicesListViewModel.devices.removeAll(where: { $0.enterpriseDeviceId == deviceData.enterpriseDeviceId })
            tableViewDeviceList.reloadData()
            tableViewDeviceList.figureOutAndShowNoResults()
        }
    }
}

// MARK: - RightIconTextFieldDelegate
extension DevicesListViewController: RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField) {
        if !textfield.text!.isEmpty {
            callGetDeviceListByTypeAPI(searchText: "", false)
        }
        self.closeSearchBar()
    }
}

// MARK: - Search bar open and close methods
extension DevicesListViewController {
    func openSearchBar() {
        UIView.animate(withDuration: 0.2, animations: {
            self.rightConstraintOfSearchBar.constant = 8
            self.viewNavigationBar.layoutIfNeeded()
        }) { (_) in
            self.searchBar.becomeFirstResponder()
        }
    }
    func closeSearchBar() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
            self.viewNavigationBar.layoutIfNeeded()
        }) { (_) in
        }
    }
}

// MARK: - UITextFieldDelegate
extension DevicesListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.getSearchText(range: range, replacementString: string)
        callGetDeviceListByTypeAPI(searchText: searchText, true)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - User defined methods
extension DevicesListViewController {
    func configureTableView() {
        tableViewDeviceList.dataSource = self
        tableViewDeviceList.delegate = self
        tableViewDeviceList.registerCellNib(identifier: DooDeviceInfoCell.identifier, commonSetting: true)
        tableViewDeviceList.registerCellNib(identifier: DooNoteTVCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewDeviceList.tableHeaderView = viewNavigationBarDetail
        tableViewDeviceList.addBounceViewAtTop()
        tableViewDeviceList.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewDeviceList.sectionHeaderHeight = 0
        tableViewDeviceList.sayNoSection = .noDeviceListFound("Device")
        
        // pagination work
        tableViewDeviceList.addRefreshControlForPullToRefresh {
            self.callGetDeviceListByTypeAPI(searchText: self.searchBar.getText(), true)
        }
        tableViewDeviceList.getRefreshControl().tintColor = .lightGray
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = selectedDeviceType.name
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: selectedDeviceType.gateway ? "Control the appliances" : "Manage and control devices")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        mainView.delegateOfSWWalert = self
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonSearch.setImage(UIImage(named: "imgSearchBlue"), for: .normal)
        
        searchBar.backgroundColor = UIColor.grayCountryHeader
        searchBar.placeholder = localizeFor("search_placeholder")
        searchBar.font = UIFont.Poppins.medium(14)
        if let rightClearIcon = UIImage.init(named: "clearButton") {
            searchBar.rightIcon =  rightClearIcon
        }
        searchBar.leadingGap = 0
        searchBar.delegateOfRightIconTextField = self
        searchBar.setRightIconUserInteraction(to: true)
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        
        rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateOnlineOfflineDeviceStatus(notification:)), name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)
    }
    

}

// MARK: - UITableViewDataSource
extension DevicesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesListViewModel.devices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooDeviceInfoCell.identifier, for: indexPath) as! DooDeviceInfoCell
        cell.cellConfigForDeviceList(data: devicesListViewModel.devices[indexPath.row], leftControlType: .dot,isGateway: selectedDeviceType.gateway)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return devicesListViewModel.devices.count.isZero() ? 0.01 : DooNoteTVCell.cellHeight
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension DevicesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destView = UIStoryboard.devices.deviceDetailVC else { return }
        destView.deviceData = devicesListViewModel.devices[indexPath.row]
        navigationController?.pushViewController(destView, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooNoteTVCell.identifier) as! DooNoteTVCell
        cell.cellConfig(note: localizeFor(selectedDeviceType.gateway ? "gateway_list_header" : "device_list_header"))
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DevicesListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension DevicesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
        fetchNextPage(scrollView)
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
    func fetchNextPage(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        guard contentYoffset != 0 else { return }
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if devicesListViewModel.getTotalElements > devicesListViewModel.getAvailableElements &&
                !tableViewDeviceList.isAPIstillWorking {
                self.callGetDeviceListByTypeAPI(isNextPage: true, searchText: self.searchBar.getText())
            }
        }
    }
}

// MARK: - internet & something went wrong work
extension DevicesListViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        self.callGetDeviceListByTypeAPI()
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}

// MARK: Service
extension DevicesListViewController {
    func callGetDeviceListByTypeAPI(isNextPage:Bool = false, searchText: String = "", _ isFromPullToRefresh: Bool = false) {
        let value = searchText.isEmpty ?  selectedDeviceType.productTypeId : searchText
        let deviceOperator = searchText.isEmpty ?  "=" : "like"
        let deviceColumn = searchText.isEmpty ?  "productTypeId" : "deviceName"

        let param: [String:Any] = [
            "criteria": [
                ["column": deviceColumn,
                 "operator": deviceOperator,
                 "values": [value]
                ]],
            "sort": ["column": deviceColumn,
                     "sortType": "asc"],
        ] + devicesListViewModel.getPageDict(isFromPullToRefresh)        
        
        if  self.devicesListViewModel.getAvailableElements == 0 && !isFromPullToRefresh && searchText.isEmpty && !isNextPage {
            API_LOADER.show(animated: true)
        }
        
        tableViewDeviceList.isAPIstillWorking = true
        devicesListViewModel.callGetDeviceListByTypeAPI(param: param,searchText: nil) { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.mainView.dismissSomethingWentWrong()
            self?.mainView.dismissInternetOff()
            self?.tableViewDeviceList.stopRefreshing()
            self?.tableViewDeviceList.isAPIstillWorking = false
             self?.tableViewDeviceList.reloadData()
            self?.tableViewDeviceList.figureOutAndShowNoResults()
        } failure: {  [weak self] msg in
            debugPrint("failure")
            self?.mainView.showSomethingWentWrong()
        } internetFailure: {  [weak self] in
            debugPrint("internetFailure")
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewDeviceList.stopRefreshing()
            self?.tableViewDeviceList.isAPIstillWorking = false
        }
    }
    
    func updateTablePlaceHolder(isSearchOn:Bool){
        if isSearchOn{
            tableViewDeviceList.changeIconAndTitleAndSubtitle(title: "Search data not Found", detailStr: "No devcie available", icon: "noDataSchedule")
        }else{
            tableViewDeviceList.changeIconAndTitleAndSubtitle(title: "Device Not Found", detailStr: "No devcie available", icon: "noDataSchedule")
        }
    }
}
