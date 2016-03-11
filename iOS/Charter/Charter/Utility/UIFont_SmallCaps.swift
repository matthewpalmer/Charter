//
//  UIFont_SmallCaps.swift
//  Charter
//
//  Created by Matthew Palmer on 12/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

// Source: http://stackoverflow.com/questions/12941984/typesetting-a-font-in-small-caps-on-ios
extension UIFont {
    class func smallCapsFontOfSize(size: CGFloat, withName name: String = UIFont.systemFontOfSize(12).fontName) -> UIFont {
        /*
        // Use this to log all of the properties for a particular font
        UIFont *font = [UIFont fontWithName: fontName size: fontSize];
        CFArrayRef  fontProperties  =  CTFontCopyFeatures ( ( __bridge CTFontRef ) font ) ;
        NSLog(@"properties = %@", fontProperties);
        */
        
        let fontFeatureSettings = [[UIFontFeatureTypeIdentifierKey: kLowerCaseType, UIFontFeatureSelectorIdentifierKey: kLowerCaseSmallCapsSelector]]
        let attributes = [UIFontDescriptorFeatureSettingsAttribute: fontFeatureSettings, UIFontDescriptorNameAttribute: name]
        let descriptor = UIFontDescriptor(fontAttributes: attributes as! [String : AnyObject])
        let font = UIFont(descriptor: descriptor, size: size)
        return font
    }
    
    class func systemSmallCapsMediumWeightFontOfSize(size: CGFloat) -> UIFont {
        return UIFont.smallCapsFontOfSize(size, withName: UIFont.systemFontOfSize(12, weight: UIFontWeightMedium).fontName)
    }
}
