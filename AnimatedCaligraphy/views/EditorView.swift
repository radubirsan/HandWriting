import SwiftUI
import Firebase


struct EditorView: View {
    @Bindable var editSTL: EditStylo
    @State private var isSaving: Bool = false
    @State private var replay: Bool = false
    @State private var isEditing: Bool = false
    @ObservedObject var videoModel: VideoModel  // <-- Change here
    @FocusState private var isFocused: Bool
    @State private var sequences: [Letter] = []
    @State private var progress: Double = 0.0
    @State private var savedVideoURL: URL? = nil
    @State private var lastCharacter: String = ""
    @State private var containerWidth2: CGFloat = 0
    @State var bgColor = Color.red
    @State var bgColor2 = Color.red
    @State private var saveTask: Task<Void, Never>? = nil
    @State private var fgColor:Color = Color.blue
    @State private var animatePlane = false
    @State private var selectedTextSize: Int = 40
    @State private var selectedAlignment: Int = 1
//    @State private var marginV: CGFloat = 90
//    @State private var marginH: CGFloat = 90
    @State private var textSpeed: CGFloat = 0.0025
    @State private var refreshTrigger: Bool = false
    @ObservedObject private var keyboard = KeyboardResponder()
    private let fixedSize: CGFloat = 365

    var characterLimit: Int {
        if selectedTextSize == 20 {
            return 1000
        } else if selectedTextSize == 40 {
            return 500
        } else {
            return 30
        }
    }

