//
//  DooNoteTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooNoteTVCell: UITableViewCell {

    static let identifier = "DooNoteTVCell"
    static let cellHeight: CGFloat = cueDevice.isDeviceSEOrLower ? 62 : 45

    @IBOutlet weak var labelNoteTitle: UILabel!
    @IBOutlet weak var labelNoteDetail: UILabel!
    @IBOutlet weak var viewSeparator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white
        
        labelNoteTitle.font = UIFont.Poppins.medium(12)
        labelNoteTitle.textColor = UIColor.blueHeadingAlpha60
        labelNoteTitle.text = localizeFor("note_title")
        
        labelNoteDetail.font = UIFont.Poppins.regular(12)
        labelNoteDetail.textColor = UIColor.blueHeadingAlpha60
        labelNoteDetail.numberOfLines = 0

        viewSeparator.backgroundColor = UIColor.blueHeadingAlpha06
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfig(note: String) {
        labelNoteDetail.text = note
    }

}
