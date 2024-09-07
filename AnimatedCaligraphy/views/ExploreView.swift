import SwiftUI

import SwiftUI

struct Stylo: Codable {
    var text: String
    var textSize: CGFloat = 30
    var bColor: Color
    var tColor: Color
    var align: CGFloat = 1
    
    // Conform to Codable for Color
    enum CodingKeys: CodingKey {
        case text, textSize, bColor, tColor, align
    }
    
    init(text: String, textSize: CGFloat = 30, bColor: Color, tColor: Color, align:CGFloat = 1) {
        self.text = text
        self.textSize = textSize
        self.bColor = bColor
        self.tColor = tColor
        self.align = align
    }
    
    // Custom encoding to handle Color
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(textSize, forKey: .textSize)
        try container.encode(UIColor(bColor).cgColor.components, forKey: .bColor)
        try container.encode(UIColor(tColor).cgColor.components, forKey: .tColor)
        try container.encode(align, forKey: .align)
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
    }
}

struct ExploreView: View {
    @Binding var styloSelection: Int
    @Binding var tabSelection: Int
    @Binding var stylos: [Stylo]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(0..<stylos.count, id: \.self) { index in
                VStack {
                    Text(stylos[index].text)
                        .font(.custom("LeckerliOne-Regular", size: stylos[index].textSize))
                        .frame(width: 375, height: 375, alignment: .top)
                        .multilineTextAlignment(stylos[index].align == 1 ? .leading : .center)
                        .background(stylos[index].bColor)
                        .foregroundColor(stylos[index].tColor)
                        .cornerRadius(9)
                   
                    HStack(spacing: 25) {
                        Button {
                            shareStylo(stylos[index])
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .scaleEffect(CGSize(width: 1.5, height: 1.5)).labelsHidden()
                        
                        Button(action: {
                            styloSelection = index
                            tabSelection = 3
                        }) {
                            Text("Go to Editor")
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button {
                            saveToFavorites(stylo: stylos[index])
                        } label: {
                            Image(systemName: "star")
                        }
                        .scaleEffect(CGSize(width: 1.5, height: 1.5)).labelsHidden()
                    }
                    .padding()
                }
            }
        }
    }
    
    // Function to save Stylo to UserDefaults as a favorite
    func saveToFavorites(stylo: Stylo) {
        var favorites = loadFavorites()
        favorites.append(stylo)
        
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteStylos")
        }
    }
    
    // Function to load favorites from UserDefaults
    func loadFavorites() -> [Stylo] {
        if let savedData = UserDefaults.standard.data(forKey: "FavoriteStylos"),
           let decoded = try? JSONDecoder().decode([Stylo].self, from: savedData) {
            return decoded
        }
        return []
    }
    
    // Placeholder for share function
    func shareStylo(_ stylo: Stylo) {
        print("ShareX \(stylo.text)")
        Helper.presentShareLink(stylo)
    }
}


#Preview {
    struct Preview: View {
            @State  var stylosX:Array =
        [ Stylo(text: "A", textSize: 30, bColor: .red, tColor: .white),
          Stylo(text: "Be be baby \n this is like goining to the movies", textSize: 10, bColor: .yellow, tColor: .black),
          Stylo(text: "Cares are owsome", textSize: 60, bColor: .blue, tColor: .white)
        ]
        
            var body: some View {
                
                ExploreView(styloSelection: .constant(2), 
                            tabSelection: .constant(2),
                            stylos: $stylosX)
            }
        }
    
    return Preview()
    
    
}
