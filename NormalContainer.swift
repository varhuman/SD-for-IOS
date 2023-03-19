//
//  NormalContainer.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/19.
//

import SwiftUI

struct NormalContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
                .blur(radius: 5)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .padding(.bottom)
                content
                    .padding()
            }
            .padding()
        }
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
    }
}

struct NormalContainer_Previews: PreviewProvider {
    static var previews: some View {
        NormalContainer(title: "Test Title") {
            VStack {
                Text("Test Content")
            }
        }
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}

