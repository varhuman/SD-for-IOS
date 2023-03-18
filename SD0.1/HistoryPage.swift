//
//  HistoryPage.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//

import SwiftUI

struct HistoryPage: View {
    @ObservedObject private var appData = AppData.appData
    @State private var selectedImage: UIImage?
    @State private var showImageDetail = false
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .center, spacing: 10) {
                    ForEach(appData.savedImages.indices, id: \.self) { index in
                        if let image = UIImage(contentsOfFile: appData.savedImages[index].path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        selectedImage = image
                                        showImageDetail = true
                                    }
                            }
                        }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("历史")
            .sheet(isPresented: $showImageDetail) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        HistoryPage(selectedTab: .constant(2))
    }
}
