//
//  ManageEnterpriseViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class ManageEnterpriseViewController: UIViewController {
    
    struct Menu{
        var image = ""
        var name = ""
    }
    enum EnumMenu: Int { case enterpriseDetail = 0, inviteUsers, userPrivileges, receivedInvitations }
    var arrayMenu = [Menu]()
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: ManageEnterpriseNavigationBarDetailView!
    @IBOutlet weak var tableViewEnterpriseMenu: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    
    // MARK: - Variables
    var enterpriseUsersViewModel = EnterpriseUsersViewModel()
    var enterpriseDataModel: EnterpriseModel? = nil
    var isViewDidLoaded: Bool = false
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        loadMenu()
        callGetUsersBelongsToEnterpriseAPI()
    }
    
    func loadMenu() {
        if let role = enterpriseDataModel?.userRole {
            switch role {
            case .admin, .owner:
                arrayMenu = [
                    Menu(image: "imgEnterpriseDetail", name: localizeFor("enterprise_detail_menu")),
                    Menu(image: "imgInviteUser", name: localizeFor("invite_users_menu")),
                    Menu(image: "imgUserAndPrivileges", name: localizeFor("user_privileges_menu"))
                ]
            default:
                arrayMenu = [
                    Menu(image: "imgEnterpriseDetail", name: localizeFor("enterprise_detail_menu")),
                ]
            }
        }
       
        tableViewEnterpriseMenu.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // if view already loaded
        if isViewDidLoaded {
            callGetUsersBelongsToEnterpriseAPI(isKeepInBackground: true)
            loadNavigationBarDetailView()
        }
        
        // for the first time after view did load, this will make it true
        isViewDidLoaded = true
    }
}

// MARK: - Action listeners
extension ManageEnterpriseViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - User defined methods
extension ManageEnterpriseViewController {
    func configureTableView() {
        tableViewEnterpriseMenu.dataSource = self
        tableViewEnterpriseMenu.delegate = self
        tableViewEnterpriseMenu.registerCellNib(identifier: EnterpriseTitleTVCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewEnterpriseMenu.tableHeaderView = viewNavigationBarDetail
        tableViewEnterpriseMenu.addBounceViewAtTop()
        tableViewEnterpriseMenu.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewEnterpriseMenu.sectionHeaderHeight = 0
        viewNavigationBarDetail.onlyPictures.delegate = self // set its delegates here.
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if let enterpriseModelStrong = enterpriseDataModel {
            enterpriseUsersViewModel.enterpriseId = "\(enterpriseModelStrong.id)"
        }
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        self.navigationTitle.font = UIFont.Poppins.medium(14)
        self.navigationTitle.isHidden = true
        
        loadNavigationBarDetailView()
    }
    
    func loadNavigationBarDetailView(animated: Bool = false) {
        guard let enterpriseData = self.enterpriseDataModel else {return}
        let title = enterpriseData.name
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Manage your enterprise",
            users: enterpriseUsersViewModel.arrayUsers.map({ $0.image }),
            animated: animated)
        self.navigationTitle.text = title
    }
    
    func callGetUsersBelongsToEnterpriseAPI(isKeepInBackground: Bool = false) {
        let param: [String : Any] = ["page": 0, "size": 10,
                                     "sort" : ["column": "name", "sortType": "asc"]]
        
        if !isKeepInBackground {
            API_LOADER.show(animated: true)
        }
        enterpriseUsersViewModel.callGetUsersBelongsToEnterpriseAPI(param,
                                                                    searchingText: "") {
            API_LOADER.dismiss(animated: true)
            self.loadNavigationBarDetailView(animated: true)
            self.tableViewEnterpriseMenu.reloadData()
            
        } unbiasedCompletion: {
        }
    }
}

