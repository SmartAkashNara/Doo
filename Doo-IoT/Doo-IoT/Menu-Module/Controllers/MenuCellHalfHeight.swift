//
//  MenuCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView

class MenuCellHalfHeight: UICollectionViewCell {
    
    static let identifier = "MenuCellHalfHeight"
    static let cellHeight: CGFloat = 120
    
    @IBOutlet weak var viewCard1: UIControl!
    @IBOutlet weak var viewCard2: UIView!
    
    @IBOutlet weak var imageMenuIcon1: UIImageView!
    @IBOutlet weak var imageMenuIcon2: UIImageView!
    
    @IBOutlet weak var labelMenuName1: UILabel!
    @IBOutlet weak var labelMenuName2: UILabel!
    
    private var callbackClosure: ((Int)->())? = nil
    func cellDidTapped(_ closure: @escaping ((Int)->())) {
        callbackClosure = closure
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewCard1.backgroundColor = UIColor(named: "menuCellBackground")
        viewCard1.isSkeletonable = true
        viewCard1.layer.cornerRadius = 12
        viewCard1.clipsToBounds = true
        viewCard2.backgroundColor = UIColor(named: "menuCellBackground")
        viewCard2.isSkeletonable = true
        viewCard2.layer.cornerRadius = 12
        viewCard2.clipsToBounds = true
        
        imageMenuIcon1.isHidden = true
        imageMenuIcon2.isHidden = true
        labelMenuName1.textColor = UIColor(named: "menuLabelTextColor")
        labelMenuName1.font = UIFont.Poppins.medium(12)
        labelMenuName1.isHidden = true
        labelMenuName2.textColor = UIColor(named: "menuLabelTextColor")
        labelMenuName2.font = UIFont.Poppins.medium(12)
        labelMenuName2.isHidden = true
        
        viewCard1.addTarget(self, action: #selector(cellDevicesMenuClicked), for: .touchUpInside)
        let tapGeture2 = UITapGestureRecognizer.init(target: self, action: #selector(cellScenesMenuClicked))
        tapGeture2.numberOfTapsRequired = 1
        viewCard2.addGestureRecognizer(tapGeture2)
    }
    
    @objc func cellDevicesMenuClicked(){
        callbackClosure?(viewCard1.tag)
    }
    
    @objc func cellScenesMenuClicked(){
        callbackClosure?(viewCard2.tag)
    }
    
    func cellConfig(data: [MenuDataModel]) {
        if let firstObjetc = data.first{
            labelMenuName1.text = firstObjetc.title
            labelMenuName1.isHidden = false
            imageMenuIcon1.image = UIImage(named: firstObjetc.image)
            imageMenuIcon1.isHidden = false
            viewCard1.tag = firstObjetc.id
            viewCard1.hideSkeleton()
        }
        
        if data.indices.contains(1){
            labelMenuName2.text = data[1].title
            labelMenuName2.isHidden = false
            imageMenuIcon2.image = UIImage(named: data[1].image)
            imageMenuIcon2.isHidden = false
            viewCard2.tag = data[1].id
            viewCard2.hideSkeleton()
        }
    }
    
    func showSkeletonAnimation() {
        viewCard1.showAnimatedSkeleton()
        viewCard2.showAnimatedSkeleton()
    }
    
}
