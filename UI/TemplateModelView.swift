//
//  TemplateModelView.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/20.
//

import SwiftUI

struct TemplateModelView: View {
    @Binding var showView: Bool
    @State private var showAlert = false
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(0..<10) { index in
                    HStack {
                        CustomButton(title: "Item \(index * 2)", showAlert: $showAlert) {
                            showView = false
                        }
                        CustomButton(title: "Item \(index * 2 + 1)", showAlert: $showAlert) {
                            showView = false
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 10000, trailing: 20))
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(color: .gray, radius: 10, x: 0, y: 0))
        .padding(EdgeInsets(top: 50, leading: 50, bottom: 150, trailing: 50))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Confirm"),
                  message: Text("Are you sure?"),
                  primaryButton: .default(Text("Yes"), action: {
                    showView = false
                    }),
                    secondaryButton: .cancel())
        }
    }
}

struct CustomButton: View {
    var title: String
    @Binding var showAlert: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            showAlert = true
        }) {
            ZStack {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fit)
                
                Text(title)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding(.top,80)
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 100)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            .shadow(radius: 5)
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        }
    }
}

struct TemplateModelView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateModelView(showView: .constant(true))
        //        CustomButton(title: "123", showAlert: .constant(true)){
//    }
        
    }
}
