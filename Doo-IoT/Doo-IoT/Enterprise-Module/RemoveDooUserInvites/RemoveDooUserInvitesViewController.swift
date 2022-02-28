//
//  RemoveDooUserInvitesViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class RemoveDooUserInvitesViewController: UIViewController {

    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var tableViewUsers: UITableView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonDone: UIButton!

    var arraySelectedUsers = [DooUser]()
    var arrayRemovedUsers = [DooUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        setDefaults()
    }
}

// MARK: - Action listeners
extension RemoveDooUserInvitesViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func doneActionListener(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindSegueFromRemoveDooUserInvitesToInviteEnterpriseUsers", sender: nil)
    }
}

// MARK: - User defined methods
extension RemoveDooUserInvitesViewController {
    func configureTableView() {
        tableViewUsers.dataSource = self
        tableViewUsers.delegate = self
        tableViewUsers.registerCellNib(identifier: EnterpriseUserTVCell.identifier, commonSetting: true)
        viewNavigationBarDetail.setWidthEqualToDeviceWidth()
        tableViewUsers.tableHeaderView = viewNavigationBarDetail
        tableViewUsers.addBounceViewAtTop()
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        let title = localizeFor("remove_doo_user_invites_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: localizeFor("remove_doo_user_invites_subtitle"))
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true

    }
}

// MARK: - UITableViewDataSource
extension RemoveDooUserInvitesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySelectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseUserTVCell.identifier, for: indexPath) as! EnterpriseUserTVCell
        cell.buttonRemove.tag = indexPath.row
        cell.buttonRemove.addTarget(self, action: #selector(cellRemoveActionListener(_:)), for: .touchUpInside)
        cell.cellConfigInviteUser(data: arraySelectedUsers[indexPath.row], active: .button)
        return cell
    }
    
    @objc func cellRemoveActionListener(_ sender: UIButton) {
        arrayRemovedUsers.append(arraySelectedUsers.remove(at: sender.tag))
        tableViewUsers.performBatchUpdates({
            tableViewUsers.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: .fade)
        }) { (flag) in
            self.tableViewUsers.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UITableViewDelegate
extension RemoveDooUserInvitesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - UIScrollViewDelegate Methods
extension RemoveDooUserInvitesViewController: UIScrollViewDelegate {
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
extension RemoveDooUserInvitesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


