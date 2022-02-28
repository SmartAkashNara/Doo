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
    @IBOutlet weak var tableViewDevicesList: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonScan: UIButton!
    
    // MARK: - Variables
    var devicesListViewModel = DevicesListViewModel()
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        loadData()
    }
}

// MARK: - Action listeners
extension DevicesTypesListViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func scanActionListener(_ sender: UIButton) {
        print("scanActionListener")
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
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = localizeFor("device_list_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: localizeFor("device_list_subtitle"))
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.Medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonScan.setImage(UIImage(named: "imgScanCamera"), for: .normal)
    }
    
    func loadData() {
        devicesListViewModel.loadData()
        tableViewDevicesList.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension DevicesTypesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesListViewModel.listOfDeviceTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooDeviceInfoCell.identifier, for: indexPath) as! DooDeviceInfoCell
        cell.cellConfig(data: devicesListViewModel.listOfDeviceTypes[indexPath.row], leftControlType: .logo)
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
        print(devicesListViewModel.listOfDeviceTypes[indexPath.row])
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
