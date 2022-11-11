import AVFoundation

@objc(VideoManager)
class VideoManager: NSObject {
    @objc(getVideoInfo:withResolver:withRejecter:)
    func getVideoInfo(source: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock){
        let fileURL = getSourceURL(source: source)
        
        var videoInfo: [String: Any] = [:]
        
        if FileManager.default.fileExists(atPath: fileURL.path){
            let videoAsset = AVAsset(url: fileURL)
            let duration = videoAsset.duration.seconds * 1000
            
            videoInfo["duration"] = duration
            
            resolve(videoInfo)
        }else{
            reject("Error in get file", "File does not exists", nil)
        }
    }
    
    @objc(compress:options:withResolver:withRejecter:)
    func compress(source: String, options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        
        let fileURL = getSourceURL(source: source)
        
        guard let data = try? Data(contentsOf: fileURL) else {
                    return
        }
        let originalFileSize = data.getSizeInKb()
        
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        
        compressVideo(inputURL: fileURL, outputURL: compressedURL) {
            exportSession in
            
            guard let session = exportSession else {
                reject("failed_compress_video", "Failed in compress video", nil)
                return
            }

            switch session.status {
            case .unknown:
                reject("faild_compress_video", "Failed in compress video", nil)
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = try? Data(contentsOf: compressedURL) else {
                    return
                }
                let filePath = exportSession?.outputURL?.absoluteString
                let fileSize = compressedData.getSizeInKb()
                
                let response = [
                    "filePath": filePath as Any,
                    "fileSize": fileSize,
                    "originalFileSize": originalFileSize
                ] as [String : Any]
                
                resolve(response)
            case .failed:
                reject("faild_compress_video", "Failed in compress video", nil)
                break
            case .cancelled:
                reject("cancel_compress_video", "Cancel in compress video", nil)
                break
            @unknown default:
                reject("failed_compress_video", "Failed in compress video", nil)
            }
        }

    }
    
    @objc(getFramesVideo:options:withResolver:withRejecter:)
    func getFramesVideo(
        source: String, options: NSDictionary, resolve: RCTPromiseResolveBlock,
        reject: RCTPromiseRejectBlock
    ) {
        createDirectory()
        
        let fileURL = getSourceURL(source: source)

        let videoAsset = AVAsset(url: fileURL)

        let videoDuration = videoAsset.duration

        let videoDurationTimes = CMTimeGetSeconds(videoDuration)

        let totalFrames: Int = (options.object(forKey: "totalFrames") as! Int?) ?? 10

        let generator = AVAssetImageGenerator(asset: videoAsset)
        
        let videoSize = getVideoSize(url: fileURL)
    
        var imagesUrls = [String]()
        
        let widthTo: Int = (options.object(forKey: "width") as! Int?) ?? 200
        let heigthTo: Int = (options.object(forKey: "height") as! Int?) ?? 300
        
        let originalWidth = (Int(videoSize!.width))
        let originalHeight = (Int(videoSize!.height))
        
        let ratioWidth = Float(widthTo) / Float(originalWidth)
        
        var newWidth = widthTo
        var newHeight = heigthTo
        
        newHeight = Int(Float(originalHeight) * ratioWidth)
        
        if options.object(forKey: "height") != nil {
            let ratioHeight = heigthTo / originalHeight
            
            newWidth = originalWidth * ratioHeight
        }
        
        if options.object(forKey: "height") != nil && options.object(forKey: "width") != nil {
            let ratioHeight = heigthTo / originalHeight
            
            newWidth = originalWidth * ratioHeight
            newHeight = heigthTo
        }

        for index in (0...(totalFrames - 1)) {
            let refTime = index == 0 ? 0 : videoDurationTimes / Double(totalFrames - 1)
            
            let time = refTime * Double(index)

            let cmTimer = CMTime(value: CMTimeValue(time), timescale: 1)

            var image: CGImage?

            do {
                image = try generator.copyCGImage(at: cmTimer, actualTime: nil)
            } catch {
                reject("Error", "Error", nil)
            }

            if image != nil {
                let img = UIImage(cgImage: image!)
                
                let cgSize = CGSize(width: newWidth, height: newHeight)
                
                let resizedImage = img.imageResized(to: cgSize)

                if let fileURL = getFileURL(fileExtension: "jpg") {
                    let imageData = resizedImage.jpegData(compressionQuality: 0.5)
                    
                    try? imageData?.write(to: fileURL)
                
                    imagesUrls.append(fileURL.absoluteString)
                }
            }
        }
        resolve(imagesUrls)
    }
    
    @objc(cropVideo:options:withResolver:withRejecter:)
    func cropVideo(
      source: String, options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) {
      let manager = FileManager.default

      let fileURL = getSourceURL(source: source)

      let videoAsset = AVAsset(url: fileURL)

      let start = Double((options.object(forKey: "startTime") as! Double))
      let end = Double((options.object(forKey: "endTime") as! Double))

      let outputURL = getFileURL(fileExtension: "mp4")

      try? manager.removeItem(at: outputURL!)

      guard
        let exportSession = AVAssetExportSession(
          asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)
      else { return }
      exportSession.outputURL = outputURL
      exportSession.outputFileType = .mp4

      let startTime = CMTime(seconds: start, preferredTimescale: 1000)
      let endTime = CMTime(seconds: end, preferredTimescale: 1000)
      let timeRange = CMTimeRange(start: startTime, end: endTime)

      exportSession.timeRange = timeRange
      exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
            resolve(outputURL?.absoluteString)
        case .failed:
          reject("failed_crop_video", "Failed in crop video", nil)
        case .cancelled:
          reject("cancel_crop_video", "Cancel crop video", nil)
        default:
          reject("failed_crop_video", "Failed in crop video", nil)
        }
      }
    }
}