// MARK: - UITableViewDataSource
extension ManageEnterpriseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseTitleTVCell.identifier, for: indexPath) as! EnterpriseTitleTVCell
        
        cell.singleEnterpriseMenuCellConfig(cellType: .rightArrow, data: self.arrayMenu[indexPath.row])
        cell.controlMain.addTarget(self, action: #selector(cellMainActionListener(_:)), for: .touchUpInside)
        cell.controlMain.tag = indexPath.row
        return cell
    }
    
    @objc func cellMainActionListener(_ sender: UIControl) {
        guard let enterpriseData = self.enterpriseDataModel else {return}
        guard let enumMenu = ManageEnterpriseViewController.EnumMenu(rawValue: sender.tag) else { return }
        switch enumMenu {
        case .enterpriseDetail:
            if let enterpriseDetailVC = UIStoryboard.enterprise.enterpriseDetailVC {
                enterpriseDetailVC.enterpriseModel = enterpriseData
                self.navigationController?.pushViewController(enterpriseDetailVC, animated: true)
            }
        case .inviteUsers:
            if let inviteEnterpriseUsersVC = UIStoryboard.enterpriseUsers.inviteEnterpriseUsersVC {
                inviteEnterpriseUsersVC.enterpriseModel = enterpriseData
                self.navigationController?.pushViewController(inviteEnterpriseUsersVC, animated: true)
            }
        case .userPrivileges:
            if let usersToAssignPrivileges = UIStoryboard.enterpriseUsers.selectUsersForAssignPrivilegesVC {
                usersToAssignPrivileges.enterpriseModel = enterpriseData
                self.navigationController?.pushViewController(usersToAssignPrivileges, animated: true)
            }
        case .receivedInvitations:
            if let receivedInvitationsVC = UIStoryboard.enterprise.receivedInvitationsVC {
                self.navigationController?.pushViewController(receivedInvitationsVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension ManageEnterpriseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ManageEnterpriseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension ManageEnterpriseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.addNavigationAnimation(scrollView)
    }
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            self.navigationTitle.isHidden = false
        }else{
            self.navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= viewNavigationBarDetail.viewCurrentHeight {
            self.viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        }else{
            self.viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}

// MARK: - OnlyPicturesDelegate
extension ManageEnterpriseViewController: OnlyPicturesDelegate {
    func pictureView(_ imageView: UIImageView, didSelectAt index: Int) {
        // navigationToEnterpriseUsers(index: index)
    }
    
    func pictureViewCountDidSelect() {
        navigationToEnterpriseUsers(true)
    }
    
    func navigationToEnterpriseUsers(_ isMoreUserClicked:Bool = false, index:Int? = nil) {
       
        if let role = enterpriseDataModel?.userRole {
            switch role {
            case .admin, .owner:
                if let enterpriseDetailVC = UIStoryboard.enterpriseUsers.enterpriseUsers {
                    enterpriseDetailVC.enterpriseId = enterpriseUsersViewModel.enterpriseId
                    self.navigationController?.pushViewController(enterpriseDetailVC, animated: true)
                }
            default:
                self.showAlert(withMessage: "You don't have access to enterprise users!", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
                break
            }
        }
        /*
         if isMoreUserClicked{
         if let enterpriseDetailVC = UIStoryboard.enterpriseUsers.enterpriseUsers {
         enterpriseDetailVC.enterpriseId = enterpriseUsersViewModel.enterpriseId
         self.navigationController?.pushViewController(enterpriseDetailVC, animated: true)
         }
         }else{
         if let enterpriseUserDetailVC = UIStoryboard.enterpriseUsers.enterpriseUserDetail, let selectedIndex = index{
         enterpriseUserDetailVC.enterpriseUser = enterpriseUsersViewModel.arrayUsers[selectedIndex]
         enterpriseUserDetailVC.enterpriseId = enterpriseUsersViewModel.enterpriseId
         self.navigationController?.pushViewController(enterpriseUserDetailVC, animated: true)
         }
         }
         */
    }

}
