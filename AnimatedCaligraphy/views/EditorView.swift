import SwiftUI

struct EditorView: View {
    @Binding private var stylo: Stylo
    @State private var isSaving: Bool = false
    @State private var isEditing: Bool = false
    @ObservedObject var videoModel: VideoModel  // <-- Change here
    @FocusState private var isFocused: Bool
    @State private var sequences: [[Letter]] = []
    @State var inputString: String = """
    Tap to edit




    x
    """
    
    @State private var savedVideoURL: URL? = nil
    @State private var lastCharacter: String = ""
    @State private var containerWidth2: CGFloat = 0
    @State var bgColor = Color.red
    @State private var fgColor = Color.blue
    @State private var textScale: CGFloat = 5
    @State private var animatePlane = false
    @State private var selectedTextSize: Int = 40
    @State private var selectedAlignment: Int = 1
    @State private var margin: CGFloat = 30
    @ObservedObject private var keyboard = KeyboardResponder()
    private let fixedSize: CGFloat = 365
    @State var characterLimit: Int = 900
    @State var typedCharacters: Int = 0
    @State private var images: [String] = ["letter_1", "letter_2", "letter_3", "letter_4", "letter_5", "letter_6", "letter_7"]
    
    @State private var tappedPhotoID: String? = nil

    init(stylo: Binding<Stylo>, videoModel: VideoModel) {
        _stylo = stylo
        self.videoModel = videoModel  // <-- Initialize videoModel
        _bgColor = State(initialValue: stylo.wrappedValue.bColor)
        _fgColor = State(initialValue: stylo.wrappedValue.tColor)
        _inputString = State(initialValue: stylo.wrappedValue.text)
        _textScale = State(initialValue: stylo.wrappedValue.textSize)
        _selectedTextSize = State(initialValue: Int(stylo.wrappedValue.textSize))
        _typedCharacters = State(initialValue: Int(stylo.wrappedValue.text.count))
       // print("INIT Stylo")
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom) {
                VStack {
                    TextEditor(text: $inputString)
                    
                        .safeAreaPadding(.horizontal, margin/2)
                        .safeAreaPadding(.vertical, margin/3)
                        .foregroundColor(fgColor)
                        .focused($isFocused)
                        .font(.custom("LeckerliOne-Regular", size: textScale))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: fixedSize, height: fixedSize)
                        .scrollContentBackground(.hidden)
                        .background(
                                                   Group {
                                                       if let tappedPhotoID = tappedPhotoID {
                                                           Image(tappedPhotoID)
                                                               .resizable()
                                                               .scaledToFill()
                                                               .clipped()
                                                       } else {
                                                           bgColor
                                                       }
                                                   }.shadow(radius: 10, y: 10.0)
                                               )
                        .multilineTextAlignment(returnAlign(selectedAlignment))
                        .environment(\.sizeCategory, .medium)
                        .opacity(isFocused ? 1 : 0.1)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .textContentType(.init(rawValue: ""))
                        .autocorrectionDisabled(true)
                        .limitText($inputString, to: characterLimit)
                        .onChange(of: inputString) { _, _ in
                            typedCharacters = inputString.count
                            if(!isFocused || sequences.isEmpty) {
                                sequences = Helper.parse(inputString.trimmingCharacters(in: .whitespaces))
                            }
                        }
                        .onChange(of: bgColor) { _, _ in
                            tappedPhotoID = nil
                        }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                 Text("\(typedCharacters) / \(characterLimit)")
                    .foregroundColor(Color.white).shadow(radius: 2).frame(height:75)
               
                if !isFocused || isSaving {
                    VStack {
                        TextWriter(inputString: $inputString, rows: $sequences, textSize: $textScale, 
                                   align: $selectedAlignment, margin:$margin)
                            .frame(width: fixedSize, height: fixedSize)
                            .foregroundColor(fgColor)
                            
                            .background(
                                                       Group {
                                                           if let tappedPhotoID = tappedPhotoID {
                                                               Image(tappedPhotoID)
                                                                   .resizable()
                                                                   .scaledToFill()
                                                                   .clipped()
                                                                   .cornerRadius(19)
                                                                   
                                                           } else {
                                                               bgColor.cornerRadius(19)
                                                           }
                                                               
                                                       }.shadow(radius: 10, y: 10.0)
                                                   )
                            .allowsHitTesting(false)
                    }
                   // .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                   // .border(.yellow)
                }
            }
            .frame(height: 365)
            
