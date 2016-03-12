//
//  LabelService.swift
//  Charter
//
//  Created by Matthew Palmer on 12/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol LabelService {
    func colorForLabel(label: String) -> UIColor
    func formattedStringForLabel(label: String) -> String
}

extension LabelService {
    func colorForLabel(label: String) -> UIColor {
        let formattedLabel = formattedStringForLabel(label)
        
        switch formattedLabel {
        case "rfc":
            return UIColor(hue:1, saturation:0.35, brightness:0.91, alpha:1)
        case "discussion":
            return UIColor(hue:0.06, saturation:0.58, brightness:0.94, alpha:1)
        case "review":
            return UIColor(hue:0.67, saturation:0.65, brightness:0.91, alpha:1)
        case "idea":
            return UIColor(hue:0.28, saturation:0.35, brightness:0.91, alpha:1)
        case "draft":
            return UIColor(hue:0.45, saturation:0.35, brightness:0.91, alpha:1)
        case "proposal":
            return UIColor(hue:0.53, saturation:0.35, brightness:0.91, alpha:1)
        case "pitch":
            return UIColor(hue:0.78, saturation:0.35, brightness:0.91, alpha:1)
        case "accepted":
            return UIColor(hue:0.29, saturation:0.53, brightness:0.8, alpha:1)
        case "rejected":
            return UIColor(hue:0.01, saturation:0.69, brightness:0.82, alpha:1)
        default:
            return UIColor(hue:0, saturation:0, brightness:0.69, alpha:1)
        }
    }
    
    func formattedStringForLabel(label: String) -> String {
        return label.lowercaseString
    }
}

class LabelServiceImpl: LabelService {}
