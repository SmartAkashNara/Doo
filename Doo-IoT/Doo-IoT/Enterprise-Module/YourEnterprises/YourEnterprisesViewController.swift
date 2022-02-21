//
//  YourEnterprisesViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
class YourEnterprisesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewYourEnterprises: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonAdd: UIButton!
    
    // MARK: - Variables
    var arrayAllEnterprises = [EnterpriseModel]()
    var arrayOtherEnterprises = [EnterpriseModel]()
    var currentSelectedEnterprise: EnterpriseModel?
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh enterprise updates
        self.reloadList() // Reload data.
    }
    
    func reloadList() {
        self.arrayAllEnterprises = ENTERPRISE_LIST
        self.loadData()
    }
}

// MARK: - Action listeners
extension YourEnterprisesViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func addActionListener(_ sender: UIButton) {
        if let addEnterprisesVC = UIStoryboard.enterprise.addEnterpriseVC {
            addEnterprisesVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addEnterprisesVC, animated: true)
        }
    }
}

// MARK: - User defined methods
extension YourEnterprisesViewController {
    func configureTableView() {
        tableViewYourEnterprises.dataSource = self
        tableViewYourEnterprises.delegate = self
        tableViewYourEnterprises.registerCellNib(identifier: EnterpriseTitleTVCell.identifier, commonSetting: true)
        tableViewYourEnterprises.registerCellNib(identifier: YECurrentlySelectedEnterpriseHeader.identifier)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewYourEnterprises.tableHeaderView = viewNavigationBarDetail
        tableViewYourEnterprises.addBounceViewAtTop()
        tableViewYourEnterprises.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewYourEnterprises.sectionHeaderHeight = 0
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = localizeFor("your_enterprises_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "You can change your enterprise from here")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonAdd.setImage(UIImage(named: "imgAddButton"), for: .normal)
    }
    
    func loadData() {
        
        if let dooUser = APP_USER, let selectedEnterprise = dooUser.selectedEnterprise {
            self.filterEnterprises(arrayAllEnterprises: self.arrayAllEnterprises, currentlySelectedEnterprise: selectedEnterprise.id)
            tableViewYourEnterprises.reloadData()
        }
    }
    func navigateToEnterprise(_ enterprise: EnterpriseModel) {
        if let manageEnterpriseVC = UIStoryboard.enterprise.manageEnterpriseVC {
            manageEnterpriseVC.enterpriseDataModel = enterprise
            self.navigationController?.pushViewController(manageEnterpriseVC, animated: true)
        }
    }
}

// MARK: - Removed currently selected enterprise from other enterprises...
extension YourEnterprisesViewController {
    func filterEnterprises(arrayAllEnterprises: [EnterpriseModel], currentlySelectedEnterprise: Int) {
        arrayOtherEnterprises = arrayAllEnterprises
        if let selectedEnterpriseIndex = arrayOtherEnterprises.firstIndex ( where: { (enterprise) -> Bool in
            enterprise.id == currentlySelectedEnterprise
        }) {
            currentSelectedEnterprise = arrayOtherEnterprises.remove(at: selectedEnterpriseIndex)
        }
    }
}

// MARK: - UITableViewDataSource
extension YourEnterprisesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOtherEnterprises.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseTitleTVCell.identifier, for: indexPath) as! EnterpriseTitleTVCell
        cell.entepriseCellConfig(cellType: .rightArrow, data: self.arrayOtherEnterprises[indexPath.row])
        cell.controlMain.addTarget(self, action: #selector(self.cellMainActionListener(_:)), for: .touchUpInside)
        cell.controlMain.tag = indexPath.row
        return cell
    }
    
    @objc func cellMainActionListener(_ sender: UIControl) {
        self.navigateToEnterprise(self.arrayOtherEnterprises[sender.tag])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.arrayOtherEnterprises.count > 0 ? YECurrentlySelectedEnterpriseHeader.cellHeightWithCurrentEnterprise : YECurrentlySelectedEnterpriseHeader.cellHeightWithoutCurrentEnterprise
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension YourEnterprisesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let currentSelectedEnterprise = self.currentSelectedEnterprise else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: YECurrentlySelectedEnterpriseHeader.identifier) as! YECurrentlySelectedEnterpriseHeader
        cell.cellConfigYourEnterprices(data: currentSelectedEnterprise)
        cell.controlMain.addTarget(self, action: #selector(cellSelectedEnterpriseActionListener(_:)), for: .touchUpInside)
        cell.labelHeaderTitleBottom.isHidden = self.arrayOtherEnterprises.count <= 0
        return cell
    }
    
    @objc func cellSelectedEnterpriseActionListener(_ sender: UIControl) {
        guard let currentSelectedEnterprise = self.currentSelectedEnterprise else { return }
        self.navigateToEnterprise(currentSelectedEnterprise)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension YourEnterprisesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension YourEnterprisesViewController: UIScrollViewDelegate {
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
