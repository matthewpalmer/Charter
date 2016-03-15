//
//  EmailQuoteRanges.swift
//  Charter
//
//  Created by Matthew Palmer on 16/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

func EmailQuoteRanges(email: String) -> [NSRange] {
    var lines = email.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).map { $0 + "\n" }
    
    // the `.map { $0 + "\n" }` may have incorrectly added a newline. Remove it if it wasn't present
    if let lastCharacter = email.characters.last {
        if lastCharacter != "\n" {
            let lastLine = lines[lines.count - 1]
            let withoutNewline = (lastLine as NSString).stringByReplacingOccurrencesOfString("\n", withString: "")
            lines[lines.count - 1] = withoutNewline
        }
    }
    
    var ranges: [NSRange] = []
    
    var location: Int = 0
    
    for line in lines {
        if line.hasPrefix(">") {
            if let lastRange = ranges.last {
                if lastRange.location + lastRange.length == location {
                    // Continue range
                    let last = ranges.popLast()!
                    let newLast = NSMakeRange(last.location, last.length + line.characters.count)
                    ranges.append(newLast)
                } else {
                    // Start new range
                    ranges.append((NSMakeRange(location, line.characters.count)))
                }
            } else {
                // Start new range
                ranges.append((NSMakeRange(location, line.characters.count)))
            }
        }
        
        location += line.characters.count
    }
    
    return ranges
}
