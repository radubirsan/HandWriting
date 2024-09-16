import SwiftUI
import Firebase
struct EditorView: View {
    @Binding private var stylo: Stylo
    @State private var isSaving: Bool = false
    @State private var replay: Bool = false
    @State private var isEditing: Bool = false
    @ObservedObject var videoModel: VideoModel  // <-- Change here
    @FocusState private var isFocused: Bool
    @State private var sequences: [[Letter]] = []
    @State var inputString: String = """
    Tap to edit




    x
    """
    @State private var progress: Double = 0.0
    @State private var savedVideoURL: URL? = nil
    @State private var lastCharacter: String = ""
    @State private var containerWidth2: CGFloat = 0
    @State var bgColor = Color.red
    @State var bgColor2 = Color.red
    @State private var saveTask: Task<Void, Never>? = nil
    @State private var fgColor = Color.blue
    @State private var textScale: CGFloat = 5
    @State private var animatePlane = false
    @State private var selectedTextSize: Int = 40
    @State private var selectedAlignment: Int = 1
    @State private var margin: CGFloat = 30
    @State private var textSpeed: CGFloat = 0.005
    @ObservedObject private var keyboard = KeyboardResponder()
    private let fixedSize: CGFloat = 365
   
   

    var characterLimit: Int {
        if selectedTextSize == 20 {
            return 100
        } else if selectedTextSize == 40 {
            return 50
        } else {
            return 30
        }
    }

    @State var typedCharacters: Int = 0
    @State private var images: [String] = ["letter_1", "letter_2", "letter_3", "letter_4", "letter_5", "letter_6", "letter_7", "letter_8"]
    @State private var videoQuality: VideoQuality = .sd
    @State private var tappedPhotoID: String = ""
    enum VideoQuality: String, CaseIterable, Identifiable {
        case sd = "SD"
        case hd = "HD"
        case _4k = "4K"
        case sd60 = "SD 60-fps"
        case hd60 = "HD 60-fps"
        case _4k60 = "4K 60-fps"
        
