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
    
    var hashValue: Int { return email.headers.messageID.hashValue }
}

func ==(lhs: EmailTreeNode, rhs: EmailTreeNode) -> Bool {
    return lhs.email.headers.messageID == rhs.email.headers.messageID && lhs.children == rhs.children
}

func PartitionEmailsIntoTreeForest(collection: [Email]) -> [EmailTreeNode] {
    var postIDs = Dictionary<String, Email>()
    collection.forEach { postIDs[$0.headers.messageID] = $0 }

    var parentToChildren = Dictionary<Email, [Email]>()
    
    for node in collection {
        if let inReplyTo = node.headers.inReplyTo, parent = postIDs[inReplyTo] {
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
        .filter { $0.headers.inReplyTo == nil }
        .map(emailTreeNodeFromEmail)
}

