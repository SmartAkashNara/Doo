//
//  InfinityTreeParameters.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 06/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

/// The InfinityTreeParameters protocol defines the customizable properties of InfinityTree.
public protocol InfinityTreeParametersProtocol {
    
    // MARK: - Navigation Item

    /// A custom bar button item displayed on the left (or leading) edge of the navigation bar when the receiver is the top navigation item.
    var showChilds: Bool { get }
    
    var showChildsUpToLevel: Int { get }
}
/// A struct with placeholders that `SmartImagePickerConfigurable` requires.
public struct InfinityTreeParameters: InfinityTreeParametersProtocol {
    
    public var showChilds: Bool = false
    public var showChildsUpToLevel: Int = 1
}
