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
    
    static func fetchAssetCollectionForAlbum(albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collection.firstObject
    }

}