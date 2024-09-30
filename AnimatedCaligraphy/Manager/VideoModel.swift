import SwiftUI
import Bitmap
import AVFoundation

class VideoModel: ObservableObject {
    var videoManager: VideoManager = VideoManager()
    var photoManager: PhotoLibraryManager = PhotoLibraryManager()
    let defaultFrameDuration = 0.04
  
   
    func saveModifiedVideo(_ s: [Letter],
                           _ bgColor: Color,
                           _ fgColor: Color,
                           _ alignment: TextAlignment,
                           _ bkgImage: String,
                           quality: CGSize,
                           fps:Int32,
                           marginV:CGFloat,
                           marginH:CGFloat,
                           progressHandler: @escaping (Double) -> Void) async -> URL? {

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

        
        let success = await withTaskCancellationHandler {
                // Code to execute when the task is cancelled
                videoManager.cancel()  // Assuming videoManager has a cancel method
        } operation: {
            
            await withCheckedContinuation { continuation in
                videoManager.createVideo(s, at: fileUrl, backgroundColor: bgcolor, foregroundColor: fgcolor,
                                         videoSize: quality, fps:fps, alignment: alignment, bkgImage: bkgImage,
                                         marginV:marginV, marginH:marginH,
                                         completion: { success in
                    continuation.resume(returning: success)
                },
                                         progress: { progress in
                    // Update the progress handler with the current progress
                    progressHandler(progress)
                })
            }
        }

        if success {
            print("Saving to photo library", fileUrl)
            return fileUrl
        } else {
            print("Could not save the video!", fileUrl)
            try? FileManager.default.removeItem(at: fileUrl)
            return nil
        }
    }

}
