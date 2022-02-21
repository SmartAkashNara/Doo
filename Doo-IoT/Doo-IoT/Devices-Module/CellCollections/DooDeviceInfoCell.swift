//
//  DooDeviceInfoCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooDeviceInfoCell: UITableViewCell {

    static let identifier = "DooDeviceInfoCell"
    static let cellHeight: CGFloat = 71
    
    @IBOutlet weak var imageViewDevice: UIImageView!
    @IBOutlet weak var imageViewRightArrow: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var buttonDot: UIButton!
    
    enum EnumDotStatus: Int { case red = 0, green }
    enum EnumLeftControl { case logo, dot }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        imageViewDevice.contentMode = .scaleAspectFill
        imageViewDevice.cornerRadius = 4
        
        imageViewRightArrow.contentMode = .scaleAspectFill
        imageViewRightArrow.image = UIImage(named: "rightArrowLightGray")

        buttonDot.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        buttonDot.isUserInteractionEnabled = false
        
        labelName.font = UIFont.Poppins.semiBold(12)
        labelName.textColor = UIColor.blueHeading
        
        labelDetail.font = UIFont.Poppins.regular(10)
        labelDetail.textColor = UIColor.blueHeadingAlpha70

        viewSeparator.backgroundColor = UIColor.blueHeadingAlpha06
        
        imageViewDevice.isHidden = true
        buttonDot.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func allLeftControlHide() {
        imageViewDevice.isHidden = true
        buttonDot.isHidden = true
    }

    private func leftControl(type: EnumLeftControl) {
        allLeftControlHide()
        switch type {
        case .logo:
            imageViewDevice.isHidden = false
        case .dot:
            buttonDot.isHidden = false
        }
    }

    func setDot(status: Int) {
        guard let enumStatus = EnumDotStatus(rawValue: status) else { return }
        switch enumStatus {
        case .green:
            buttonDot.setImage(UIImage(named: "greenDot"), for: .normal)
        case .red:
            buttonDot.setImage(UIImage(named: "redDot"), for: .normal)
        }
    }
}

extension DooDeviceInfoCell {
    func cellConfig(data: DeviceTypeDataModel, leftControlType: EnumLeftControl) {
        leftControl(type: leftControlType)
        labelName.text = data.name
        labelDetail.text = data.deviceCount.setSufix(
            single: " \(localizeFor(data.gateway ? "gateway_sufix" : "device_sufix"))",
            multiple: " \(localizeFor(data.gateway ? "gateways_sufix" : "devices_sufix"))",
            isZeroAccept: true)
        imageViewDevice.backgroundColor = UIColor.clear
        imageViewDevice.setImage(url: data.image, placeholder: nil)
        if imageViewDevice.image == nil{
            imageViewDevice.backgroundColor = UIColor.blueSwitchAlpha10
        }
    }
}

extension DooDeviceInfoCell {
    func cellConfigForDeviceList(data: DeviceDataModel, leftControlType: EnumLeftControl, isGateway:Bool=false) {
        leftControl(type: leftControlType)
        setDot(status: data.deviceStatus)
        let deviceCount = data.productIsGateway ? data.deviceCount : data.applienceEndpoint
        let single = data.productIsGateway ? localizeFor("device_connected_sufix") : localizeFor("appliance_connected_sufix")
        let multiple = data.productIsGateway ? localizeFor("devices_connected_sufix") : localizeFor("appliances_connected_sufix")
        labelName.text = data.deviceName
        labelDetail.text = deviceCount.setSufix(single: " \(single)", multiple: " \(multiple)", isZeroAccept: true)
    }
}

