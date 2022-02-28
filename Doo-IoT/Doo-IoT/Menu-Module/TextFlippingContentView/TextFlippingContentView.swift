//
//  TextFlippingContentView.swift
//  TextFlipping
//
//  Created by Kiran Jasvanee on 24/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class TextFlippingContentView: UIView {
    
    var tableView: UITableView = UITableView.init(frame: .zero)
    var selectedPosition: Int = 0
    var enterPrices: [EnterpriseModel] = [EnterpriseModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var callbackClosureOfSwitchingEnterprise: ((Int)->())? = nil
    func switchedEnterpriseBySwipeUpOrDown(_ closure: @escaping ((Int)->())) {
        callbackClosureOfSwitchingEnterprise = closure
    }
    
    var getCurrentEnterprise: String{
        if enterPrices.indices.contains(selectedPosition) {
            return enterPrices[selectedPosition].name
        }else{
            return ""
        }
    }

    var getCurrentEnterpriseId: Int{
        return enterPrices[selectedPosition].id
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetup()
    }
    
//   convenience init(_ arrayOfEnterpirse: [EnterpriseModel]) {
//        self.init()
//        self.enterPrices = arrayOfEnterpirse
//    }
    
    private func initSetup() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.tableView)
        self.addConstraint(NSLayoutConstraint.init(item: self.tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.tableView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.tableView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.tableView.backgroundColor = .cyan
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isScrollEnabled = false
        self.tableView.rowHeight = 74
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: EnterpriseTextFlipCell.identifier, bundle: nil), forCellReuseIdentifier: EnterpriseTextFlipCell.identifier)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        upSwipe.direction = .up
        self.addGestureRecognizer(upSwipe)
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        downSwipe.direction = .down
        self.addGestureRecognizer(downSwipe)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
            
        if (sender.direction == .up) {
            print("Swipe up")
            let nextIndex = self.selectedPosition + 1
            if self.enterPrices.indices.contains(nextIndex) {
                self.scrollToIndex(nextIndex)
            }
        }
            
        if (sender.direction == .down) {
            print("Swipe down")
            let nextIndex = self.selectedPosition - 1
            if self.enterPrices.indices.contains(nextIndex) {
                self.scrollToIndex(nextIndex)
            }
        }
    }
    
    func finalizeIndexWithScroll(_ nextIndex: Int) {
        UIView.animate(withDuration: 0.1) {
            self.tableView.scrollToRow(at: IndexPath.init(row: nextIndex, section: 0), at: .middle, animated: true)
        }
        self.layoutIfNeeded()
        self.selectedPosition = nextIndex
    }
    
    func scrollToIndex(_ nextIndex: Int) {
        UIView.animate(withDuration: 0.1) {
            self.tableView.scrollToRow(at: IndexPath.init(row: nextIndex, section: 0), at: .middle, animated: true)
        }
        self.layoutIfNeeded()
        callbackClosureOfSwitchingEnterprise?(nextIndex)
        self.selectedPosition = nextIndex
    }
    
    func setSuccessToNewPosition(atIndex index: Int) {
        self.selectedPosition = index
    }
    func fallbackToPreviousPosition() {
        UIView.animate(withDuration: 0.1) {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.selectedPosition, section: 0), at: .top, animated: false)
        }
        self.layoutIfNeeded()
    }

}


extension TextFlippingContentView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.enterPrices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseTextFlipCell.identifier, for: indexPath) as! EnterpriseTextFlipCell
        cell.labelEnterPrise?.text = self.enterPrices[indexPath.row].name
        return cell
    }
}
