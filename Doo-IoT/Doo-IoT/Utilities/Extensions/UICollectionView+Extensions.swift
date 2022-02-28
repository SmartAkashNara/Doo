//
//  UICollectionView+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

extension UICollectionView {
    func registerCellNib(identifier: String, commonSetting: Bool = false) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        if commonSetting { commonSettings() }
    }
           
    func commonSettings() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    func getDefaultCell(_ indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell! = self.dequeueReusableCell(withReuseIdentifier: "identifier", for: indexPath)
        if cell == nil {
            cell = UICollectionViewCell.init()
        }
        return cell
    }
    
    func reloadData(_ completion: (() -> Void)? = nil) {
        reloadData()
        guard let completion = completion else { return }
        layoutIfNeeded()
        completion()
    }


}
