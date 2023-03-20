//
//  SomeCustomNormalUI.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/19.
//

import SwiftUI

struct HStackTextField: View {
    var title: String
    @Binding var textFieldValue: Int
    var keyboardType: UIKeyboardType = .numberPad
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: $textFieldValue, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct HStackPicker: View {
    var title: String
    @Binding var textFieldValue: Int
    var Options: [Int]
    
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: $textFieldValue) {
                ForEach(Options, id: \.self) { option in
                    Text("\(option)")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct SectionImageHeader: View {
    let symbolName: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Text(title)
        }
    }
}


struct HStackToggle: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("",isOn: $isOn)
        }
    }
}

struct PickerSelectionView: View {
    @Binding var selectedIndex: Int
    let options: [String]
    
    var body: some View {
        List{
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button(action: {
                    selectedIndex = index
                    // Pop back to the main view
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    HStack{
                        Text(option)
                            .foregroundColor(.pickerPageItem)
                        Spacer()
                        if options[selectedIndex] == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Select Item", displayMode: .inline)
    }
}


struct HStackTextField_Previews: PreviewProvider {

    static var previews: some View {
//        HStackTextField(title: "test",textFieldValue: .constant(2))
//        SectionImageHeader(symbolName: "bolt.fill", title: "模型选择")
        PickerSelectionView(selectedIndex: .constant(2), options: ["2,", "2"])
    }
}
