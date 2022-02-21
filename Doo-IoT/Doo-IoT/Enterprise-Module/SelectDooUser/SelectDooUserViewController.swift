//
//  SelectDooUserViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SelectDooUserViewController: KeyboardNotifBaseViewController {

    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var tableViewUsers: SayNoForDataTableView!
//    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    @IBOutlet weak var searchBar: RightIconTextField!
    
    let selectDooUserViewModel = SelectDooUserViewModel()
    var arrayUsersPreSelected = [DooUser]()
    var enterpriseId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setDefaults()
        callGetUserListApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
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

// MARK: - Action listeners
extension SelectDooUserViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - User defined methods
extension SelectDooUserViewController {
    func configureTableView() {
        tableViewUsers.dataSource = self
        tableViewUsers.delegate = self
        tableViewUsers.registerCellNib(identifier: EnterpriseUserTVCell.identifier, commonSetting: true)
        // pagination work
        tableViewUsers.addRefreshControlForPullToRefresh {
            self.callGetUserListApi(searchText: self.searchBar.getText(), true)
        }
        tableViewUsers.sayNoSection = .noUsersFound("Users")
        tableViewUsers.getRefreshControl().tintColor = .lightGray
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
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
        
//        searchBar.borderStyle = .none
//        searchBar.attributedPlaceholder = NSAttributedString(string: localizeFor("search_placeholder"),
//                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.blueHeadingAlpha20])
//        searchBar.tintColor = UIColor.blueSwitch
//        searchBar.font = UIFont.Poppins.medium(14)
//        searchBar.textColor = UIColor.blueHeading
//        searchBar.backgroundColor = UIColor.clear
//        searchBar.returnKeyType = .search
//        searchBar.delegate = self
    }

    func callGetUserListApi(isNextPage:Bool = false,
                            searchText: String = "",
                            _ isFromPullToRefresh: Bool = false) {
        var isForNextPage = isNextPage
        if isFromPullToRefresh {
            isForNextPage = false // just passing false, so it works with page: 0
        }
        let param = selectDooUserViewModel.getPageDict(isFromPullToRefresh)
        
        if selectDooUserViewModel.getAvailableElements == 0 && !isFromPullToRefresh && searchText.isEmpty && !isNextPage {
            API_LOADER.show(animated: true)
        }
        if searchText.isEmpty {
            self.searchBar.text = ""
        }
        tableViewUsers.isAPIstillWorking = true
        selectDooUserViewModel.callGetAllEnterpriseUsersAPI(searchText: searchText, arrayPreSelectedGroups: arrayUsersPreSelected, param: param) {
            if !isFromPullToRefresh && searchText.isEmpty {
                API_LOADER.dismiss(animated: true)
            }
            self.tableViewUsers.stopRefreshing()
            self.tableViewUsers.isAPIstillWorking = false
            self.tableViewUsers.reloadData()
            
            if !searchText.isEmpty {
                self.tableViewUsers.sayNoSection = .noSearchResultFound("Search")
            } else {
                self.tableViewUsers.sayNoSection = .noUsersFound("Users")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tableViewUsers.figureOutAndShowNoResults()
            }
        } failureMessageBlock: {
            API_LOADER.dismiss(animated: true)
            self.tableViewUsers.stopRefreshing()
        }
    }
}


// MARK: - UITableViewDataSource
extension SelectDooUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectDooUserViewModel.getTotalElements > self.selectDooUserViewModel.arrayUsers.count
            && self.selectDooUserViewModel.arrayUsers.count != 0 {
            
            return selectDooUserViewModel.arrayUsers.count + 1 // Last one for pagination loader
        }else{
            return selectDooUserViewModel.arrayUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard selectDooUserViewModel.arrayUsers.indices.contains(indexPath.row) else {
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
        cell.cellConfigInviteUser(data: selectDooUserViewModel.arrayUsers[indexPath.row], active: .none)
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UITableViewDelegate
extension SelectDooUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDooUserViewModel.selectedUser = selectDooUserViewModel.arrayUsers[indexPath.row]
        performSegue(withIdentifier: "unwindSegueFromSelectDooUserToInviteEnterpriseUsers", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - UIScrollViewDelegate
extension SelectDooUserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        // guard contentYoffset != 0 else { return }
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if selectDooUserViewModel.getTotalElements > selectDooUserViewModel.getAvailableElements &&
                !tableViewUsers.isAPIstillWorking {
                self.callGetUserListApi(isNextPage: true, searchText: searchBar.getText())
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension SelectDooUserViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.getSearchText(range: range, replacementString: string)
        self.callGetUserListApi(searchText: searchText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SelectDooUserViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - RightIconTextFieldDelegate
extension SelectDooUserViewController: RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField) {
        self.searchBar.text = ""
        self.loadDefaultListOfAllUsers()
    }
    
    func loadDefaultListOfAllUsers() {
        self.selectDooUserViewModel.arrayUsers = self.selectDooUserViewModel.arrayUsersWithoutSearch // Assign the default list of all users as it is.
        self.tableViewUsers.reloadData()
        if self.searchBar.text?.count ?? 0 > 0  {
            self.tableViewUsers.sayNoSection = .noSearchResultFound("Search")
        } else {
            self.tableViewUsers.sayNoSection = .noUsersFound("Users")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tableViewUsers.figureOutAndShowNoResults()
        }
    }
}
