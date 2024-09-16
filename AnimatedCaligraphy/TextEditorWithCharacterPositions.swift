import SwiftUI

struct TextEditorWithCharacterPositions: UIViewRepresentable {
    @Binding var text: String
    var textScale: CGFloat
    var onCharacterPositions: ([CGRect]) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.font = UIFont(name: "LeckerliOne-Regular", size: textScale) // Set the custom font
              textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        updateCharacterPositions(in: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Function to calculate and update the positions and sizes of each character in the text
    func updateCharacterPositions(in textView: UITextView) {
        var characterRects: [CGRect] = []
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let textStorage = textView.textStorage

        // Ensure the layout is up to date
        layoutManager.ensureLayout(for: textContainer)

        // Loop through each character in the string
        let range = NSRange(location: 0, length: textStorage.length)
        for i in 0..<range.length {
            let glyphRange = NSRange(location: i, length: 1)
            let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

            // Convert glyphRect from text container to text view coordinates
            let rectInView = glyphRect.offsetBy(dx: textView.textContainerInset.left, dy: textView.textContainerInset.top)
            characterRects.append(rectInView)
        }

        // Pass the character positions back via the callback
        onCharacterPositions(characterRects)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextEditorWithCharacterPositions

        init(_ parent: TextEditorWithCharacterPositions) {
            self.parent = parent
        }

        // This delegate method is called whenever the text is changed
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.updateCharacterPositions(in: textView)
        }
    }
}

struct ContentViewX: View {
    @State private var text = "Hello, world!"
    @State private var characterPositions: [CGRect] = []
    @State private var textScale:CGFloat = 20
    var body: some View {
        VStack {
            // Custom TextEditor that tracks character positions
            TextEditorWithCharacterPositions(text: $text, textScale:textScale) { positions in
                self.characterPositions = positions
            }
            
            .frame(height: 200)
            .border(Color.gray)

            // List the position and size of each character entered (for debugging purposes)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(characterPositions.indices, id: \.self) { index in
                        let rect = characterPositions[index]
                        Text("Character \(index + 1): Position (\(rect.origin.x), \(rect.origin.y)), Size: \(rect.size.width) x \(rect.size.height)")
                    }
                }
            }
        }
        .padding()
    }
}



#Preview
{
    ContentViewX()
}
