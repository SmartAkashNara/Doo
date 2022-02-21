//
//  TreeNode.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation


// MARK: Tree Nodes
public class TreeNode<T> {
    
    public var jsonValue: [String: Any]? = nil
    public var value: T
    // to check that current node is visible or not.
    public var isVisible: Bool = false
    // to keep unique id for each tree node.
    public var identity: String = UUID().uuidString
    // to keep level, at which level child is in.
    public var deepAtLevel: Int = 0
    
    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()
    
    public var isMarked: Bool = false // If you are marked any parent, chidls will be marked automatically. and if you are marking all childs of parent, parent will be selected automatically.
    
    public init(value: T, jsonValue: [String: Any]? = nil) {
        self.value = value
    }
    
    public func addChild(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self
    }
}

extension TreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return s
    }
}

extension TreeNode where T: Equatable {
    public func search(_ value: T) -> TreeNode? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value) {
                return found
            }
        }
        return nil
    }
}

extension TreeNode where T: Equatable {
    public func indexOf(_ value: T) -> Int? {
        for index in 0..<children.count {
            let child = self.children[index]
            if child.value == self.value {
                return index
            }
        }
        return nil
    }
}

extension TreeNode{
    public func getCount() -> Int {
        return self.children.count
    }
}
