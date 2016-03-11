//
//  ColorGenerator.swift
//  Charter
//
//  Created by Matthew Palmer on 11/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

extension UIColor {
    var HSBAValues: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue = CGFloat()
        var sat = CGFloat()
        var bright = CGFloat()
        var alpha = CGFloat()
        self.getHue(&hue, saturation: &sat, brightness: &bright, alpha: &alpha)
        return (hue: hue, saturation: sat, brightness: bright, alpha: alpha)
    }
}

/// Returns a color (with the provided saturation and brightness) whose hue is the greatest possible distance from the hue of the colors in the list provided.
/// Saturation, brightness, alpha, and hue follow UIColor in the range of their values—from 0.0 to 1.0.
func ColorGenerator(saturation saturation: CGFloat)(brightness: CGFloat)(alpha: CGFloat)(existingColors: [UIColor]) -> UIColor {
    let existingHues = existingColors.map { $0.HSBAValues.hue }.sort()
    
    // Find the largest interval in the list of existing hues
    var rangeWithLargestDelta: (low: CGFloat, high: CGFloat) = (0, 1)
    var lastHue: CGFloat?
    
    for hue in existingHues {
        if lastHue == nil {
            // First hue in list
            rangeWithLargestDelta = (low: 0.0, high: hue)
        } else {
            let delta = hue - lastHue!
            
            if delta > rangeWithLargestDelta.high - rangeWithLargestDelta.low {
                rangeWithLargestDelta = (low: lastHue!, high: hue)
            }
            
            if hue == existingHues.last {
                // Check that the distance from here to the end won't be better
                if 1.0 - hue > rangeWithLargestDelta.high - rangeWithLargestDelta.low {
                    rangeWithLargestDelta = (low: hue, high: 1.0)
                }
            }
        }
        
        
        lastHue = hue
    }
    
    let split = rangeWithLargestDelta.low + (rangeWithLargestDelta.high - rangeWithLargestDelta.low) / 2
    return UIColor(hue: split, saturation: saturation, brightness: brightness, alpha: alpha)
}
