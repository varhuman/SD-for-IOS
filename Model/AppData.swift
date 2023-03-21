//
//  AppData.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//
import SwiftUI

class AppData: ObservableObject {
    static let appName = "SD For Ios"
    static let appVersion = "v0.0.1"
    
    static let appData = AppData()
    @Published var savedImages: [URL] = []
    @Published var resImages: [UIImage] = []
    init() {
        savedImages = Utils.loadSavedImages()
    }
}
