import Foundation
import SwiftUI
import Firebase
//import FirebaseFirestoreSwift

class QuotesService:ObservableObject {
    @Published var activeLesson:[Quote] =
    [Quote(id:  "Test ? Question", align: "0", tColor: ".white", bColor: ".purple", textSize: "60", text:"2", bkImage: "", cat: "")]
 
    
    
    static func fetchAllAvailableQuotes() async throws -> [Stylo] {
        var q = [Stylo]()
        //let snapshot2 = try await Firestore.firestore().collection("quotes").getDocuments()
        let snapshot2 = try await Firestore.firestore().collection("FirstCollection").getDocuments()
        let documents = snapshot2.documents
        
        for doc in documents {
            guard let qqq = try? doc.data(as:Quote.self)  else {  print("Cannot find this QUOTE 👚 doc");return q}
            var s:Stylo =  Stylo(text:  qqq.text.replacingOccurrences(of: "\\n", with: "\n"), 
                                 textSize: CGFloat(Double(qqq.textSize) ?? 30),
                                 bColor: Color(hex: qqq.bColor) ?? .red,
                                 tColor: Color(hex: qqq.tColor) ?? .orange,
                                 align: CGFloat(Double(qqq.align) ?? 30),
                                 bkImage: qqq.bkImage,
                                 cat:qqq.cat,
                                 id: CGFloat(Double(qqq.id) ?? 0))
            q.append(s)
        }
        return q.sorted { Int($0.id) ?? 0 < Int($1.id) ?? 0 }
    }
}


struct Quote: Codable, Identifiable , Hashable{
    var id:String
    var align:String
    var tColor: String
    var bColor:String
    var textSize:String
    var text:String
    var bkImage:String
    var cat:String
   
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
