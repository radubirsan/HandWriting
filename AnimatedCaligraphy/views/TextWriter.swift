import SwiftUI

struct TextWriter: View {
    @Binding var letters: [Letter]
    @Binding var textSize: CGFloat
    var align: CGFloat // 0: Left, 1: Center, 2: Right
    var marginV: CGFloat
    var marginH: CGFloat
    @Binding var textSpeed:CGFloat
    @State private var cumulativeFrameCounts: [Int] = [] // Safe initialization
    @State var render:Bool = false
    
    var body: some View {
        ScrollView {
            if !letters.isEmpty && render {
               // ForEach(0..<rows.count, id: \.self) { index in
             
                    
                        MultiImageSequence(letters: letters,
                                           delay: 0 , // Safe access
                                           divideScale: 220 / textSize,
                                           marginV: 0,
                                           marginH: 0,
                                           speed:$textSpeed)
                            //.frame(height: textSize)
                            // .border(.green)
                    .frame(width: 365 - marginH*2, height: 365 - marginV*2)
                   // .border(.red)
                   // .frame(maxWidth: .infinity, alignment: alignmentForIndex(align))
                //}
            }// else {
              //  Text("Tap to edit")
               //     .foregroundColor(.red)
           // }
        }
        .padding(.vertical, marginV)
        .padding(.horizontal, marginH)
        
        .onChange(of: letters) { _, newValue in
            print("Changed rows")
            if(!render){
                render = true
            }
        }
        .onAppear {
            print("onAppear TextWriter")
            if(!render){
                render = true
            }
        }
    }
    
    func alignmentForIndex(_ align: CGFloat) -> Alignment {
        switch align {
        case 0:
            return .leading
        case 2:
            return .trailing
        default:
            return .center
        }
    }
    
   
}

// Safe subscript extension to avoid out-of-bounds error
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


import SwiftUI
import Combine
struct Letter: Equatable {
    let namePrefix: String
    let frameCount: Int
    let w: CGFloat
    let h: CGFloat
    var x:CGFloat = 0
    var y:CGFloat = 0
}