    @State var typedCharacters: Int = 0
    @State private var videoQuality: VideoQuality = .sd60
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

    
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom) {
                VStack {
                    if(!isSaving){
                        textEditorView
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                 Text("\(typedCharacters) / \(characterLimit)")
                    .padding()
                    .foregroundColor(Color.black)
                    .background(Color.gray)
                    .shadow(radius: 2)
                    .frame(height:75)
               
                if !isFocused || isSaving || replay {
                    Writter//.opacity(0.5)
                }
            }
            .frame(height: 365)
            controlBar()
            .frame(width: UIScreen.main.bounds.width - 10, height: 86)
            .background(.gray).cornerRadius(20)
            .padding(.top , 20)
            HStack(spacing:7){
                ColorPicker("Background", selection: $bgColor2, supportsOpacity: false)
                    //.scaleEffect(CGSize(width: 1.1, height: 1.1))
                    .frame(maxWidth: 145)
                    .padding()
                ColorPicker("Text", selection: $fgColor, supportsOpacity: false)
                    //.scaleEffect(CGSize(width: 1.1, height: 1.1))
                    //.labelsHidden()
                    .frame(maxWidth: 130)
            }
            if(!isEditing && !isFocused){
                createPhotoGallery()
            }
        }
        .padding(.top, 47)
        .ignoresSafeArea()
      
        .onChange(of: fgColor) {
            _, new in
            print("FGColor", new)
            editSTL.tColor = new
        }
        .onChange(of: editSTL.id) {
            print("STYLO EDIT", editSTL.id ,editSTL.marginV)
            selectedTextSize = Int(editSTL.textSize)
            selectedAlignment = Int(editSTL.align)
            fgColor = editSTL.tColor
//            marginV = editSTL.marginV
//            marginH = editSTL.marginH
            
        }
        .onChange(of: selectedTextSize) { _, new in
            if new == 60 {
                Helper.size = 60
                editSTL.textSize = 60
            }
            if new == 40 {
                Helper.size = 40
                editSTL.textSize = 40
            }
            if new == 20 {
                Helper.size = 20
                editSTL.textSize = 20
            }
        }
        .onChange(of: selectedAlignment ) { _, newValue in
            editSTL.align = CGFloat(newValue)
        }
        .onChange(of: bgColor2) { _, _ in
            editSTL.bkImage = ""
        }
        .onChange(of: videoQuality) {  _ , newQuality in
                print("videoQUality" , videoQuality)
                        if(newQuality == .sd60 || newQuality == .hd60 || newQuality == ._4k60) {
                            textSpeed = 0.0025
                            
                        }
                        else{
                            textSpeed = 0.005
                        }
            }
    }
    
    
    private func processCharacterPositions(_ positions: [CGRect]) -> [Letter] {
        var letters: [Letter] = []
       
        for i in 0..<positions.count {
            guard i < editSTL.text.count else { continue }
            
            let stringIndex = editSTL.text.index(editSTL.text.startIndex, offsetBy: i)
            guard stringIndex < editSTL.text.endIndex else { continue }

            let character = String(editSTL.text[stringIndex])
            
            if positions[i].origin.y + positions[i].size.height >= fixedSize {
                break
            }

            
            let namePrefix = character
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "!", with: "exclamation")
                .replacingOccurrences(of: "?", with: "question")
                .replacingOccurrences(of: ",", with: "comma")
                .replacingOccurrences(of: ".", with: "dot")
                .replacingOccurrences(of: "#", with: "hashtag")
                .replacingOccurrences(of: "@", with: "at")
                .replacingOccurrences(of: ":", with: "doubledot")
                .replacingOccurrences(of: "-", with: "line")

            let count = namePrefix == namePrefix.lowercased() ? 3 : 2
            let expandedPrefix = String(repeating: namePrefix, count: count)

            if var matchingLetter = Helper.letters.first(where: { $0.namePrefix == expandedPrefix }) {
                matchingLetter.x = positions[i].origin.x
                matchingLetter.y = positions[i].origin.y
                letters.append(matchingLetter)
            } else {
                var defaultLetter = Helper.letters.first!
                defaultLetter.x = positions[i].origin.x
                defaultLetter.y = positions[i].origin.y
                letters.append(defaultLetter)
                print("No Match Found For: \(namePrefix):" + expandedPrefix)
            }

        }

        return letters
    }
    
    @ViewBuilder
    func createPhotoGallery() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Helper.BKimages, id: \.self) { imageName in
                    Image(imageName.imageName)
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
        
        HStack(spacing: 6){
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
                .frame(width: 30)
               
            }
            .frame(height: 40)
            .padding(7)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    
            
            ZStack {
                VStack(spacing:0) {
                    if(textSpeed == 0.0025) {
                        Text(videoQuality  == .sd60 ? "SD": videoQuality  == .hd60 ? "HD" : "4K")
                            .scaleEffect(CGSize(width: 1.3, height: 1.3)).frame(width:47)
                        Image(systemName: "goforward.60")
                            .scaleEffect(CGSize(width: 0.7, height: 0.7)).frame(width:47)
                    }
                    else{
                        Text(videoQuality == .sd ? "SD" : videoQuality == .hd ? "HD" : "4K")
                            .scaleEffect(CGSize(width: 1.3, height: 1.3)).frame(width:47)
                    }
                }
                        Picker(selection: $videoQuality, label: Text("")) {
                            ForEach(VideoQuality.allCases) { quality in
                                Text(quality.rawValue).tag(quality)
                            }
                        }
                    .opacity(0.011)
                    .scaleEffect(CGSize(width: 1.3, height: 1.3))
                    .frame(width: 30)
                    
                }
               
                .frame(height: 40)
                .padding(7)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
            Spacer().frame(width:3)
            Divider()
            Spacer().frame(width:3)
                Button {
                    if(isSaving) {
                        saveTask?.cancel()
                        isSaving = false
                        animatePlane = false
                    }
                    else {
                        presentShareLink(for: videoQuality, editSTL.marginV, editSTL.marginH) // Pass the selected video quality
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
                .padding(7)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, options: animatePlane ? .repeating : .nonRepeating , value: animatePlane)
   
            }.padding(0)
            
       
    }
    
    private var textEditorView: some View {
           TextEditorWithCharacterPositions(text: $editSTL.text, textScale: editSTL.textSize,
                                         align: editSTL.align, color: editSTL.tColor, refreshTrigger: refreshTrigger) { positions in
            DispatchQueue.main.async {
                typedCharacters = editSTL.text.count
                sequences = processCharacterPositions(positions)
                print("PPPosition recalculateding")
            }
        }
                                         .border(.blue)
                                         .safeAreaPadding(.horizontal, editSTL.marginH)
                                         .safeAreaPadding(.vertical, editSTL.marginV)
                                         .foregroundColor(editSTL.tColor)
                                         .focused($isFocused)
                                         .textFieldStyle(RoundedBorderTextFieldStyle())
                                         .frame(width: fixedSize, height: fixedSize)
                                         .scrollContentBackground(.hidden)
                                         .background(
                                                        Group {
                                                            if !editSTL.bkImage.isEmpty {
                                                                Image(editSTL.bkImage)
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .clipped()
                                                            } else {
                                                                editSTL.bColor
                                                            }
                                                        }.shadow(radius: 10, y: 10.0)
                                                    )
                                         .multilineTextAlignment(returnAlign(selectedAlignment))
                                         .environment(\._lineHeightMultiple, 0.8)
                                         .environment(\.sizeCategory, .medium)
                                         .autocapitalization(.none)
                                         .textInputAutocapitalization(.never)
                                         .keyboardType(.asciiCapable)
                                         .textContentType(.init(rawValue: ""))
                                         .autocorrectionDisabled(true)
                                        // .limitText(editSTL.text, to: characterLimit)
                                         .clipped()
                                         .cornerRadius(19)
                                         .shadow(radius: 10, y: 10.0)
                                      
    }
    
    private var Writter: some View {
        VStack {
            TextWriter( letters: $sequences, textSize: $editSTL.textSize,
                        align: editSTL.align, marginV:editSTL.marginV, marginH:editSTL.marginH,
                        textSpeed:$textSpeed)
                .frame(width: fixedSize , height: fixedSize )
                .foregroundColor(editSTL.tColor)
                .background(
                       Group {
                           if  !editSTL.bkImage.isEmpty {
                               Image(editSTL.bkImage)
                                   .resizable()
                                   .scaledToFill()
                                   .clipped()
                                   .cornerRadius(19)
                                   
                           } else {
                               editSTL.bColor.cornerRadius(19)
                           }
                               
                       }.shadow(radius: 10, y: 10.0)
                                       )
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Function to handle the photo tap and return the ID
     func handlePhotoTap(photoID: LetterImage) {
         editSTL.marginV = photoID.verticalPadding
         editSTL.marginH = photoID.horizontalPadding
         editSTL.bkImage = photoID.imageName
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             sequences = [Helper.letters[0]]}
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             refreshTrigger.toggle() }
       
        
        // isFocused = true
        // isEditing = true
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
    func presentShareLink(for quality: VideoQuality, _ marginV:CGFloat, _ marginH:CGFloat) {
        print("Selected quality:", quality)
        Analytics.logEvent(AnalyticsEventShare,  parameters: ["param_appShared" : "App Shared from\( EditorView.self)"])
        isSaving = true
        animatePlane = true
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
            print("Render", sequences.count, " rows")
            savedVideoURL = await videoModel.saveModifiedVideo(sequences, editSTL.bColor, editSTL.tColor,
                                                               returnAlign(selectedAlignment),
                                                               editSTL.bkImage,
                                                               quality: size,
                                                               fps:fps,
                                                               marginV:marginV,
                                                               marginH:editSTL.marginH,
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

