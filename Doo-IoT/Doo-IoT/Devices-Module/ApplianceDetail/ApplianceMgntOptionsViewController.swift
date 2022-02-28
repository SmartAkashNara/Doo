//
//  ApplianceMgntOptionsViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class ApplianceMgntOptionsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewDetail: UITableView!
    
    var applianceData: ApplianceDataModel!
    private var viewModel = ApplianceMgntOptionsViewModel()
    private var deviceDetailViewModel = DeviceDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard applianceData != nil else { return }
        setDefaults()
        configureTableView()
        viewModel.loadMenu()
        tableViewDetail.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNavigationBar()
    }
}

// MARK: Appliance Enable disable API
extension ApplianceMgntOptionsViewController {
    func callApplianceToggleEnableAPI() {
        let param: [String:Any] = [
            "applianceId": applianceData.id,
            "flag": !applianceData.accessStatus,
        ]
        
        API_LOADER.show(animated: true)
        deviceDetailViewModel.callApplianceToggleEnableAPI(param) {
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: localizeFor(self.applianceData.accessStatus ? "appliance_enabled" : "appliance_disabled"), forPurpose: .success).showForWhile(animated: true)
            self.applianceData.accessStatus.toggle()
            DispatchQueue.getMain(delay: 0.3) {
                self.navigationController?.popViewController(animated: true)
            }
        } failureMessageBlock: { msg in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        }
    }
}

// MARK: - User defined methods
extension ApplianceMgntOptionsViewController {
    func configureTableView() {
        tableViewDetail.dataSource = self
        tableViewDetail.delegate = self
        tableViewDetail.registerCellNib(identifier: EnterpriseTitleTVCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewDetail.tableHeaderView = viewNavigationBarDetail
        tableViewDetail.addBounceViewAtTop()
        tableViewDetail.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewDetail.sectionHeaderHeight = 0
        tableViewDetail.separatorStyle = .none
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
        
        loadNavigationBar()
        buttonBack.addTarget(self, action: #selector(self.backActionListener(sender:)), for: .touchUpInside)
        buttonMenu.addTarget(self, action: #selector(self.menuActionListener(sender:)), for: .touchUpInside)
    }
    
    func loadNavigationBar() {
        let title = applianceData.applianceName
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: applianceData.applianceTypeName)
        navigationTitle.text = title
    }
}

// MARK: - Actions
extension ApplianceMgntOptionsViewController {
    @objc func backActionListener(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func menuActionListener(sender: UIButton) {
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption(
                title: localizeFor(applianceData.accessStatus ? "disable_appliance" : "enable_appliance"),
                color: UIColor.blueHeading, action: {
                    self.callApplianceToggleEnableAPI()
                })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption(
                title: localizeFor("edit_appliance"),
                color: UIColor.blueHeading, action: {
                    DispatchQueue.getMain(delay: 0.1) {
                        guard let destView = UIStoryboard.devices.editApplicationVC else { return }
                        destView.applianceData = self.applianceData
                        self.navigationController?.pushViewController(destView, animated: true)
                    }
                })
            actionsVC.popupType = .generic(localizeFor("quick_actions"), "Appliance management options", [action1, action2])
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension ApplianceMgntOptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrayMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseTitleTVCell.identifier, for: indexPath) as! EnterpriseTitleTVCell
        cell.singleApplianceMgnOption(cellType: .rightArrow, data: viewModel.arrayMenu[indexPath.row])
        //        cell.controlMain.addTarget(self, action: #selector(setNewEnterpriseIfItsNotTheCurrentSelectedOne(_:)), for: .touchUpInside)
        cell.controlMain.tag = indexPath.row
        return cell
    }
    
    @objc func cellMainActionListener(_ sender: UIControl) {
        guard let enumMenu = ApplianceMgntOptionsViewModel.EnumMenu(rawValue: sender.tag) else { return }
        switch enumMenu {
        case .schedulers:
            break
        case .accessHistory:
            break
        case .bindingList:
            break
        case .groups:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
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
extension ApplianceMgntOptionsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

