//
//  InfinityTree.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 03/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

enum InfinityTreesActionPerformed {
    case expanded, collapsed
}

class InfinityTree {
    
    internal var trees: [TreeNode<Any>] = []
    internal var visibleChilds: [TreeNode<Any>] = []
    internal var totalCountOfNodesInTree: Int = 0
    
    // stuff to be reused.
    private var treeParameters: InfinityTreeParameters!
    private var childrenOfClosure: (([String: Any]) -> (values: [Any], jsonValues: [[String: Any]]))!
    
    // can be assigned by developer
    var sectionOfTreeInTableview: Int = 0
    var isAllSelected = false
    
    // accessible to developers. -------------------------------------------------------
    init(jsonValues: [[String: Any]]?,
         values: [Any],
         infinityTreeParameters: InfinityTreeParameters = InfinityTreeParameters(),
         sectionInTableView: Int,
         childrenOf: @escaping ([String: Any]) -> (values: [Any], jsonValues: [[String: Any]])) {
        
        self.treeParameters = infinityTreeParameters
        self.sectionOfTreeInTableview = sectionInTableView
        self.childrenOfClosure = childrenOf
        
        let treeNodes = self.parseTree(jsonValues, values)
        self.trees = treeNodes // assign all nodes.
        
        // After completion of the tree. If you want to look for tree visible values
        self.totalCountOfNodesInTree = calculateVisibileChilds(self.trees)
        print("total childs: \(self.totalCountOfNodesInTree)")
        print("visible childs: \(self.visibleChilds.count)")
    }
    
    func appendValues(jsonValues: [[String: Any]]?, values: [Any]) {
        let treeNodes = self.parseTree(jsonValues, values)
        self.trees.append(contentsOf: treeNodes)
        
        // After completion of the new tree nodes. If you want to look for newly added visible values
        self.totalCountOfNodesInTree = calculateVisibileChilds(treeNodes)
        print("total childs: \(self.totalCountOfNodesInTree)")
        print("visible childs: \(self.visibleChilds.count)")
    }
    // ----------------------------- ----------------------------------------------------
}


// MARK: Inital Parsing, adding children to parents & adding parent to children.
extension InfinityTree {
    private func parseTree(_ jsonValues: [[String: Any]]?,_ values: [Any]) -> [TreeNode<Any>]{
        var treeNodes: [TreeNode<Any>] = []
        for index in 0..<values.count {
            let parent = TreeNode.init(value: values[index])
            parent.deepAtLevel = 1 // Additional work around: assigning deep level to each node.
            
            if let jsonValuesConfirmed = jsonValues, jsonValuesConfirmed.indices.contains(index) {
                // Give single JSON dictionary and get return multiple childs from this function.
                // Additional work around: is deep at level, will set level of node in tree
                let children = addChildren(deepAtLevel: (parent.deepAtLevel+1), childJSON: jsonValuesConfirmed[index])
                // Additional work around: assigning children a parent
                assignParentToChilds(parent, childs: children)
                parent.children = children
            }
            treeNodes.append(parent)
        }
        return treeNodes
    }
    
    // create tree for parent
    private func addChildren(deepAtLevel: Int, childJSON: [String: Any]) -> [TreeNode<Any>]{
        let childrensReceived = self.childrenOfClosure(childJSON)
        var children: [TreeNode<Any>] = []
        for index in 0..<childrensReceived.values.count {
            
            let child = TreeNode.init(value: childrensReceived.values[index])
            child.deepAtLevel = deepAtLevel
            
            if childrensReceived.jsonValues.indices.contains(index) {
                // Give single JSON dictionary and get return multiple childs from this function.
                // Additional work around: is deep at level, will set level of node in tree
                let subChildren = addChildren(deepAtLevel: (child.deepAtLevel+1), childJSON: childrensReceived.jsonValues[index])
                // Additional work around: assigning children a parent
                assignParentToChilds(child, childs: subChildren)
                child.children = subChildren
            }
            children.append(child)
        }
        return children
    }
    
    private func assignParentToChilds(_ parent: TreeNode<Any>, childs: [TreeNode<Any>]) {
        
        // if user wants to show all of their childs. then showChilds will be true to show all childs
        if self.treeParameters.showChilds {
            parent.isVisible = true
        }
        // show childs up to only specific level.
        if parent.deepAtLevel <= self.treeParameters.showChildsUpToLevel {
            parent.isVisible = true
        }
        // assign parent to each childs
        for child in childs {
            child.parent = parent
        }
    }
}


// MARK: Helper Methods for parsing at initial stage, calculated methods
extension InfinityTree {
    
    // Will return visible childs plus it also responsible visibleChilds array construction.
    private func calculateVisibileChilds(_ parents: [TreeNode<Any>]) -> Int{
        var totalCount: Int = 0
        
        func addChilds(_ parent: TreeNode<Any>) -> Int{
            var childsCount = 0
            if parent.isVisible {
                for child in parent.children {
                    self.visibleChilds.append(child)
                    childsCount += addChilds(child)
                }
            }
            return childsCount
        }
        
        for parent in parents {
            self.visibleChilds.append(parent)
            totalCount += addChilds(parent)
        }
        return (parents.count + totalCount)
    }
    
