//
//  Fonts.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SwiftUI

extension UIFont {
    struct Poppins {
        static let regular = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Regular", size: size)!
        }
        
        static let medium = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Medium", size: size) ?? UIFont.systemFont(ofSize: 15)
        }
        
        static let semiBold = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-SemiBold", size: size)!
        }
        
        static let bold = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Bold", size: size)!
        }
        
        static let extraBold = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-ExtraBold", size: size)!
        }
        
        static let black = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Black", size: size)!
        }
        
        static let italic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Italic", size: size)!
        }
        
        static let thin = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Thin", size: size)!
        }
        
        static let light = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-Light", size: size)!
        }
        
        static let extraLight = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-ExtraLight", size: size)!
        }
        

        static let mediumItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-MediumItalic", size: size)!
        }

        static let semiBoldItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-SemiBoldItalic", size: size)!
        }

        static let boldItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-BoldItalic", size: size)!
        }

        static let extraBoldItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-ExtraBoldItalic", size: size)!
        }

        static let blackItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-BlackItalic", size: size)!
        }

        static let thinItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-ThinItalic", size: size)!
        }

        static let lightItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-LightItalic", size: size)!
        }

        static let extraLightItalic = { (size: CGFloat) -> UIFont in
            return UIFont(name: "Poppins-ExtraLightItalic", size: size)!
        }

    }
}



extension Font {
    struct Poppins {
        static let regular = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Regular", size: size)
        }
        
        static let medium = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Medium", size: size)
        }
        
        static let semiBold = { (size: CGFloat) -> Font in
            Font.custom("Poppins-SemiBold", size: size)
        }
        
        static let bold = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Bold", size: size)
        }
        
        static let extraBold = { (size: CGFloat) -> Font in
            Font.custom("Poppins-ExtraBold", size: size)
        }
        
        static let black = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Black", size: size)
        }
        
        static let italic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Italic", size: size)
        }
        
        static let thin = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Thin", size: size)
        }
        
        static let light = { (size: CGFloat) -> Font in
            Font.custom("Poppins-Light", size: size)
        }
        
        static let extraLight = { (size: CGFloat) -> Font in
            Font.custom("Poppins-ExtraLight", size: size)
        }
        

        static let mediumItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-MediumItalic", size: size)
        }

        static let semiBoldItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-SemiBoldItalic", size: size)
        }

        static let boldItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-BoldItalic", size: size)
        }

        static let extraBoldItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-ExtraBoldItalic", size: size)
        }

        static let blackItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-BlackItalic", size: size)
        }

        static let thinItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-ThinItalic", size: size)
        }

        static let lightItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-LightItalic", size: size)
        }

        static let extraLightItalic = { (size: CGFloat) -> Font in
            Font.custom("Poppins-ExtraLightItalic", size: size)
        }

    }
}
