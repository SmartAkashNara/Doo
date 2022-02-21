//
//  ErrorInterface.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 05/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import Foundation

protocol ErrorControlHandler {
    var isShowError: Bool { get set }
    func showError()
}

