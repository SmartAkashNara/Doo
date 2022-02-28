//
//  EnterpriseUsersViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 06/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseUsersViewController: KeyboardNotifBaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonShowQuickActions: UIButton!
    @IBOutlet weak var searchBar: RightIconTextField!
    @IBOutlet weak var rightConstraintOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var tableViewEnterpriseUsers: SayNoForDataTableView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    // MARK: - Variables
    var enterpriseId: String?
    var enterpriseUsersViewModel = EnterpriseUsersViewModel()
    
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enterpriseUsersViewModel.enterpriseId = enterpriseId
        
        configureTableView()
        setDefaults()
        self.callGetUsersBelongsToEnterpriseAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enterpriseUsersViewModel.shiftAcceptedDisableUserToBottom()
        tableViewEnterpriseUsers.reloadData()
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
}

// MARK: - User defined methods
extension EnterpriseUsersViewController {
    func configureTableView() {
        tableViewEnterpriseUsers.dataSource = self
        tableViewEnterpriseUsers.delegate = self
        tableViewEnterpriseUsers.registerCellNib(identifier: EnterpriseUserTVCell.identifier, commonSetting: true)
        tableViewEnterpriseUsers.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableViewEnterpriseUsers.addBounceViewAtTop()
        
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewEnterpriseUsers.tableHeaderView = viewNavigationBarDetail
        
        tableViewEnterpriseUsers.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewEnterpriseUsers.sectionHeaderHeight = 0
        
        tableViewEnterpriseUsers.addRefreshControlForPullToRefresh {
            self.callGetUsersBelongsToEnterpriseAPI(searchText: self.searchBar.text!, true)
        }

        tableViewEnterpriseUsers.sayNoSection = .noEnterpriseUsersFound("Enterprise Users")
        tableViewEnterpriseUsers.getRefreshControl().tintColor = .lightGray
    }
    
    func setDefaults() {
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
        widthConstraintOfSearchBar.constant = (UIScreen.main.bounds.size.width - 64.0)
        
        searchBar.backgroundColor = UIColor.grayCountryHeader
        searchBar.placeholder = localizeFor("search_placeholder")
        searchBar.font = UIFont.Poppins.medium(14)
        if let rightClearIcon = UIImage.init(named: "clearButton") {
            searchBar.rightIcon =  rightClearIcon
        }
        searchBar.leadingGap = 0
        searchBar.delegateOfRightIconTextField = self
        searchBar.setRightIconUserInteraction(to: true)
        searchBar.returnKeyType = .search
//        searchBar.addTarget(self, action: #selector(self.searchValueChanged(sender:)), for: .editingChanged)
        searchBar.delegate = self
        buttonShowQuickActions.isHidden = true
        searchBar.textColor = .blueHeading
        loadNavigationBarDetail()
    }
    
    func loadNavigationBarDetail() {
        let title = localizeFor("enterprise_users_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "\(enterpriseUsersViewModel.getTotalElements) \(localizeFor("enterprise_users_subtitle"))")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
    }
    
    @IBAction func backActionListener(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func searchActionListener(sender: UIButton) {
        self.openSearchBar()
    }
    @IBAction func searchValueChanged(sender: RightIconTextField) {
        callGetUsersBelongsToEnterpriseAPI(searchText: sender.text!, true)
    }
    
    @IBAction func quickActionsActionListener(sender: UIButton) {
    }
}

// MARK: - Service
extension EnterpriseUsersViewController {
    func callGetUsersBelongsToEnterpriseAPI(isNextPage:Bool = false, searchText: String = "", _ isFromPullToRefresh: Bool = false) {
        var param = enterpriseUsersViewModel.getPageDict(isFromPullToRefresh)
        param["sort"] = ["column": "name", "sortType": "asc"]
        param["criteria"] = [
            ["column": "roleId",
             "operator": "!in",
             "values": ["2"]
            ]
        ] as [[String: Any]]
        if !searchText.isEmpty {
            /*
            param["criteria"] = [
                ["column": "name",
                 "operator": "like",
                 "values": [searchText]
                ]
            ]
             */
        }
        
        tableViewEnterpriseUsers.isAPIstillWorking = true
        if self.enterpriseUsersViewModel.getAvailableElements == 0 && !isFromPullToRefresh && searchText.isEmpty && !isNextPage {
            API_LOADER.show(animated: true)
        }
        enterpriseUsersViewModel.callGetUsersBelongsToEnterpriseAPI(param,
                                                                    searchingText: searchText) { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewEnterpriseUsers.stopRefreshing()
            self?.loadNavigationBarDetail()
            self?.tableViewEnterpriseUsers.reloadData()
            self?.tableViewEnterpriseUsers.isAPIstillWorking = false
            if !searchText.isEmpty {
                self?.tableViewEnterpriseUsers.sayNoSection = .noSearchResultFound("Search")
            } else {
                self?.tableViewEnterpriseUsers.sayNoSection = .noEnterpriseUsersFound("Enterprise Users")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.tableViewEnterpriseUsers.figureOutAndShowNoResults()
            }
        } unbiasedCompletion: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewEnterpriseUsers.stopRefreshing()
            self?.tableViewEnterpriseUsers.isAPIstillWorking = false
        }
    }
    
    func callEnableDisableEnterpriseUserAPI(index: Int) {
        let targetUser = enterpriseUsersViewModel.arrayUsers[index]
        let routingParam: [String: Any] = [
            "id" : targetUser.userId,
            "flag" : !targetUser.enable,
            "enterpriseId" : targetUser.enterpriseId
        ]
        
        // API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .enableDisableEnterpriseUser(routingParam), method: .put) { (parsingResponse) in
            // API_LOADER.dismiss(animated: true)
            // UI Work
            self.enterpriseUsersViewModel.arrayUsers[index].enable.toggle()
            self.animateSwitch(index: index) {
                self.tableViewEnterpriseUsers.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade) {
                    if !self.enterpriseUsersViewModel.arrayUsers[index].enable {
                        // Shift user down at run time... keep this part commented, will be keeping if required.
                        // self.enterpriseUsersViewModel.shiftUserToBottom(index: index)
                        // self.tableViewEnterpriseUsers.reloadData()
                    }
                }
            }
        } failureInform: {
            self.tableViewEnterpriseUsers.reloadData() // Only reload, as internally in array we are toggling after API success.
            let operation = !targetUser.enable ? "Disable" : "Enable"
            CustomAlertView.init(title: "Unable to perform operation \(operation)")
        }
    }
    
    func animateSwitch(index: Int, callBack:(()->())?) {
        guard let cell = tableViewEnterpriseUsers.cellForRow(at: IndexPath(row: index, section: 0)) as? EnterpriseUserTVCell else { callBack?(); return }
        cell.switchToEnableDisable.switchStatusChanged = { value in
            if self.enterpriseUsersViewModel.arrayUsers[index].enable {
                cell.switchToEnableDisable.setOnSwitch()
            }else{
                cell.switchToEnableDisable.setOffSwitch()
            }
        }
        DispatchQueue.getMain(delay: 0.1) {
            callBack?()
        }
    }
    
    func callReinviteEnterpriseUserAPI(index: Int) {
        let targetUser = enterpriseUsersViewModel.arrayUsers[index]
        let routingParam = ["id" : targetUser.id]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .reinviteEnterpriseUser(routingParam), method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            self.enterpriseUsersViewModel.arrayUsers[index].invitationStatus = 1 // show invited again.
            self.tableViewEnterpriseUsers.reloadData()
        }
    }
}

