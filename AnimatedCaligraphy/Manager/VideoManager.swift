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
    var frameRate: Int32 = 0
    
  
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
    
    func createVideo(_ letter: [Letter], at fileUrl: URL,
                        backgroundColor: CGColor,
                        foregroundColor: CGColor,
                        videoSize: CGSize,
                        fps:Int32,
                        alignment: TextAlignment,
                        bkgImage:String,
                        marginV:CGFloat,
                        marginH:CGFloat,
                        completion: ((Bool) -> Void)?,
                        progress: ((Double) -> Void)?) {

            var letters = letter
            let width = Int(videoSize.width)
            let height = Int(videoSize.height)
           self.resetBitmap(width, height, backgroundColor: backgroundColor, bkgImage:bkgImage)
           self.frameRate = fps
        let qualityScale = CGFloat(height) / 2000.0
        var charScale = qualityScale * Helper.size / 40
      
            let marginV = marginV/365 * videoSize.height  // + (242 + 100) * charScale
            let marginH = marginH/365 * videoSize.width
       print("Margin Horizontal", marginH)
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
          let totalFrames = letters.flatMap { $0 }.reduce(0) { $0 + $1.frameCount }

           assetWriterInput.requestMediaDataWhenReady(on: writerQueue) {
              print("RequestMediaDataWhenReady to write video")
              

               self.resetBitmap(width, height, backgroundColor: backgroundColor, bkgImage:bkgImage)
                           var frameCount = 0
                           var strokeNr = 0
                         

               while !letters.isEmpty && self.frameRate != 0{
                               if assetWriterInput.isReadyForMoreMediaData == false {
                                   print("more buffers need to be written.")
                                   Thread.sleep(forTimeInterval: 0.1)
                                   continue
//  Initial code used break, moved to continue to try and fix a occasionally bug where video generation goes wrong some of the time
//                                   break
                               }
                               var presentationTime:CMTime
                                   presentationTime = CMTimeMake(value: Int64(frameCount), timescale: self.frameRate)
                               var point = CGPoint(x: Int(marginH +  letters.first!.x / 365 * CGFloat(width)),
                                                   y: Int( videoSize.height - (242 * charScale)  -  marginV - ( letters.first!.y / 365 * videoSize.height )))
                  // print("Letter position",letters.first!.namePrefix, letters.first!.x ,letters.first!.y)
                               strokeNr += 1
                               let img = String(format: "\(letters.first!.namePrefix)%04d", strokeNr)
                               let uiImage = UIImage(named: img)
                             
                               if let ui = uiImage {
                                   let pinkTint = UIColor(cgColor: foregroundColor)
                                 
                                   var tintedImage = self.tintedImage(ui, with: pinkTint)
                                   let hhh = Int(tintedImage!.size.height * charScale)
                                   let www = Int(tintedImage!.size.width * charScale)
                                   tintedImage = tintedImage!.resize(www, hhh)
                                   //point.y = point.y - hhh
                                   self.bitmap!.drawImage(tintedImage!.cgImage!, atPoint: point)
                               } else {
                                   print("cannot find", img)
                               }
                                    let pixelBuffer = self.bitmap!.ciImage!.cgImage!.cvPixelBuffer!
                                    let success = self.tryAppendingBuffer(pixelBuffer, at: presentationTime, using: pixelBufferAdaptor)
                                   
                                   if !success {
                                       print("Failed to append pixel buffer at frame \(frameCount), presentation time: \(presentationTime.seconds)")
                                       completion?(false)
                                       return
                                   }
                              let currentProgress = Double(frameCount) / Double(totalFrames)
                              DispatchQueue.main.async {
                                  progress?(currentProgress) // Send progress to the caller
                              }

                               if strokeNr >= letters.first!.frameCount - 1 {
                                   letters.removeFirst()
                                   strokeNr = 0
                               }

                            

                               frameCount += 1
                           }
               
               self.finishWriting(letters: letters, assetWriterInput: assetWriterInput, assetWriter: assetWriter, completion: completion)
           }
         
       }
    
    private func finishWriting(letters: [Letter], assetWriterInput: AVAssetWriterInput, assetWriter: AVAssetWriter, completion: ((Bool) -> Void)?) {
           if letters.isEmpty {
               assetWriterInput.markAsFinished()
               assetWriter.finishWriting {
                   print("writing finished")
                   DispatchQueue.main.async {
                       completion?(true)
                   }
               }
           } else {
               print("HEHEH CANCEL")
               assetWriterInput.markAsFinished()
           }
       }

    
    // Helper function to retry pixel buffer append operation
    func tryAppendingBuffer(_ pixelBuffer: CVPixelBuffer,
                            at presentationTime: CMTime,
                            using pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor) -> Bool {
        for attempt in 0..<3 {
            if pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                return true
            } else {
                print("Retrying append operation (attempt \(attempt + 1))...")
                Thread.sleep(forTimeInterval: attempt == 2 ? 5 : 0.1) // Adjust delay
            }
        }
        return false
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
                      _ frames:[Letter],
                      _ frameDuration:CMTime,
                      _ pixelBufferAdaptor:AVAssetWriterInputPixelBufferAdaptor) {
        print(assetWriterInput, frameDuration)
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
