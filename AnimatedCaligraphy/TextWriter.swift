import SwiftUI

import SwiftUI

struct TextWriter: View {
    @Binding var inputString: String
    @Binding var rows: [[Letter]]
    @Binding var textSize: CGFloat
    @Binding var align: Int // 0: Left, 1: Center, 2: Right
    @Binding var margin: CGFloat
    @Binding var textSpeed:CGFloat
    @State private var cumulativeFrameCounts: [Int] = [] // Safe initialization
    @State var render:Bool = false
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: 20)
            if !rows.isEmpty && render {
                ForEach(0..<rows.count, id: \.self) { index in
                    HStack {
                        if align == 2 {
                            Spacer(minLength: 0)
                        }
                        MultiImageSequence(letters: rows[index],
                                           delay: Double(cumulativeFrameCounts[safe: index] ?? index) * 0.005 , // Safe access
                                           divideScale: 220 / textSize,
                                           margin: margin, speed:$textSpeed)
                            .frame(height: textSize)
                        if align == 0 {
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: alignmentForIndex(align))
                }
            } else {
                Text("No sequences to display")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .onAppear {
            print("onAppear TextWriter", inputString)
            if(!render){
                rows = Helper.parse(inputString.trimmingCharacters(in: .whitespaces))
                calculateCumulativeFrameCounts() // Update cumulativeFrameCounts
                render = true
            }
        }
        .onChange(of: inputString) { _ , newValue in
            
            print("onChange TextWriter", newValue)
                    // Update rows whenever inputString changes to always display the latest content
                    rows = Helper.parse(newValue.trimmingCharacters(in: .whitespaces))
                    calculateCumulativeFrameCounts()
                }
    }
    
    func alignmentForIndex(_ align: Int) -> Alignment {
        switch align {
        case 0:
            return .leading
        case 2:
            return .trailing
        default:
            return .center
        }
    }
    
    // This function calculates the cumulative frame counts
    func calculateCumulativeFrameCounts() {
        cumulativeFrameCounts = [0] // Initialize with first row having zero delay
        var totalFrames = 0
        
        for row in rows {
            totalFrames += row.reduce(0) { $0 + $1.frameCount }
          
            cumulativeFrameCounts.append(totalFrames) // Keep adding cumulative counts
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
    var x: CGFloat = 0
}

// Just One row of text
struct MultiImageSequence: View {
    let randomBorderColors = [Color.red, Color.blue, Color.yellow]
    @State private var currentFrame = 0
    @State private var letterIndex = 0
    @State private var isTimerActive = false
    @State private var sss:CGFloat  =  0.005
    let letters: [Letter]
    let delay: Double
    let divideScale: CGFloat
    let margin: CGFloat// New margin property
    @Binding var speed:CGFloat
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
       
    
   // var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        //   Timer.publish(every: speed, on: .main, in: .common).autoconnect()
      // }// Move timer to @State
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< letters.count, id: \.self) { index in
                strokeView(for: index)
                    .offset(x: letters[index].x / divideScale)
            }
        }
        .padding(margin) // Apply the margin around the whole sequence
        .onDisappear {
           // print("onDisappear MultiImageSequence")
        }
        .onAppear {
            timer = Timer.publish(every: 0.005, on: .main, in: .common).autoconnect()
            isTimerActive = false
            letterIndex = 0
            currentFrame = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                isTimerActive = true
            }
        }
        .onChange(of: letters) { _, _ in
            
            isTimerActive = false
            letterIndex = 0
            currentFrame = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                isTimerActive = true
            }
        }
        .onChange(of: speed) { _ , newValue in
            sss = newValue
            timer = Timer.publish(every: speed, on: .main, in: .common).autoconnect()
            
        }
        .onReceive(timer ?? Timer.publish(every: speed, on: .main, in: .common).autoconnect()) { _ in
                    if isTimerActive {
                        updateFrame()
                    }
                }
       
    }


    private func strokeView(for index: Int) -> some View {
        ZStack {
            if index <= letterIndex {
                Image(getImageName(for: index))
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: letters[index].w / divideScale, height: letters[index].h / divideScale)
            }
        }
        .frame(width: letters[index].w / divideScale, height: (letters[index].h - 30) / divideScale)
        .padding(0)
    }

    func getImageName(for index: Int) -> String {
        let sequence = letters[index]
        let frameNumber = (index == letterIndex) ? currentFrame + 1 : sequence.frameCount - 1

        if frameNumber == 1 {
            return "___0001"
        }
       
        return String(format: "\(sequence.namePrefix)%04d", frameNumber)
    }

    func updateFrame() {
        guard !letters.isEmpty else { return }

        if letterIndex >= letters.count {
            letterIndex = letters.count - 1
        }

        let l = letters[letterIndex] // Safely access the letter

        currentFrame += 1

        if currentFrame >= l.frameCount - 1 {
            letterIndex += 1
            currentFrame = 0

            if letterIndex >= letters.count {
                isTimerActive = false // Stop the timer
            }
        }
    }
}

#Preview {
    VStack {
        MultiImageSequence(letters: [
            Letter(namePrefix: "iii", frameCount: 11, w: 67, h: 242),
            Letter(namePrefix: "jjj", frameCount: 16, w: 122, h: 242),
            Letter(namePrefix: "kkk", frameCount: 23, w: 111, h: 242),
            Letter(namePrefix: "lll", frameCount: 15, w: 89, h: 242),
        ], delay: 1, divideScale: 8, margin:10, speed:.constant(0.005))
        .frame(height: 242 / 8)

        MultiImageSequence(letters: [
            Letter(namePrefix: "mmm", frameCount: 20, w: 162, h: 242),
            Letter(namePrefix: "nnn", frameCount: 18, w: 117, h: 242),
            Letter(namePrefix: "yyy", frameCount: 14, w: 124, h: 242),
            Letter(namePrefix: "zzz", frameCount: 11, w: 101, h: 242),
        ], delay: 6, divideScale: 4, margin:10, speed:.constant(0.005))
        .frame(height: 242 / 4)
    }
}