        var id: String { self.rawValue }
    }
    init(stylo: Binding<Stylo>, videoModel: VideoModel) {
        _stylo = stylo
        self.videoModel = videoModel  // <-- Initialize videoModel
        _bgColor = State(initialValue: stylo.wrappedValue.bColor)
        _fgColor = State(initialValue: stylo.wrappedValue.tColor)
        _inputString = State(initialValue: stylo.wrappedValue.text)
        _textScale = State(initialValue: stylo.wrappedValue.textSize)
        _selectedTextSize = State(initialValue: Int(stylo.wrappedValue.textSize))
        _typedCharacters = State(initialValue: Int(stylo.wrappedValue.text.count))
        _tappedPhotoID = State(initialValue: stylo.wrappedValue.bkImage)
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
                                                       if !tappedPhotoID.isEmpty {
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
                        .environment(\._lineHeightMultiple, 0.8)
                        .environment(\.sizeCategory, .medium)
                        .opacity(isFocused ? 1 : 0.1)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .textContentType(.init(rawValue: ""))
                        .autocorrectionDisabled(true)
                        .limitText($inputString, to: characterLimit)
                        .clipped()
                        .cornerRadius(19)
                        .shadow(radius: 10, y: 10.0)
                     
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                 Text("\(typedCharacters) / \(characterLimit)")
                    .padding()
                    .foregroundColor(Color.black)
                    .background(Color.gray)
                    .shadow(radius: 2)
                    .frame(height:75)
               
                if !isFocused || isSaving || replay {
                    VStack {
                        TextWriter(inputString: $inputString, rows: $sequences, textSize: $textScale, 
                                   align: $selectedAlignment, margin:$margin, textSpeed:$textSpeed)
                            .frame(width: fixedSize, height: fixedSize)
                            .foregroundColor(fgColor)
                            
                            .background(
                                   Group {
                                       if  !tappedPhotoID.isEmpty {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: 365)
            
            controlBar()
            .frame(width: UIScreen.main.bounds.width - 10, height: 86)
            .background(.gray).cornerRadius(20)
            .padding(.top , 20)
            HStack(spacing:7){
                ColorPicker("", selection: $bgColor2, supportsOpacity: false)
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    .labelsHidden()
                    .frame(width: 33)
                
                ColorPicker("", selection: $fgColor, supportsOpacity: false)
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    .labelsHidden()
                    .frame(width: 33)
            }
            if(!isEditing && !isFocused){
                createPhotoGallery()
            }
        }
        .padding(.top, 47)
        .ignoresSafeArea()
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
        .onChange(of: inputString) { _, _ in
            typedCharacters = inputString.count
            if(!isFocused || sequences.isEmpty) {
                sequences = Helper.parse(inputString.trimmingCharacters(in: .whitespaces))
            }
        }
        .onChange(of: bgColor2) { _, _ in
            tappedPhotoID = ""
            bgColor = bgColor2
        }
        .onChange(of: bgColor) { _, newValue in
            bgColor = newValue
            if(tappedPhotoID.isEmpty) {
                bgColor2 = bgColor
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
        .onChange(of: stylo.bkImage) { _, newValue in
            self.tappedPhotoID = newValue
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
        
        HStack(spacing: 8){
            if(isSaving) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width:210)
                    .padding()
            }
            else{
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
                    //Image(systemName: isFocused ? "" : "pencil")
                }
                .frame(width:73, height: 40 )
                .padding(7)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            ZStack {
                Image(systemName: selectedAlignment == 0 ? "text.alignleft" : selectedAlignment == 1 ? "text.aligncenter" : "text.alignright")
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
            
           
            
            ZStack {
                Image(systemName:  "textformat.size")
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                Picker(selection: $selectedTextSize, label: Text("")) {
                    
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
    
            
            ZStack {
                VStack(spacing:0) { Text(videoQuality  == .sd ? "SD": videoQuality  == .hd ? "HD" : "4K")
                        .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    if(textSpeed == 0.0025) {
                        Text("60fps")
                            .scaleEffect(CGSize(width: 0.7, height: 0.7))
                    }
                }
                Picker(selection: $videoQuality, label: Text("")) {
                    ForEach(VideoQuality.allCases) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
                .onChange(of: videoQuality) {  _ , newQuality in
                   
                    print("videoQUality" , videoQuality)
                            if(videoQuality == .sd60 || videoQuality == .hd60 || videoQuality == ._4k60) {
                                textSpeed = 0.0025
                            }
                            else{
                                textSpeed = 0.005
                            }
                            
                        
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
        }
                Button {
                    if(isSaving) {
                        saveTask?.cancel()
                        isSaving = false
                        animatePlane = false
                    }
                    else {
                        presentShareLink(for: videoQuality) // Pass the selected video quality
                    }
                    
                } label: {
                  //  HStack {
                        Text(isSaving ? "Cancel" : "Send").bold()
                       // Image(systemName: isSaving ? "timelapse" : "paperplane")
                  //  }
                    .frame(width:73, height: 40)
                    .padding(7)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(0)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, options: animatePlane ? .repeating : .nonRepeating , value: animatePlane)
                

            
            
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
    func presentShareLink(for quality: VideoQuality) {
        print("Selected quality:", quality)
        Analytics.logEvent(AnalyticsEventShare,  parameters: ["param_appShared" : "App Shared from\( EditorView.self)"])
        isSaving = true
        animatePlane = true
        sequences = Helper.parse(inputString.trimmingCharacters(in: .whitespaces))
        saveTask = Task {
            
            var size = CGSize(width: 719, height: 719)
            var fps:Int32 = 30
            if(quality == .hd) {
                fps = 30
                size = CGSize(width: 1080, height: 1080)
            }
            else if(quality == ._4k) {
                fps = 30
                size = CGSize(width: 2160, height: 2160)
            }
            else if (quality == .sd60) {
                fps = 60
                var size = CGSize(width: 719, height: 719)
            }
            else if(quality == .hd60 ) {
                fps = 60
                size = CGSize(width: 1080, height: 1080)
            }
            else if( quality == ._4k60) {
                fps = 60
                size = CGSize(width: 2160, height: 2160)
            }
          
            savedVideoURL = await videoModel.saveModifiedVideo(sequences, bgColor, fgColor,
                                                               returnAlign(selectedAlignment),
                                                               tappedPhotoID ?? "",
                                                               quality: size,
                                                               fps:fps,
                                                               progressHandler: { value in
                                                                                      DispatchQueue.main.async {
                                                                                          progress = value
                                                                                      }
                                                                                  }) // Pass quality here
            print("saveModifiedVideo", savedVideoURL ?? "no file")
            DispatchQueue.main.async {
                isSaving = false
                animatePlane = false
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


