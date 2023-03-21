//
//  Utils.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//

import Foundation
import Photos
import UIKit

class Utils: ObservableObject {
    static func base64ToUIImage(base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    static func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    static func saveImageToDocumentsDirectory(_ image: UIImage) -> URL? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(UUID().uuidString).png")
        
        do {
            let imageData = image.pngData()
            try imageData?.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    
    static func loadSavedImages() -> [URL] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let imageURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            return imageURLs.filter { $0.pathExtension == "png" }
        } catch {
            print("Error loading images: \(error)")
        }
        return []
    }
    
    static func saveImageToPhotoLibrary(image: UIImage) {
        let albumName = "Stable Diffusion_ios"
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest: PHAssetCollectionChangeRequest
            if let album = fetchAssetCollectionForAlbum(albumName: albumName), let changeRequest = PHAssetCollectionChangeRequest(for: album) {
                createAlbumRequest = changeRequest
            } else {
                createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }
            
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let placeholder = assetChangeRequest.placeholderForCreatedAsset
            createAlbumRequest.addAssets([placeholder!] as NSArray)
        }, completionHandler: { success, error in
            if success {
                print("Successfully saved image to \(albumName) album")
            } else if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            }
        })
    }
    
    //compressionQuality -> 0.0 - 1.0 worst - best
    static func compressBase64Image(image: UIImage, compressionQuality: CGFloat) -> String? {
        // 压缩图片
        guard let compressedImageData = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        
        // 将压缩后的Data编码为Base64字符串
        let compressedBase64 = compressedImageData.base64EncodedString()
        return compressedBase64
    }

    
    static func fetchAssetCollectionForAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collection.firstObject
    }
    
    static func SaveOutputLogForData(data: Data, fileName:String){
        guard let utf8String = String(data: data, encoding: .utf8) else {
            print("Failed to convert data to UTF-8 string.")
            return
        }
        SaveOutputLog(content: utf8String, fileName: fileName)
    }
    
    static func SaveOutputLog(content: String, fileName:String){
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get the documents directory.")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Successfully saved the string to file: \(fileURL.path)")
        } catch {
            print("Error writing string to file: \(error)")
        }
    }

}
