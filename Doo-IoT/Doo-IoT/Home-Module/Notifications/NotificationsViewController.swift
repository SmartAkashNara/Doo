//
//  NotificationsViewController.swift
//  Doo-IoT
//
//  Created by Shraddha on 24/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var viewSuper: UIView!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView! {
        didSet {
            mainView.delegateOfSWWalert = self
        }
    }
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var tableViewNotificationsList: SayNoForDataTableView! {
        didSet{
            tableViewNotificationsList.delegate = self
            tableViewNotificationsList.dataSource = self
        }
    }
    @IBOutlet weak var buttonOtherOptionsForAllNotifs: UIButton!
    
    //MARK: - Variable declaration
    var notificationsViewModel = NotificationsViewModel()
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadStaticData()
        self.setDefaults()
        self.configureTableView()
    }
}

// MARK: - Other Methods
extension NotificationsViewController {
    func loadStaticData() {
        self.notificationsViewModel.notificationsList = [
            NotificationsDataModel(id: 0, title: "Invitation", receivedDate: "1 day", descriptionString: "<html><body style=\"font-family:\("Poppins-Regular"); font-size: \(12)\">You have been invited from Rody's Enterprise for user role</body></html>"),
            NotificationsDataModel(id: 1, title: "Invitation", receivedDate: "1 day", descriptionString: "<html><body style=\"font-family:\("Poppins-Regular"); font-size: \(12)\">Lee William has accepted your invitation</body></html>"),
            NotificationsDataModel(id: 2, title: "App Update", receivedDate: "1 year", descriptionString: "<html><body style=\"font-family:\("Poppins-Regular"); font-size: \(12)\">Looks like you are running an old version. Upgrade to get a faster & smoother experience on our latest app</body></html>"),
            NotificationsDataModel(id: 3, title: "Firmware Update", receivedDate: "2 years", descriptionString: "<html><body style=\"font-family:\("Poppins-Regular"); font-size: \(12)\">Firmware update of your app is available</body></html>"),
            NotificationsDataModel(id: 4, title: "Invitation", receivedDate: "1 day", descriptionString: "<html><body style=\"font-family:\("Poppins-Regular"); font-size: \(12)\">You have been invited from Rody's Enterprise for user role</body></html>"),
            NotificationsDataModel(id: 5, title: "Invitation", receivedDate: "1 day", descriptionString: "<html><body style=\"font-family:\("Poppins-Regular"); font-size: \(12)\">Lee William has accepted your invitation</body></html>")]
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.text = "Notifications"
        navigationTitle.isHidden = true
        
        self.setNavigationTitle()
    }
    
    // Navigation Header of TableView
    func setNavigationTitle() {
        let  title = "Notifications"
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Lorem Ipsum is simply typesetting industry")
        navigationTitle.text = title
    }
    
    func configureTableView() {
        tableViewNotificationsList.registerCellNib(identifier: NotificationsTVCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewNotificationsList.tableHeaderView = viewNavigationBarDetail
        tableViewNotificationsList.addBounceViewAtTop()
        tableViewNotificationsList.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewNotificationsList.sectionHeaderHeight = 0
        tableViewNotificationsList.getRefreshControl().tintColor = .lightGray
        tableViewNotificationsList.sayNoSection = .none
        tableViewNotificationsList.separatorStyle = .none
        tableViewNotificationsList.addRefreshControlForPullToRefresh{
            // remove this when api call done and replace with api call
            self.tableViewNotificationsList.reloadData {
                self.tableViewNotificationsList.stopPullToRefresh()
            }
        }
    }
    
    func openQuickActionsForAllPopup() {
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption.init(title: "show unread", color: UIColor.blueSwitch, action: {
                // api call to show unread
            })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption.init(title: "mark all as read", color: UIColor.blueSwitch, action: {
                // api call to mark all as read
            })
            let action3 = DooBottomPopupActions_1ViewController.PopupOption.init(title: "clear all", color: UIColor.textFieldErrorColor, action: {
                
            })
            let actions = [action1, action2, action3]
            actionsVC.popupType = .generic("Quick Actions", "Lorem Ipsum is simply typesetting industry", actions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
    
    @objc func openQuickActionsForSingleNotificationPopup() {
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption.init(title: "mark as read", color: UIColor.blueSwitch, action: {
                // api call to show unread
            })
            
            let action2 = DooBottomPopupActions_1ViewController.PopupOption.init(title: "delete", color: UIColor.textFieldErrorColor, action: {
                
            })
            let actions = [action1, action2]
            actionsVC.popupType = .generic("Quick Actions", "Lorem Ipsum is simply typesetting industry", actions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Action Listeners
extension NotificationsViewController {
    @IBAction func buttonBackActionListener(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonOtherOptionsActionListener(_ sender: UIButton) {
        self.openQuickActionsForAllPopup()
    }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsViewModel.notificationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewNotificationsList.dequeueReusableCell(withIdentifier: NotificationsTVCell.identifier, for: indexPath) as! NotificationsTVCell
        cell.cellConfig(notifDataModel: self.notificationsViewModel.notificationsList[indexPath.row])
        cell.buttonSingleNotificationOption.addTarget(self, action: #selector(openQuickActionsForSingleNotificationPopup), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

// MARK: - SomethingWentWrong Delegate
extension NotificationsViewController: SomethingWentWrongAlertViewDelegate {
    
    func retryTapped() {
        
    }
}

// MARK: - UIGestureRecognizerDelegate
extension NotificationsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension NotificationsViewController: UIScrollViewDelegate {
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

// MARK: - Initial Handlings
extension NotificationsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}
