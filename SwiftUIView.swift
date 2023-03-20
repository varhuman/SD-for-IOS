//
//  SwiftUIView.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/18.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button(action: {
                configuration.isOn.toggle()
            }) {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .accessibility(label: Text("Checkmark"))
                    .accessibility(removeTraits: .isButton)
            }
            .buttonStyle(PlainButtonStyle()) // 添加这一行
        }
    }
}

