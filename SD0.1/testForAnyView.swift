//
//  testForAnyView.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/20.
//

import SwiftUI

struct testForAnyView: View {
    var body: some View {
        List(UIFont.familyNames, id: \.self) { fontName in
            VStack(alignment: .leading, spacing: 10) {
                Text(fontName)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                HStack{
                    Text("中文效果,..")
                        .font(Font.custom(fontName, size: 20))
                    Spacer()
                    Text("This is a Apple")
                        .font(Font.custom(fontName, size: 20))
                }
            }
        }
    }
}

struct testForAnyView_Previews: PreviewProvider {
    static var previews: some View {
        testForAnyView()
    }
}
