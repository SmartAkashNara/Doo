//
//  InfinityTreeOperationsUIKitMethods.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation


// MARK: Add or Remove parent or childs - will defer in SwiftUI, because it returns [IndexPaths]
extension InfinityTree {
    
    // accessible to developers ----------------------------------------------------------
    // add sub childs
    func addNodes(forIdentity identity: String, _ values: [Any]) -> [IndexPath] {
        
        guard let index = self.visibleChilds.firstIndex(where: {$0.identity == identity}) else { return [] }
        if self.visibleChilds.indices.contains(index) {
            // add as a child in parent
            let parent = self.visibleChilds[index]
            return self.addChilds(inParent: parent, afterIndex: index, withValues: values)
        }else {
            // add as parent
            return []
        }
    }
    
    // add siblings - in the same line.
    func addSiblings(forIdentity identity: String, _ values: [Any]) -> [IndexPath] {
        guard let index = self.visibleChilds.firstIndex(where: {$0.identity == identity}) else { return [] }
        if self.visibleChilds.indices.contains(index) {
            // add as a child in parent
            let tappedChild = self.visibleChilds[index]
            if tappedChild.parent != nil {
                // add in tree.
                if let parentIndex = self.visibleChilds.firstIndex(where: {$0.identity == tappedChild.parent!.identity}) {
                    return self.addChilds(inParent: tappedChild.parent!, afterIndex: parentIndex, withValues: values)
                }else{
                    return []
                }
            }else{
                // add siblings on parents parents in tree (top level)
                let startingIndex = (self.visibleChilds.count-1)
                let endingIndex = values.count
                for value in values {
                    let parent = TreeNode.init(value: value)
                    parent.deepAtLevel = 1
                    self.trees.append(parent)           // just append on tree
                    self.visibleChilds.append(parent)   // just append on tree
                    self.totalCountOfNodesInTree += 1
                }
                return getIndexPathsOfInsertionsOrDeletions(startingIndex, upToChildrenCount: endingIndex)
            }
        }
        return []
    }
    
    // remove single, sub childs will be removed automatically.
    func remove(atIndex index: Int) -> [IndexPath]?{
        guard self.visibleChilds.indices.contains(index) else { return nil }
        let node = self.visibleChilds[index]
        if let parent = node.parent {
            // 1 means itself and it's childs
            // removing single children from parent will automatically remove below connections to subchilds.
            let childsCount = 1 + calculateAllChilds(childs: node.children)
            if let indexInParent = parent.children.firstIndex(where: {$0.identity == node.identity}) {
                parent.children.remove(at: indexInParent)           // Remove it then.
                self.totalCountOfNodesInTree -= childsCount         // Reduce count.
            }
        }else{
            // Remove from top layer
            let childsCount = 1 + calculateAllChilds(childs: node.children)
            if let indexInParent = self.trees.firstIndex(where: {$0.identity == node.identity}) {
                self.trees.remove(at: indexInParent)           // Remove it then.
            }
            self.totalCountOfNodesInTree -= childsCount // Reduce count.
        }
        // Remove itself and it's visible childs from visible childs array. ------
        let childrenCount = self.countOfOnlyVisibleChilds(forParent: node)
        // Remove all chidls with child itself ------
        self.visibleChilds.removeSubrange(index...(index+childrenCount))
        
        // return indexpaths ------
        return getIndexPathsRemoveOrRefreshNodes(index,
                                        upToChildrenCount: childrenCount)
    }
    // -------------------------------------------------------------------------------
}

