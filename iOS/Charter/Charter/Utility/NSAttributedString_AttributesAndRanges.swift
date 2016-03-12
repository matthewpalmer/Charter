//
//  NSAttributedString_AttributesAndRanges.swift
//  Charter
//
//  Created by Matthew Palmer on 12/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func applyEachAttribute(attributes: [String: AnyObject], toEachRange ranges: [NSRange]) {
        ranges.forEach { range in
            attributes.forEach {
                self.addAttribute($0.0, value: $0.1, range: range)
            }
        }
    }
}
