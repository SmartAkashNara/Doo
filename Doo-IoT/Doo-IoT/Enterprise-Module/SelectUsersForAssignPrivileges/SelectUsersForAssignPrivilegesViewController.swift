//
//  SelectUsersForAssignPrivilegesViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 14/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SelectUsersForAssignPrivilegesViewController: KeyboardNotifBaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var searchBar: RightIconTextField!
    @IBOutlet weak var rightConstraintOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewUsers: SayNoForDataTableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var buttonAssignPrivileges: UIButton!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    // MARK: - Variables
    var selectUsersForAssignPrivilegesViewModel = SelectUsersForAssignPrivilegesViewModel()
    var headerViewCell: DooUsersCollectionTVCell?
    var isSearchActive = false
    
    var enterpriseModel: EnterpriseModel!
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        callGetUserListApi()
    }
    override func keyboardShown(keyboardHeight: CGFloat, duration: Double) {
        UIView.animate(withDuration: duration) {
            self.constraintBottomTableView.constant = keyboardHeight - cueSize.bottomHeightOfSafeArea - 70
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
extension SelectUsersForAssignPrivilegesViewController {
    func configureTableView() {
        tableViewUsers.dataSource = self
        tableViewUsers.delegate = self
        tableViewUsers.registerCellNib(identifier: DooUsersCollectionTVCell.identifier, commonSetting: true)
        tableViewUsers.registerCellNib(identifier: EnterpriseUserTVCell.identifier)
        tableViewUsers.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewUsers.sectionHeaderHeight = 0
        
        tableViewUsers.addBounceViewAtTop()
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewUsers.tableHeaderView = viewNavigationBarDetail
        
        // pagination work
        tableViewUsers.addRefreshControlForPullToRefresh {
            self.callGetUserListApi(searchText:  self.searchBar.text!, true)
        }
        tableViewUsers.sayNoSection = .noUsersToInviteFound("Users")
        tableViewUsers.getRefreshControl().tintColor = .lightGray
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
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
        searchBar.textColor = .blueHeading
        
        rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
        widthConstraintOfSearchBar.constant = (UIScreen.main.bounds.size.width - 64.0)
        
        let title = localizeFor("select_users")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: localizeFor("select_users_for_assign_privileges_subtitle"))
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonSearch.setImage(UIImage(named: "imgSearchBlue"), for: .normal)
        
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
        buttonAssignPrivileges.setThemeAppBlueWithArrow(localizeFor("assign_privileges_button"))
        enableDisbaleAssignButton()
    }
    
    func reloadLists(tableIndexPath: IndexPath) {
        tableViewUsers.performBatchUpdates({
            tableViewUsers.reloadRows(at: [tableIndexPath], with: .fade)
        }) { (flag) in
            self.tableViewUsers.reloadData {
                self.headerViewCell?.scollToLastIndexPath()
            }
        }
    }
    
    func resetAllSelectedData(){
        closeSearchBar()
        selectUsersForAssignPrivilegesViewModel.arrayUsers.forEach { (obj) in
            obj.selected = false
        }
        selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.removeAll()
        tableViewUsers.reloadData()
        if self.isSearchActive == true {
            self.tableViewUsers.sayNoSection = .noSearchResultFound("Search")
        } else {
            self.tableViewUsers.sayNoSection = .noUsersToInviteFound("Users")
        }
        tableViewUsers.figureOutAndShowNoResults()
    }
}

// MARK: - Action listeners
extension SelectUsersForAssignPrivilegesViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func searchActionListener(_ sender: UIButton) {
        self.openSearchBar()
    }
    @IBAction func assignPrivilegesActionListener(_ sender: UIButton) {
        if let privilegesVC = UIStoryboard.enterpriseUsers.userPrivilegesVC {
            privilegesVC.redirectedFrom = .enterpriseUsersPrivilegesSelection(nil, nil)
            privilegesVC.selectedUsersId = selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.map({String($0.userId)}).joined(separator: ",")
            privilegesVC.objSelectUsersForAssignPrivilegesVC = self
            self.navigationController?.pushViewController(privilegesVC, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension SelectUsersForAssignPrivilegesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(callGetUserListbasedOnSearchActive), object: nil)
        self.perform(#selector(callGetUserListbasedOnSearchActive), with: nil, afterDelay: 0.5)
//        self.hideButtonAndHeaderPartIfArrayNotEmpty()
//        if textField.text?.count == 1 {
//            self.buttonAssignPrivileges.isHidden = false
//        } else {
//            self.buttonAssignPrivileges.isHidden = true
//        }
        return true
    }
    
    @objc func callGetUserListbasedOnSearchActive(){
        isSearchActive = true
        // if search text is empty, don't search
            callGetUserListApi(searchText: searchBar.getText(),true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - RightIconTextFieldDelegate
extension SelectUsersForAssignPrivilegesViewController: RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField) {
        self.closeSearchBar()
        self.callGetUserListApi(isNextpage: false , searchText: "", true)
    }
}

extension SelectUsersForAssignPrivilegesViewController {
    func openSearchBar() {
        isSearchActive = true
        UIView.animate(withDuration: 0.2, animations: {
            self.rightConstraintOfSearchBar.constant = 8
            self.viewNavigationBar.layoutIfNeeded()
        }) { (_) in
            self.searchBar.becomeFirstResponder()
        }
    }
    
    func closeSearchBar() {
        isSearchActive = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
//        self.buttonAssignPrivileges.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
            self.viewNavigationBar.layoutIfNeeded()
        }) { (_) in
        }
    }
    
    func enableDisbaleAssignButton(){
        buttonAssignPrivileges.alpha = selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.count == 0 ? 0.5 : 1
        buttonAssignPrivileges.isUserInteractionEnabled = selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.count == 0 ? false : true
    }
}

// MARK: - UITableViewDataSource
extension SelectUsersForAssignPrivilegesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.selectUsersForAssignPrivilegesViewModel.getTotalElements > self.selectUsersForAssignPrivilegesViewModel.arrayUsers.count) &&
            self.selectUsersForAssignPrivilegesViewModel.arrayUsers.count != 0{
            
            return selectUsersForAssignPrivilegesViewModel.arrayUsers.count + 1 // Last one for pagination loader
        }else{
            return selectUsersForAssignPrivilegesViewModel.arrayUsers.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard selectUsersForAssignPrivilegesViewModel.arrayUsers.indices.contains(indexPath.row) else {
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
        cell.cellConfigUserPrivileges(data: selectUsersForAssignPrivilegesViewModel.arrayUsers[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.selectUsersForAssignPrivilegesViewModel.arrayUsers.count == 0 && selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.count != 0 {
            return 0.01
        }
        return selectUsersForAssignPrivilegesViewModel.isHeaderShow ? DooUsersCollectionTVCell.cellHeight : 0.01
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UITableViewDelegate
extension SelectUsersForAssignPrivilegesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.selectUsersForAssignPrivilegesViewModel.arrayUsers.indices.contains(indexPath.row) else {
            return
        }
        selectUsersForAssignPrivilegesViewModel.checkUncheckMainList(index: indexPath.row)
        // self.buttonAssignPrivileges.isHidden = false
        reloadLists(tableIndexPath: indexPath)
        enableDisbaleAssignButton()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooUsersCollectionTVCell.identifier) as! DooUsersCollectionTVCell
        cell.cellConfig(data: selectUsersForAssignPrivilegesViewModel.arraySelectedUsers)
        cell.didSelectUser = { selectedUser in
            if let selectedUserIndex = self.selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.firstIndex ( where: { (user) -> Bool in
                selectedUser.id == user.id
            }) {
                let index = self.selectUsersForAssignPrivilegesViewModel.removeSelectedUser(index: selectedUserIndex)
                self.reloadLists(tableIndexPath: IndexPath(row: index, section: 0))
                self.enableDisbaleAssignButton()
            }
        }
        headerViewCell = cell
        return cell
    }
    func setSelectedUser(){
        for (index,obj) in selectUsersForAssignPrivilegesViewModel.arrayUsers.enumerated(){
            if   self.selectUsersForAssignPrivilegesViewModel.arraySelectedUsers.contains(where: {$0.id == obj.id}){
                selectUsersForAssignPrivilegesViewModel.arrayUsers[index].selected = true
            }else{
                selectUsersForAssignPrivilegesViewModel.arrayUsers[index].selected = false
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - UIScrollViewDelegate Methods
extension SelectUsersForAssignPrivilegesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        // guard contentYoffset != 0 else { return }
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if selectUsersForAssignPrivilegesViewModel.getTotalElements > selectUsersForAssignPrivilegesViewModel.getAvailableElements &&
                !tableViewUsers.isAPIstillWorking {
                callGetUserListApi(isNextpage: true, searchText: searchBar.text!)
            }
        }
    }
    
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            navigationTitle.isHidden = false
        } else {
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 76.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        } else {
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SelectUsersForAssignPrivilegesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Service
extension SelectUsersForAssignPrivilegesViewController {
    func callGetUserListApi(isNextpage: Bool = false,
                            searchText: String = "",
                            _ isFromPullToRefresh: Bool = false) {
       
        var param = selectUsersForAssignPrivilegesViewModel.getPageDict(isFromPullToRefresh)
        param["sort"] = ["column": "name", "sortType": "asc"]
        param["criteria"] = [
            ["column": "roleId",
             "operator": "!in",
             "values": ["2", "3"]
            ]
        ] as [[String: Any]]
        if !searchText.isEmpty {
            /*
            if var criteria = param["criteria"] as? [[String: Any]]{
                criteria.append(["column": "name",
                                 "operator": "in",
                                 "values": [searchText]
                                ])
                param["criteria"] = criteria
            }
             */
        }
        
        self.tableViewUsers.isAPIstillWorking = true
        
        if self.selectUsersForAssignPrivilegesViewModel.getAvailableElements == 0 && searchText.isEmpty && !isFromPullToRefresh && !isNextpage{
            // when there is no search
            API_LOADER.show(animated: true)
        }
        
        selectUsersForAssignPrivilegesViewModel.getEnterpriseUsersAPI(searchText: searchText,
                                                                             param: param) { [weak self] in
            API_LOADER.dismiss(animated: true)
            
            self?.tableViewUsers.isAPIstillWorking = false
            if isFromPullToRefresh {
                self?.tableViewUsers.stopRefreshing()
            }
            // below stuff was kept earlier by Krunal, still we are not sure about the purpose of these two lines of code.
              self?.setSelectedUser()
             self?.hideButtonAndHeaderPartIfArrayNotEmpty()
            self?.enableDisbaleAssignButton()
             self?.tableViewUsers.reloadData()
            if self?.isSearchActive == true {
                self?.tableViewUsers.sayNoSection = .noSearchResultFound("Search")
            } else {
                self?.tableViewUsers.sayNoSection = .noUsersToInviteFound("Users")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                
                self?.tableViewUsers.figureOutAndShowNoResults()
            }
        } failureMessageBlock: { msg in
            API_LOADER.dismiss(animated: true)
            self.tableViewUsers.isAPIstillWorking = false
        }
    }
    
    func hideButtonAndHeaderPartIfArrayNotEmpty(){
        if self.selectUsersForAssignPrivilegesViewModel.arrayUsers.count == 0{
            self.buttonAssignPrivileges.isHidden = true
            self.headerViewCell = nil
        } else {
            buttonAssignPrivileges.isHidden = false
        }
    }
}
