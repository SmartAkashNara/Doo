//
//  RGBAndFanUIView.swift
//  DooIotExtensionUI
//
//  Created by Akash on 30/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
import UIKit

class RGBAndFanUIView: UIView {
    enum SectionType {
        case speed, rgb
    }
    
    @IBOutlet weak var tableViewUIContainer: UITableView!
    
    var arrayOfSectionType:[SectionType] = [.rgb]
    
    func configureTableView() {
        tableViewUIContainer.dataSource = self
        tableViewUIContainer.delegate = self
        tableViewUIContainer.registerCellNib(identifier: ApplienceRGBColorPickerTVCell.identifier, commonSetting: true)
    }
}

// MARK: - UITableViewDataSource
extension RGBAndFanUIView: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfSectionType.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch arrayOfSectionType[section]{
        case .speed:
            return 4
        case .rgb:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch arrayOfSectionType[indexPath.section]{
        case .speed:
            var cell = tableView.dequeueReusableCell(withIdentifier: "test")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "test")
            }
            cell?.textLabel?.text = "Title 12"
            cell?.detailTextLabel?.text = "Detail title"
            return cell!
        case .rgb:
            let cell = tableView.dequeueReusableCell(withIdentifier: ApplienceRGBColorPickerTVCell.identifier, for: indexPath) as! ApplienceRGBColorPickerTVCell
            cell.cellConfig(.red)
            return cell
        }
    }
}

// MARK: UITableViewDataDelegate
extension RGBAndFanUIView: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("taped")
    }
}
