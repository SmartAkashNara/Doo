//
//  InfinityTreeTableViewHelperMethods.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation


// MARK: Helper methods for tableview - won't come in SwiftUI
// Only internal methods will be accessed here.

extension InfinityTree {
    
    // Accessible Outside -------------------------------------------------------
    func getNumberOfRows() -> Int{
        return self.visibleChilds.count
    }
    func infinityCellForRowAtIndex(_ index: Int) -> TreeNode<Any> {
        return self.visibleChilds[index]
    }
    func infinityDidSelectAtIndex(_ index: Int) -> (selectedNode: TreeNode<Any>, refreshed: [IndexPath], rowsAddedOrRemoved: [IndexPath], actionPerformed: InfinityTreesActionPerformed) {
        
        let node = self.visibleChilds[index]
        // if there are no children to selected node. don't go further.
        guard node.children.count != 0 else {return (node, [], [], .expanded)}
        node.isVisible = !node.isVisible
        
        // make it expand for default, if its gonna collapse then node.visible will be false.
        var actionPerform: InfinityTreesActionPerformed = .expanded
        if !node.isVisible {
            actionPerform = .collapsed
        }
        
        let addedOrRemovedRows = addOrRemoveVisibleChilds(node, actionPerform) // Show or Hide Childs.
        return (self.visibleChilds[index], [IndexPath.init(row: index, section: self.sectionOfTreeInTableview)], addedOrRemovedRows, actionPerform)
    }
    // ----------------------------------------------------------------------------

    private func addOrRemoveVisibleChilds(_ node: TreeNode<Any>, _ actionPerform: InfinityTreesActionPerformed) -> [IndexPath] {
        guard let indexAfterWhichYouCanAddOrRemove = self.getIndexOfNodeInVisibleChilds(node) else { return [] }
        
        switch actionPerform {
        case .expanded:
            // add childs in self.visibleChilds
            self.visibleChilds.insert(contentsOf: node.children, at: indexAfterWhichYouCanAddOrRemove+1)
            return getIndexPathsOfInsertionsOrDeletions(indexAfterWhichYouCanAddOrRemove,
                                                        upToChildrenCount: node.children.count)
        case .collapsed:
            // remove childs in self.visibleChilds
            let childrenCount = self.countOfSelfChildsAndVisibleSubChilds(parent: node)
            let startingIndex = (indexAfterWhichYouCanAddOrRemove+1)
            let endingIndex = startingIndex + childrenCount
            self.visibleChilds.removeSubrange(startingIndex..<endingIndex)
            return getIndexPathsOfInsertionsOrDeletions(indexAfterWhichYouCanAddOrRemove,
                                                        upToChildrenCount: childrenCount)
        }
    }
    
    internal func getIndexPathsOfInsertionsOrDeletions(_ indexAfterWhichAddedOrRemoved: Int,
                                              upToChildrenCount count: Int) -> [IndexPath] {
        var addedOrRemovedRows: [IndexPath] = []
        for row in 1...count {
            addedOrRemovedRows.append(IndexPath.init(row: (indexAfterWhichAddedOrRemoved+row), section: self.sectionOfTreeInTableview))
        }
        return addedOrRemovedRows
    }
    internal func getIndexPathsRemoveOrRefreshNodes(_ indexAfterWhichAddedOrRemoved: Int,
                                  upToChildrenCount count: Int) -> [IndexPath] {
        var removedRows: [IndexPath] = [IndexPath.init(row: indexAfterWhichAddedOrRemoved, section: self.sectionOfTreeInTableview)]
        guard count != 0 else {return removedRows}
        for row in 1...count {
            removedRows.append(IndexPath.init(row: (indexAfterWhichAddedOrRemoved+row), section: self.sectionOfTreeInTableview))
        }
        return removedRows
    }
}
