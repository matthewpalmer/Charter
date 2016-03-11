//
//  ColorGeneratorTest.swift
//  Charter
//
//  Created by Matthew Palmer on 11/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import XCTest
@testable import Charter

class ColorGeneratorTest: XCTestCase {
    func testWithEmptyHistory() {
        let generator = ColorGenerator(saturation: 0.2)(brightness: 0.25)(alpha: 0.95)
        let nextColor = generator(existingColors: []).HSBAValues
        XCTAssertEqual(nextColor.hue, 0.5)
        XCTAssertEqual(nextColor.brightness, 0.25)
        XCTAssertEqual(nextColor.alpha, 0.95)
        XCTAssertEqualWithAccuracy(nextColor.saturation, CGFloat(0.2), accuracy: CGFloat(FLT_EPSILON))
    }
    
    func testColorGenerator() {
        var pastColors = [
            UIColor(hue: 0.5, saturation: 0.25, brightness: 0.25, alpha: 0.25)
        ]
        
        let generator = ColorGenerator(saturation: 0.37)(brightness: 0.43)(alpha: 1.0)
        var nextColor = generator(existingColors: pastColors).HSBAValues
        
        XCTAssertEqual(nextColor.hue, 0.25)
        XCTAssertEqual(nextColor.brightness, 0.43)
        XCTAssertEqual(nextColor.alpha, 1.0)

        // Should be deterministic and stable -- repeat the test
        nextColor = generator(existingColors: pastColors).HSBAValues
        
        XCTAssertEqual(nextColor.hue, 0.25)
        XCTAssertEqual(nextColor.brightness, 0.43)
        XCTAssertEqual(nextColor.alpha, 1.0)
        
        pastColors.append(generator(existingColors: pastColors))
        nextColor = generator(existingColors: pastColors).HSBAValues
        XCTAssertEqual(nextColor.hue, 0.75)
        
        pastColors.append(generator(existingColors: pastColors))
        nextColor = generator(existingColors: pastColors).HSBAValues
        XCTAssertEqual(nextColor.hue, 0.125)
        
        pastColors.append(generator(existingColors: pastColors))
        nextColor = generator(existingColors: pastColors).HSBAValues
        XCTAssertEqualWithAccuracy(nextColor.hue, CGFloat(0.375), accuracy: CGFloat(FLT_EPSILON))
        
        pastColors.append(generator(existingColors: pastColors))
        nextColor = generator(existingColors: pastColors).HSBAValues
        XCTAssertEqualWithAccuracy(nextColor.hue, CGFloat(0.625), accuracy: CGFloat(FLT_EPSILON))
        
        pastColors.append(generator(existingColors: pastColors))
        nextColor = generator(existingColors: pastColors).HSBAValues
        XCTAssertEqual(nextColor.hue, 0.875)
    }
}
