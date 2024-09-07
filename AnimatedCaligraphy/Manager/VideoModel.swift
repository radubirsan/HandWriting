import SwiftUI
import Bitmap
import AVFoundation

class VideoModel: ObservableObject {
    var videoManager: VideoManager = VideoManager()
    var photoManager: PhotoLibraryManager = PhotoLibraryManager()
    let defaultFrameDuration = 0.04
   
   
    func saveModifiedVideo(_ s:[[Letter]], 
                           _ bgColor: Color,
                           _ fgColor: Color,
                           _ alignment: TextAlignment,
                           _ bkgImage:String ) async -> URL? {
        print("Save alignment", bkgImage)
        guard let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Cannot access local file domain")
            
            return nil
        }

        let fileUrl = directoryPath.appendingPathComponent("modified").appendingPathExtension("mp4")
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try? FileManager.default.removeItem(at: fileUrl)
        }
       
        let bgUIColor = UIColor(bgColor)
        let fgUIColor = UIColor(fgColor)
        let bgcolor = bgUIColor.cgColor
        let fgcolor = fgUIColor.cgColor
        let success = await withCheckedContinuation { continuation in
        
            videoManager.createVideo(s, at: fileUrl, backgroundColor: bgcolor, foregroundColor: fgcolor ,
                                     videoSize: CGSize(width: 719, height: 719),
                                     alignment: alignment, bkgImage: bkgImage) { success in
                continuation.resume(returning: success)
            }
        }
        
        if success {
            print("Saving to photo library" ,fileUrl)
           // await photoManager.saveVideo(fileUrl)
            return fileUrl
        }
        else {
            print("Could not save the video! " ,fileUrl)
                    try? FileManager.default.removeItem(at: fileUrl)
                    return nil
                }
        
       
    }
}
