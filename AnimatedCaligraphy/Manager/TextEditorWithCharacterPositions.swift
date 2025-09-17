import SwiftUI

struct TextEditorWithCharacterPositions: UIViewRepresentable {
    @Binding var text: String
    var textScale: CGFloat
    var align: CGFloat
    var color: Color
    var refreshTrigger: Bool
    var onCharacterPositions: ([CGRect]) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.isEditable = true
        textView.textColor = Color.convert(color)
        textView.isScrollEnabled = true
        textView.backgroundColor  = .clear
        textView.font = UIFont(name: "LeckerliOne-Regular", size: textScale) // Set the custom font
        textView.delegate = context.coordinator
       
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.autocapitalizationType = .none
        
        // Set initial alignment to preload layout calculations
        textView.textAlignment = align == 0 ? .left : align == 1 ? .center : .right
        
        // Apply reduced line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = -11.0 // Negative values reduce spacing, positive values increase spacing
        paragraphStyle.alignment = textView.textAlignment // Set alignment in paragraph style too

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor:  Color.convert(color),
            .font: UIFont(name: "LeckerliOne-Regular", size: textScale) ?? UIFont.systemFont(ofSize: textScale)
        ]

        textView.attributedText = NSAttributedString(string: text, attributes: attributes)
        
        // Force initial layout to preload calculations
        textView.layoutIfNeeded()
        textView.layoutManager.ensureLayout(for: textView.textContainer)
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let shouldUpdateFont = uiView.font?.pointSize != textScale
        let shouldUpdateAlignment = uiView.textAlignment != (align == 0 ? .left : align == 1 ? .center : .right)
        let shouldUpdateText = uiView.text != text
        let shouldUpdateColor = uiView.textColor != Color.convert(color)
        
        if shouldUpdateText {
            uiView.text = text
        }
        
        if shouldUpdateFont {
            uiView.font = UIFont(name: "LeckerliOne-Regular", size: textScale)
        }
        
        if shouldUpdateAlignment {
            let newAlignment:NSTextAlignment = align == 0 ? .left : align == 1 ? .center : .right
            uiView.textAlignment = newAlignment
            
            // Update the paragraph style to maintain consistency
            if let attributedText = uiView.attributedText?.mutableCopy() as? NSMutableAttributedString {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = -11.0
                paragraphStyle.alignment = newAlignment
                
                let range = NSRange(location: 0, length: attributedText.length)
                attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
                uiView.attributedText = attributedText
            }
        }
        
        if shouldUpdateColor {
            uiView.textColor = Color.convert(color)
        }
        
        // Only update character positions if something actually changed or if explicitly triggered
        if shouldUpdateText || shouldUpdateFont || shouldUpdateAlignment || refreshTrigger {
            // Use a small delay to ensure layout is complete
            DispatchQueue.main.async {
                self.updateCharacterPositions(in: uiView)
            }
        }
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
            // Only update if text actually changed
            if parent.text != textView.text {
                parent.text = textView.text
                // Small delay to ensure layout is complete after text change
                DispatchQueue.main.async {
                    self.parent.updateCharacterPositions(in: textView)
                }
            }
        }
    }
}


