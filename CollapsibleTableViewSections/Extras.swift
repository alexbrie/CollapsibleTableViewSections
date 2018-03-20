//
//  Extras.swift
//  CollapsibleTableViewSections
//
//  Created by Alex Brie on 20/03/2018.
//  Copyright © 2018 Alex Brie. All rights reserved.
//

import Foundation

import UIKit


// MARK: Utils

// important: snippet for loading fonts
func loadFonts() {
    for font_name in ["Roboto-Bold", "Roboto-Light", "Roboto-Regular"] {
        let fontURL = Bundle.main.url(forResource: font_name, withExtension: "ttf")
        CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)
    }
}

@objc class CommonColors : NSObject {
    @objc static let TextDarkest      = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.00)
    @objc static let TextDark         = UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00)
    @objc static let Error            = UIColor(red:0.73, green:0.06, blue:0.20, alpha:1.00)
    @objc static let TextPlaceholder  = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.00)
    @objc static let BorderGray       = UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.00)
    
    @objc static let RedColor: UIColor = UIColor(red: 203.0/255.0, green: 33.0/255.0, blue: 61.0/255.0, alpha: 1.0)
    
    @objc static let RedButtonEnabled = UIColor(red:203.0/255.0, green:33.0/255.0, blue:61.0/255.0, alpha:1.00)
    @objc static let ButtonDisabled = UIColor(red:220.0/255.0, green:222.0/255.0, blue:224.0/255.0, alpha:0.5)
    
    @objc static let NeutralGray  = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.00)
    @objc static let BackgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.00)
}

@objc class FontBuilder : NSObject {
    @objc static func light(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Light", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
    @objc static func bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    @objc static func font(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
@objc class JSONFileTools : NSObject {
    // MARK: Utils
    static func dictionaryFromFile(path: String) -> [AnyHashable: Any]? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .uncached)
        return try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyHashable: Any]
    }

    static func loadJsonByName(_ fileName: String) -> [AnyHashable: Any]? {
        let bundle = Bundle.main
        let pathOrNil = bundle.path(forResource: fileName, ofType: "json")
        guard let path = pathOrNil else {return nil}
        return dictionaryFromFile(path: path)
    }
}
