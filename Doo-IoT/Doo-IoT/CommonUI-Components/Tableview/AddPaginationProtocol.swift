//
//  AddPaginationProtocol.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 08/07/19.
//  Copyright © 2019 SmartSense. All rights reserved.
//

import Foundation
import UIKit

class PaginationTableView: UITableView {
    
    let refreshIndicator = UIRefreshControl()
    
    func addTopBackgroundView(view: UIView) {
        var frame = self.bounds
        frame.origin.y = -frame.size.height
        view.frame = frame
        self.addSubview(view)
    }
    
    func addRefreshControlForPullToRefresh(_ completion: @escaping ()->()) {
        self.refreshIndicator.attributedTitle = NSAttributedString(string: "")
        self.addSubview(self.refreshIndicator)
        self.refreshIndicator.backgroundColor = .clear
        self.refreshIndicator.addAction(for: .valueChanged) {
            completion()
        }
    }
    
    func getRefreshControl() -> UIRefreshControl {
        return refreshIndicator
    }
    
    func stopRefreshing() {
        self.refreshIndicator.endRefreshing()
    }
    func stopPullToRefresh() {
        self.refreshIndicator.endRefreshing()
    }
    
    var isFirstCallOfAPIWorking: Bool = false
    var isAPIstillWorking: Bool = false
    func startPaginationAPI()  {
        self.isAPIstillWorking = true
    }
    func stopPaginationAPI() {
        self.isAPIstillWorking = false
    }
}

class PaginationCollectionView: UICollectionView {
    
    let refreshIndicator = UIRefreshControl()
    
    func addTopBackgroundView(view: UIView) {
        var frame = self.bounds
        frame.origin.y = -frame.size.height
        view.frame = frame
        self.addSubview(view)
    }
    
    func addPagination(_ completion: @escaping ()->()) {
        self.alwaysBounceVertical = true
        self.refreshIndicator.attributedTitle = NSAttributedString(string: "")
        self.addSubview(self.refreshIndicator)
        self.refreshIndicator.backgroundColor = .clear
        self.refreshIndicator.addAction(for: .valueChanged) {
            completion()
        }
    }
    
    func getRefreshControl() -> UIRefreshControl {
        return refreshIndicator
    }
    
    func stopRefreshing() {
        self.refreshIndicator.endRefreshing()
    }
    func stopPullToRefresh() {
        self.refreshIndicator.endRefreshing()
    }
    
    var isAPIstillWorking: Bool = false
    func startPaginationAPI()  {
        self.isAPIstillWorking = true
    }
    func stopPaginationAPI() {
        self.isAPIstillWorking = false
    }
}
