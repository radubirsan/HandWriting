//
//  Helper.swift
//  AnimatedCaligraphy
//
//  Created by radu on 29.08.2024.
//

import Foundation
import UIKit
import SwiftUI
class Helper{
    
    static var letters = [
        Letter(namePrefix: "___", frameCount: 4, w: 82, h: 242),
        Letter(namePrefix: "000", frameCount: 12, w: 138, h: 242),
        Letter(namePrefix: "111", frameCount: 11, w: 103, h: 242),
        Letter(namePrefix: "222", frameCount: 15, w: 135, h: 242),
        Letter(namePrefix: "333", frameCount: 12, w: 108, h: 242),
        Letter(namePrefix: "444", frameCount: 10, w: 141, h: 242),
        Letter(namePrefix: "555", frameCount: 11, w: 129, h: 242),
        Letter(namePrefix: "666", frameCount: 12, w: 147, h: 242),
        Letter(namePrefix: "777", frameCount: 12, w: 120, h: 242),
        Letter(namePrefix: "888", frameCount: 15, w: 124, h: 242),
        Letter(namePrefix: "999", frameCount: 16, w: 141, h: 242),
        
        Letter(namePrefix: "aaa", frameCount: 21, w: 125, h: 242),
        Letter(namePrefix: "bbb", frameCount: 21, w: 105, h: 242),
        Letter(namePrefix: "ccc", frameCount: 14, w: 78, h: 242),
        Letter(namePrefix: "ddd", frameCount: 19, w: 129, h: 242),
        Letter(namePrefix: "eee", frameCount: 20, w: 96, h: 242),
        Letter(namePrefix: "fff", frameCount: 23, w: 105, h: 242),
        Letter(namePrefix: "ggg", frameCount: 22, w: 128, h: 242),
        Letter(namePrefix: "hhh", frameCount: 18, w: 120, h: 242),
        Letter(namePrefix: "iii", frameCount: 12, w: 67, h: 242),
        Letter(namePrefix: "jjj", frameCount: 18, w: 80, h: 242, x:-41),
        Letter(namePrefix: "kkk", frameCount: 24, w: 111, h: 242),
        Letter(namePrefix: "lll", frameCount: 15, w: 89, h: 242),
        Letter(namePrefix: "mmm", frameCount: 21, w: 162, h: 242),
        Letter(namePrefix: "nnn", frameCount: 19, w: 117, h: 242),
        Letter(namePrefix: "ooo", frameCount: 22, w: 122, h: 242),
        Letter(namePrefix: "ppp", frameCount: 15, w: 105, h: 242, x:-3),
        Letter(namePrefix: "qqq", frameCount: 25, w: 127, h: 242),
        Letter(namePrefix: "rrr", frameCount: 15, w: 101, h: 242),
        Letter(namePrefix: "sss", frameCount: 12, w: 85, h: 242),
        Letter(namePrefix: "ttt", frameCount: 16, w: 77, h: 242),
        Letter(namePrefix: "uuu", frameCount: 16, w: 121, h: 242),
        Letter(namePrefix: "vvv", frameCount: 18, w: 110, h: 242),
        Letter(namePrefix: "www", frameCount: 26, w: 160, h: 242),
        Letter(namePrefix: "xxx", frameCount: 16, w: 105, h: 242),
        Letter(namePrefix: "yyy", frameCount: 15, w: 124, h: 242),
        Letter(namePrefix: "zzz", frameCount: 12, w: 101, h: 242),
        
        Letter(namePrefix: "AA", frameCount: 18, w: 144, h: 242),
        Letter(namePrefix: "BB", frameCount: 20, w: 141, h: 242),
        Letter(namePrefix: "CC", frameCount: 15, w: 125, h: 242),
        Letter(namePrefix: "DD", frameCount: 15, w: 144, h: 242),
        Letter(namePrefix: "EE", frameCount: 21, w: 141, h: 242),
        Letter(namePrefix: "FF", frameCount: 15, w: 125, h: 242),
        Letter(namePrefix: "GG", frameCount: 25, w: 144, h: 242),
        Letter(namePrefix: "HH", frameCount: 15, w: 141, h: 242),
        Letter(namePrefix: "II", frameCount: 7, w: 70, h: 242),
        Letter(namePrefix: "JJ", frameCount: 14, w: 114, h: 242),
        Letter(namePrefix: "KK", frameCount: 15, w: 141, h: 242),
        Letter(namePrefix: "LL", frameCount: 14, w: 125, h: 242),
        Letter(namePrefix: "MM", frameCount: 18, w: 144, h: 242),
        Letter(namePrefix: "NN", frameCount: 13, w: 141, h: 242),
        Letter(namePrefix: "OO", frameCount: 13, w: 125, h: 242),
        Letter(namePrefix: "QQ", frameCount: 14, w: 125, h: 242),
        Letter(namePrefix: "PP", frameCount: 12, w: 144, h: 242),
        Letter(namePrefix: "RR", frameCount: 18, w: 141, h: 242),
        Letter(namePrefix: "SS", frameCount: 12, w: 125, h: 242),
        Letter(namePrefix: "TT", frameCount: 11, w: 125, h: 242),
        Letter(namePrefix: "UU", frameCount: 15, w: 125, h: 242),
        Letter(namePrefix: "VV", frameCount: 16, w: 125, h: 242),
        Letter(namePrefix: "XX", frameCount: 17, w: 125, h: 242),
        Letter(namePrefix: "YY", frameCount: 15, w: 125, h: 242),
        Letter(namePrefix: "WW", frameCount: 22, w: 125, h: 242),
        Letter(namePrefix: "ZZ", frameCount: 15, w: 125, h: 242),
        
        Letter(namePrefix: "questionquestionquestion", frameCount: 9, w: 124, h: 242),
        Letter(namePrefix: "exclamationexclamationexclamation", frameCount: 9, w: 111, h: 242),
        Letter(namePrefix: "commacommacomma", frameCount: 6, w: 61, h: 242),
        Letter(namePrefix: "dotdotdot", frameCount: 4, w: 82, h: 242),
        Letter(namePrefix: "atatat", frameCount: 16, w: 191, h: 242),
        Letter(namePrefix: "hashtaghashtaghashtag", frameCount: 6, w: 97, h: 242),
        Letter(namePrefix: "dobledotdobledotdobledot", frameCount: 5, w: 90, h: 242),
        Letter(namePrefix: "linelineline", frameCount: 3, w: 78, h: 242),
        

    
    ]
    static public var size:CGFloat = 20
    static func postRequest() -> [String:String] {
         // do a post request and return post data
         return ["someData" : "someData"]
    }
    
