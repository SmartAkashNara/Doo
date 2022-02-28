//
//  DevicesListViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DevicesTypesListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewDevicesList: SayNoForDataTableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonScan: UIButton!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    
    // MARK: - Variables
    private var devicesTypesListViewModel = DevicesTypesListViewModel()
    private var isLoad = false
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        callGetDeviceTypeListAPI(showLoader: true)
        roleBasedDecision()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // call callGetDeviceTypeListAPI APi once view already loaded.
        // This will only call device types list in background to refresh list and device count inside it. Only for count purpose we have kept below logic. Otherwise types are predefined. Going inside of those types, we will have our list.
        if isLoad { callGetDeviceTypeListAPI(showLoader: false) }
        isLoad = true
    }
    
    func roleBasedDecision() {
        // user not allowed to add devices.
        if let user = APP_USER, let role = user.selectedEnterprise?.userRole {
            switch role {
            case .admin, .owner:
                buttonScan.isHidden = false
            default:
                buttonScan.isHidden = true
            }
        }
    }
}

// MARK: - Action listeners
extension DevicesTypesListViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func scanActionListener(_ sender: UIButton) {
        if let qrCodeVC = UIStoryboard.devices.addDeviceUsingQRCodeVC {
            qrCodeVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(qrCodeVC, animated: true)
        }
    }
}

// MARK: - User defined methods
extension DevicesTypesListViewController {
    func configureTableView() {
        tableViewDevicesList.dataSource = self
        tableViewDevicesList.delegate = self
        tableViewDevicesList.registerCellNib(identifier: DooDeviceInfoCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewDevicesList.tableHeaderView = viewNavigationBarDetail
        tableViewDevicesList.addBounceViewAtTop()
        tableViewDevicesList.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewDevicesList.sectionHeaderHeight = 0
        tableViewDevicesList.sayNoSection = .noDeviceListFound("Device")
        
        tableViewDevicesList.addRefreshControlForPullToRefresh {
            self.callGetDeviceTypeListAPI(showLoader: false)
        }
        tableViewDevicesList.sayNoSection = .none
        tableViewDevicesList.getRefreshControl().tintColor = .lightGray
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = localizeFor("device_types_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: localizeFor("device_list_subtitle"))
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        mainView.delegateOfSWWalert = self
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonScan.setImage(UIImage(named: "imgScanCamera"), for: .normal)
    }
}

// MARK: - UITableViewDataSource
extension DevicesTypesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesTypesListViewModel.deviceTypes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooDeviceInfoCell.identifier, for: indexPath) as! DooDeviceInfoCell
        cell.cellConfig(data: devicesTypesListViewModel.deviceTypes[indexPath.row], leftControlType: .logo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension DevicesTypesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let devicesListVC = UIStoryboard.devices.devicesListVC {
            devicesListVC.selectedDeviceType = devicesTypesListViewModel.deviceTypes[indexPath.row]
            self.navigationController?.pushViewController(devicesListVC, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DevicesTypesListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension DevicesTypesListViewController: UIScrollViewDelegate {
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

// MARK: Get Device Type List APi
extension DevicesTypesListViewController {
    func callGetDeviceTypeListAPI(showLoader: Bool = true) {
        if showLoader { API_LOADER.show(animated: true) }
        
        devicesTypesListViewModel.callGetDeviceTypeListAPI { [weak self] in
            if showLoader { API_LOADER.dismiss(animated: true) }
            self?.tableViewDevicesList.stopRefreshing()
            self?.tableViewDevicesList.reloadData()
            self?.tableViewDevicesList.figureOutAndShowNoResults()
        } failure: { [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            if showLoader { API_LOADER.dismiss(animated: true) }
            self?.tableViewDevicesList.stopRefreshing()
        }
    }
}

// MARK: - internet & something went wrong work
extension DevicesTypesListViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.dismissAnyAlerts()
        self.callGetDeviceTypeListAPI(showLoader: true)
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}
