//
//  CodeBlockParser.swift
//  Charter
//
//  Created by Matthew Palmer on 12/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol CodeBlockParser {
    func codeBlockRangesInText(text: String) -> [NSRange]
    func inlineCodeRangesInText(text: String) -> [NSRange]
}

class SwiftCodeBlockParser: CodeBlockParser {
    func inlineCodeRangesInText(text: String) -> [NSRange] {
        let regex = try! NSRegularExpression(pattern: "`[^`].*?`", options: []) // Must not include ```-style blocks
        let matches = regex.matchesInString(text, options: [], range: NSMakeRange(0, text.characters.count))
        return matches.map { $0.range }
    }
    
    func codeBlockRangesInText(text: String) -> [NSRange] {
        let swiftBlocks = swiftBlockRanges(text)
        let markdownBlocks = markdownBlockRanges(text)
        return markdownBlocks + swiftBlocks
    }
    
    /// Github flavoured code blocks.
    private func markdownBlockRanges(text: String) -> [NSRange] {
        let regex = try! NSRegularExpression(pattern: "^```.*?```[^\n]*\n", options: [.DotMatchesLineSeparators, .AnchorsMatchLines])
        return regex.matchesInString(text, options: [], range: NSMakeRange(0, text.characters.count)).map { $0.range }
    }
    
    private func swiftBlockRanges(text: String) -> [NSRange] {
        return []
    }
    
    /// Swift-specific `func {...}` style blocks
    /*
    private func _swiftBlockRanges(text: String) -> [NSRange] {
        // This method is *not* performant enough for production.
        
        
        // ^[a-z]+.*\{\\n*$
        // Need to keep an eye out for nested blocks
        
        var currentPosition = 0
        let regex = try! NSRegularExpression(pattern: "^[a-z]+.*\\{\\s*$", options: [.AnchorsMatchLines, .CaseInsensitive])
        
        var nextMatch = regex.firstMatchInString(text, options: [], range: NSMakeRange(currentPosition, text.characters.count))
        
        var ranges: [NSRange] = []
        
        while nextMatch != nil {
            let start = nextMatch!.range.location
            
            // Find the balancing curly and move the current position to the end of the block
            var unresolvedBraceCount = 0
            for i in start..<text.characters.count {
                if text[text.startIndex.advancedBy(i)] == "{" {
                    unresolvedBraceCount++
                } else if text[text.startIndex.advancedBy(i)] == "}" {
                    unresolvedBraceCount--
                    
                    // We've balanced our braces. Advance to the end of the line to complete the block.
                    if (unresolvedBraceCount == 0) {
                        var j = i
                        while j < text.characters.count && text[text.startIndex.advancedBy(j)] != "\n" {
                            j++
                        }
                        
                        let length: Int
                        if j - start + 1 > text.characters.count - start {
                            length = text.characters.count - start
                        } else {
                            length = j - start + 1  // + 1 to include the newline if possible
                        }
                        
                        ranges.append(NSMakeRange(start, length))
                        currentPosition = j + 1
                        break
                    }
                }
            }
            
            if currentPosition > text.characters.count || unresolvedBraceCount > 0 {
                nextMatch = nil
            } else {
                nextMatch = regex.firstMatchInString(text, options: [], range: NSMakeRange(currentPosition, text.characters.count - currentPosition))
            }
        }
        
        return ranges
    }
    */
}
