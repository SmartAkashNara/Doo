//
//  MenuCellHalfWidth.swift
//  Doo-IoT
//
//  Created by Shraddha on 13/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class MenuCellHalfWidth: UICollectionViewCell {

    static let identifier = "MenuCellHalfWidth"
    static let cellHeight: CGFloat = 55
    
    @IBOutlet weak var viewCardMain: UIView!
    @IBOutlet weak var viewCard1: UIControl!
    @IBOutlet weak var imageMenuIcon1: UIImageView!
    @IBOutlet weak var labelMenuName1: UILabel!
    
    @IBOutlet weak var viewCard2: UIView!
    @IBOutlet weak var imageMenuIcon2: UIImageView!
    @IBOutlet weak var labelMenuName2: UILabel!
    
    private var callbackClosure: ((Int)->())? = nil
    func cellDidTapped(_ closure: @escaping ((Int)->())) {
        callbackClosure = closure
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewCardMain.backgroundColor = UIColor(named: "menuCellBackground")
        viewCard1.backgroundColor = .clear
        viewCardMain.layer.cornerRadius = 12
        viewCardMain.clipsToBounds = true
        viewCard1.isSkeletonable = true
        viewCard2.backgroundColor = .clear
//        viewCard2.layer.cornerRadius = 12
//        viewCard2.clipsToBounds = true
        viewCard2.isSkeletonable = true
        
        imageMenuIcon1.isHidden = true
        imageMenuIcon2.isHidden = true
        labelMenuName1.textColor = UIColor(named: "menuLabelTextColor")
        labelMenuName1.textColor =  UIColor.init(named: "menuLabelTextColor")
        labelMenuName1.font = UIFont.Poppins.medium(12)
        labelMenuName1.isHidden = true
        labelMenuName2.textColor = UIColor(named: "menuLabelTextColor")
        labelMenuName2.textColor =  UIColor.init(named: "menuLabelTextColor")
        labelMenuName2.font = UIFont.Poppins.medium(12)
        labelMenuName2.isHidden = true
        
//        viewCard1.addTarget(self, action: #selector(callAlexaMenuClicked), for: .touchUpInside)
        let tapGeture1 = UITapGestureRecognizer.init(target: self, action: #selector(callAlexaMenuClicked))
        tapGeture1.numberOfTapsRequired = 1
        viewCard1.addGestureRecognizer(tapGeture1)
        
        let tapGeture2 = UITapGestureRecognizer.init(target: self, action: #selector(cellSiriMenuClicked))
        tapGeture2.numberOfTapsRequired = 1
        viewCard2.addGestureRecognizer(tapGeture2)
        
    }
    
    @objc func callAlexaMenuClicked(){
        callbackClosure?(viewCard1.tag)
    }
    
    @objc func cellSiriMenuClicked(){
        callbackClosure?(viewCard2.tag)
    }
    
    func cellConfig(data: [MenuDataModel]) {
        if let firstObjetc = data.first {
        imageMenuIcon1.image = UIImage(named: firstObjetc.image)
        imageMenuIcon1.isHidden = false
        labelMenuName1.text = firstObjetc.title
        labelMenuName1.isHidden = false
            viewCard1.tag = firstObjetc.id
        viewCard1.hideSkeleton()
        }
        
        if data.indices.contains(1){
            imageMenuIcon2.image = UIImage(named: data[1].image)
            imageMenuIcon2.isHidden = false
            labelMenuName2.text = data[1].title
            labelMenuName2.isHidden = false
            viewCard2.tag = data[1].id
            viewCard2.hideSkeleton()
        }
    }
    
    func showSkeletonAnimation() {
        viewCard1.showAnimatedSkeleton()
        viewCard2.showAnimatedSkeleton()
    }

}

