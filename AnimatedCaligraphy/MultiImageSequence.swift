// Just One row of text
import SwiftUI
import Combine

struct MultiImageSequence: View {
    let randomBorderColors = [Color.red, Color.blue, Color.yellow]
    @State private var currentFrame = 0
    @State private var letterIndex = 0
    @State private var isTimerActive = false
    @State private var sss:CGFloat  =  0.005
    let letters: [Letter]
    let delay: Double
    let divideScale: CGFloat
    let marginV: CGFloat// New margin property
    let marginH: CGFloat//
    @Binding var speed:CGFloat
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
       
    var body: some View {
        ZStack(alignment:.topLeading) {
            ForEach(0 ..< letters.count, id: \.self) { index in
                strokeView(for: index)
                    .offset(x: letters[index].x ,y: letters[index].y)
                    .alignmentGuide(.top) { _ in 0 } // Align it to the top
                    .alignmentGuide(.leading) { _ in 0 } // Align it to the leading edge
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            timer = Timer.publish(every: speed, on: .main, in: .common).autoconnect()
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
                print("Line x",letters.count,  delay)
            }
        }
        .onChange(of: speed) { _ , newValue in
            speed = newValue
            timer = Timer.publish(every: speed, on: .main, in: .common).autoconnect()
            print("Speed", speed)
            
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
