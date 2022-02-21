//
//  EnterpriseUserDetailViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 11/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SDWebImage

class EnterpriseUserDetailViewController: UIViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonQuickActions: UIButton!
    @IBOutlet weak var userHeader: UserDetailHeaderView!
    @IBOutlet weak var tableViewUserDetail: UITableView!
    
    var enterpriseUserDetailViewModel = EnterpriseUserDetailViewModel()
    var enterpriseId: String?
    
    var enterpriseUsersViewModel = EnterpriseUsersViewModel()
    var enterpriseUser: DooUser?
    var privilegesViewModel: PrivilegesViewModel = PrivilegesViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTableView()
        userHeader.labelOfUsername.text = ""
        userHeader.labelOfWrittenUser.text = ""
        
        // callGetOtherUserProfileDataAPI()
        self.loadUserData()
        
        // commented becouse we need to show defult opption delete and manage privilges
        // self.showQuickActionsOnlyForAcceptedUsers()
        
    }
    
    func showQuickActionsOnlyForAcceptedUsers() {
        guard let enterpriseUserStrong = self.enterpriseUser else { return }
        if let status = enterpriseUserStrong.getEnumInvitationStatus,
           status == .accepted {
            self.buttonQuickActions.isHidden = false
        }else{
            self.buttonQuickActions.isHidden = true
        }
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
    }
    
    func loadUserData() {
        guard let enterpriseUser = self.enterpriseUser else {return}
        self.userHeader.setDetail(enterpriseUser)
        self.userHeader.backgroundColor = UIColor.grayCountryHeader
        
        self.navigationTitle.text = enterpriseUser.fullname
        self.enterpriseUserDetailViewModel.loadData(enterpriseUser: enterpriseUser)
        self.tableViewUserDetail.reloadData()
        self.callGetUserPrivillegeDeviceListApi()
    }
    
    func configureTableView() {
        self.tableViewUserDetail.dataSource = self
        self.tableViewUserDetail.delegate = self
        self.tableViewUserDetail.rowHeight = UITableView.automaticDimension
        self.tableViewUserDetail.estimatedRowHeight = 44
        self.tableViewUserDetail.tableHeaderView = self.userHeader
        self.tableViewUserDetail.addBounceViewAtTop()
        self.tableViewUserDetail.registerCellNib(identifier: DooHeaderDetail_1TVCell.identifier, commonSetting: true)
        self.tableViewUserDetail.registerCellNib(identifier: SeparatorFooterTVCell.identifier)
        self.tableViewUserDetail.registerCellNib(identifier: DooDetail_1TVCell.identifier)
        self.tableViewUserDetail.registerCellNib(identifier: DooTree_1TVCell.identifier, commonSetting: true)
    }
    
    @IBAction func backActionListener(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func menuActionListener(sender: UIButton) {
        guard let enterpriseUserStrong = enterpriseUser else { return }
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            var actions = [DooBottomPopupActions_1ViewController.PopupOption]()
            
            let actionManagePrivillege = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("manage_privileges_menu"), color: UIColor.blueSwitch, action: {
                if let userPrivilegesVC = UIStoryboard.enterpriseUsers.userPrivilegesVC {
                    userPrivilegesVC.selectedUsersId = String(self.enterpriseUser?.userId ?? 0)
                    userPrivilegesVC.objEnterpriseUserDetailVC = self
                    userPrivilegesVC.redirectedFrom = .enterpriseUsersPrivilegesSelection(self.privilegesViewModel.infinityTree, cueAlert.Button.update)
                    self.navigationController?.pushViewController(userPrivilegesVC, animated: true)
                }
            })
            
            let deleteUser = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("delete_from_enterprise_menu"), color: UIColor.red, action: {
                self.showDeleteAlert()
            })
            
            if let status = enterpriseUserStrong.getEnumInvitationStatus,
               status == .accepted {
                let actionRole = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("change_user_role_menu"), color: UIColor.blueSwitch, action: {
                    if let changeUserRole = UIStoryboard.enterpriseUsers.changeUserRoleVC{
                        changeUserRole.enterpriseUser = self.enterpriseUser
                        changeUserRole.didChangedEnterpriseUserRole = { [weak self] objEnterpriseUser in
                            guard let strongSelf = self else { return }
                            strongSelf.enterpriseUser = objEnterpriseUser
                            strongSelf.loadUserData()
                        }
                        self.navigationController?.pushViewController(changeUserRole, animated: true)
                    }
                })
                
                let enalbeDisableTitle = localizeFor(enterpriseUserStrong.enable ? "disable_user_menu" : "enable_user_menu")
                let actionEnableDisable = DooBottomPopupActions_1ViewController.PopupOption.init(title: enalbeDisableTitle, color: UIColor.blueSwitch, action: {
                    self.callEnableDisableEnterpriseUserAPI()
                })
                actions.append(actionRole)
                actions.append(actionManagePrivillege)
                actions.append(actionEnableDisable)
                actions.append(deleteUser)
            }else{
                actions.append(actionManagePrivillege)
                actions.append(deleteUser)
            }
            
            actionsVC.popupType = .generic(localizeFor("quick_actions"), "Enterprise user management options", actions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
    func showDeleteAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.white, backgroundColor: UIColor.blueSwitch) {
                    print("cancel tapped")
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.delete, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.clear) {
                    print("delete tapped")
                    DispatchQueue.getMain(delay: 0.2) {
                        self.deleteEnterpriseUser()
                    }
                }
                alertVC.setAlert(alertTitle: localizeFor("are_you_sure_want_to_delete_this_user"), leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    func deleteEnterpriseUser() {
        func callUnwindAndRemoveUser() {
            self.performSegue(withIdentifier: "unwindToUsersList", sender: nil)
            self.view.makeToast("User Removed Successfully!")
            self.navigationController?.popViewController(animated: true)
        }
        
        guard let enterpriseUserStrong = enterpriseUser, let strongEnterpriseId = self.enterpriseId else { return }
        let routingParam: [String: Any] = ["userId" : "\(enterpriseUserStrong.userId)", "enterpriseId": strongEnterpriseId]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .deleteEnterpriseUser(routingParam), method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            callUnwindAndRemoveUser()
        }
    }
}

