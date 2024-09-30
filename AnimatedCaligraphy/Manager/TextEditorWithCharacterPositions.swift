import SwiftUI

struct TextEditorWithCharacterPositions: UIViewRepresentable {
    @Binding var text: String
    var textScale: CGFloat
    var align: CGFloat
    var color: Color
    var refreshTrigger: Bool
    var onCharacterPositions: ([CGRect]) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.textColor = Color.convert(color)
        textView.isScrollEnabled = true
        textView.backgroundColor  = .clear
        textView.font = UIFont(name: "LeckerliOne-Regular", size: textScale) // Set the custom font
        textView.delegate = context.coordinator
       
        
        
        // Apply reduced line spacing
              let paragraphStyle = NSMutableParagraphStyle()
              paragraphStyle.lineSpacing = -11.0 // Negative values reduce spacing, positive values increase spacing

              let attributes: [NSAttributedString.Key: Any] = [
                  .paragraphStyle: paragraphStyle,
                  .foregroundColor:  Color.convert(color)
              ]

              textView.attributedText = NSAttributedString(string: text, attributes: attributes)
              
              return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont(name: "LeckerliOne-Regular", size: textScale)
        uiView.textAlignment  = align == 0 ? .left : align == 1 ? .center : .right
        
        uiView.textColor = Color.convert(color)
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