// MARK: add Childs helper method
extension InfinityTree {
    private func addChilds(inParent parent: TreeNode<Any>, afterIndex index: Int, withValues values: [Any]) -> [IndexPath] {
        // add single or multiple child
        var childs: [TreeNode<Any>] = []
        for value in values {
            let child = TreeNode.init(value: value)
            child.deepAtLevel = parent.deepAtLevel + 1
            parent.addChild(child)
            childs.append(child)
            // increase count of nodes in tree.
            self.totalCountOfNodesInTree += 1
        }
        
        // if section is closed and you have added child, our responsibility is to open the section and show all childs, even newly added once too.
        if !parent.isVisible {
            parent.isVisible = true
            
            // countOfSelfChildsAndVisibleSubChilds - because we are opening that parent. so we need childs plus the added once too.
            let childrenCount = self.countOfSelfChildsAndVisibleSubChilds(parent: parent)
            let startingIndex = (index+1)
            self.visibleChilds.insert(contentsOf: parent.children, at: startingIndex)
            return getIndexPathsOfInsertionsOrDeletions(index,
                                                        upToChildrenCount: childrenCount)
        }else{
            // countOfOnlyVisibleChilds - we have already expanded parent, we just need their visible childs to figure out the index in visibleChilds array.
            let childrenCount = self.countOfOnlyVisibleChilds(forParent: parent)
            // index of parent, where tapped. childrenCount already includes newly added children, so minus it to get the exact figure.
            let insertAtIndex = (index+childrenCount-childs.count)
            self.visibleChilds.insert(contentsOf: childs, at: insertAtIndex+1)
            return getIndexPathsOfInsertionsOrDeletions(insertAtIndex,
                                                        upToChildrenCount: childs.count)
        }
    }
}



// MARK: Add childs
extension InfinityTree {
    func mark(identitiyOfNode: String) -> [IndexPath]{
        // Use-cases
        // 1. first we are going to make child selected.
        // 2. find out any childs or subchilds. Make all of those marked. and return visible childs indexPaths.
        // 3. find out parent is having all childs marked, if yes. mark it.
        // 4. return IndexPaths to refresh visible childs
        
        guard let index = self.visibleChilds.firstIndex(where: {$0.identity == identitiyOfNode}) else { return [] }
        let node = self.visibleChilds[index]
        var indexToStart = index
        
        // 1 - usecase
        node.isMarked = !node.isMarked
        
        // 2 - usecase
        var refreshChildsOf: TreeNode<Any> = node  // This will help in [IndexPath], also can be modified in case-3
        self.makeOrUnmarkAllChilds(forParent: node, status: node.isMarked)
        
        // 3 - mark parent if its all childs selected.
        // Now, this will return one top parent to refresh it's all childs (If all childs selected). suppose parent's parent also have all childs selected now, in this case we can't figure out the visible childs to refresh, so will refresh all visible childs of that parent.
        if let parent = node.parent {
            let parentNode = self.markUnmarkParents(forParent: parent)
            // replace child to it's parent (or parent's parent) to make all childs refresh.
            if parentNode != nil {
                if let index = self.visibleChilds.firstIndex(where: {$0.identity == parentNode!.identity}) {
                    indexToStart = index
                    refreshChildsOf = parentNode!
                }
            }
        }
        
        // 4 - usecase
        let childrenCount = self.countOfOnlyVisibleChilds(forParent: refreshChildsOf)
        print(childrenCount)
        
        let indexPathsRefresh = getIndexPathsRemoveOrRefreshNodes(indexToStart,
        upToChildrenCount: childrenCount)
        return indexPathsRefresh
    }
    internal func makeOrUnmarkAllChilds<T>(forParent node: TreeNode<T>, status: Bool){
        for child in node.children {
            child.isMarked = status
            makeOrUnmarkAllChilds(forParent: child, status: status)
        }
    }
    internal func markUnmarkParents<T>(forParent node: TreeNode<T>) -> TreeNode<T>?{
        let countOfMarked = node.children.filter({$0.isMarked == true})
        var isAllMarked = false
        if countOfMarked.count == node.children.count {
            isAllMarked = true
        }
        // parent status changing
        if node.isMarked != isAllMarked {
            node.isMarked = isAllMarked
            if let parentAvailable = node.parent, let parent = markUnmarkParents(forParent: parentAvailable) {
                return parent
            }
            return node
        }else{
            return nil
        }
    }
}
