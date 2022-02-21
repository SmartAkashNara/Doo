//
//  EnterpriseDetailViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewEnterpriseDetail: UITableView!
    
    // MARK: - Variables
    var enterpriseDetailViewModel = EnterpriseDetailViewModel()
    var enterpriseModel: EnterpriseModel!
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard enterpriseModel != nil else { return }
        
        configureTableView()
        setDefaults()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
}

// MARK: - Action listeners
extension EnterpriseDetailViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editActionListener(_ sender: UIButton) {
        if let destView = UIStoryboard.enterprise.addEnterpriseVC {
            destView.enterpriseModel = enterpriseModel
            destView.isEditFlow = true
            self.navigationController?.pushViewController(destView, animated: true)
        }
    }
}

// MARK: - User defined methods
extension EnterpriseDetailViewController {
    func configureTableView() {
        tableViewEnterpriseDetail.dataSource = self
        tableViewEnterpriseDetail.delegate = self
        tableViewEnterpriseDetail.registerCellNib(identifier: DooHeaderDetail_1TVCell.identifier, commonSetting: true)
        tableViewEnterpriseDetail.registerCellNib(identifier: SeparatorFooterTVCell.identifier)
        tableViewEnterpriseDetail.registerCellNib(identifier: DooDetail_1TVCell.identifier)
        tableViewEnterpriseDetail.registerCellNib(identifier: DooTitle_1TVCell.identifier)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewEnterpriseDetail.tableHeaderView = viewNavigationBarDetail
        tableViewEnterpriseDetail.addBounceViewAtTop()
        tableViewEnterpriseDetail.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewEnterpriseDetail.sectionHeaderHeight = 0
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonEdit.setImage(UIImage(named: "imgEditButton"), for: .normal)
        
        if let user = APP_USER, let role = user.selectedEnterprise?.userRole {
            switch role {
            case .admin, .owner:
                buttonEdit.isHidden = false
            default:
                buttonEdit.isHidden = true
            }
        }
    }
    
    func loadData() {
        let title = enterpriseModel.name
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Manage your enterprise detail")
        navigationTitle.text = title
        
        enterpriseDetailViewModel.loadData(enterpriseDetail: enterpriseModel)
        tableViewEnterpriseDetail.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension EnterpriseDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return enterpriseDetailViewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EnterpriseDetailViewModel.EnumSection.enterpriseDetail.index:
            return enterpriseDetailViewModel.arrayEnterPriceDetailFields.count
        case EnterpriseDetailViewModel.EnumSection.groups.index:
            return enterpriseModel.groups.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case EnterpriseDetailViewModel.EnumSection.enterpriseDetail.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: DooDetail_1TVCell.identifier, for: indexPath) as! DooDetail_1TVCell
            cell.cellConfigForEnterpriseDetails(data: enterpriseDetailViewModel.arrayEnterPriceDetailFields[indexPath.row])
            return cell
        case EnterpriseDetailViewModel.EnumSection.groups.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: DooTitle_1TVCell.identifier, for: indexPath) as! DooTitle_1TVCell
            cell.cellConfigEnterpriseDetailGroup(data: enterpriseModel.groups[indexPath.row].name)
            
            return cell
        default:
            return tableView.getDefaultCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DooHeaderDetail_1TVCell.cellHeight
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == EnterpriseDetailViewModel.EnumSection.enterpriseDetail.index {
            return SeparatorFooterTVCell.cellHeight
        } else {
            return 0.01
        }
    }
}

// MARK: - UITableViewDelegate
extension EnterpriseDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooHeaderDetail_1TVCell.identifier) as! DooHeaderDetail_1TVCell
        cell.cellConfig(title: enterpriseDetailViewModel.sections[section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == EnterpriseDetailViewModel.EnumSection.enterpriseDetail.index {
            return tableView.dequeueReusableCell(withIdentifier: SeparatorFooterTVCell.identifier)
        } else {
            return nil
        }
    }
}

// MARK: - UIScrollViewDelegate Methods
extension EnterpriseDetailViewController: UIScrollViewDelegate {
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
extension EnterpriseDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
