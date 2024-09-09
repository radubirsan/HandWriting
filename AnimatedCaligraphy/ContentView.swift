// sources https://github.com/0Itsuki0/VideoWithAVFoundation_SwiftUI
import SwiftUI
/*Names:
 Post it
 AnimatedCaligraphy
 WriteIt
 HandWrittenNotes
 Handy
 StckyNotes
 QuatA
 Stylo
 Banner Bussines
 Write it Down
 Say it in Writing
 I said it
 -----Hand Writeing------
 Bugs:
 EditorView custom binding in text editor causes problem with dictation
 */
// 414.0
//375 iphone
//360

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var model: Model  // Use the shared model
    @State private var tabSelection = 1
    @State private var styloSelection = 1
    @State private var stylo: Stylo = Stylo(text: "Style", textSize: 30, bColor: .red, tColor: .black)
    @StateObject private var videoModel = VideoModel()
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection) {
                
                // Pass model.quotes to the Favorites view for Explore
                Favorites(styloSelection: $styloSelection,
                          tabSelection: $tabSelection,
                          stylos: $model.quotes, showAll: true, columns: 1)
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                    .tag(1)
                
                // Editor View with videoModel
                EditorView(stylo: $stylo, videoModel: videoModel)
                    .tabItem {
                        Label("Editor", systemImage: "pencil")
                    }
                    .tag(3)
                
                // Pass model.quotes to Favorites for Favorite quotes
                Favorites(styloSelection: $styloSelection,
                          tabSelection: $tabSelection,
                          stylos: $model.quotes, showAll: false, columns: 2 )
                    .tabItem {
                        Label("Favorites", systemImage: "star")
                    }
                    .tag(2)
            }
            .onChange(of: tabSelection) { _, newSelection in
                if newSelection == 3 {  // When switching to the Editor tab
                    let selectedStylo = model.quotes[styloSelection]
                    stylo = Stylo(text: selectedStylo.text,
                                  textSize: selectedStylo.textSize,
                                  bColor: selectedStylo.bColor,
                                  tColor: selectedStylo.tColor,
                                  bkImage: selectedStylo.bkImage)
                    Helper.size = selectedStylo.textSize
                } else {
                    stylo = Stylo(text: "X",
                                  textSize: 2,
                                  bColor: .red,
                                  tColor: .blue,
                                  bkImage: "")
                    Helper.size = model.quotes[styloSelection].textSize
                }
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(Model.shared)  // Pass the shared model to ContentView
}
@MainActor final class Model: ObservableObject {
    static let shared = Model()
    
    @Published var quotes = [Stylo]()
    private init() {
        print("init model")
       Task { try await fetchAllQuotes()}
      
    }
    
    
    @MainActor
    func fetchAllQuotes() async throws {
        quotes = try await   QuotesService.fetchAllAvailableQuotes()
        print(344222, quotes.count)
                   
//        if let set = ( lessons.first { $0.lessonName == "FirebaseSettings" }){
//            fireBaseSettings = set
//            print("FirebaseSettings:\n",
//                  fireBaseSettings.sheetID,
//                  fireBaseSettings.available,
//                  fireBaseSettings.category,
//                  fireBaseSettings.available,
//                  fireBaseSettings.id,
//                  fireBaseSettings.tip,
//                  fireBaseSettings.time,
//                  fireBaseSettings.img)
//        }
        
    }
    
}
