import SwiftUI
import Firebase
struct Favorites: View {
    @Binding var styloSelection: Int
    @Binding var tabSelection: Int
    @Binding var stylos: [Stylo]
    @State private var progress: Double = 0
    @State private var favorites: [Stylo] = []
    @State var showAll: Bool = true
    @State private var isSaving: Bool = false
    @State private var saveTask: Task<Void, Never>? = nil
    var columns: Int // New property to determine the number of columns
    @State private var selectedFilter: FilterOption = .all
    enum FilterOption: String, CaseIterable {
           case all = "All"
           case favorite = "Favorite"
           case funny = "Funny"
           case love = "Love"
           case money = "Money"
           case invite = "Invitation"
           case flyer = "Flyer"
           case cupon = "Coupon"
           case other = "Other" // You can add more filter options as needed
       }

    var body: some View {
//        VStack {
               

        ScrollView(showsIndicators: false) {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(FilterOption.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            //.pickerStyle(.segmented)
            .padding()
       // List{
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
        .safeAreaInset(edge: .bottom, alignment: isSaving ? .center : .trailing){
            if(isSaving) {
                ZStack  {
                    RoundedRectangle(cornerRadius: 12)
                    // .foregroundStyle(.gray.gradient.opacity(0.8))
                        .background(
                            .ultraThickMaterial,
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                        .frame(width: isSaving ? UIScreen.main.bounds.width - 20 : 74 , height:74)
                        .padding()
                    HStack {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width:210)
                            .padding()
                        Button {
                            print("Cancel", saveTask ?? "no saved task")
                            saveTask?.cancel()
                            progress = 0
                            isSaving = false
                        } label: {
                            Text("Cancel").bold()
                                .frame(width:73, height: 40)
                                .padding(7)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
           // }
            }
        }
        .onAppear {
            loadFavorites()
        }
        .onChange(of: progress) { _, newValue in
            print (9922, newValue)
            if( newValue > 0.9) {
                isSaving = false
            }
            
        }
        .onAppear() {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(columns == 1 ? "ExploreView" : "Favorites")",
                                                AnalyticsParameterScreenClass: "\(Favorites.self)"])
              }
    }

    // Extracted the main content into a computed property
    var contentView: some View {
        ForEach(filteredStylos, id: \.self) { index in
        //ForEach(0..<stylos.count, id: \.self) { index in
            if showAll || isFavorite(stylo: stylos[index]) {
                VStack {
                    Text(stylos[index].text)
                        .safeAreaPadding(.horizontal, 15)
                        .safeAreaPadding(.vertical, 15)
                        .font(.custom("LeckerliOne-Regular", size: stylos[index].textSize))
                        .frame(width: 365, height: 365, alignment: .top)
                        .multilineTextAlignment(stylos[index].align == 0 ? .leading : stylos[index].align == 1 ? .center : .trailing)
                        .background(
                                                   Group {
                                                       if (stylos[index].bkImage.count > 4) {
                                                           Image(stylos[index].bkImage)
                                                               .resizable()
                                                               .scaledToFill()
                                                               .clipped()
                                                       } else {
                                                           stylos[index].bColor
                                                       }
                                                   }.shadow(radius: 10, y: 10.0)
                                               )
                        .foregroundColor(stylos[index].tColor)
                        .cornerRadius(19)
                        .onTapGesture {
                            styloSelection = index
                            tabSelection = 3
                        }
                    
                    
                        HStack(spacing: 25) {
                            Button {
                                styloSelection = index
                                tabSelection = 3
                                
                            } label: {
                                
                                Image(systemName: "square.and.pencil")
                                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                            }
                            .contentTransition(.symbolEffect(.replace))
                            
                            .labelsHidden()
                            
                             if(columns == 1) {
                                Button(action: {
                                    isSaving = true
                                    saveTask = shareStylo(stylos[index])
                                }) {
                                    HStack {
                                        Text("Send")
                                        Image(systemName:  "paperplane")
                                    }
                                    .frame(width: 95, height: 24) // Fixed size for the "Go to Editor" button
                                    .font(.headline)
                                    .padding()
                                    .background(isSaving ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .disabled(isSaving)
                               // .symbolEffect(.bounce, options: isSaving ? .repeating : .nonRepeating , value: isSaving)
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
    func shareStylo(_ stylo: Stylo) -> Task<Void, Never>{
        print("Share Z \(stylo.text)")
        Helper.size = stylo.textSize
        return Helper.presentShareLink(stylo, $progress)
        
        Analytics.logEvent(AnalyticsEventShare,  parameters: ["param_appShared" : "App Shared from\( Favorites.self)"])
    }
    
    
    // Filter stylos based on selectedFilter
    var filteredStylos: [Int] {
           switch selectedFilter {
           case .all:
               return Array(0..<stylos.count)
           case .favorite:
               return Array(0..<stylos.count).filter { isFavorite(stylo: stylos[$0]) }
           case .funny:
               return Array(0..<stylos.count).filter {  stylos[$0].cat.contains("funny") }
           case .love:
               return Array(0..<stylos.count).filter {   stylos[$0].cat.contains("love") }
           case .money:
               return Array(0..<stylos.count).filter { stylos[$0].cat.contains("money") }
           
               
           case .invite:
               // Implement filtering logic for "invite" if needed
               return Array(0..<stylos.count) // Placeholder
           case .flyer:
               // Implement filtering logic for "flyer" if needed
               return Array(0..<stylos.count) // Placeholder
           case .cupon:
               // Implement filtering logic for "cupon" if needed
               return Array(0..<stylos.count) // Placeholder
           case .other:
               // Implement filtering logic for "other" if needed
               return Array(0..<stylos.count) // Placeholder
           }
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
