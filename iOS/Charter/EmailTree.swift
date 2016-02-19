//
//  EmailTree.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

struct EmailTreeNode: Hashable, Equatable {
    let email: Email
    let children: [EmailTreeNode]
    
    var hashValue: Int { return email.messageID.hashValue }
}

func ==(lhs: EmailTreeNode, rhs: EmailTreeNode) -> Bool {
    return lhs.email.messageID == rhs.email.messageID && lhs.children == rhs.children
}

func PartitionEmailsIntoTreeForest(collection: [Email]) -> [EmailTreeNode] {
    var postIDs = Dictionary<String, Email>()
    collection.forEach { postIDs[$0.messageID] = $0 }

    var parentToChildren = Dictionary<Email, [Email]>()
    
    for node in collection {
        if let parent = node.inReplyTo {
            if parentToChildren[parent] == nil {
                parentToChildren[parent] = []
            }
            
            parentToChildren[parent]?.append(node)
        }
    }
    
    // Now construct tree nodes
    func emailTreeNodeFromEmail(email: Email) -> EmailTreeNode {
        let children = parentToChildren[email]?.map(emailTreeNodeFromEmail) ?? []
        return EmailTreeNode(email: email, children: children)
    }
    
    return collection
        .filter { $0.inReplyTo == nil }
        .map(emailTreeNodeFromEmail)
}