            controlBar()
          //  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - keyboard.currentHeight - 410)
            .frame(width: UIScreen.main.bounds.width - 10, height: 86)
            .background(.gray).cornerRadius(20)
            .padding(.top , 20)
            if(!isEditing && !isFocused){
                createPhotoGallery()
            }
        }
        .padding(.top, 47)
        .ignoresSafeArea()
        .onAppear() {
         //   isFocused = true
        }
        .onChange(of: selectedTextSize) { _, new in
            if new == 60 {
                Helper.size = 60
                textScale = 60
            }
            if new == 40 {
                Helper.size = 40
                textScale = 40
            }
            if new == 20 {
                Helper.size = 20
                textScale = 20
            }
           
            sequences = Helper.parse(inputString.trimmingCharacters(in: .whitespaces))
        }
        .onChange(of: isEditing) { newValue, _ in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 //   isFocused = true
                }
            }
        }
        .onChange(of: stylo.bColor) { _, newValue in
            bgColor = newValue
            
            textScale = stylo.textSize
            selectedTextSize = Int(textScale)
        }
        .onChange(of: stylo.tColor) { _, newValue in
            fgColor = newValue
        }
        .onChange(of: stylo.text) { _, newValue in
            self.inputString = newValue
            textScale = stylo.textSize
            selectedTextSize = Int(textScale)
        }
        .onChange(of: stylo.textSize) { _, newValue in
            textScale = newValue
            selectedTextSize = Int(textScale)
          
        }
    }
    
    @ViewBuilder
    func createPhotoGallery() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal, 5)
                        .onTapGesture {
                             handlePhotoTap(photoID: imageName)
                        }
                }
            }
        }.shadow(radius: 10, y: 10.0)
        //.background(Color.black.opacity(0.2))
    }
    
    @ViewBuilder
    func controlBar() -> some View {
        
        HStack(spacing: 5){
                Button {
                    if isFocused {
                              isFocused = false
                              isEditing = false
                          } else {
                              isFocused = true
                              isEditing = true
                          }
                } label: {
                   
                    HStack {
                        Text(isFocused ? "Done" : "Edit")
                        Image(systemName: isFocused ? "" : "pencil")
                    }
                    .frame(height: 40)
                    .padding(7)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                ZStack {
                    Image(systemName: "text.alignleft")
                        
                        .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    Picker(selection: $selectedAlignment, label: Text("")) {
                        Label("left", systemImage: "text.alignleft").tag(0)
                        Label("center", systemImage: "text.aligncenter").tag(1)
                        Label("right", systemImage: "text.alignright").tag(2)
                    }
                    .opacity(0.011)
                    .scaleEffect(CGSize(width: 2.3, height: 2.3))
                    .frame(width: 30)
                }
                .frame(height: 40)
                .padding(7)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)


                ColorPicker("", selection: $bgColor, supportsOpacity: false)
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    .labelsHidden()
                    .frame(width: 35)

                ColorPicker("", selection: $fgColor, supportsOpacity: false)
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    .labelsHidden()
                    .frame(width: 35)

                ZStack {
                    Image(systemName: "textformat.size")
                        .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    Picker(selection: $selectedTextSize, label: Text("")) {
                        ColorPicker("Back Color", selection: $bgColor, supportsOpacity: false)
                            .scaleEffect(CGSize(width: 1.3, height: 1.3))
                           // .labelsHidden()
                            .frame(width: 135)
                        Text("Large").tag(60)
                        Text("Medium").tag(40)
                        Text("Small").tag(20)
                    }
                    .opacity(0.011)
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    .frame(width: 33)
                }
                .frame(height: 40)
                .padding(7)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                
                Button {
                    presentShareLink()
                    animatePlane.toggle()
                } label: {
                    HStack {
                        Text("Send")
                        Image(systemName: isSaving ? "timelapse" : "paperplane")
                    }
                    .frame(height: 40)
                    .padding(7)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, options: .repeating, value: isSaving)
                .disabled(isSaving)
            }.padding(0)
            
       
    }
    
    // Function to handle the photo tap and return the ID
     func handlePhotoTap(photoID: String) {
         tappedPhotoID = photoID
         print("Tapped photo ID: \(photoID)")
     }
       
    func returnAlign(_ i:Int ) -> TextAlignment {
        if(i == 1) {
            return  .center
        }
        else if ( i == 2) {
            return  .trailing
        }
        else{
            return .leading
        }
    }
    func presentShareLink() {
        print("your logic here", bgColor)
        isSaving = true
        sequences = Helper.parse(inputString.trimmingCharacters(in: .whitespaces))
        Task {
            savedVideoURL = await videoModel.saveModifiedVideo(sequences, bgColor, fgColor, 
                                                               returnAlign(selectedAlignment),
                                                               tappedPhotoID ?? ""
                                                    )
            print(" saveModifiedVideo",  savedVideoURL ?? "no file")
            DispatchQueue.main.async {
                print("Saving done?" )
                
                isSaving = false
                
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
       
    }
    
    }


extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) { _ in
                text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
}



import SwiftUI
import UIKit

struct TextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var numberOfLines: Int
    
    var font: UIFont
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWrapper
        
        init(_ parent: TextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            
            // Calculate the number of lines
            let lineHeight = textView.font?.lineHeight ?? 0
            let contentHeight = textView.contentSize.height
            parent.numberOfLines = Int(contentHeight / lineHeight)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font
    }
}
