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

/*Simulator iPhoneMini photos
 
/Users/radu/Library/Developer/CoreSimulator/Devices/AC4F6052-1C8D-409B-A958-61CC481B40A4/data/Media/DCIM/100APPLE
 */
// -FIRDebugEnabled add this in Produc-Scheme-Edit scheme to debug firebase analytics events
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import RevenueCat
import RevenueCatUI


struct ContentView: View {
    @Environment(Model.self) var model: Model  // Use the shared model
    @State private var tabSelection = 1
    @State private var styloSelection = 1
    @State private var stylo: Stylo = Stylo(text: "Style", textSize: 30, bColor: .red, tColor: .black)
    @StateObject private var videoModel = VideoModel()
  //  @State var userM = UserViewModel()
    @State private var player2 = Player()
    var editSTL:EditStylo = EditStylo()
    var body: some View {
    
        NavigationView {
            TabView(selection: $tabSelection) {
                
                // Pass model.quotes to the Favorites view for Explore
                Favorites(selectIDX: $styloSelection,
                          tabSelection: $tabSelection,
                           showAll: true, columns: 1)
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                    .tag(1)
               
                // Editor View with videoModel
                EditorView(editSTL:editSTL, videoModel:videoModel)
                    .tabItem {
                        Label("Editor", systemImage: "square.and.pencil")
                    }
                    .tag(3)
                
                // Pass model.quotes to Favorites for Favorite quotes
                Favorites(selectIDX: $styloSelection,
                          tabSelection: $tabSelection,
                           showAll: false, columns: 2 )
                    .tabItem {
                        Label("Favorites", systemImage: "star")
                    }
                    .tag(2)
            }
            .onChange(of: tabSelection) { _, newSelection in
                if newSelection == 3 {  // When switching to the Editor tab
                    let selectedStylo = model.quotes[styloSelection]
                    print("tab3", selectedStylo.text)
                    stylo = Stylo(text: selectedStylo.text,
                                  textSize: selectedStylo.textSize,
                                  bColor: selectedStylo.bColor,
                                  tColor: selectedStylo.tColor,
                                  align: selectedStylo.align,
                                  bkImage: selectedStylo.bkImage)
                    Helper.size = selectedStylo.textSize
                    Helper.mapStyloToEditSTL(stylo, self.editSTL)
                    print("Genereate EditStye", selectedStylo.tColor)
                    
                   
                } else {
                    stylo = Stylo(text: "X",
                                  textSize: 2,
                                  bColor: .red,
                                  tColor: .blue,
                                  align: 4,
                                  bkImage: "")
                    Helper.size = model.quotes[styloSelection].textSize
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(Model.shared)  // Pass the shared model to ContentView
}
@Observable
class Model {
    static let shared = Model()
    
    var quotes = [Stylo]()
    private init() {
        print("init model")
       Task { try await fetchAllQuotes()}
      
    }
    
    
    @MainActor
    func fetchAllQuotes() async throws {
        quotes = try await   QuotesService.fetchAllAvailableQuotes()
    }
    
}






extension View {
    func limitText(_ text:String, to characterLimit: Int) -> some View {
        self
            .onChange(of: text) { _ in
              //  text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
}

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}


extension Color {
    static func convert(_ color: Color) -> UIColor {
        return UIColor(color)
    }
}


@Observable
class Player {
    var name = "Anonymous"
    var highScore = 0
}

