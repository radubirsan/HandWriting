import SwiftUI

import SwiftUI

struct Stylo: Codable {
    var text: String
    var textSize: CGFloat = 30
    var bColor: Color
    var tColor: Color
    var align: CGFloat = 1
    var bkImage: String = ""
    var cat:String = ""
    
    // Conform to Codable for Color
    enum CodingKeys: CodingKey {
        case text, textSize, bColor, tColor, align, bkImage, cat
    }
    
    init(text: String, textSize: CGFloat = 30, bColor: Color, tColor: Color, align:CGFloat = 1, bkImage:String = "", cat:String = "") {
        self.text = text
        self.textSize = textSize
        self.bColor = bColor
        self.tColor = tColor
        self.align = align
        self.bkImage = bkImage
        self.cat = cat
    }
    
    // Custom encoding to handle Color
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(textSize, forKey: .textSize)
        try container.encode(UIColor(bColor).cgColor.components, forKey: .bColor)
        try container.encode(UIColor(tColor).cgColor.components, forKey: .tColor)
        try container.encode(align, forKey: .align)
        try container.encode(bkImage, forKey: .bkImage)
        try container.encode(cat, forKey: .cat)
    }
    
    // Custom decoding to handle Color
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        textSize = try container.decode(CGFloat.self, forKey: .textSize)
        let bColorComponents = try container.decode([CGFloat].self, forKey: .bColor)
        let tColorComponents = try container.decode([CGFloat].self, forKey: .tColor)
        bColor = Color(red: bColorComponents[0], green: bColorComponents[1], blue: bColorComponents[2])
        tColor = Color(red: tColorComponents[0], green: tColorComponents[1], blue: tColorComponents[2])
        align = try container.decode(CGFloat.self, forKey: .align)
        bkImage = try container.decode(String.self, forKey:  .bkImage)
        cat = try container.decode(String.self, forKey:  .cat)
    }
}

