//
//  HtmlFontSizeConstant.swift
//  StackPinLayout
//
//  Created by Muhammad Ghifari on 19/2/2023.
//

import Foundation

enum HtmlFontSize: String {
    case Paragraph = "p"
    case Heading1 = "h1"
    case Heading2 = "h2"
    case Heading3 = "h3"
    case Heading4 = "h4"
    case Heading5 = "h5"
    case Heading6 = "h6"
    
    func title() -> String {
        switch self {
        case .Paragraph:
            return "Paragraph"
        case .Heading1:
            return "Heading 1"
        case .Heading2:
            return "Heading 2"
        case .Heading3:
            return "Heading 3"
        case .Heading4:
            return "Heading 4"
        case .Heading5:
            return "Heading 5"
        case .Heading6:
            return "Heading 6"
        }
    }
}


