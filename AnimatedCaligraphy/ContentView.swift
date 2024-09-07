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
 Bugs:
 EditorView custom binding in text editor causes problem with dictation
 */
// 414.0
//375 iphone
//360

import SwiftUI

struct ContentView: View {
    
    @State private var stylos:Array =

    [
        Stylo(text:  "Men go abroad to wonder at the heights of mountains, at the huge waves of the sea, at the long courses of the rivers, at the vast compass of the ocean, at the circular motions of the stars, and they pass by themselves without wondering.", textSize: 20, bColor: .purple, tColor: .white, align:2),
        Stylo(text:  "Lets try this one more time se how it wrapps", textSize: 20, bColor: .red, tColor: .white, align:0),
        Stylo(text:  "In the sweetness of friendship let there be laughter, and sharing of pleasures. For in the dew of little things the heart finds its morning and is refreshed. — Khalil Gibran", textSize: 40, bColor: .green, tColor: .white ,  align:1),
        Stylo(text: "The only thing to fear it's fear it self", textSize: 60, bColor: .green, tColor: .white, align: 2),
        Stylo(text: "Life is what happens when you're busy making other plans.", textSize: 40, bColor: .orange, tColor: .black, align: 3),
        Stylo(text: "Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.", textSize: 20, bColor: .purple, tColor: .white),
        Stylo(text: "The future belongs to those who believe in the beauty of their dreams.", textSize: 60, bColor: .pink, tColor: .black),
        Stylo(text: "It is during our darkest moments that we must focus to see the light.", textSize: 40, bColor: .gray, tColor: .white),
        Stylo(text: "Success is not final, failure is not fatal: It is the courage to continue that counts.", textSize: 20, bColor: .yellow, tColor: .black),
        Stylo(text: "Keep smiling, because life is a beautiful thing and there's so much to smile about.", textSize: 60, bColor: .cyan, tColor: .black),
        Stylo(text: "The best way to predict the future is to create it.", textSize: 40, bColor: .red, tColor: .white),
        Stylo(text: "In the end, it's not the years in your life that count. It's the life in your years.", textSize: 20, bColor: .blue, tColor: .white),
        Stylo(text: "Believe you can and you're halfway there.", textSize: 60, bColor: .purple, tColor: .white),
        Stylo(text: "The only impossible journey is the one you never begin.", textSize: 40, bColor: .green, tColor: .black),
        Stylo(text: "Do what you can, with what you have, where you are.", textSize: 20, bColor: .orange, tColor: .black),
        Stylo(text: "Life is either a daring adventure or nothing at all.", textSize: 60, bColor: .pink, tColor: .white),
        Stylo(text: "You only live once, but if you do it right, once is enough.", textSize: 40, bColor: .cyan, tColor: .black),
        Stylo(text: "It always seems impossible until it’s done.", textSize: 20, bColor: .yellow, tColor: .black),
        Stylo(text: "To live is the rarest thing in the world. Most people exist, that is all.", textSize: 60, bColor: .gray, tColor: .white),
        Stylo(text: "Life is made of ever so many partings welded together.", textSize: 40, bColor: .red, tColor: .white),
        Stylo(text: "Love the life you live. Live the life you love.", textSize: 20, bColor: .blue, tColor: .white),
        Stylo(text: "The purpose of our lives is to be happy.", textSize: 60, bColor: .green, tColor: .black),
        Stylo(text: "Turn your wounds into wisdom.", textSize: 40, bColor: .purple, tColor: .white)
    ]
    
    @State private var tabSelection = 1
    @State private var styloSelection = 1
    @State private var stylo:Stylo = Stylo(text: "Style", textSize: 30, bColor: .red, tColor: .black)
    @StateObject private var videoModel = VideoModel()
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection) {
                
                Favorites(styloSelection: $styloSelection,
                          tabSelection:$tabSelection ,
                          stylos: $stylos, showAll: true, columns:1)
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }.tag(1)
                
                
                
                EditorView(stylo:$stylo, videoModel: videoModel) 
                    .tabItem {
                        Label("Editor", systemImage: "pencil")
                    }.tag(3)
                
                Favorites(styloSelection: $styloSelection,
                          tabSelection:$tabSelection ,
                          stylos: $stylos, showAll: false, columns:2)
                    .tabItem {
                        Label("Favorites", systemImage: "star")
                    }.tag(2)
                
     
                
            }//.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
             //.animation(.easeInOut) // 2
             //.transition(.slide) // 3
           
                .onChange(of: tabSelection) { _, newSelection in
                    
                    
                    stylo = Stylo(text:"X" ,
                                  textSize:CGFloat.random(in: 0..<6),
                                  bColor:.red,
                                  tColor: .blue)

                                   Helper.size = stylos[styloSelection].textSize
                    print("BACK TO CONTENT VIEW")
                    
                    if newSelection == 3 { // Check if the Editor tab is selected
                        print("tabSelection 3")
                        stylo = Stylo(text:stylos[styloSelection].text ,
                                      textSize:stylos[styloSelection].textSize,
                                      bColor:stylos[styloSelection].bColor,
                                      tColor: stylos[styloSelection].tColor)
                                      Helper.size = stylos[styloSelection].textSize
                    }
                    else{
                        stylo = Stylo(text:"X" ,
                                      textSize:2,
                                      bColor:.red,
                                      tColor: .blue)

                                       Helper.size = stylos[styloSelection].textSize
                        print("BACK TO CONTENT VIEW")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
