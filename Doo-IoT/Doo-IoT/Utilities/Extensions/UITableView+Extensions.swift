//
//  UITableView+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.0, animations: { self.reloadData() })
        { _ in completion() }
    }
    
    func reloadRows(at:[IndexPath], with:UITableView.RowAnimation, completion: @escaping ()->()) {
        self.reloadRows(at: at, with: with)
        DispatchQueue.getMain(delay: 0.1) {
            completion()
        }
    }
    
    func reloadSections(_ sections:IndexSet, with: UITableView.RowAnimation, completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadSections(sections, with: with) })
        { _ in completion() }
    }
    
    func registerCellNib(identifier:String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }

    func registerCellNib(identifier: String, commonSetting: Bool = false) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        if commonSetting { commonSettings() }
    }
       
    func registerHeaderFooterNib(identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func commonSettings() {
        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    func getDefaultCell() -> UITableViewCell {
        var cell: UITableViewCell! = self.dequeueReusableCell(withIdentifier: "identifier")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "identifier")
        }
        return cell
    }
    
    func isWholeSectionVisible(section: Int) -> Bool {
        let topSpace = self.rect(forSection: section).minY - self.contentOffset.y
        return topSpace >= 0
    }
    
    func isWholeRowVisible(indexPath: IndexPath) -> Bool {
        let topSpace = self.rectForRow(at: indexPath).minY - self.contentOffset.y
        return topSpace >= 0
    }

    var getWhiteHeaderFooter : UIView {
        let headerOrFooter = UIView(frame: .zero)
        headerOrFooter.backgroundColor = UIColor.white
        return headerOrFooter
    }
    
    var autolayoutTableViewHeader: UIView? {
        set {
            self.tableHeaderView = newValue
            guard let header = newValue else { return }
            header.setNeedsLayout()
            header.layoutIfNeeded()
            header.frame.size =
            header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            self.tableHeaderView = header
        }
        get {
            return self.tableHeaderView
        }
    }
    
    var autolayoutTableViewFooterHeader: UIView? {
        set {
            self.tableFooterView = newValue
            guard let header = newValue else { return }
            header.setNeedsLayout()
            header.layoutIfNeeded()
            header.frame.size =
            header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            self.tableFooterView = header
        }
        get {
            return self.tableFooterView
        }
    }



}

extension UITableViewCell {
    func separator(hide: Bool) {
        separatorInset.left += hide ? bounds.size.width : 0
    }
}
