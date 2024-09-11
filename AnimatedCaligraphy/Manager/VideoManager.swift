//
//  VideoManager.swift
//  SwiftUIDemo3
//
//  Created by Itsuki on 2024/08/06.
//

import SwiftUI
import AVFoundation
import Bitmap
class VideoManager {
    
    // MARK: For reading video
    private var videoAsset: AVAsset?
    private var videoTrack: AVAssetTrack?
    private var assetReader: AVAssetReader?
    private var videoAssetReaderOutput: AVAssetReaderTrackOutput?
    private var fullPicture:CGImage?
    private var bitmap:Bitmap?
    // MARK: For writing video
    private let writerQueue = DispatchQueue(label: "mediaInputQueue")

    
    // MARK: video properties
    // frames per second
    var frameRate: Float32 = 0
    
  
    var cmMinFrameDuration: CMTime?
    
    // Provides access to an array of AVMetadataItems for all metadata identifiers for which a value is available
    var metadata: [AVMetadataItem]?
    
    // transform specified in the track's storage container as the preferred transformation of the visual media data for display purposes: Value returned is often but not always `.identity`
    var affineTransform: CGAffineTransform!
    
    var duration: Float64?
    
    
    func cancel() {
        print("Cancel !!!!" )
        frameRate  = 0
    }
    
    func createVideo(_ rows: [[Letter]], at fileUrl: URL,
                        backgroundColor: CGColor,
                        foregroundColor: CGColor,
                        videoSize: CGSize,
                        alignment: TextAlignment,
                        bkgImage:String,
                        completion: ((Bool) -> Void)?,
                        progress: ((Double) -> Void)?) {

           var frames = rows
            let width = Int(videoSize.width)
            let height = Int(videoSize.height)
            self.resetBitmap(width, height, backgroundColor: backgroundColor, bkgImage:bkgImage)
           print("createVideo ============", bkgImage, frames.count)
           self.frameRate = 120
          
        var scaleFactor = CGFloat(height) / 2000.0
        scaleFactor = scaleFactor * Helper.size / 40
        
       
           let avOutputSettings: [String: Any] = [
               AVVideoCodecKey: AVVideoCodecType.h264,
               AVVideoWidthKey: NSNumber(value: Float(width)),
               AVVideoHeightKey: NSNumber(value: Float(height))
           ]

           guard let assetWriter = try? AVAssetWriter(outputURL: fileUrl, fileType: AVFileType.mp4) else {
               print("AVAssetWriter creation failed")
               completion?(false)
               return
           }

           guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
               print("Cannot apply output setting.")
               completion?(false)
               return
           }