// MARK: - Services
extension EnterpriseUserDetailViewController {
    func callGetOtherUserProfileDataAPI() {
        guard let enterpriseUserStrong = enterpriseUser else { return }
        let routingParam: [String: Any] = ["id" : "\(enterpriseUserStrong.userId)"]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .getOtherUserProfileData(routingParam), method: .get) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            guard let payload = parsingResponse?["payload"] else { return }
            self.enterpriseUser = DooUser(dict: payload)
            self.loadUserData()
        }
    }
    
    func callGetUserPrivillegeDeviceListApi(isFromPullToRefresh: Bool = false) {
        API_LOADER.show(animated: true)
        privilegesViewModel.callGetSelectedAllDevicesByUserAPI(routingParam: ["userId":enterpriseUser?.userId ?? 0]) {
            API_LOADER.dismiss(animated: true)
            
            if let enterpriseUserStrong = self.enterpriseUser {
                enterpriseUserStrong.privilegesTree = self.privilegesViewModel.infinityTree
                self.enterpriseUserDetailViewModel.createPrivillgesSection(enterpriseUserStrong)
                self.tableViewUserDetail.reloadData()
            }
        }
    }
    
    func callEnableDisableEnterpriseUserAPI() {
        guard let enterpriseUserStrong = enterpriseUser else { return }
        let routingParam: [String: Any] = [
            "id" : enterpriseUserStrong.userId,
            "flag" : !enterpriseUserStrong.enable,
            "enterpriseId" : enterpriseUserStrong.enterpriseId
        ]
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .enableDisableEnterpriseUser(routingParam), method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            self.enterpriseUser?.enable.toggle()
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EnterpriseUserDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension EnterpriseUserDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return enterpriseUserDetailViewModel.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EnterpriseUserDetailViewModel.EnumSection.userDetail.index:
            return enterpriseUserDetailViewModel.arrayOfUserDetailFields.count
        case EnterpriseUserDetailViewModel.EnumSection.privileges.index:
            return self.enterpriseUser?.privilegesTree?.getNumberOfRows() ?? 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case EnterpriseUserDetailViewModel.EnumSection.userDetail.index:
            let cell = tableView.dequeueReusableCell(withIdentifier: DooDetail_1TVCell.identifier, for: indexPath) as! DooDetail_1TVCell
            cell.cellConfig(data: enterpriseUserDetailViewModel.arrayOfUserDetailFields[indexPath.row])
            return cell
        case EnterpriseUserDetailViewModel.EnumSection.privileges.index:
            let node = self.enterpriseUser?.privilegesTree?.infinityCellForRowAtIndex(indexPath.row)
            
            if let value = node?.value as? UserPrivilegeDataModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: DooTree_1TVCell.identifier) as! DooTree_1TVCell
                cell.cellConfig(forEnterpriseUser: value, deepAtLevel: node!.deepAtLevel,
                                isContainsChilds: (node!.children.count != 0), isExpanded: node!.isVisible)
                cell.selectionStyle = .none
                return cell
            }else{
                return tableView.getDefaultCell()
            }
        default:
            return tableView.getDefaultCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case EnterpriseUserDetailViewModel.EnumSection.privileges.index:
            if let _ = self.enterpriseUser?.privilegesTree?.infinityDidSelectAtIndex(indexPath.row) {
                /*
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
                */
                tableView.reloadData()
            }
        default:
            break
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooHeaderDetail_1TVCell.identifier) as! DooHeaderDetail_1TVCell
        cell.cellConfig(title: enterpriseUserDetailViewModel.sections[section])
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == EnterpriseDetailViewModel.EnumSection.enterpriseDetail.index {
            return tableView.dequeueReusableCell(withIdentifier: SeparatorFooterTVCell.identifier)
        } else {
            return nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
    }
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 140.0 {
            navigationTitle.isHidden = false
        }else{
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 186.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        }else{
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
    // healper actions
    @objc func checkmarkOrUnmarkAcitonListener(sender: ButtonOfInfinityTree) {
        if let indexPaths = self.privilegesViewModel.infinityTree?.mark(identitiyOfNode: sender.identity){
            self.tableViewUserDetail.reloadRows(at: indexPaths, with: .fade)
        }
    }
}
