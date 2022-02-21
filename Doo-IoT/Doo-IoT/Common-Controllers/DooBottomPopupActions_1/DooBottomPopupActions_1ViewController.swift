//
//  DooBottomPopupActions_1ViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopupActions_1ViewController: UIViewController {
    
    // Genric Popup Option model
    struct PopupOption {
        
        var title: String = ""
        var color: UIColor? = nil
        var action: (()->())? = nil
        
        init(title: String, color: UIColor, action: (()->())? = nil) {
            self.title =  title
            self.color =  color
            self.action =  action
        }
    }
    
    enum PopupType {
        case generic(String, String, [PopupOption]), none
        
        func getTitle() -> String{
            switch self {
            case .generic(let title, _, _):
                return title
            default:
                return "--"
            }
        }
        
        func getSubTitle() -> String{
            switch self {
            case .generic(_, let subTitle, _):
                return subTitle
            default:
                return "-"
            }
        }
        
        func getValues() -> [PopupOption]{
            switch self {
            case .generic(_, _, let options):
                return options
            default:
                return []
            }
        }
    }
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackViewOfTitle: UIStackView!
    @IBOutlet weak var labeNavigationDetailTitle: UILabel!
    @IBOutlet weak var labelNavigaitonDetailSubTitle: UILabel!
    
    @IBOutlet weak var bottomConstraintOfOptionTableView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfOptionTableView: NSLayoutConstraint!
    @IBOutlet weak var tableViewMoreOptions: UITableView!
    
    var popupType: PopupType = .none
    var titleTextColor:UIColor = UIColor.black
    var subTitleTextColor:UIColor = UIColor.black
    var isShowSubtitle: Bool = true
    var isNeedToShowExtraBottomSpcace: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaultData()
        loadData()
        
        self.tableViewMoreOptions.dataSource = self
        self.tableViewMoreOptions.delegate = self
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraintOfOptionTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func setDefaultData() {
        self.labeNavigationDetailTitle.text = self.popupType.getTitle()
        if self.isShowSubtitle {
            self.labelNavigaitonDetailSubTitle.isHidden = false
            if !self.popupType.getSubTitle().isEmpty {
                self.labelNavigaitonDetailSubTitle.text = self.popupType.getSubTitle()
                self.labelNavigaitonDetailSubTitle.isHidden = false
            }else{
                self.labelNavigaitonDetailSubTitle.isHidden = true
            }
        }else{
            self.labelNavigaitonDetailSubTitle.isHidden = true
        }
        self.labeNavigationDetailTitle.textColor = titleTextColor
        self.labelNavigaitonDetailSubTitle.textColor = subTitleTextColor

    }
    
    func configureTableView() {
        tableViewMoreOptions.dataSource = self
        tableViewMoreOptions.delegate = self
        tableViewMoreOptions.separatorStyle = .none
        tableViewMoreOptions.rowHeight =  UITableView.automaticDimension
        tableViewMoreOptions.estimatedRowHeight = 44 // 30
        tableViewMoreOptions.registerCellNib(identifier: DooBottomPopupActions_1TVCell.identifier, commonSetting: true)
    }
    
    func loadData(){
        
        tableViewMoreOptions.reloadData()
        tableViewMoreOptions.reloadData { [weak self] in
            self?.stackViewOfTitle.layoutIfNeeded()
            let contentSizeOfTitles = self?.stackViewOfTitle.bounds.size.height ?? 0.0
            let tableViewOffset =  contentSizeOfTitles + 52.7  //26 (Gap above titles) + 13.35 (Gap below titles) + 13.35 (below table view)
            let tableViewContent = self?.tableViewMoreOptions.contentSize.height ?? 0.0
            let finalHeight = tableViewContent + tableViewOffset
            self?.heightConstraintOfOptionTableView.constant = finalHeight + (self?.isNeedToShowExtraBottomSpcace ?? true ? 26 : 0)
        }
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */


}


// MARK: - UITableViewDataSource
extension DooBottomPopupActions_1ViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.popupType.getValues().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooBottomPopupActions_1TVCell.identifier, for: indexPath) as! DooBottomPopupActions_1TVCell
        
        let option = self.popupType.getValues()[indexPath.row]
        cell.cellConfig(popupOption: option)

        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.popupType.getValues()[indexPath.row]
        option.action?()
        DispatchQueue.getMain(delay: 0.05) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
