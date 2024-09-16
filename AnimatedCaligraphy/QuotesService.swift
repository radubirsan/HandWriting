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
            print(123, doc.data())
            guard let qqq = try? doc.data(as:Quote.self)  else {  print("Cannot find this QUOTE 👚 doc");return q}
            var s:Stylo =  Stylo(text:  qqq.text.replacingOccurrences(of: "\\n", with: "\n"), 
                                 textSize: CGFloat(Double(qqq.textSize) ?? 30),
                                 bColor: Color(hex: qqq.bColor) ?? .white,
                                 tColor: Color(hex: qqq.tColor) ?? .black,
                                 align: CGFloat(Double(qqq.align) ?? 30),
                                 bkImage: qqq.bkImage,
                                 cat:qqq.cat)
            q.append(s)
        }
        return q//.sorted { Int($0.id) ?? 0 < Int($1.id) ?? 0 }
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
    init?(hex: String) {
        var cleanedHex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        // Remove the '#' if it exists
        if cleanedHex.hasPrefix("#") {
            cleanedHex.remove(at: cleanedHex.startIndex)
        }

        // The hex code should be exactly 6 characters
        if cleanedHex.count != 6 {
            return nil
        }

        // Split the hex string into RGB components
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        // Create the SwiftUI Color from the RGB values
        self = Color(red: red, green: green, blue: blue)
    }
}
