//
//  CustomNavigationBar.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/15.
//
import SwiftUI

struct CustomNavigationBar: View {
    let showInfoButton: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false

    var body: some View {
        HStack {
            Spacer()

            Text(AppData.appName)
                .font(.title2)
                .bold()
                

            Spacer()
            if showInfoButton {
                Button(action: {
                    showAlert.toggle()
                }) {
                    Image(systemName: "exclamationmark.circle")
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("版本信息"), message: Text(AppData.appVersion), dismissButton: .default(Text("知道了")))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(showInfoButton: true)
    }
}
