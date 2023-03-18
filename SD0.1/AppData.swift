//
//  AppData.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//
import SwiftUI

class AppData: ObservableObject {
    static let appData = AppData()
    @Published var savedImages: [URL] = []
    @Published var resImages: [UIImage] = []
    init() {
        loadSavedImages()
    }

    func loadSavedImages() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let imageURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            savedImages = imageURLs.filter { $0.pathExtension == "png" }
        } catch {
            print("Error loading images: \(error)")
        }
    }

}
