//
//  Helpers.swift
//  react-native-video-manager
//
//  Created by Admin on 18/10/22.
//

import Foundation
import AVFoundation

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension Data {
    func getSizeInKb() -> Int {
        let sizeInBytes = self.count
        let sizeInKiloBytes = sizeInBytes / 1000
        return sizeInKiloBytes
    }
}

func getVideoSize(url: URL) -> CGSize? {
    guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
    let size = track.naturalSize.applying(track.preferredTransform)
    return CGSize(width: size.width, height: size.height)
}

func getSourceURL(source: String) -> URL {
    var sourceURL: URL
    if source.contains("assets-library") {
        sourceURL = NSURL(string: source)! as URL
    } else {
        let bundleUrl = Bundle.main.resourceURL!
        sourceURL = URL(string: source, relativeTo: bundleUrl)!
    }
    return sourceURL
}

func getFileURL(fileExtension: String) -> URL? {
    let fileName = UUID().uuidString
    
    let documentUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:false)
    let path = documentUrl!.absoluteString + "react-native-video-manager"
    
    let url = URL(string: path)!.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
    return url
}

func createDirectory(){
    let url = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
    )
    .first
    
    let dataPath = url?.appendingPathComponent("react-native-video-manager")
    
    if dataPath?.path != nil {
        if !FileManager.default.fileExists(atPath: dataPath!.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath!.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

func compressVideo(inputURL: URL,
                   outputURL: URL,
                   handler: @escaping (_ exportSession: AVAssetExportSession?) -> Void) {
    let urlAsset = AVAsset(url: inputURL)
    guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
        handler(nil)
        return
    }

    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously {
        handler(exportSession)
    }
}

