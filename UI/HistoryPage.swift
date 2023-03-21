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
    @State private var zoomScale: CGFloat = 1.0
    
    private var showImageDetailBinding: Binding<Bool> {
        Binding(get: { showImageDetail },
                set: {
            if $0 {
                DispatchQueue.main.async {
                    showImageDetail = $0
                }
            } else {
                showImageDetail = $0
            }
        })
    }
    
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
            .sheet(isPresented: showImageDetailBinding) {
                if let selectedImage = selectedImage {
                    NavigationView {
//                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            GeometryReader { geometry in
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .edgesIgnoringSafeArea(.all)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .gesture(MagnificationGesture()
                                        .onChanged { scale in
                                            withAnimation(.linear) {
                                                self.zoomScale = scale
                                            }
                                        }
                                    )
                                    .scaleEffect(zoomScale)
                            }
//                        }
                        .navigationTitle("Image Detail")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showImageDetail = false
                                }) {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                        .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global)
                            .onEnded { value in
                                if value.translation.height > 0 {
                                    showImageDetail = false
                                }
                            }
                        )
                    }
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
