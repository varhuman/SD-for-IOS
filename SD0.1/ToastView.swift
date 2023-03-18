//
//  ToastView.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/18.
//

import SwiftUI

struct ToastView: View {
    @Binding var showToast: Bool
    let message: String = "成功接收，已将图片存至设备相册"
    @State private var opacity = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .opacity(opacity)
                    .scaleEffect(showToast ? 1 : 0.1)
                    .animation(.easeInOut(duration: 1.0), value: showToast)
                Spacer()
            }
            .padding(.bottom)
        }
        .onAppear {
            if showToast {
                withAnimation {
                    opacity = 1.0
                }
            }
        }
        .onChange(of: showToast) { newValue in
            if newValue {
                withAnimation {
                    opacity = 1.0
                }
            } else {
                withAnimation {
                    opacity = 0.0
                }
            }
        }
    }
}


struct ToastView_Previews: PreviewProvider {
    @State static private var showToast = true
    
    static var previews: some View {
        ToastView(showToast: $showToast)
    }
}