    static func parse(_ i: String) -> [[Letter]] {
        var input = i
       
        wrapTextIfNeeded(&input)
       
        // Split the input by newline while keeping empty lines
        let lines = input.components(separatedBy: "\n")
        var allSequences: [[Letter]] = []
        
        for line in lines {
            // Handle lines that may be empty
            if line.isEmpty {
                print("Added new LINE with 'x' for empty line")
               // let xSequence = ImageSequence(namePrefix: "x") // Adjust this to match your ImageSequence initializer
                allSequences.append([letters.first! ])
                continue
            }
            
            let lett = line.map { String($0) }
            var sequences: [Letter] = []
            
            for l in lett {
               
                print("ll", l)
                let namePrefix = l.replacingOccurrences(of: " ", with: "_")
                                  .replacingOccurrences(of: "!", with: "exclamation")
                                  .replacingOccurrences(of: "?", with: "question")
                                  .replacingOccurrences(of: ",", with: "comma")
                                  .replacingOccurrences(of: ".", with: "dot")
                                  .replacingOccurrences(of: "#", with: "hashtag")
                                  .replacingOccurrences(of: "@", with: "at")
                                  .replacingOccurrences(of: ":", with: "doubledot")
                                  .replacingOccurrences(of: "-", with: "line")
                //.trimmingCharacters(in: .whitespaces)
                
                var count = 2
                if( namePrefix == namePrefix.lowercased() ){
                    count = 3
                }
                let expandedPrefix = String(repeating: namePrefix, count: count)
                if let matchingSequence = letters.first(where: { $0.namePrefix == expandedPrefix }) {
                    sequences.append(matchingSequence)
                } else {
                    print("No match found for: \(namePrefix)")
                }
            }
            
            if !sequences.isEmpty {
                allSequences.append(sequences)
            }
        }
        
        return allSequences
    }
    
    
    static func wrapTextIfNeeded(_ inputString: inout String) {
        let words = inputString.split(separator: " ").map(String.init)
        var currentLine = ""
        var modifiedText = ""
        var isFirstWordOnLine = true

        for word in words {
            let testLine = currentLine.isEmpty ? word : "\(currentLine) \(word)"
            let textWidth = textWidth(for: testLine)
            //print("WIDTH -> ", textWidth, testLine)
            
            if textWidth > 335  {
                // Add the current line to the modifiedText and start a new line with the word
                modifiedText += isFirstWordOnLine ? currentLine : "\n\(word)"
                currentLine = word
                isFirstWordOnLine = false
            } else {
                currentLine = testLine
                modifiedText += isFirstWordOnLine ? word : " \(word)"
                isFirstWordOnLine = false
            }
        }

        inputString = modifiedText
    }

    
    
    static func textWidth(for text: String) -> CGFloat {
       
        let font = UIFont(name: "LeckerliOne-Regular", size: size)
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
       // print("texWidth:", size.width)
        return size.width
    }
    
    static func presentShareLink(_ s:Stylo, _ progress: Binding<Double> ) -> Task<Void, Never> {
        
       
      let task  = Task {
            var sequences = Helper.parse(s.text.trimmingCharacters(in: .whitespaces))
            var videoModel: VideoModel = VideoModel()
            var savedVideoURL = await videoModel.saveModifiedVideo(sequences, s.bColor, s.tColor,
                                                                   .center,
                                                                   s.bkImage,
                                                                   quality: CGSize(width:719, height:719),
                                                                   fps:30,
                                                                   progressHandler: { value in
                                                                                  DispatchQueue.main.async {
                                                                                      progress.wrappedValue = value
                                                                                  }
                      
                                                                        }
                                                    )
            print(" saveModifiedVideo",  savedVideoURL ?? "no file")
            DispatchQueue.main.async {
               
                
                print("and here")
               // Thread.sleep(forTimeInterval: 5.2)
                let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let fileUrl2 = directoryPath!.appendingPathComponent("modified").appendingPathExtension("mp4")
                
               
                
                guard let url = URL(string: fileUrl2.absoluteString) else { return }
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
                scene?.keyWindow?.rootViewController?.present(vc, animated: true)
            }
        }
        return task
       
    }
    
}

