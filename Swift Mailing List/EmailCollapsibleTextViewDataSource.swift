//
//  EmailCollapsibleTextViewDataSource.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 6/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import CollapsibleTextView

private func threeDotsToggleIndicator(lightBackground: Bool) -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 26))
    
    let background: UIColor
    let foreground: UIColor
    
    if lightBackground {
        background = UIColor.groupTableViewBackgroundColor()
        foreground = UIColor.lightGrayColor()
    } else {
        background = UIColor.lightGrayColor()
        foreground = UIColor.groupTableViewBackgroundColor()
    }
    
    view.backgroundColor = background
    view.layer.cornerRadius = 4
    view.layer.masksToBounds = true
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 22))
    label.text = "•••"
    label.textColor = foreground
    label.font = UIFont.systemFontOfSize(32)
    label.textAlignment = .Center
    
    view.addSubview(label)
    
    return view
}

private class CollapsedRegionView: UIView {
    lazy var expandIndicator: UIView = {
        return threeDotsToggleIndicator(true)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(expandIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func intrinsicContentSize() -> CGSize {
        let height = expandIndicator.frame.size.height + 10
        let width = expandIndicator.frame.size.width
        return CGSize(width: width, height: height)
    }
}

private class ExpandedRegionView: UIView {
    lazy var collapseIndicator: UIView = {
        let view = threeDotsToggleIndicator(false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.userInteractionEnabled = false
        textView.scrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .whiteColor()
        textView.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textView)
        self.addSubview(collapseIndicator)
        
        setupTextViewConstraints()
        setupCollapseIndicatorConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func updateConstraints() {
        super.updateConstraints()
    }
    
    private override func intrinsicContentSize() -> CGSize {
        let width = textView.intrinsicContentSize().width + collapseIndicator.frame.width
        let height = textView.intrinsicContentSize().height + collapseIndicator.frame.height + 10
        return CGSize(width: width, height: height)
    }
    
    private func setupTextViewConstraints() {
        let top = NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 10)
        
        addConstraints([top, left, right, height])
    }
    
    private func setupCollapseIndicatorConstraints() {
        let top = NSLayoutConstraint(item: collapseIndicator, attribute: .Top, relatedBy: .Equal, toItem: textView, attribute: .Bottom, multiplier: 1, constant: 0)
        // Slight margin
        let bottom = NSLayoutConstraint(item: collapseIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -10)
        let left = NSLayoutConstraint(item: collapseIndicator, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: collapseIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: collapseIndicator.frame.width)
        let height = NSLayoutConstraint(item: collapseIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: collapseIndicator.frame.height)
        
        addConstraints([top, bottom, left, width, height])
    }
}

class EmailCollapsibleTextViewDataSource: CollapsibleTextViewDataSource {
    override func staticRegionForIndex(index: Int, text: String) -> UIView {
        let view = UITextView()
        view.userInteractionEnabled = false
        view.scrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = text.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        view.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        return view
    }
    
    override func expandedRegionForIndex(index: Int, text: String) -> UIView {
        let view = ExpandedRegionView()
        
        view.textView.text = text.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        
        view.collapseIndicator.tag = index
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapRegion:")
        view.collapseIndicator.removeGestureRecognizer(tapGestureRecognizer)
        view.collapseIndicator.addGestureRecognizer(tapGestureRecognizer)
        
        return view
    }
    
    override func collapsedRegionForIndex(index: Int) -> UIView {
        let view = CollapsedRegionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.expandIndicator.tag = index
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapRegion:")
        view.expandIndicator.removeGestureRecognizer(tapGestureRecognizer)
        view.expandIndicator.addGestureRecognizer(tapGestureRecognizer)
        return view
    }
    
    override func didTapRegion(gesture: UITapGestureRecognizer) {
        super.didTapRegion(gesture)
    }
    
    class func QuoteRanges(email: String) -> [NSRange] {
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
}

