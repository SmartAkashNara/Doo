//
//  HomeLayoutSettingViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 25/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class HomeLayoutSettingViewController: UIViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var labelScreenTitle: UILabel!
    @IBOutlet weak var tableViewSetting: UITableView!
    
    var homeViewModel: HomeViewModel!
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        setDefaults()
    }
    
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - User defined methods
extension HomeLayoutSettingViewController {
    func configureTableView() {
        tableViewSetting.dataSource = self
        tableViewSetting.delegate = self
        tableViewSetting.isEditing = true
        tableViewSetting.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableViewSetting.registerCellNib(identifier: DooTitle_1TVCell.identifier, commonSetting: true)
    }
    
    func setDefaults() {
        viewStatusBar.backgroundColor = UIColor.graySceneCard
        viewNavigationBar.backgroundColor = UIColor.graySceneCard

        buttonBack.setTitle(cueAlert.Button.back, for: .normal)
        buttonBack.setTitleColor(UIColor.black, for: .normal)
        buttonBack.titleLabel?.font = UIFont.Poppins.semiBold(17)
        
        labelScreenTitle.font = UIFont.Poppins.semiBold(17)
        labelScreenTitle.textColor = UIColor.black
        labelScreenTitle.text = localizeFor("arrange_home_layout")
    }
    
}

// MARK: - UITableViewDataSource
extension HomeLayoutSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeViewModel.homeLayouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooTitle_1TVCell.identifier, for: indexPath) as! DooTitle_1TVCell
        cell.cellConfig(withTitle: self.homeViewModel.homeLayouts[indexPath.row].layoutTitle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = self.homeViewModel.homeLayouts[sourceIndexPath.row]
        self.homeViewModel.homeLayouts.remove(at: sourceIndexPath.row)
        self.homeViewModel.homeLayouts.insert(itemToMove, at: destinationIndexPath.row)

        self.homeViewModel.homeLayouts.forEach({ print($0.layoutTitle) })
        if let homeView = self.navigationController?.getSpecificViewControllerFromPreviousHistory(destView: HomeViewController()) as? HomeViewController{
            homeView.tableViewHome.reloadData()
        }
    }
}

extension HomeLayoutSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}
