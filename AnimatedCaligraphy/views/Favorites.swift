import SwiftUI
import Firebase
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Favorites: View {
    @FocusState private var isSearchFieldFocused: Bool
    @State private var editSTL = EditStylo()
    @State private var refreshTrigger: Bool = false
    @Binding var selectIDX: Int
    @Binding var tabSelection: Int
    @Environment(Model.self) var model
    @State private var progress: Double = 0
    @State private var favorites: [Stylo] = []
    @State var showAll: Bool = true
    @State private var isSaving: Bool = false
    @State private var saveTask: Task<Void, Never>? = nil
    var columns: Int
    @State private var selectedFilter: FilterOption = .all
    @State private var searchText: String = ""
    @State private var showEditorView = false
    @StateObject private var videoModel = VideoModel()
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case funny = "Funny"
        case love = "Love"
        case money = "Money"
        case invite = "Invite"
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                // Just the filter picker - no more custom search field
                HStack {
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(FilterOption.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                
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
          //  .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(columns == 1 ? "Explore" : "Favorites") // Required for .searchable
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search quotes..."
            ) {
                // Optional: Add search suggestions based on categories
                if !searchText.isEmpty {
                    ForEach(FilterOption.allCases.filter { $0 != .all }, id: \.self) { filter in
                        Text(filter.rawValue)
                            .searchCompletion(filter.rawValue.lowercased())
                    }
                }
            }
//            .toolbar {
//                //      DefaultToolbarItem(kind: .search, placement: .bottomBar)
//
//                      ToolbarSpacer(placement: .bottomBar)
//
//                      ToolbarItem(placement: .bottomBar) {
//                          Button {} label: { Label("New", systemImage: "square.and.pencil") }
//                      }
//                  }
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                Button(action: {
                    selectIDX = 999
                    loadSelectedStylo()
                    showEditorView = true
                }) {
                    Image(systemName: "plus")
                        .frame(width: 40.0, height: 40.0)
                        .font(.system(size: 26)).bold()
                }
                .buttonStyle(.glass)
                .padding([.bottom, .trailing], 20)
            }
            .fullScreenCover(isPresented: $showEditorView) {
                EditorView(editSTL: editSTL, videoModel: videoModel)
            }
            .safeAreaInset(edge: .bottom, alignment: isSaving ? .center : .trailing) {
                if(isSaving) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
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
                }
            }
            .onAppear {
                loadFavorites()
            }
            .onChange(of: progress) { _, newValue in
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
    }
    
    // Rest of your methods remain the same...
    var contentView: some View {
        ForEach(filteredStylos, id: \.self) { index in
            if showAll || isFavorite(stylo: model.quotes[index]) {
                VStack {
                    if let hh = Helper.BKimages.first ( where: { $0.imageName == model.quotes[index].bkImage} ) {
                        Text(model.quotes[index].text)
                            .font(.custom("LeckerliOne-Regular", size: model.quotes[index].textSize))
                            .padding(EdgeInsets(top: hh.verticalPadding, leading:  hh.horizontalPadding, bottom: hh.verticalPadding, trailing: hh.horizontalPadding))
                            .fixedSize(horizontal: false, vertical: false)
                            .frame(width: 365, height: 365, alignment: .top)
                            .multilineTextAlignment(model.quotes[index].align == 0 ? .leading : model.quotes[index].align == 1 ? .center : .trailing)
                            .background(
                                Group {
                                    if (model.quotes[index].bkImage.count > 4) {
                                        Image(model.quotes[index].bkImage)
                                            .resizable()
                                            .scaledToFill()
                                            .clipped()
                                    } else {
                                        model.quotes[index].bColor
                                    }
                                }.shadow(radius: 10, y: 10.0)
                            )
                            .foregroundColor(model.quotes[index].tColor)
                            .cornerRadius(19)
                            .onTapGesture {
                                selectIDX = index
                                loadSelectedStylo()
                                showEditorView = true
                            }
                            .shadow(radius: 10, y: 10.0)
                    }
                    
                    HStack(spacing: 25) {
                        Button {
                            selectIDX = index
                            loadSelectedStylo()
                            showEditorView = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .scaleEffect(CGSize(width: 1.3, height: 1.3))
                        }
                        .contentTransition(.symbolEffect(.replace))
                        .labelsHidden()
                        
                        if(false && columns == 1 ) {
                            Button(action: {
                                isSaving = true
                                saveTask = shareStylo(model.quotes[index])
                            }) {
                                HStack {
                                    Text("Send")
                                    Image(systemName:  "paperplane")
                                }
                                .frame(width: 95, height: 24)
                                .font(.headline)
                                .padding()
                                .background(isSaving ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(isSaving)
                        }
                        
                        Button {
                            toggleFavorite(stylo: model.quotes[index])
                        } label: {
                            Image(systemName: isFavorite(stylo: model.quotes[index]) ? "star.fill" : "star")
                                .scaleEffect(CGSize(width: 1.3, height: 1.3))
                        }
                        .labelsHidden()
                        
                    }.scaleEffect(CGSize(width: columns, height: columns))
                        .padding()
                }
            }
        }
    }
    
    // All your existing methods remain the same...
    func loadSelectedStylo() {
        var selectedStylo: Stylo = Stylo(text: "",
                                       textSize: 40,
                                       bColor: .red,
                                       tColor: Color(hex: "#ff00ff"),
                                       align: 0,
                                       bkImage: "letter_1")
        
        if selectIDX != 999 && selectIDX < model.quotes.count {
            selectedStylo = model.quotes[selectIDX]
        }
        
        Helper.size = selectedStylo.textSize
        Helper.mapStyloToEditSTL(selectedStylo, editSTL)
    }

    func toggleFavorite(stylo: Stylo) {
        if let index = favorites.firstIndex(where: { $0.text == stylo.text && $0.textSize == stylo.textSize }) {
            favorites.remove(at: index)
        } else {
            favorites.append(stylo)
        }
        saveFavorites()
    }

    func isFavorite(stylo: Stylo) -> Bool {
        return favorites.contains(where: { $0.text == stylo.text && $0.textSize == stylo.textSize })
    }

    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteStylos")
        }
    }

    func loadFavorites() {
        if let savedData = UserDefaults.standard.data(forKey: "FavoriteStylos"),
           let decoded = try? JSONDecoder().decode([Stylo].self, from: savedData) {
            favorites = decoded
        }
    }

    func shareStylo(_ stylo: Stylo) -> Task<Void, Never>{
        print("Share Z \(stylo.text)")
        Helper.size = stylo.textSize
        
        var editSTL:EditStylo = EditStylo()
        Helper.mapStyloToEditSTL(stylo, editSTL)
        return Helper.presentShareLink(stylo, $progress)
    }
    
    var filteredStylos: [Int] {
        Array(0..<model.quotes.count)
            .filter { styloIndex in
                let stylo = model.quotes[styloIndex]
                return (searchText.isEmpty || stylo.text.localizedCaseInsensitiveContains(searchText)) &&
                (selectedFilter == .all ||  stylo.cat.contains(selectedFilter.rawValue.lowercased()))
            }
    }
}

#Preview {
    struct Preview: View {
        @State var XsxtylosX: [Stylo] = [
            Stylo(text: "A", textSize: 30, bColor: .red, tColor: .white),
            Stylo(text: "Be be baby \n this is like going to the movies", textSize: 10, bColor: .yellow, tColor: .black),
            Stylo(text: "Cars are awesome", textSize: 60, bColor: .blue, tColor: .white)
        ]

        var body: some View {
            Favorites(selectIDX: .constant(2),
                      tabSelection: .constant(2),
                      columns: 2) // Pass either 1 or 2 columns here
        }
    }

    return Preview()
}