           let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)

           guard assetWriter.canAdd(assetWriterInput) else {
               print("cannot add writer input")
               completion?(false)
               return
           }
           assetWriter.add(assetWriterInput)

           let sourcePixelBufferAttributesDictionary = [
               kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
               kCVPixelBufferWidthKey as String: NSNumber(value: Float(width)),
               kCVPixelBufferHeightKey as String: NSNumber(value: Float(height))
           ]
           let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
               assetWriterInput: assetWriterInput,
               sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary
           )

           Thread.sleep(forTimeInterval: 0.2)

           guard assetWriter.startWriting() else {
               print("cannot starting writing with error: \(assetWriter.error?.localizedDescription ?? "Unknown error")")
               completion?(false)
               return
           }

           assetWriter.startSession(atSourceTime: CMTime.zero)
        // Track total frame count to calculate progress
          let totalFrames = frames.flatMap { $0 }.reduce(0) { $0 + $1.frameCount }

           assetWriterInput.requestMediaDataWhenReady(on: writerQueue) {
              
                           var frameCount = 0
                           var letterNr = 0
                           var strokeNr = 0
                           var rowX: CGFloat
                           var rowY = (242 + 100) * scaleFactor

                           if alignment == .center {
                               rowX = (CGFloat(width) - self.alignX(frames.first) * scaleFactor) / 2
                           } else if alignment == .trailing {
                               rowX = (CGFloat(width) - self.alignX(frames.first) * scaleFactor) / 2}
                           else {
                               rowX =  30
                           }

               while !frames.isEmpty && self.frameRate != 0{
                               if assetWriterInput.isReadyForMoreMediaData == false {
                                   print("more buffers need to be written.")
                                   Thread.sleep(forTimeInterval: 0.1)
                                   continue
//  Initial code used break, moved to continue to try and fix a occasionally bug where video generation goes wrong some of the time
//                                   break
                               }
                       
                          //  let presentationTime = CMTimeMultiply(CMTimeMake(value: 1, timescale: 30), multiplier: Int32(frameCount))
                               var presentationTime:CMTime
                                    presentationTime = CMTimeMake(value: Int64(frameCount), timescale: 102) // at 120 fps playback has slow motion marked witch makes the beginning of the video run at double the speed
                                  
                               let point = CGPoint(x: Int(rowX + (frames.first![letterNr].x * scaleFactor)), y: height - Int(rowY))
                               strokeNr += 1
                               let img = String(format: "\(frames.first![letterNr].namePrefix)%04d", strokeNr)
                               let uiImage = UIImage(named: img)
                               if self.bitmap == nil {
                                   self.resetBitmap(width, height, backgroundColor: backgroundColor, bkgImage:bkgImage)
                               }
                               if let ui = uiImage {
                                   let pinkTint = UIColor(cgColor: foregroundColor)
                                   var tintedImage = self.tintedImage(ui, with: pinkTint)
                                   tintedImage = tintedImage!.resize(Int(tintedImage!.size.width * scaleFactor), Int(tintedImage!.size.height * scaleFactor))
                                   self.bitmap!.drawImage(tintedImage!.cgImage!, atPoint: point)
                               } else {
                                   print("cannot find", img)
                               }

                               // Retry mechanism to handle append failures
                               var success = false
                               for attempt in 0..<3 { // Try up to 3 times
                                   
                                   //print(9999, self.bitmap!.ciImage!.cgImage!.cvPixelBuffer!)
                                   if pixelBufferAdaptor.append(self.bitmap!.ciImage!.cgImage!.cvPixelBuffer!, 
                                                                                  withPresentationTime: presentationTime) {
                                       let currentTime = Date()
                                       print("Frame \(img) appended at \(Calendar.current.component(.second, from: currentTime)), presentation time: \(presentationTime.seconds)")    //  let currentTime = Date()
                                     //  print("Frame \(img) appended at \(Calendar.current.component(.second, from: currentTime)), presentation time: \(presentationTime.seconds)")
                                       success = true
                                       break
                                   } else {
                                       print("Retrying append operation (attempt \(attempt + 1))...")
                                       Thread.sleep(forTimeInterval:  attempt  == 2 ? 5 : 0.1) // Small delay before retrying
                                   }
                               }

                               if !success {
                                   print("Failed to append pixel buffer at frame \(frameCount), presentation time: \(presentationTime.seconds)")
                                   completion?(false)
                                   return
                               }
                               
                               // Update progress
                                          let currentProgress = Double(frameCount) / Double(totalFrames)
                                          DispatchQueue.main.async {
                                              progress?(currentProgress) // Send progress to the caller
                                          }

                               if strokeNr >= frames.first![letterNr].frameCount - 1 {
                                   rowX += (frames.first![letterNr].w - 10) * scaleFactor
                                   letterNr += 1
                                   strokeNr = 0
                               }

                               if letterNr >= frames.first!.count {
                                   letterNr = 0
                                   strokeNr = 0
                                   frames.removeFirst()

                                   if alignment == .center {
                                       rowX = (CGFloat(width) - self.alignX(frames.first) * scaleFactor) / 2
                                   } else if alignment == .trailing {
                                       rowX = (CGFloat(width) - self.alignX(frames.first) * scaleFactor)
                                   }
                                   else {
                                       rowX = 30
                                   }

                                   rowY += 242 * scaleFactor
                               }

                               frameCount += 1
                           }

                           if frames.isEmpty {
                               assetWriterInput.markAsFinished()
                               assetWriter.finishWriting {
                                   print("writing finished")
                                   DispatchQueue.main.async {
                                       completion?(true)
                                       return
                                   }
                               }
                           }
               else{
                   print("HEHEH CANCEL", letterNr)
                   assetWriterInput.markAsFinished()
//                   DispatchQueue.main.async {
//                       completion?(false)
//                       return
//                   }
                     return
                   
               }
           }
           self.resetBitmap(width, height, backgroundColor: backgroundColor, bkgImage: bkgImage)
           print("end")
       }
    
    func tintedImage(_ image: UIImage, with color: UIColor) -> UIImage? {
        // Start a graphics context of the same size as the image
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        // Get the context
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = image.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        let rect = CGRect(origin: .zero, size: image.size)
        
        // Flip the context vertically because UIKit coordinate system is flipped
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -image.size.height)
        
        // Draw the original image
        context.draw(cgImage, in: rect)
        
        // Set the blend mode to source-in, which preserves the transparency
        context.setBlendMode(.sourceIn)
        
        // Set the tint color
        context.setFillColor(color.cgColor)
        
        // Fill the image with the tint color
        context.fill(rect)
        
        // Get the new tinted image
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
    
    func doWhileLoop( _ assetWriterInput:AVAssetWriterInput, 
                      _ frames:[[Letter]],
                      _ frameDuration:CMTime,
                      _ pixelBufferAdaptor:AVAssetWriterInputPixelBufferAdaptor) {
        print(assetWriterInput, frameDuration)
    }
    func alignX(_ s:[Letter]?) -> CGFloat {
        
        if let firstInnerArray = s {
            let sumOfW = firstInnerArray.reduce(0) { sum, imageSequence in
                return sum + imageSequence.w - 10
            }
            return sumOfW
        } else {
            return 0
            print("The outer array is empty.")
        }
    }
    
    func resetBitmap(_ w: Int, _ h: Int, backgroundColor: CGColor, bkgImage:String) {
        do {
            let s = CGSize(width: w, height: h)
            self.bitmap = try Bitmap(size: s, backgroundColor: backgroundColor)
            if(!bkgImage.isEmpty){
                print("We have a background")
                let uiImage = UIImage(named: bkgImage)
                self.bitmap!.drawImage(uiImage!.cgImage!, in: CGRect(x: 0, y: 0, width: s.width, height: s.height))
            }
        } catch {
            print("Error creating Bitmap")
        }
    }
    
    
    
    func createPixelBufferFromBitmap(bitmap: Bitmap) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?

        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let width = Int(bitmap.size.width)
        let height = Int(bitmap.size.height)
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            print("Failed to create pixel buffer")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        
        if let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) {
            // Copy pixel data directly
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let context = CGContext(data: baseAddress,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

            context?.draw(bitmap.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        
        return pixelBuffer
    }
    
}