extension EnterpriseUsersViewController {
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

// MARK: - UITableViewDataSource
extension EnterpriseUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.enterpriseUsersViewModel.getTotalElements > self.enterpriseUsersViewModel.arrayUsers.count) &&
            self.enterpriseUsersViewModel.arrayUsers.count != 0{
            
            return enterpriseUsersViewModel.arrayUsers.count + 1 // Last one for pagination loader
        }else{
            return enterpriseUsersViewModel.arrayUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard enterpriseUsersViewModel.arrayUsers.indices.contains(indexPath.row) else {
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "identifier")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "identifier")
            }
            if let activityView = cell.contentView.viewWithTag(102) as? UIActivityIndicatorView {
                activityView.startAnimating()
            }else{
                let activityIndicator = UIActivityIndicatorView.init(style: .medium)
                activityIndicator.tag = 102
                activityIndicator.center = CGPoint.init(x: tableView.center.x, y: 14)
                activityIndicator.startAnimating()
                cell.contentView.addSubview(activityIndicator)
            }
            cell.backgroundColor = .clear
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseUserTVCell.identifier, for: indexPath) as! EnterpriseUserTVCell
        cell.cellConfig(data: enterpriseUsersViewModel.arrayUsers[indexPath.row])
        cell.switchToEnableDisable.switchStatusChanged = { value in
            self.callEnableDisableEnterpriseUserAPI(index: indexPath.row)
        }
        cell.buttonResend.tag = indexPath.row
        cell.buttonResend.addTarget(self, action: #selector(callResendInviteActionListener(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func callResendInviteActionListener(_ sender: UIButton) {
        callReinviteEnterpriseUserAPI(index: sender.tag)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}


// MARK: - UITableViewDelegate
extension EnterpriseUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath)
        if let enterpriseUserDetailVC = UIStoryboard.enterpriseUsers.enterpriseUserDetail {
            enterpriseUserDetailVC.enterpriseUser = enterpriseUsersViewModel.arrayUsers[indexPath.row]
            enterpriseUserDetailVC.enterpriseId = self.enterpriseId
            self.navigationController?.pushViewController(enterpriseUserDetailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - UIScrollViewDelegate
extension EnterpriseUsersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        guard contentYoffset != 0 else { return }
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if enterpriseUsersViewModel.getTotalElements > enterpriseUsersViewModel.getAvailableElements &&
                !tableViewEnterpriseUsers.isAPIstillWorking {
                self.callGetUsersBelongsToEnterpriseAPI(isNextPage: true, searchText: searchBar.text!)
            }
        }
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

// MARK: - UITextFieldDelegate
extension EnterpriseUsersViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callGetUserListbasedOnSearchActive), object: nil)
        self.perform(#selector(callGetUserListbasedOnSearchActive), with: nil, afterDelay: 0.5)
        return true
    }
    
    @objc func callGetUserListbasedOnSearchActive(){
        // if search text is empty, don't search
        self.callGetUsersBelongsToEnterpriseAPI( searchText: self.searchBar.getText(),true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextFieldDelegate
extension EnterpriseUsersViewController: RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField) {
        self.closeSearchBar()
        self.callGetUsersBelongsToEnterpriseAPI(isNextPage: false, searchText: "", true)
    }
}

// MARK: - Unwind from enterprise user detail
extension EnterpriseUsersViewController{
    @IBAction func unwindFromUserDetail(segue: UIStoryboardSegue) {
        if let userDetailVC = segue.source as? EnterpriseUserDetailViewController,
           let userId = userDetailVC.enterpriseUser?.userId {
            
            if let index = self.enterpriseUsersViewModel.arrayUsers.firstIndex(where: {$0.userId == userId}) {
                self.enterpriseUsersViewModel.arrayUsers.remove(at: index)
                self.enterpriseUsersViewModel.totalElements -= 1
                self.loadNavigationBarDetail() // refresh header data
                self.tableViewEnterpriseUsers.reloadData() // refresh table
            }
        }
    }
}