    // Will return all childs or sub childs of tree
    func calculateAllChilds<T>(childs: [TreeNode<T>]) -> Int{
        var totalCount: Int = 0
        for parent in childs {
            totalCount += calculateAllChilds(childs: parent.children)
        }
        return (childs.count + totalCount)
    }
    
    // Will return all childs or sub childs of specific one.
    func getCountOfChildren<T>(parent node: TreeNode<T>) -> Int{
        var totalCount: Int = 0
        for child in node.children {
            totalCount += getCountOfChildren(parent: child)
        }
        return (node.children.count + totalCount)
    }
    
    func getIndexOfNodeInVisibleChilds(_ node: TreeNode<Any>) -> Int?{
        if let index = self.visibleChilds.firstIndex(where: {$0.identity == node.identity}) {
            return index
        }
        return nil
    }
}



// MARK: Get Counts
extension InfinityTree {
    // will be used when we are collapsing any node.
    internal func countOfSelfChildsAndVisibleSubChilds<T>(parent node: TreeNode<T>) -> Int{
        var totalCount: Int = 0
        for child in node.children {
            if child.isVisible {
                // go ahead only if those are visible
                child.isVisible = false
                totalCount += countOfSelfChildsAndVisibleSubChilds(parent: child)
            }
        }
        return (node.children.count + totalCount)
    }
    
    
    // will be used when you are about to remove any child.
    // then only below case is going to be fulfilled. like if that node itself is visible then only get counts of all cihlds of it.
    internal func countOfOnlyVisibleChilds<T>(forParent node: TreeNode<T>) -> Int{
        var totalCount: Int = 0
        if node.isVisible {
            totalCount += node.children.count // difference from above method is that. if child/parent is visible then only it will return the childs count of it.
            for child in node.children {
                totalCount += countOfOnlyVisibleChilds(forParent: child)
            }
        }
        return totalCount
    }
}


// MARK: Make childs selectabled
extension InfinityTree {
    internal func selectParentsAndChildsFromTree(tree: InfinityTree? = nil){
        guard let receivedTree = tree else {
            return
        }
        debugPrint("visible childs to be selected: \(self.visibleChilds.count)")
        
        for referenceParentIndex in 0..<receivedTree.trees.count {
            
            // Find out parent index in received values list.
            let selfParentIndex = self.trees.firstIndex { node in
                if let selfNodeDataModel = node.value as? UserPrivilegeDataModel,
                   let referenceDataModel = receivedTree.trees[referenceParentIndex].value as? UserPrivilegeDataModel{
                    if selfNodeDataModel.title == referenceDataModel.title {
                        return true
                    }
                }
                return false
            }
            if let parentIndex = selfParentIndex{
                makeChildrensSelectable(selfNode: self.trees[parentIndex], referenceNode: receivedTree.trees[referenceParentIndex])
            }
        }
        var childrensSelectedCount: Int = 0
        for parentNode in self.trees {
            if parentNode.isMarked {
                childrensSelectedCount += 1
            }
        }
        // (childrensSelectedCount-1) except All Groups
        //if self.trees.count == (childrensSelectedCount+1) {
        if self.trees.count >= 1 {
            let allGroupsIndex = self.trees.firstIndex { node in
                if let selfNodeDataModel = node.value as? UserPrivilegeDataModel{
                    if selfNodeDataModel.title == "All Groups" {
                        return true
                    }
                }
                return false
            }
            if let foundAllGroupIndex = allGroupsIndex {
                self.trees[foundAllGroupIndex].isMarked = true
            }
        }
        
    }
    func makeChildrensSelectable<T>(selfNode: TreeNode<T>, referenceNode: TreeNode<T>) {
        guard selfNode.children.count != 0 else {
            // Its a leaf node. Make it marked
            selfNode.isMarked = true
            return
        }
        for referenceChildIndex in 0..<referenceNode.children.count {
                
                // Find out parent index in received values list.
                let selfParentIndex = selfNode.children.firstIndex { node in
                    if let selfNodeDataModel = node.value as? UserPrivilegeDataModel,
                       let referenceDataModel = referenceNode.children[referenceChildIndex].value as? UserPrivilegeDataModel{
                        if selfNodeDataModel.title == referenceDataModel.title {
                            return true
                        }
                    }
                    return false
                }
                if let parentIndex = selfParentIndex{
                    makeChildrensSelectable(selfNode: selfNode.children[parentIndex],
                                            referenceNode: referenceNode.children[referenceChildIndex])
                }
        }
        var childrensSelectedCount: Int = 0
        for selfNodeChildren in selfNode.children {
            if selfNodeChildren.isMarked {
                childrensSelectedCount += 1
            }
        }
        // if selfNode.children.count == childrensSelectedCount {
        if selfNode.children.count >= 1 {
            selfNode.isMarked = true
        }
    }
    
    
}
