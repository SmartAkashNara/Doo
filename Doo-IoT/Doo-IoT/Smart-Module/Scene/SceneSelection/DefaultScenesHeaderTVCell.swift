//
//  GroupTopOptionsCVCell.swift
//  Doo-IoT
//
//  Created by Shraddha on 04/08/21.
//

import UIKit

class DefaultScenesHeaderTVCell: UITableViewCell {
    
    // MARK:- IBOutlets
    @IBOutlet weak var labelOptionTitle: UILabel!
    
    // MARK: - Variable Declaration
    static let identifier = "DefaultScenesHeaderTVCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.defaultConfig()
    }
    
    // Default Config
    func defaultConfig() {
        self.labelOptionTitle.font = UIFont.Poppins.medium(11)
        self.labelOptionTitle.text = localizeFor("scenes")
        self.labelOptionTitle.textColor = UIColor.blueHeading
        self.labelOptionTitle.numberOfLines = 1
    }
}
