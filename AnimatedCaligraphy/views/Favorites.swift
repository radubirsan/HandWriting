import SwiftUI

struct Favorites: View {
    @Binding var styloSelection: Int
    @Binding var tabSelection: Int
    @Binding var stylos: [Stylo]
    
    @State private var favorites: [Stylo] = []
    @State var showAll: Bool = true
    var columns: Int // New property to determine the number of columns

    var body: some View {
        ScrollView(showsIndicators: false) {
            if columns == 2 {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    contentView.scaleEffect(CGSize(width: 0.5, height: 0.5)).frame(height: 230)
                }
            } else {
                VStack {
                    contentView
                }
                .padding()
            }
        }
        .onAppear {
            loadFavorites()
        }
    }

    // Extracted the main content into a computed property
    var contentView: some View {
        ForEach(0..<stylos.count, id: \.self) { index in
            if showAll || isFavorite(stylo: stylos[index]) {
                VStack {
                    Text(stylos[index].text)
                        .safeAreaPadding(.horizontal, 15)
                        .safeAreaPadding(.vertical, 15)
                        .font(.custom("LeckerliOne-Regular", size: stylos[index].textSize))
                        .frame(width: 365, height: 365, alignment: .top)
                       
                        .multilineTextAlignment(stylos[index].align == 0 ? .leading : stylos[index].align == 1 ? .center : .trailing)
                        .background(stylos[index].bColor)
                        .foregroundColor(stylos[index].tColor)
                        .cornerRadius(19)
                        .onTapGesture {
                            styloSelection = index
                            tabSelection = 3
                        }
                    HStack(spacing: 25) {
                        Button {
                            shareStylo(stylos[index])
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .scaleEffect(CGSize(width: 1.3, height: 1.3))
                               // .resizable()
                                //.frame(width: 24, height: 24) // Fixed size for the share button
                        }
                        .labelsHidden()
                        if(columns == 1) {
                            Button(action: {
                                styloSelection = index
                                tabSelection = 3
                            }) {
                                Text("Edit")
                                    .frame(width: 70, height: 24) // Fixed size for the "Go to Editor" button
                                    .font(.headline)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                            Button {
                                toggleFavorite(stylo: stylos[index])
                            } label: {
                                Image(systemName: isFavorite(stylo: stylos[index]) ? "star.fill" : "star")
                                   // .resizable()
                                    //.frame(width: 24, height: 24) // Fixed size for the star button
                                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                            }
                            .labelsHidden()
                        
                    }.scaleEffect(CGSize(width: columns, height: columns))
                    .padding()
                }
            }
        }
    }

    // Function to save or remove Stylo from UserDefaults as a favorite
    func toggleFavorite(stylo: Stylo) {
        if let index = favorites.firstIndex(where: { $0.text == stylo.text && $0.textSize == stylo.textSize }) {
            // If the stylo is already a favorite, remove it
            favorites.remove(at: index)
        } else {
            // Otherwise, add it to the favorites
            favorites.append(stylo)
        }
        
        saveFavorites()
    }

    // Function to check if a Stylo is already in favorites
    func isFavorite(stylo: Stylo) -> Bool {
        return favorites.contains(where: { $0.text == stylo.text && $0.textSize == stylo.textSize })
    }

    // Function to save favorites to UserDefaults
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteStylos")
        }
    }

    // Function to load favorites from UserDefaults
    func loadFavorites() {
        if let savedData = UserDefaults.standard.data(forKey: "FavoriteStylos"),
           let decoded = try? JSONDecoder().decode([Stylo].self, from: savedData) {
            favorites = decoded
        }
    }

    // Placeholder for share function
    func shareStylo(_ stylo: Stylo) {
        print("Share Z \(stylo.text)")
        Helper.presentShareLink(stylo)
    }
}

#Preview {
    struct Preview: View {
        @State var stylosX: [Stylo] = [
            Stylo(text: "A", textSize: 30, bColor: .red, tColor: .white),
            Stylo(text: "Be be baby \n this is like going to the movies", textSize: 10, bColor: .yellow, tColor: .black),
            Stylo(text: "Cars are awesome", textSize: 60, bColor: .blue, tColor: .white)
        ]

        var body: some View {
            Favorites(styloSelection: .constant(2),
                      tabSelection: .constant(2),
                      stylos: $stylosX,
                      columns: 2) // Pass either 1 or 2 columns here
        }
    }

    return Preview()
}
