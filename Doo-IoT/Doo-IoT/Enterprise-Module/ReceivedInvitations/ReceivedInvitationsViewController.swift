//
//  ReceivedInvitationsViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import Toast_Swift

class ReceivedInvitationsViewController: UIViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableviewReceivedInvitations: SayNoForDataTableView!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!

    var receivedInvitationViewModel: ReceivedInvitationsViewModel = ReceivedInvitationsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefaults()
        self.configureTableView()
        self.getReceivedInvitaitons()
    }
}

// MARK: - User defined methods
extension ReceivedInvitationsViewController {
    func configureTableView() {
        tableviewReceivedInvitations.dataSource = self
        tableviewReceivedInvitations.delegate = self
        tableviewReceivedInvitations.registerCellNib(identifier: DooHeaderDetail_1TVCell.identifier, commonSetting: true)
        tableviewReceivedInvitations.registerCellNib(identifier: ReceivedInvitationTVCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableviewReceivedInvitations.tableHeaderView = viewNavigationBarDetail
        tableviewReceivedInvitations.addBounceViewAtTop()
        tableviewReceivedInvitations.rowHeight = UITableView.automaticDimension
        tableviewReceivedInvitations.estimatedRowHeight = 44
        // pagination work
        tableviewReceivedInvitations.addRefreshControlForPullToRefresh {
            self.getReceivedInvitaitons(isFromPullToRefresh: true)
        }
        
        tableviewReceivedInvitations.sayNoSection = .noRecievedInvitations("Received Invitation")
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        mainView.delegateOfSWWalert = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.text = localizeFor("received_invitations_title")
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
    }
    
    func setHeader(totalCount:Int){
        let title = localizeFor("received_invitations_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Invitations from enterprise owners are received here.")
//        Assign privileges to the users of your enterprise.
        // "\(totalCount) \(localizeFor("received_invitations_subtitle"))" // previously added.
        
    }
}

// MARK: - UITableViewDataSource
extension ReceivedInvitationsViewController {
    func getReceivedInvitaitons(isNextPage:Bool = false, isFromPullToRefresh: Bool = false) {
        
        var params = receivedInvitationViewModel.getPageDict(isFromPullToRefresh)
        params["sort"] = ["column": "invitationDate",
                          "sortType": "desc"]
        params["criteria"] = [["column": "invitationStatus",
                               "operator": "=",
                               "values": ["1"]
        ]]
                
        if self.receivedInvitationViewModel.getAvailableElements == 0 && !isFromPullToRefresh && !isNextPage{
            API_LOADER.show(animated: true)
        }
        self.tableviewReceivedInvitations.isAPIstillWorking = true
        self.receivedInvitationViewModel.callGetReceivedInvitations(params) { [weak self] in
            if !isFromPullToRefresh {
                API_LOADER.dismiss(animated: true)
            }
            self?.mainView.dismissSomethingWentWrong()
            self?.tableviewReceivedInvitations.stopRefreshing()
            self?.setHeader(totalCount: self?.receivedInvitationViewModel.receivedInvitations.count ?? 0)
            self?.tableviewReceivedInvitations.isAPIstillWorking = false
            self?.receivedInvitationViewModel.filterOutSectionsBasedOnTime()
            self?.tableviewReceivedInvitations.reloadData()
            self?.tableviewReceivedInvitations.figureOutAndShowNoResults()
        } failureMessageBlock: { [weak self] msg in
            self?.tableviewReceivedInvitations.isAPIstillWorking = false
            API_LOADER.dismiss(animated: true)
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.mainView.showInternetOff()
        }
    }
}

// MARK: - Action listeners
extension ReceivedInvitationsViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ReceivedInvitationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return receivedInvitationViewModel.sortedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDate = receivedInvitationViewModel.sortedSections[section]
        return receivedInvitationViewModel.receivedInvitationsFiltered[sectionDate]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DooHeaderDetail_1TVCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooHeaderDetail_1TVCell.identifier) as! DooHeaderDetail_1TVCell
        let sectionDate = receivedInvitationViewModel.sortedSections[section]
        if Calendar.current.isDateInToday(sectionDate) { cell.cellConfigBlue(title: localizeFor("today")) }
        else if Calendar.current.isDateInYesterday(sectionDate) { cell.cellConfigBlue(title: localizeFor("yesterday")) }
        else {
            let getDateInString = sectionDate.getDateInString(withFormat: .ddSpaceMMspaceYYYY)
            cell.cellConfigBlue(title: getDateInString)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionDate = receivedInvitationViewModel.sortedSections[indexPath.section]
        if let enterprise = receivedInvitationViewModel.receivedInvitationsFiltered[sectionDate]?[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceivedInvitationTVCell.identifier, for: indexPath) as! ReceivedInvitationTVCell
            cell.cellConfig(enterprise)
            cell.buttonAccept.addTarget(self, action: #selector(acceptInvitationActionListener(sender:)), for: .touchUpInside)
            cell.buttonAccept.section = indexPath.section; cell.buttonAccept.row = indexPath.row
            cell.buttonReject.addTarget(self, action: #selector(rejectInvitationActionListener(sender:)), for: .touchUpInside)
            cell.buttonReject.section = indexPath.section; cell.buttonReject.row = indexPath.row
            cell.selectionStyle = .none
            return cell
        }
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "identifier")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "identifier")
        }
        return cell
    }
    
    @objc func acceptInvitationActionListener(sender: TableButton) {
        let sectionDate = receivedInvitationViewModel.sortedSections[sender.section]
        if let enterprise = receivedInvitationViewModel.receivedInvitationsFiltered[sectionDate]?[sender.row] {
            acceptRejectAPI(invitation: enterprise, sender: sender, true)
        }
    }
    @objc func rejectInvitationActionListener(sender: TableButton) {
        let sectionDate = receivedInvitationViewModel.sortedSections[sender.section]
        if let enterprise = receivedInvitationViewModel.receivedInvitationsFiltered[sectionDate]?[sender.row] {
            acceptRejectAPI(invitation: enterprise, sender: sender, false)
        }
    }
    
    func acceptRejectAPI(invitation: ReceivedInvitationDataModel, sender: TableButton, _ isAccepted: Bool) {
        
        let params = ["invitationId": invitation.id,
                      "flag": isAccepted ? "true" : "false"] as [String : Any]
        
        API_LOADER.show(animated: true)
        self.receivedInvitationViewModel.callAcceptRejectInvitation(params) { [weak self] msg in
            if isAccepted {
                // If its accepted, fetch enterprise, and then stop loading.
                self?.fetchEnterpriseObjAndAddToOurList(invitation: invitation, sender: sender, message: msg)
            }else{
                // If its for rejection just stop loading and show alert of reject success
                self?.removeInvitation(sender: sender)
                API_LOADER.dismiss(animated: true)
                CustomAlertView.init(title: msg, forPurpose: .success).showForWhile(animated: true)
            }
            if let tableView = self?.tableviewReceivedInvitations {
                self?.scrollViewDidScroll(tableView)
            }
        } failureMessageBlock: { [weak self] msg in
            self?.tableviewReceivedInvitations.isAPIstillWorking = false
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        }
    }
    
    func fetchEnterpriseObjAndAddToOurList(invitation: ReceivedInvitationDataModel, sender: TableButton, message: String) {
        
        let params:[String:Any] = ["criteria": [
            ["column": "id",
             "operator": "=",
             "values": ["\(invitation.enterpriseId)"]
            ]
        ]
        ]
        
        self.receivedInvitationViewModel.callGetEnterprises(params) { [weak self] in
            API_LOADER.dismiss(animated: true)
            // Show accepted successfully
            if let _ = self?.navigationController?.viewControllers.first as? AddEnterpriseWhenNotAvailableViewController {
                // Switch to home when very first enterprise accepted.
                SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.instantiateInitialViewController()
            }else{
                CustomAlertView.init(title: message, forPurpose: .success).showForWhile(animated: true)
                
                // remove invitation from the list.
                self?.removeInvitation(sender: sender)
                
                // auto refresh home and menu view
                (TABBAR_INSTANCE as? DooTabbarViewController)?.refreshAllViewsOfTabsWhenEnterpriseChanges()
            }
        } failureMessageBlock: { msg in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        }
    }
    
    func removeInvitation(sender: TableButton) {
        let sectionDate = self.receivedInvitationViewModel.sortedSections[sender.section]
        
        // remove invitaion
        self.receivedInvitationViewModel.receivedInvitationsFiltered[sectionDate]?.remove(at: sender.row)
        if self.receivedInvitationViewModel.receivedInvitationsFiltered[sectionDate]?.count == 0 {
            // remove section it self from sections list
            self.receivedInvitationViewModel.sortedSections.remove(at: sender.section)
            // remove date section from dictionary too
            self.receivedInvitationViewModel.receivedInvitationsFiltered.removeValue(forKey: sectionDate)
        }
        self.setHeader(totalCount: receivedInvitationViewModel.receivedInvitationsFiltered.count)
        self.tableviewReceivedInvitations.reloadData()
        self.tableviewReceivedInvitations.figureOutAndShowNoResults()
    }
}


// MARK: - UIGestureRecognizerDelegate
extension ReceivedInvitationsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension ReceivedInvitationsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        //guard contentYoffset != 0 else { return }
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if receivedInvitationViewModel.getTotalElements > receivedInvitationViewModel.getAvailableElements &&
                !tableviewReceivedInvitations.isAPIstillWorking {
                self.getReceivedInvitaitons(isNextPage: true)
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

// MARK: - Something went wrong
extension ReceivedInvitationsViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        // dismiss both and try again.
        self.mainView.dismissSomethingWentWrong()
        self.getReceivedInvitaitons()
    }
}
