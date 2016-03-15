//
//  ThreeDotsButton.swift
//  Charter
//
//  Created by Matthew Palmer on 16/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class ThreeDotsButton: UIView {
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
    
    override func intrinsicContentSize() -> CGSize {
        let height = expandIndicator.frame.size.height
        let width = expandIndicator.frame.size.width
        return CGSize(width: width, height: height)
    }
}

private func threeDotsToggleIndicator(lightBackground: Bool) -> UIView {
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 40)) // Gives the nutri grain piece some padding
    let view = UIView(frame: CGRect(x: 5, y: 7, width: 60, height: 26))
    
    let background: UIColor
    let foreground: UIColor
    
    if lightBackground {
        background = UIColor.groupTableViewBackgroundColor()
        foreground = UIColor.lightGrayColor()
    } else {
        background = UIColor.lightGrayColor()
        foreground = UIColor.groupTableViewBackgroundColor()
    }
    
    parent.addSubview(view)
    
    view.backgroundColor = background
    view.layer.cornerRadius = 4
    view.layer.masksToBounds = true
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 22))
    label.text = "•••"
    label.textColor = foreground
    label.font = UIFont.systemFontOfSize(32)
    label.textAlignment = .Center
    
    view.addSubview(label)
    
    return parent
}
