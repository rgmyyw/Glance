//
//  UIFont+.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift

// MARK: Fonts

extension UIFont {

    static func titleFont(_ size: CGFloat = 16) -> UIFont {
        return UIFont(name: "Helvetica", size: size)!
    }

    static func titleBoldFont(_ size: CGFloat = 16) -> UIFont {
        return UIFont(name: "Helvetica-Bold", size: size)!
    }

    static func descriptionFont() -> UIFont {
        return UIFont(name: "Helvetica", size: 14)!
    }
}

// MARK: All Fonts

extension UIFont {

    static func allSystemFontsNames() -> [String] {
        var fontsNames = [String]()
        let fontFamilies = UIFont.familyNames
        for fontFamily in fontFamilies {
            let fontsForFamily = UIFont.fontNames(forFamilyName: fontFamily)
            for fontName in fontsForFamily {
                fontsNames.append(fontName)
            }
        }
        return fontsNames
    }
}

// MARK: Randomizing Fonts

extension UIFont {

    static func randomFont(ofSize size: CGFloat) -> UIFont {
        let allFontsNames = UIFont.allSystemFontsNames()
        let fontsCount = UInt32(allFontsNames.count)
        let randomFontIndex = Int(arc4random_uniform(fontsCount))
        let randomFontName = allFontsNames[randomFontIndex]
        return UIFont(name: randomFontName, size: size)!
    }
}

extension Reactive where Base: UILabel {

    public var fontSize: Binder<CGFloat> {
        return Binder<CGFloat>(self.base) { label, size in
            label.font = label.font.withSize(size)
        }
    }
}
